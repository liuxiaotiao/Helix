"""
Drive the whole cluster from ONE control node (ssh by default), using cluster.json.
Run from this directory, ideally inside tmux/screen (profiling takes a while).

  python cluster_ctl.py sync                   # copy this repo (code, cluster.json, profiles, plans) to all nodes
  python cluster_ctl.py install [--install-conda] [--cuda-from-conda]
                                               # tools/install_node.sh on every node, in parallel
  python cluster_ctl.py check                  # reachability, env, GPU model/VRAM vs. 'type', comm libs
  python cluster_ctl.py profile                # profile one worker per GPU type, in parallel,
                                               #   results copied into the local profiles dir
  python cluster_ctl.py profile --types L4 --force
  python cluster_ctl.py bandwidth [--write]    # single-stream TCP Gb/s between nodes (-> cluster.json)
  python cluster_ctl.py collect [--bundle plan_inputs.tgz]   # profiles (+ cluster.json) for planning
  python cluster_ctl.py push-plan [--bundle plan.tgz]        # plan files -> every node
  python cluster_ctl.py net-test --layout ilp  # real host + fake (no-GPU) workers: network/routing test
  python cluster_ctl.py start-workers maxflow  # step3_start_worker.py on every worker (background)
  python cluster_ctl.py stop-workers

cluster.json "remote" section (all optional):
  "run":       command prefix that runs one shell command on a node; {ip} is substituted.
               default "ssh -o BatchMode=yes {ip}"  (password-less ssh needed)
  "pre":       shell snippet run before anything on a node, e.g. "module load cuda/12.4". default ""
  "env":       conda env name. `install` creates it (Python 3.10) unless "venv" is set. default "runtime"
  "venv":      path of a Python venv to create on top of the EXISTING conda env "env"; all packages
               go into the venv, nothing into the conda env. default: null (no venv)
  "setup":     activates the env. default "source ~/.helix_env.sh" (written by `install`)
  "repo":      path of this repository on the nodes. default: same path as here
  "shared_fs": true if the nodes see this very directory (results need no copying). default false
Per worker, "gpu": <index> selects the GPU (CUDA_VISIBLE_DEVICES) for profiling and serving.
"""
import argparse
import json
import os
import shlex
import statistics
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.realpath(__file__))
CWD0 = os.getcwd()
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, REPO)
import helix_cluster as hc  # noqa: E402

DEFAULT_RUN = "ssh -o BatchMode=yes -o ConnectTimeout=10 -o ServerAliveInterval=30 {ip}"
DEFAULT_SETUP = "source ~/.helix_env.sh"
SYNC_EXCLUDES = [".git", "./llm_sys/comm/build", "__pycache__", "*.egg-info", "*.pyc",
                 "./examples/real_sys_qwen3/logs", "./examples/real_sys_qwen3/result",
                 "./examples/real_sys_qwen3/sim_files", "tmp_maxflow_*",
                 # plan data + measured profiles: never overwrite a node's copy with ours here;
                 # they move with `collect` / `push-plan`
                 "./simulator/model_manager/qwen3_30b_a3b/profiles", "./examples/real_sys_qwen3/config",
                 "./examples/real_sys_qwen3/layouts", "./examples/real_sys_qwen3/deploy"]
# repo-relative locations (the same on every node)
PROFILE_REL = "simulator/model_manager/qwen3_30b_a3b/profiles"
EXAMPLE_REL = "examples/real_sys_qwen3"
PLAN_REL = [f"{EXAMPLE_REL}/cluster.json", f"{EXAMPLE_REL}/config", f"{EXAMPLE_REL}/layouts",
            f"{EXAMPLE_REL}/deploy", PROFILE_REL]
LOG_DIR = os.path.join(HERE, "logs")


class Remote:
    def __init__(self, c):
        r = c.get("remote", {})
        self.run_tpl = r.get("run") or DEFAULT_RUN
        self.setup = r.get("setup") or DEFAULT_SETUP
        self.pre = r.get("pre") or ""
        self.env = r.get("env") or "runtime"
        self.venv = r.get("venv") or ""
        self.repo = r.get("repo") or REPO
        self.shared_fs = bool(r.get("shared_fs", False))

    def argv(self, ip, cmd, setup=True):
        parts = [x for x in [self.pre, self.setup if setup else ""] if x] + [cmd]
        # always bash, whatever the login shell on the node is (tcsh/zsh would break `source`, &&)
        return shlex.split(self.run_tpl.format(ip=ip)) + ["bash -c " + shlex.quote(" && ".join(parts))]

    def run(self, ip, cmd, setup=True, timeout=120):
        return subprocess.run(self.argv(ip, cmd, setup), capture_output=True, text=True,
                              timeout=timeout, stdin=subprocess.DEVNULL)

    def popen(self, ip, cmd, log_file, setup=True):
        f = open(log_file, "w")
        return subprocess.Popen(self.argv(ip, cmd, setup), stdout=f, stderr=subprocess.STDOUT,
                                stdin=subprocess.DEVNULL, text=True)


def all_nodes(c, only=None):
    """host first, then workers; optionally restricted to the IPs in `only`."""
    ips = [c["host_ip"]] + [w["ip"] for w in c["workers"]]
    if only:
        unknown = set(only) - set(ips)
        assert not unknown, f"not in cluster.json: {sorted(unknown)}"
        ips = [ip for ip in ips if ip in only]
    return ips


def wait_all(procs, ok_marker=None):
    """procs: {ip: (Popen, log)} -> list of failed ips. Prints as they finish."""
    failed, start = [], time.time()
    while procs:
        time.sleep(3)
        for ip in list(procs):
            p, log = procs[ip]
            if p.poll() is None:
                continue
            del procs[ip]
            text = open(log, errors="replace").read()
            ok = p.returncode == 0 and (ok_marker is None or ok_marker in text)
            print(f"[{'done' if ok else 'FAIL'}] {ip} after {time.time() - start:.0f}s  "
                  f"(log: {os.path.relpath(log, HERE)})")
            if not ok:
                failed.append(ip)
                for line in text.strip().splitlines()[-6:]:
                    print(f"         | {line}")
    return failed


def _gpu_env(w):
    return f"CUDA_VISIBLE_DEVICES={int(w['gpu'])} " if "gpu" in w else ""


def _nominal_vram():
    prof = hc._load_module("profile_qwen3_moe", os.path.join(REPO, "tools", "profile_qwen3_moe.py"))
    return prof.NOMINAL_VRAM_GB


# ------------------------------------------------------------------------------------------- #
def cmd_sync(c, rm, only):
    if rm.shared_fs:
        print("shared_fs is true: every node already sees this repository, nothing to copy.")
        return
    excl = [f"--exclude={e}" for e in SYNC_EXCLUDES]
    tar = subprocess.run(["tar", "-C", REPO, "-czf", "-"] + excl + ["."],
                         stdout=subprocess.PIPE, check=True).stdout
    print(f"repo archive: {len(tar) / 1e6:.1f} MB -> {rm.repo} on each node")
    failed = []
    for ip in all_nodes(c, only):
        t0 = time.time()
        r = subprocess.run(rm.argv(ip, f"mkdir -p {shlex.quote(rm.repo)} && "
                                       f"tar -C {shlex.quote(rm.repo)} -xzf - && echo synced",
                                   setup=False),
                           input=tar, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=600)
        ok = r.returncode == 0 and b"synced" in r.stdout
        print(f"[{'done' if ok else 'FAIL'}] {ip} ({time.time() - t0:.1f}s)"
              + ("" if ok else f": {r.stderr.decode(errors='replace').strip()[-300:]}"))
        if not ok:
            failed.append(ip)
    if failed:
        raise SystemExit(f"sync failed on {failed}")


def cmd_install(c, rm, only, every, flags):
    ips = all_nodes(c, only)
    if rm.shared_fs and not only and not every:
        ips = [c["workers"][0]["ip"]]
        print(f"shared_fs: installing once, on {ips[0]} (the conda env and the comm build land in the "
              f"shared home / repo). If each node has its own conda, re-run with --all.")
    os.makedirs(LOG_DIR, exist_ok=True)
    procs = {}
    for ip in ips:
        log = os.path.join(LOG_DIR, f"install_{ip}.log")
        venv = f"--venv {shlex.quote(rm.venv)} " if rm.venv else ""
        cmd = (f"cd {shlex.quote(rm.repo)} && bash tools/install_node.sh --env {shlex.quote(rm.env)} "
               f"{venv}{flags}")
        procs[ip] = (rm.popen(ip, cmd, log, setup=False), log)
        print(f"[run ] {ip}")
    failed = wait_all(procs, ok_marker="HELIX_INSTALL_OK")
    if failed:
        raise SystemExit(f"install failed on {failed}; fix and re-run (finished steps are skipped)")
    print("all nodes installed; next: python cluster_ctl.py check")


# ------------------------------------------------------------------------------------------- #
def gpu_info(rm, w):
    """(gpu name, total memory GB) of the worker's GPU, or raises RuntimeError."""
    idx = int(w.get("gpu", 0))
    r = rm.run(w["ip"], f"nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits "
                        f"-i {idx}", setup=False, timeout=60)
    if r.returncode != 0:
        raise RuntimeError((r.stderr or r.stdout).strip().splitlines()[-1:] or "nvidia-smi failed")
    name, mem_mib = [x.strip() for x in r.stdout.strip().splitlines()[0].split(",")]
    return name, float(mem_mib) * 1024 ** 2 / 1e9


def check_worker(rm, w, nominal):
    """Returns a list of (level, message)."""
    out = []
    try:
        name, gb = gpu_info(rm, w)
        exp = nominal.get(w["type"])
        if exp is None:
            out.append(("WARN", f"GPU {name} {gb:.0f} GB; type '{w['type']}' has no nominal VRAM "
                                f"(profile uses the measured size; better set machine_types.{w['type']}.vram_gb)"))
        elif 0.85 <= gb / exp <= 1.15:
            out.append(("OK", f"GPU {name} {gb:.0f} GB matches '{w['type']}' ({exp} GB)"))
        else:
            out.append(("FAIL", f"GPU {name} {gb:.0f} GB does not match type '{w['type']}' "
                                f"({exp} GB); fix the type (e.g. A100-80G)"))
    except Exception as e:  # noqa: BLE001
        out.append(("FAIL", f"GPU query failed: {e}"))
    r = rm.run(w["ip"], f"cd {shlex.quote(rm.repo)} && python -c "
                        f"\"import llm_worker, vllm, transformers; print(vllm.__version__, "
                        f"transformers.__version__)\"")
    if r.returncode == 0:
        v = r.stdout.strip().splitlines()[-1]
        ok = v == "0.4.0.post1 4.40.2"
        out.append(("OK" if ok else "FAIL", f"repo + env ok, vllm/transformers = {v}"
                    + ("" if ok else " (need 0.4.0.post1 / 4.40.2)")))
    else:
        tail = (r.stderr or r.stdout).strip().splitlines()[-1:] or ["?"]
        out.append(("FAIL", f"env/repo/llm_worker problem on node: {tail[0]}"))
    return out


def cmd_check(c, rm):
    nominal = _nominal_vram()
    bad = 0
    r = rm.run(c["host_ip"], f"cd {shlex.quote(rm.repo)} && python -c \"import llm_host, gurobipy\"")
    lvl = "OK" if r.returncode == 0 else "FAIL"
    bad += lvl == "FAIL"
    print(f"[{lvl}] host {c['host_ip']}: " + ("llm_host + gurobipy importable" if lvl == "OK" else
                                              ((r.stderr or r.stdout).strip().splitlines()[-1:] or ['?'])[0]))
    for w in c["workers"]:
        for lvl, msg in check_worker(rm, w, nominal):
            bad += lvl == "FAIL"
            print(f"[{lvl}] {w['ip']:15s} {w['type']:9s} {msg}")
    print("all good" if not bad else f"{bad} problem(s)")
    return bad


# ------------------------------------------------------------------------------------------- #
def fetch_profile(rm, ip, t):
    """tar stream of <repo>/PROFILE_REL/<t> on node ip, or None if that node has no such profile."""
    remote = f"{rm.repo}/{PROFILE_REL}"
    r = subprocess.run(rm.argv(ip, f"test -f {shlex.quote(remote)}/{shlex.quote(t)}/meta.json && "
                                   f"tar -C {shlex.quote(remote)} -cf - {shlex.quote(t)}", setup=False),
                       stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.DEVNULL)
    return r.stdout if r.returncode == 0 and r.stdout else None


def cmd_profile(c, rm, types, force, extra, fetch):
    from simulator.model_manager.qwen3_30b_a3b.qwen3_30b_a3b import get_profile_dir
    local_dir = get_profile_dir()
    os.makedirs(local_dir, exist_ok=True)
    os.makedirs(LOG_DIR, exist_ok=True)
    nominal = _nominal_vram()

    # one worker per type: the first one whose GPU matches the type
    chosen = {}
    for w in c["workers"]:
        t = w["type"]
        if (types and t not in types) or t in chosen:
            continue
        try:
            name, gb = gpu_info(rm, w)
        except Exception as e:  # noqa: BLE001
            print(f"[skip] {w['ip']} ({t}): {e}")
            continue
        exp = nominal.get(t)
        if exp is not None and not 0.85 <= gb / exp <= 1.15 and not force:
            print(f"[skip] {w['ip']}: {name} {gb:.0f} GB does not look like '{t}' ({exp} GB)")
            continue
        chosen[t] = w
        print(f"[pick] {t:9s} -> {w['ip']} ({name}, {gb:.0f} GB)")
    missing = sorted(set(types or {w["type"] for w in c["workers"]}) - set(chosen))
    if missing:
        raise SystemExit(f"no usable worker for type(s) {missing}")

    procs = {}
    for t, w in chosen.items():
        out = f"{rm.repo}/{PROFILE_REL}"     # kept on the profiled node, inside its repo copy
        flags = " --force" if force else ""
        vram = c.get("machine_types", {}).get(t, {}).get("vram_gb")
        if vram is None and t not in nominal:
            vram = round(gpu_info(rm, w)[1])      # unknown type: use the card's real size
            print(f"[note] {t} not in the built-in VRAM table: using {vram} GB (measured); put "
                  f'"machine_types": {{"{t}": {{"vram_gb": {vram}}}}} in cluster.json')
        if vram is not None:
            flags += f" --vram-gb {vram}"
        cmd = (f"cd {shlex.quote(rm.repo)} && {_gpu_env(w)}python tools/profile_qwen3_moe.py "
               f"--machine {shlex.quote(t)} --out {shlex.quote(out)}{flags} {extra}")
        log = os.path.join(LOG_DIR, f"profile_{t}_{w['ip']}.log")
        procs[t] = (w, rm.popen(w["ip"], cmd, log), log)
        print(f"[run ] {t} on {w['ip']}  (log: {os.path.relpath(log, HERE)})")

    failed = []
    start = time.time()
    while procs:
        time.sleep(5)
        for t in list(procs):
            w, p, log = procs[t]
            if p.poll() is None:
                continue
            del procs[t]
            if p.returncode != 0:
                failed.append(t)
                print(f"[FAIL] {t} on {w['ip']} exit {p.returncode}, see {log}")
                continue
            data = fetch_profile(rm, w["ip"], t)
            if data is None:
                failed.append(t)
                print(f"[FAIL] {t}: no profile written on {w['ip']}, see {log}")
                continue
            where = f"{w['ip']}:{rm.repo}/{PROFILE_REL}/{t}"
            if fetch and not rm.shared_fs:
                subprocess.run(["tar", "-C", local_dir, "-xf", "-"], input=data, check=True)
                where += f"  (copy here: {os.path.join(local_dir, t)})"
            print(f"[done] {t} after {time.time() - start:.0f}s -> {where}")
    if failed:
        raise SystemExit(f"profiling failed for {failed}")
    print("profiles done. Plan here (python helix_cluster.py init ...), or elsewhere: "
          "python cluster_ctl.py collect --bundle plan_inputs.tgz")


def cmd_collect(c, rm, bundle):
    """Profiles of every GPU type (from whichever node has one) [+ cluster.json] -> here or a bundle."""
    import io
    import tarfile
    from simulator.model_manager.qwen3_30b_a3b.qwen3_30b_a3b import get_profile_dir
    types = sorted({w["type"] for w in c["workers"]})
    got, missing = {}, []
    for t in types:
        for w in [w for w in c["workers"] if w["type"] == t]:
            data = fetch_profile(rm, w["ip"], t)
            if data:
                got[t] = (w["ip"], data)
                break
        else:
            missing.append(t)
    for t, (ip, _) in got.items():
        print(f"  {t:9s} <- {ip}")
    if missing:
        print(f"  no profile on any node for {missing}: run `cluster_ctl.py profile --types {' '.join(missing)}`")
    if bundle:
        with tarfile.open(bundle, "w:gz") as out:
            for t, (_, data) in got.items():
                with tarfile.open(fileobj=io.BytesIO(data)) as src:
                    for m in src.getmembers():
                        f = src.extractfile(m) if m.isfile() else None
                        m.name = f"{PROFILE_REL}/{m.name}"
                        out.addfile(m, f)
            out.add(os.path.join(HERE, "cluster.json"), arcname=f"{EXAMPLE_REL}/cluster.json")
        print(f"wrote {bundle}: {len(got)} profile(s) + cluster.json. On the planning machine:\n"
              f"  tar -xzf {os.path.basename(bundle)} -C <repo>   then helix_cluster.py init / layout / "
              f"gen-config / export-plan")
    else:
        local_dir = get_profile_dir()
        os.makedirs(local_dir, exist_ok=True)
        for t, (_, data) in got.items():
            subprocess.run(["tar", "-C", local_dir, "-xf", "-"], input=data, check=True)
        print(f"profiles copied into {local_dir}")
    if missing:
        raise SystemExit(1)


def cmd_push_plan(c, rm, bundle, only):
    """Plan data (cluster.json, config/, layouts/, deploy/, profiles) -> every node's repo copy."""
    if bundle:
        subprocess.run(["tar", "-xzf", bundle, "-C", REPO], check=True)
        print(f"unpacked {bundle} into {REPO}")
        c = hc.load_cluster()      # the bundle may carry an updated cluster.json
    if rm.shared_fs:
        print("shared_fs is true: every node already sees the plan files.")
        return
    paths = [p for p in PLAN_REL if os.path.exists(os.path.join(REPO, p))]
    tar = subprocess.run(["tar", "-C", REPO, "-czf", "-", "--exclude=__pycache__"] + paths,
                         stdout=subprocess.PIPE, check=True).stdout
    print(f"plan archive: {len(tar) / 1e3:.0f} KB ({', '.join(paths)})")
    failed = []
    for ip in all_nodes(c, only):
        r = subprocess.run(rm.argv(ip, f"mkdir -p {shlex.quote(rm.repo)} && "
                                       f"tar -C {shlex.quote(rm.repo)} -xzf - && echo pushed", setup=False),
                           input=tar, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=300)
        ok = r.returncode == 0 and b"pushed" in r.stdout
        print(f"[{'done' if ok else 'FAIL'}] {ip}" + ("" if ok else f": {r.stderr.decode(errors='replace')[-300:]}"))
        if not ok:
            failed.append(ip)
    if failed:
        raise SystemExit(f"push-plan failed on {failed}")


# ------------------------------------------------------------------------------------------- #
def measure_pair(rm, src_ip, dst_ip, port, seconds):
    bench = f"cd {shlex.quote(rm.repo)} && python tools/net_bench.py"
    server = subprocess.Popen(rm.argv(dst_ip, f"{bench} server --bind {dst_ip} --port {port} "
                                              f"--timeout {seconds + 60}"),
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.DEVNULL)
    try:
        r = rm.run(src_ip, f"{bench} client --connect {dst_ip} --port {port} --seconds {seconds}",
                   timeout=seconds + 120)
    finally:
        try:
            server.wait(timeout=30)
        except subprocess.TimeoutExpired:
            server.kill()
    for line in r.stdout.splitlines():
        if line.startswith("GBPS "):
            return float(line.split()[1])
    raise RuntimeError((r.stderr or r.stdout).strip()[-300:])


def cmd_bandwidth(c, rm, pairs, port, seconds, write):
    ws = [w["ip"] for w in c["workers"]]
    todo = [(c["host_ip"], ws[0])] + [(ws[i], ws[(i + 1) % len(ws)]) for i in range(min(pairs, len(ws) - 1))]
    results = []
    for src, dst in todo:
        try:
            g = measure_pair(rm, src, dst, port, seconds)
            results.append(g)
            print(f"{src:15s} -> {dst:15s} {g:8.2f} Gb/s")
        except Exception as e:  # noqa: BLE001
            print(f"{src:15s} -> {dst:15s} FAILED: {e}")
    if not results:
        raise SystemExit("no measurement succeeded")
    med = statistics.median(results)
    print(f"median {med:.2f} Gb/s, min {min(results):.2f} Gb/s (single TCP stream, like ZeroMQ)")
    if write:
        path = os.path.join(HERE, "cluster.json")
        cj = json.load(open(path))
        cj.setdefault("network", {})["bandwidth_gbps"] = round(med, 2)
        json.dump(cj, open(path, "w"), indent=2)
        print(f"wrote network.bandwidth_gbps = {round(med, 2)} to cluster.json "
              f"(re-run helix_cluster.py init + layouts)")


# ------------------------------------------------------------------------------------------- #
def cmd_start_workers(c, rm, method):
    d = os.path.join(rm.repo, "examples", "real_sys_qwen3")
    for w in c["workers"]:
        log = f"logs/worker_{w['ip']}.log"
        # only the worker goes to the background ({ ... & }), so ssh returns right away
        cmd = (f"cd {shlex.quote(d)} && mkdir -p logs && {{ {_gpu_env(w)}HELIX_LOCAL_IP={w['ip']} "
               f"setsid nohup python step3_start_worker.py {method} > {log} 2>&1 < /dev/null & }} && "
               f"sleep 1 && echo started")
        r = rm.run(w["ip"], cmd, timeout=60)
        status = "started" if r.returncode == 0 and "started" in r.stdout else \
            f"FAILED: {(r.stderr or r.stdout).strip()[-200:]}"
        print(f"{w['ip']:15s} {w['type']:9s} {status}  (log on node: {d}/{log})")


def cmd_net_test(c, rm, layout, duration):
    """Real host + tools/fake_worker.py on every worker: no GPU work, tests network + routing."""
    d = os.path.join(rm.repo, "examples", "real_sys_qwen3")
    addr = hc.broadcast_addr(c)
    print(f"starting fake workers (no GPU) for layout '{layout}' ...")
    for w in c["workers"]:
        cmd = (f"cd {shlex.quote(d)} && mkdir -p logs && {{ HELIX_COMM_CPU_TENSORS=1 setsid nohup python "
               f"../../tools/fake_worker.py --ip {w['ip']} --host {addr} "
               f"> logs/fake_worker_{w['ip']}.log 2>&1 < /dev/null & }} && sleep 1 && echo started")
        r = rm.run(w["ip"], cmd, timeout=60)
        if "started" not in r.stdout:
            print(f"  {w['ip']}: FAILED to start: {(r.stderr or r.stdout).strip()[-200:]}")
    res = f"./result/nettest_{layout}/"
    print(f"running the host on {c['host_ip']} for {duration}s (maxflow, offline) ...")
    try:
        h = rm.run(c["host_ip"], f"cd {shlex.quote(d)} && HELIX_COMM_CPU_TENSORS=1 python step2_start_host.py "
                                 f"offline maxflow --layout {layout} --duration {duration} --result-dir {res}",
                   timeout=duration + 600)
        host_out = h.stdout + h.stderr
    except subprocess.TimeoutExpired as e:
        host_out = (e.stdout or b"").decode(errors="replace") if isinstance(e.stdout, bytes) else (e.stdout or "")
        host_out += "\n[net-test] host timed out (some worker probably never connected)"
    finally:
        for w in c["workers"]:
            rm.run(w["ip"], "pkill -u \"$(id -u)\" -f '[f]ake_worker.py'; true", setup=False)

    ok = True
    for w in c["workers"]:
        r = rm.run(w["ip"], f"cat {shlex.quote(d)}/logs/fake_worker_{w['ip']}.log", setup=False)
        line = [x for x in r.stdout.splitlines() if "cluster initialization finished" in x]
        ok &= bool(line)
        print(f"  [{'OK' if line else 'FAIL'}] {w['ip']:15s} "
              + (line[0].split("] ", 1)[-1] if line else "never joined (firewall / wrong IP / not started?)"))
    finished = host_out.count("finished (total_len")
    routes = rm.run(c["host_ip"], f"cat {shlex.quote(d)}/{res}query_route.txt", setup=False).stdout
    paths = {tuple(eval(x)[3]) for x in routes.splitlines() if x.strip()}
    # a round trip = the host got a request's output back from the last stage
    back = rm.run(c["host_ip"], f"grep -c \"'in'\" {shlex.quote(d)}/{res}events.txt", setup=False).stdout.strip()
    back = int(back) if back.isdigit() else 0
    ok &= back > 0 and "[host] done" in host_out
    print(f"  host: {len(routes.splitlines())} requests launched over {len(paths)} distinct paths, "
          f"{back} round trips completed, {finished} requests fully finished")
    if not ok:
        print("  host output (tail):\n    " + "\n    ".join(host_out.strip().splitlines()[-15:]))
    print("network test PASSED" if ok else "network test FAILED")
    return ok


def cmd_stop_workers(c, rm):
    for w in c["workers"]:
        # "[s]tep3": matches the workers but not the shell that runs this very command line
        r = rm.run(w["ip"], "pkill -u \"$(id -u)\" -f '[s]tep3_start_worker.py'; echo done", setup=False)
        print(f"{w['ip']:15s} {'stopped' if 'done' in r.stdout else r.stderr.strip()[-200:]}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    y = sub.add_parser("sync")
    y.add_argument("--nodes", nargs="*", help="only these IPs (default: host + all workers)")
    i = sub.add_parser("install")
    i.add_argument("--nodes", nargs="*", help="only these IPs (default: host + all workers)")
    i.add_argument("--all", action="store_true", help="with shared_fs: still install on every node")
    i.add_argument("--install-conda", action="store_true", help="install Miniforge where conda is missing")
    i.add_argument("--cuda-from-conda", action="store_true", help="install nvcc into the env if missing")
    i.add_argument("--rebuild", action="store_true", help="rebuild llm_sys/comm")
    sub.add_parser("check")
    p = sub.add_parser("profile")
    p.add_argument("--types", nargs="*", help="only these GPU types (default: all in cluster.json)")
    p.add_argument("--force", action="store_true", help="skip the GPU-memory sanity check")
    p.add_argument("--extra", default="", help="extra args for tools/profile_qwen3_moe.py")
    p.add_argument("--no-fetch", action="store_true",
                   help="leave the results only on the profiled nodes (collect them later)")
    co = sub.add_parser("collect", help="gather every GPU type's profile from the nodes")
    co.add_argument("--bundle", default=None,
                    help="write profiles + cluster.json to this .tgz (for planning on another machine)")
    pp = sub.add_parser("push-plan", help="send cluster.json, config/, layouts/, deploy/, profiles to nodes")
    pp.add_argument("--bundle", default=None, help="first unpack this plan .tgz (helix_cluster.py export-plan)")
    pp.add_argument("--nodes", nargs="*")
    b = sub.add_parser("bandwidth")
    b.add_argument("--pairs", type=int, default=3)
    b.add_argument("--port", type=int, default=5099)
    b.add_argument("--seconds", type=float, default=5)
    b.add_argument("--write", action="store_true", help="store the median in cluster.json")
    s = sub.add_parser("start-workers")
    s.add_argument("method", choices=["maxflow", "swarm", "random"])
    sub.add_parser("stop-workers")
    n = sub.add_parser("net-test", help="host + fake workers: test network and routing without GPUs")
    n.add_argument("--layout", default="ilp")
    n.add_argument("--duration", type=int, default=30)
    a = ap.parse_args()

    c = hc.load_cluster()
    rm = Remote(c)
    if a.cmd == "sync":
        cmd_sync(c, rm, a.nodes)
    elif a.cmd == "install":
        flags = " ".join(f for f, on in [("--install-conda", a.install_conda),
                                          ("--cuda-from-conda", a.cuda_from_conda),
                                          ("--rebuild", a.rebuild)] if on)
        cmd_install(c, rm, a.nodes, a.all, flags)
    elif a.cmd == "check":
        sys.exit(1 if cmd_check(c, rm) else 0)
    elif a.cmd == "profile":
        cmd_profile(c, rm, a.types, a.force, a.extra, fetch=not a.no_fetch)
    elif a.cmd == "collect":
        cmd_collect(c, rm, a.bundle and os.path.abspath(os.path.join(CWD0, a.bundle)))
    elif a.cmd == "push-plan":
        cmd_push_plan(c, rm, a.bundle and os.path.abspath(os.path.join(CWD0, a.bundle)), a.nodes)
    elif a.cmd == "bandwidth":
        cmd_bandwidth(c, rm, a.pairs, a.port, a.seconds, a.write)
    elif a.cmd == "start-workers":
        cmd_start_workers(c, rm, a.method)
    elif a.cmd == "net-test":
        sys.exit(0 if cmd_net_test(c, rm, a.layout, a.duration) else 1)
    else:
        cmd_stop_workers(c, rm)


if __name__ == "__main__":
    main()
