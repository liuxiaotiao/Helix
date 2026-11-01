"""
Drive the whole cluster from ONE control node (ssh by default), using cluster.json.
Run from this directory, ideally inside tmux/screen (profiling takes a while).

  python cluster_ctl.py sync                   # copy this repo (code, cluster.json, profiles, plans) to all nodes
  python cluster_ctl.py install [--install-conda] [--cuda-from-conda]
                                               # tools/install_node.sh on every node, in parallel
  python cluster_ctl.py check                  # reachability, env, GPU model/VRAM vs. 'type', comm libs
  python cluster_ctl.py profile                # profile one worker per GPU type, in parallel;
                                               #   results stay on those nodes (--fetch: copy here too)
  python cluster_ctl.py profile --types L4 --force
  python cluster_ctl.py bandwidth [--write]    # single-stream TCP Gb/s between nodes (-> cluster.json)
  python cluster_ctl.py collect [--bundle plan_inputs.tgz]   # profiles, for planning (here or elsewhere)
  python cluster_ctl.py push-plan [--bundle plan.tgz]        # plan files -> every node
  python cluster_ctl.py net-test --layout ilp  # real host + fake (no-GPU) workers: network/routing test
  python cluster_ctl.py disk [--quick]         # what uses disk space on each node, what could be cleaned
  python cluster_ctl.py gpus                   # GPU memory in use + the processes holding it
  python cluster_ctl.py start-workers maxflow  # step3_start_worker.py on every worker (background)
  python cluster_ctl.py start-workers maxflow --real   # ... with the real weights (greedy decoding)
  python cluster_ctl.py stop-workers
  python cluster_ctl.py weights --layout ilp [--clean] [--dry-run]
                                               # HF safetensors shards for each worker's layers
                                               #   -> cluster.json "weights": {"dir": ..., "repo": ...}
                                               #   (shows a progress table every --interval s)
  python cluster_ctl.py weights-status --watch 10   # the same progress table, from any terminal

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
# where `profile` leaves its results on the profiled node: OUTSIDE the repo, so a git checkout on
# that node (e.g. the control node, when it is also a worker) never gets untracked files
NODE_PROFILE_DIR = "$HOME/.helix/profiles"
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
    ips = list(dict.fromkeys([c["host_ip"]] + [w["ip"] for w in c["workers"]]))   # host may share a worker's IP
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
GPU_BUSY_GB = 1.0      # memory already used on a GPU above which we call it busy


def gpu_info(rm, w, with_used=False):
    """(gpu name, total memory GB[, used GB]) of the worker's GPU, or raises RuntimeError."""
    idx = int(w.get("gpu", 0))
    r = rm.run(w["ip"], f"nvidia-smi --query-gpu=name,memory.total,memory.used --format=csv,noheader,nounits "
                        f"-i {idx}", setup=False, timeout=60)
    if r.returncode != 0:
        raise RuntimeError((r.stderr or r.stdout).strip().splitlines()[-1:] or "nvidia-smi failed")
    name, mem_mib, used_mib = [x.strip() for x in r.stdout.strip().splitlines()[0].split(",")]
    total, used = float(mem_mib) * 1024 ** 2 / 1e9, float(used_mib) * 1024 ** 2 / 1e9
    return (name, total, used) if with_used else (name, total)


def gpu_processes(rm, ip):
    """'pid name MiB' lines of the processes using GPU memory on that node."""
    r = rm.run(ip, "nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader,nounits",
               setup=False, timeout=60)
    return [" ".join(x.strip() for x in line.split(",")) + " MiB" for line in r.stdout.strip().splitlines() if line.strip()]


def check_worker(rm, w, nominal):
    """Returns a list of (level, message)."""
    out = []
    try:
        name, gb, used = gpu_info(rm, w, with_used=True)
        if used > GPU_BUSY_GB:
            out.append(("WARN", f"GPU busy: {used:.1f} of {gb:.0f} GB already used by other processes "
                                f"({'; '.join(gpu_processes(rm, w['ip']))[:120]}). Helix needs the GPU free."))
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
    # free disk space (a fresh install needs ~7 GB for the env + ~4 GB of downloads in $TMPDIR)
    venv_dir = rm.venv or "~"
    for ip in all_nodes(c):
        r = rm.run(ip, f"d={venv_dir}; while [ ! -d \"$d\" ]; do d=$(dirname \"$d\"); done; "
                       f"df -Pk \"$d\" ${{TMPDIR:-/tmp}} | awk 'NR>1 {{printf \"%d \", $4/1048576}}'",
                   setup=False, timeout=60)
        try:
            env_gb, tmp_gb = (int(x) for x in r.stdout.split()[:2])
        except ValueError:
            print(f"[WARN] {ip:15s} disk: could not read free space")
            continue
        low = env_gb < 11 or tmp_gb < 4
        print(f"[{'WARN' if low else 'OK'}] {ip:15s} disk: {env_gb} GB free for the env "
              f"({rm.venv or 'home'}), {tmp_gb} GB free in $TMPDIR"
              + (" -- a (re)install of torch/vLLM needs ~11 GB / ~4 GB" if low else ""))
    print("all good" if not bad else f"{bad} problem(s)")
    return bad


# ------------------------------------------------------------------------------------------- #
def fetch_profile(rm, ip, t):
    """tar stream of the profile <t> on node ip (~/.helix/profiles/<t>, or, from older runs,
    <repo>/PROFILE_REL/<t>), or None if that node has none."""
    for remote in (f'"{NODE_PROFILE_DIR}"', shlex.quote(f"{rm.repo}/{PROFILE_REL}")):
        r = subprocess.run(rm.argv(ip, f"test -f {remote}/{shlex.quote(t)}/meta.json && "
                                       f"tar -C {remote} -cf - {shlex.quote(t)}", setup=False),
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.DEVNULL)
        if r.returncode == 0 and r.stdout:
            return r.stdout
    return None


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
            name, gb, used = gpu_info(rm, w, with_used=True)
        except Exception as e:  # noqa: BLE001
            print(f"[skip] {w['ip']} ({t}): {e}")
            continue
        exp = nominal.get(t)
        if exp is not None and not 0.85 <= gb / exp <= 1.15 and not force:
            print(f"[skip] {w['ip']}: {name} {gb:.0f} GB does not look like '{t}' ({exp} GB)")
            continue
        if used > GPU_BUSY_GB:
            # measuring on a busy GPU gives wrong timings and a too small KV capacity
            print(f"[skip] {w['ip']} ({t}): GPU busy, {used:.1f} GB used by other processes")
            continue
        chosen[t] = w
        print(f"[pick] {t:9s} -> {w['ip']} ({name}, {gb:.0f} GB)")
    missing = sorted(set(types or {w["type"] for w in c["workers"]}) - set(chosen))
    if missing:
        raise SystemExit(f"no usable (free) worker for type(s) {missing}; see `python cluster_ctl.py gpus`")

    procs = {}
    for t, w in chosen.items():
        out = f'"{NODE_PROFILE_DIR}"'          # kept on the profiled node, outside its repo copy
        flags = " --force" if force else ""
        vram = c.get("machine_types", {}).get(t, {}).get("vram_gb")
        if vram is None and t not in nominal:
            vram = round(gpu_info(rm, w)[1])      # unknown type: use the card's real size
            print(f"[note] {t} not in the built-in VRAM table: using {vram} GB (measured); put "
                  f'"machine_types": {{"{t}": {{"vram_gb": {vram}}}}} in cluster.json')
        if vram is not None:
            flags += f" --vram-gb {vram}"
        cmd = (f"cd {shlex.quote(rm.repo)} && {_gpu_env(w)}python tools/profile_qwen3_moe.py "
               f"--machine {shlex.quote(t)} --out {out}{flags} {extra}")
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
                for line in open(log, errors="replace").read().strip().splitlines()[-8:]:
                    print(f"         | {line}")
                continue
            data = fetch_profile(rm, w["ip"], t)
            if data is None:
                failed.append(t)
                print(f"[FAIL] {t}: no profile written on {w['ip']}, see {log}")
                continue
            where = f"{w['ip']}:~/.helix/profiles/{t}"
            if fetch and not rm.shared_fs:
                subprocess.run(["tar", "-C", local_dir, "-xf", "-"], input=data, check=True)
                where += f"  (copy here: {os.path.join(local_dir, t)})"
            print(f"[done] {t} after {time.time() - start:.0f}s -> {where}")
    if failed:
        raise SystemExit(f"profiling failed for {failed}")
    print("profiles done. Plan here (python helix_cluster.py init ...), or elsewhere: "
          "python cluster_ctl.py collect --bundle plan_inputs.tgz")


def cmd_collect(c, rm, bundle, with_cluster_json=False):
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
            if with_cluster_json:
                out.add(os.path.join(HERE, "cluster.json"), arcname=f"{EXAMPLE_REL}/cluster.json")
        extra = " + cluster.json" if with_cluster_json else ""
        print(f"wrote {bundle}: {len(got)} profile(s){extra}. On the planning machine:\n"
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
def cmd_start_workers(c, rm, method, force=False, real=False):
    busy = []
    for w in c["workers"]:
        try:
            if gpu_info(rm, w, with_used=True)[2] > GPU_BUSY_GB:
                busy.append(w["ip"])
        except Exception:  # noqa: BLE001
            pass
    if busy and not force:
        raise SystemExit(f"GPUs busy (other processes hold memory) on {busy}; the workers would fail or be "
                         f"slow. Free them (see `python cluster_ctl.py gpus`) or pass --force.")
    d = os.path.join(rm.repo, "examples", "real_sys_qwen3")
    for w in c["workers"]:
        log = f"logs/worker_{w['ip']}.log"
        # only the worker goes to the background ({ ... & }), so ssh returns right away
        cmd = (f"cd {shlex.quote(d)} && mkdir -p logs && {{ {_gpu_env(w)}HELIX_LOCAL_IP={w['ip']} "
               f"setsid nohup python step3_start_worker.py {method}{' --real' if real else ''} > {log} 2>&1 "
               f"< /dev/null & }} && "
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


def cmd_disk(c, rm, only, quick):
    """tools/disk_report.sh on every node (read-only); full reports in logs/disk_<ip>.txt."""
    import re
    os.makedirs(LOG_DIR, exist_ok=True)
    procs = {}
    for ip in all_nodes(c, only):
        log = os.path.join(LOG_DIR, f"disk_{ip}.txt")
        cmd = f"cd {shlex.quote(rm.repo)} && bash tools/disk_report.sh{' --quick' if quick else ''}"
        procs[ip] = (rm.popen(ip, cmd, log, setup=False), log)
    print(f"scanning {len(procs)} node(s){' (quick)' if quick else ''} ...")
    rows = []
    for ip, (p, log) in procs.items():
        try:
            p.wait(timeout=1800)
        except subprocess.TimeoutExpired:
            p.kill()
        text = open(log, errors="replace").read()
        m = re.search(r"SUMMARY home_free_gb=(\d+) tmp_free_gb=(\d+) safe_gb=(\d+) review_gb=(\d+)", text)
        rows.append((ip, m.groups() if m else None, log, text))
    print(f"\n{'node':15s} {'home 剩余':>9s} {'/tmp 剩余':>9s} {'可放心清理':>10s} {'需确认':>7s}  清理缓存后 home 约")
    for ip, g, log, text in rows:
        if g is None:
            tail = (text.strip().splitlines() or ["(no output)"])[-1]
            print(f"{ip:15s} FAILED: {tail[:90]}   (full: {os.path.relpath(log, HERE)})")
            continue
        home, tmp, safe, review = (int(x) for x in g)
        after = home + safe
        flag = "够装 Helix" if after >= 11 else "仍不够 11 GB"
        print(f"{ip:15s} {home:>7d}GB {tmp:>7d}GB {safe:>8d}GB {review:>5d}GB  {after:>4d}GB  {flag}")
    print(f"\n每台的完整报告（含具体路径和清理命令）: {os.path.relpath(LOG_DIR, HERE)}/disk_<ip>.txt")


def cmd_gpus(c, rm):
    print(f"{'node':15s} {'type':9s} {'GPU':22s} {'used / total':>14s}  processes")
    free = 0
    for w in c["workers"]:
        try:
            name, total, used = gpu_info(rm, w, with_used=True)
        except Exception as e:  # noqa: BLE001
            print(f"{w['ip']:15s} {w['type']:9s} ERROR: {e}")
            continue
        procs = gpu_processes(rm, w["ip"]) if used > GPU_BUSY_GB else []
        free += used <= GPU_BUSY_GB
        print(f"{w['ip']:15s} {w['type']:9s} {name[:22]:22s} {used:5.1f} / {total:4.0f} GB  "
              f"{'free' if not procs else '; '.join(procs)}")
    print(f"\n{free} of {len(c['workers'])} GPUs free. Helix (test_gpu_stage, profile, workers) needs them free.")


def layer_ranges(layout):
    """ip -> [(start, end)] from deploy/<layout>/real_sys_config.txt (machine 0 = host, skipped)."""
    cfg = os.path.join(hc.deploy_dir(layout), "real_sys_config.txt")
    if not os.path.exists(cfg):
        raise SystemExit(f"{cfg} not found: run `helix_cluster.py gen-config --layout {layout}` "
                         f"(and push-plan) first")
    out = {}
    for m in hc.parse_real_sys_config(cfg):
        if m["machine_id"] != 0:
            out.setdefault(m["ip_address"], []).append((m["start_layer"], m["end_layer"]))
    return out


WEIGHTS_PROGRESS = ".helix_weights_progress.json"   # written by tools/fetch_weights.py


def _weights_dir(c, wdir):
    wdir = wdir or c.get("weights", {}).get("dir")
    if not wdir:
        raise SystemExit('give --dir, or set "weights": {"dir": "..."} in cluster.json')
    return wdir


def poll_weights(rm, ips, wdir):
    """ip -> (progress dict or None, bytes in the directory or None), all nodes in parallel."""
    q = shlex.quote(wdir)
    cmd = f"cat {q}/{WEIGHTS_PROGRESS} 2>/dev/null || echo '{{}}'; echo; du -sb {q} 2>/dev/null | cut -f1"
    procs = {ip: subprocess.Popen(rm.argv(ip, cmd, setup=False), stdout=subprocess.PIPE,
                                  stderr=subprocess.DEVNULL, stdin=subprocess.DEVNULL, text=True)
             for ip in ips}
    out = {}
    for ip, p in procs.items():
        try:
            text, _ = p.communicate(timeout=30)
            first, _, rest = text.strip().partition("\n")
            prog = json.loads(first) or None
            size = int(rest.strip()) if rest.strip().isdigit() else None
            out[ip] = (prog, size)
        except Exception:  # noqa: BLE001
            p.kill()
            out[ip] = (None, None)
    return out


def _dur(s):
    s = int(max(0, s))
    return f"{s // 3600}h{s // 60 % 60:02d}m" if s >= 3600 else f"{s // 60}m{s % 60:02d}s"


def print_weights_table(ips, polled, prev, interval, status=None):
    """One refresh of the progress table. prev: ip -> (time, bytes) of the last poll (updated here).
    status: ip -> 'running'/'done'/'FAIL'/'queued' as seen by this control process (optional)."""
    now = time.time()
    if sys.stdout.isatty():
        print("\033[H\033[J", end="")          # clear the screen: a refreshing table
    print(f"[{time.strftime('%H:%M:%S')}] weight download progress"
          + (f" (refresh every {interval:g}s; " + ("Ctrl-C only stops watching)" if status is None else
             "Ctrl-C ABORTS the downloads, rerun without --clean to resume)") if interval else ""))
    print(f"  {'node':15s} {'state':11s} {'done / need':>17s} {'%':>5s} {'speed':>10s} {'ETA':>8s} "
          f"{'shards':>6s}  current")
    tot_done = tot_need = tot_speed = 0.0
    for ip in ips:
        prog, size = polled.get(ip, (None, None))
        st = (status or {}).get(ip)
        if not prog:
            state = st or ("unreachable" if size is None else "not started")
            print(f"  {ip:15s} {state:11s}")
            continue
        need = prog.get("need", 0)
        done = need if prog.get("state") == "done" else max(0, min(need, (size or 0) - prog.get("base", 0)))
        speed = 0.0
        if ip in prev and size is not None and now > prev[ip][0]:
            speed = max(0.0, (size - prev[ip][1]) / (now - prev[ip][0]))
        elif prog.get("state") == "downloading" and now > prog.get("started", now):
            speed = done / (now - prog["started"])              # first poll: average so far
        if size is not None:
            prev[ip] = (now, size)
        state = prog.get("state", "?")
        if st == "FAIL" or state == "failed":
            state = "FAILED"
        pct = 100.0 * done / need if need else (100.0 if state == "done" else 0.0)
        eta = _dur((need - done) / speed) if state == "downloading" and speed > 1e5 else ""
        cur = (prog.get("current") or "").replace(".safetensors", "")
        print(f"  {ip:15s} {state:11s} {done / 1e9:7.1f}/{need / 1e9:5.1f} GB {pct:5.0f} "
              f"{speed / 1e6 if state == 'downloading' else 0:7.0f} MB/s {eta:>8s} "
              f"{prog.get('shards_done', 0)}/{prog.get('shards_total', 0):<4d}  {cur}"
              + (f"  {prog.get('error', '')[:60]}" if state == "FAILED" else ""))
        tot_done += done
        tot_need += need
        tot_speed += speed if state == "downloading" else 0
    pct = 100.0 * tot_done / tot_need if tot_need else 0
    eta = _dur((tot_need - tot_done) / tot_speed) if tot_speed > 1e5 else ""
    print(f"  {'TOTAL':15s} {'':11s} {tot_done / 1e9:7.1f}/{tot_need / 1e9:5.1f} GB {pct:5.0f} "
          f"{tot_speed / 1e6:7.0f} MB/s {eta:>8s}", flush=True)


def cmd_weights_status(c, rm, wdir, only, watch):
    wdir = _weights_dir(c, wdir)
    ips = list(dict.fromkeys(w["ip"] for w in c["workers"] if not only or w["ip"] in only))
    prev = {}
    try:
        while True:
            print_weights_table(ips, poll_weights(rm, ips, wdir), prev, watch or 0)
            if not watch:
                break
            time.sleep(watch)
    except KeyboardInterrupt:
        print()


def cmd_weights(c, rm, layout, wdir, repo, clean, dry_run, every, only, max_parallel, interval=15,
                no_xet=False, curl=False):
    """tools/fetch_weights.py on every worker: the HF shards for that worker's layers."""
    wcfg = c.get("weights", {})
    wdir = _weights_dir(c, wdir)
    repo = repo or wcfg.get("repo") or "Qwen/Qwen3-30B-A3B"
    ranges = {} if every else layer_ranges(layout)
    ips = [w["ip"] for w in c["workers"]]
    ips = list(dict.fromkeys(ip for ip in ips if not only or ip in only))
    os.makedirs(LOG_DIR, exist_ok=True)
    env = " ".join(f"{k}={shlex.quote(os.environ[k])}" for k in ("HF_ENDPOINT", "HF_TOKEN") if os.environ.get(k))
    print(f"{repo} -> {wdir} on {len(ips)} node(s), "
          f"{'every shard' if every else f'layers of layout {layout!r}'}"
          f"{', CLEANING the directory first' if clean else ''}{' (dry run)' if dry_run else ''}")
    jobs = []
    for ip in ips:
        if not every and ip not in ranges:
            print(f"  {ip}: holds no layers in layout {layout!r}, skipped")
            continue
        args = ["--dir", shlex.quote(wdir), "--repo", shlex.quote(repo)]
        args += ["--all"] if every else [x for s, e in ranges[ip] for x in ("--layers", str(s), str(e))]
        args += (["--clean"] if clean else []) + (["--dry-run"] if dry_run else [])
        args += ["--no-xet"] if no_xet else []
        args += ["--curl"] if curl else []
        cmd = (f"cd {shlex.quote(rm.repo)} && {env + ' ' if env else ''}"
               f"python tools/fetch_weights.py {' '.join(args)}")
        jobs.append((ip, cmd, os.path.join(LOG_DIR, f"weights_{ip}.log")))
        print(f"  {ip}: {'all' if every else ' '.join(f'[{s},{e})' for s, e in ranges[ip])}")
    failed = []
    if dry_run:
        for k in range(0, len(jobs), max_parallel):
            procs = {ip: (rm.popen(ip, cmd, log), log) for ip, cmd, log in jobs[k:k + max_parallel]}
            failed += wait_all(procs, ok_marker="HELIX_WEIGHTS_OK")
    else:
        # at most max_parallel nodes at a time; a progress table refreshes every `interval` s
        queue, running, status, prev = list(jobs), {}, {ip: "queued" for ip, _, _ in jobs}, {}
        ips = [ip for ip, _, _ in jobs]
        last = 0.0
        while queue or running:
            while queue and len(running) < max_parallel:
                ip, cmd, log = queue.pop(0)
                running[ip] = (rm.popen(ip, cmd, log), log)
                status[ip] = "running"
            for ip in list(running):
                p, log = running[ip]
                if p.poll() is None:
                    continue
                del running[ip]
                ok = p.returncode == 0 and "HELIX_WEIGHTS_OK" in open(log, errors="replace").read()
                status[ip] = "done" if ok else "FAIL"
                if not ok:
                    failed.append(ip)
            if time.time() - last >= interval or not (queue or running):
                print_weights_table(ips, poll_weights(rm, ips, wdir), prev, interval, status)
                last = time.time()
            if queue or running:
                time.sleep(3)
        for ip in failed:
            print(f"[FAIL] {ip}  (log: logs/weights_{ip}.log)")
            for line in open(os.path.join(LOG_DIR, f"weights_{ip}.log"), errors="replace").read().strip().splitlines()[-6:]:
                print(f"         | {line}")
    for ip, _, log in jobs:
        lines = [x for x in open(log, errors="replace").read().splitlines() if "shard(s)" in x]
        if lines:
            print(f"  {ip:15s} {lines[-1].split('] ', 1)[-1]}")
    print("weights: all nodes OK" if not failed else f"weights: FAILED on {failed}")
    return not failed


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
    i.add_argument("--clean", action="store_true",
                   help="reinstall from scratch: delete the venv (or the Helix-created conda env), the "
                        "comm build, ~/.helix_env.sh and the pip cache on each node first")
    sub.add_parser("check")
    p = sub.add_parser("profile")
    p.add_argument("--types", nargs="*", help="only these GPU types (default: all in cluster.json)")
    p.add_argument("--force", action="store_true", help="skip the GPU-memory sanity check")
    p.add_argument("--extra", default="", help="extra args for tools/profile_qwen3_moe.py")
    p.add_argument("--fetch", action="store_true",
                   help="also copy the results into this repo (default: they stay on the profiled "
                        "nodes only, so a git checkout here stays clean; use `collect` later)")
    co = sub.add_parser("collect", help="gather every GPU type's profile from the nodes")
    co.add_argument("--bundle", default=None,
                    help="write the profiles to this .tgz (for planning on another machine)")
    co.add_argument("--with-cluster-json", action="store_true",
                    help="also put this node's cluster.json into the bundle (default: no, the planning "
                         "machine's copy is the one that counts)")
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
    s.add_argument("--force", action="store_true", help="start even if some GPUs are busy")
    s.add_argument("--real", action="store_true",
                   help="real Qwen3 weights (cluster.json weights.dir) + greedy; host: step2 ... --real")
    sub.add_parser("gpus", help="GPU memory in use and the processes holding it, on every node")
    sub.add_parser("stop-workers")
    dk = sub.add_parser("disk", help="what uses disk space on each node and what could be cleaned (read-only)")
    dk.add_argument("--nodes", nargs="*")
    dk.add_argument("--quick", action="store_true", help="skip the slow scans (largest dirs / big files)")
    n = sub.add_parser("net-test", help="host + fake workers: test network and routing without GPUs")
    n.add_argument("--layout", default="ilp")
    n.add_argument("--duration", type=int, default=30)
    wt = sub.add_parser("weights", help="download the HF safetensors shards each worker needs for its layers")
    wt.add_argument("--layout", default="ilp", help="which placement decides each node's layers")
    wt.add_argument("--dir", default=None, help='target directory on the nodes (default: cluster.json "weights.dir")')
    wt.add_argument("--repo", default=None, help='HF repo (default: "weights.repo" or Qwen/Qwen3-30B-A3B)')
    wt.add_argument("--clean", action="store_true", help="DELETE everything inside the directory first")
    wt.add_argument("--dry-run", action="store_true", help="show shards / sizes / free disk, change nothing")
    wt.add_argument("--all", action="store_true", help="every shard on every node (whole model, ~61 GB)")
    wt.add_argument("--nodes", nargs="*")
    wt.add_argument("--max-parallel", type=int, default=15, help="nodes downloading at the same time")
    wt.add_argument("--interval", type=float, default=15, help="seconds between progress refreshes")
    wt.add_argument("--no-xet", action="store_true",
                    help="plain HTTPS downloads instead of HF Xet storage (when Xet transfers fail)")
    wt.add_argument("--curl", action="store_true",
                    help="download shards with curl on the nodes (resumable; bypasses huggingface_hub)")
    ws = sub.add_parser("weights-status", help="download progress of `weights` on every node (any terminal)")
    ws.add_argument("--dir", default=None)
    ws.add_argument("--nodes", nargs="*")
    ws.add_argument("--watch", type=float, default=0, help="refresh every N seconds (0: print once)")
    a = ap.parse_args()

    c = hc.load_cluster()
    rm = Remote(c)
    if a.cmd == "sync":
        cmd_sync(c, rm, a.nodes)
    elif a.cmd == "install":
        flags = " ".join(f for f, on in [("--install-conda", a.install_conda),
                                          ("--cuda-from-conda", a.cuda_from_conda),
                                          ("--rebuild", a.rebuild),
                                          ("--clean", a.clean)] if on)
        cmd_install(c, rm, a.nodes, a.all, flags)
    elif a.cmd == "check":
        sys.exit(1 if cmd_check(c, rm) else 0)
    elif a.cmd == "profile":
        cmd_profile(c, rm, a.types, a.force, a.extra, fetch=a.fetch)
    elif a.cmd == "collect":
        cmd_collect(c, rm, a.bundle and os.path.abspath(os.path.join(CWD0, a.bundle)), a.with_cluster_json)
    elif a.cmd == "push-plan":
        cmd_push_plan(c, rm, a.bundle and os.path.abspath(os.path.join(CWD0, a.bundle)), a.nodes)
    elif a.cmd == "bandwidth":
        cmd_bandwidth(c, rm, a.pairs, a.port, a.seconds, a.write)
    elif a.cmd == "start-workers":
        cmd_start_workers(c, rm, a.method, a.force, a.real)
    elif a.cmd == "gpus":
        cmd_gpus(c, rm)
    elif a.cmd == "disk":
        cmd_disk(c, rm, a.nodes, a.quick)
    elif a.cmd == "net-test":
        sys.exit(0 if cmd_net_test(c, rm, a.layout, a.duration) else 1)
    elif a.cmd == "weights":
        sys.exit(0 if cmd_weights(c, rm, a.layout, a.dir, a.repo, a.clean, a.dry_run, a.all, a.nodes,
                                  a.max_parallel, a.interval, a.no_xet, a.curl) else 1)
    elif a.cmd == "weights-status":
        cmd_weights_status(c, rm, a.dir, a.nodes, a.watch)
    else:
        cmd_stop_workers(c, rm)


if __name__ == "__main__":
    main()
