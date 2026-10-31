"""
Plan a Helix deployment of Qwen3-30B-A3B on YOUR cluster, described in cluster.json.
Run from this directory (examples/real_sys_qwen3), on any machine with the repo + gurobipy
(no GPU / vLLM / ZeroMQ needed for these commands).

  python helix_cluster.py from-hosts ../../hosts.txt --host-ip <ip>   # optional: hosts.txt -> cluster.json
  python helix_cluster.py init                 # cluster.json -> config/cluster.ini + machine_profile.ini
  python helix_cluster.py layout petals        # heuristic placements (fast)
  python helix_cluster.py layout swarm         # (needs >= 8 workers)
  python helix_cluster.py layout ilp           # Helix MILP (Gurobi), starts from the best heuristic
  python helix_cluster.py simulate offline --layout ilp     # optional: simulated throughput
  python helix_cluster.py gen-config --layout ilp           # -> deploy/ilp/real_sys_config.txt + launch commands
  python helix_cluster.py export-plan --layout ilp          # -> plan.tgz (planned elsewhere? push it with
                                                            #    cluster_ctl.py push-plan --bundle plan.tgz)

Then: step2_start_host.py on the host, step3_start_worker.py on every worker.
Profiles for every GPU type in cluster.json must exist first (tools/profile_qwen3_moe.py).
"""
import argparse
import importlib.util
import ipaddress
import json
import os
import socket
import sys
from collections import Counter

HERE = os.path.dirname(os.path.realpath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
CLUSTER_JSON = os.path.join(HERE, "cluster.json")
CLUSTER_NAME = "cluster"                       # -> ./config/cluster.ini, ./layouts/cluster/<method>/
CLUSTER_INI = f"./config/{CLUSTER_NAME}.ini"
MACHINE_PROFILE_INI = "./config/machine_profile.ini"
MAX_COMPUTE_HOPS = 31                          # llm_sys/comm/src/const.h MAX_HOP (32) - 1


# ------------------------------------------------------------------------------------------- #
#                         cluster.json helpers (no heavy imports here)                         #
# ------------------------------------------------------------------------------------------- #
def load_cluster(path=CLUSTER_JSON) -> dict:
    if not os.path.exists(path):
        raise SystemExit(f"{path} not found: copy cluster.example.json to cluster.json and edit it.")
    with open(path) as f:
        c = json.load(f)
    for key in ["host_ip", "workers"]:
        assert key in c, f"cluster.json: missing '{key}'"
    ips = [w["ip"] for w in c["workers"]]
    for ip in [c["host_ip"]] + ips:
        ipaddress.IPv4Address(ip)   # raises on a malformed address
    dup = [ip for ip, n in Counter(ips).items() if n > 1]
    assert not dup, (f"cluster.json: duplicate worker IPs {dup}. Helix workers identify themselves "
                     f"by IP, so each worker needs its own IP (one worker = one machine = one GPU).")
    # host_ip may equal one worker's IP: the host (coordinator, no GPU) then runs next to that worker
    for w in c["workers"]:
        assert w.get("type"), f"cluster.json: worker {w['ip']} has no 'type'"
    return c


def machine_num_dict(c: dict) -> dict:
    return dict(Counter(w["type"] for w in c["workers"]))


def type2ips(c: dict) -> dict:
    d = {}
    for w in c["workers"]:
        d.setdefault(w["type"], []).append(w["ip"])
    return d


def broadcast_addr(c: dict) -> str:
    return f"tcp://{c['host_ip']}:{int(c.get('config_port', 5000))}"


def local_ips_among(candidates) -> list:
    """The candidate IPs that belong to this machine (a socket can bind to them)."""
    mine = []
    for ip in candidates:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
                s.bind((ip, 0))
            mine.append(ip)
        except OSError:
            pass
    return mine


def deploy_dir(layout: str) -> str:
    return f"./deploy/{layout}"


def layout_dir(layout: str) -> str:
    return f"./layouts/{CLUSTER_NAME}/{layout}"


# ------------------------------------------------------------------------------------------- #
#                                         commands                                            #
# ------------------------------------------------------------------------------------------- #
def _load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def _run_qwen3():
    """examples/simulation_qwen3/run_qwen3.py, reused with cluster name 'cluster' (paths relative
    to the current directory, i.e. ./config, ./layouts, ./sim_files here)."""
    return _load_module("run_qwen3", os.path.join(REPO, "examples", "simulation_qwen3", "run_qwen3.py"))


def _vram_gb(c, mtype):
    from simulator.model_manager.qwen3_30b_a3b import model_card as card
    from simulator.model_manager.qwen3_30b_a3b.qwen3_30b_a3b import get_profile_dir
    from simulator.model_manager.qwen3_30b_a3b.profiled_machine import load_meta
    prof = _load_module("profile_qwen3_moe", os.path.join(REPO, "tools", "profile_qwen3_moe.py"))
    meta_dir = os.path.join(get_profile_dir(), mtype)
    if not os.path.isfile(os.path.join(meta_dir, "meta.json")):
        raise SystemExit(f"No Qwen3-30B-A3B profile for '{mtype}' in {get_profile_dir()}.\n"
                         f"Run on a {mtype} worker:  python tools/profile_qwen3_moe.py --machine {mtype}")
    meta = load_meta(meta_dir)
    max_layers = int(meta["max_num_layers"])
    need = 2 * max_layers * card.LAYER_PARAM_BYTES / 1e9      # Helix: params <= half of VRAM
    given = c.get("machine_types", {}).get(mtype, {}).get("vram_gb")
    vram = given if given is not None else prof.NOMINAL_VRAM_GB.get(mtype)
    if vram is None:   # type not in the built-in table: the card's size recorded by the profiler
        vram = max(round(float(meta.get("gpu_total_mem_gb", 0)), 1), round(need + 0.05, 1))
    assert vram + 1e-9 >= need, (f"{mtype}: vram_gb={vram} but its profile allows {max_layers} layers "
                                 f"({need:.1f} GB needed). Fix machine_types.{mtype}.vram_gb.")
    return vram, max_layers


def parse_hosts_txt(path):
    """Lines like `N01  192.168.1.2:9101   # A30 24GB` -> [(name, ip, type)]; '#' lines skipped."""
    import re
    nodes = []
    for line in open(path, encoding="utf-8"):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        m = re.match(r"(\S+)\s+([0-9.]+)(?::\d+)?\s*(?:#\s*(\S+))?", line)
        assert m and m.group(3), f"{path}: cannot parse '{line}' (expected: NAME IP[:PORT] # TYPE ...)"
        ipaddress.IPv4Address(m.group(2))
        nodes.append((m.group(1), m.group(2), m.group(3)))
    return nodes


def cmd_from_hosts(path, out, host_ip, host_node, env, venv, bandwidth, host_only=False):
    nodes = parse_hosts_txt(path)
    if host_node:
        match = [n for n in nodes if host_node in (n[0], n[1])]        # node name or its IP
        assert match, (f"--host-node {host_node} not in {path} (use a node name such as "
                       f"{nodes[0][0]} or one of its IPs such as {nodes[0][1]})")
        host_node = match[0][0]
        host_ip = match[0][1]
        if host_only:
            nodes = [n for n in nodes if n[0] != host_node]
            print(f"host = {host_node} ({host_ip}); its GPU is not used as a worker")
        else:
            print(f"host = {host_node} ({host_ip}), which also stays a worker")
    assert host_ip, "give --host-ip <coordinator IP> or --host-node <a node from hosts.txt>"
    # the shell on THIS machine expands ~/x before we see it (/Users/me/x on a Mac): the venv path
    # is meant for the cluster nodes, so turn a path under this machine's home back into ~/x
    home = os.path.expanduser("~")
    if venv and (venv == home or venv.startswith(home + os.sep)):
        fixed = "~" + venv[len(home):]
        print(f"note: --venv {venv} is under this machine's home; writing {fixed} (expanded on each node)")
        venv = fixed
    c = {"host_ip": host_ip, "config_port": 5000,
         "network": {"bandwidth_gbps": bandwidth, "latency_ms": 1},
         "workers": [{"name": n, "ip": ip, "type": t} for n, ip, t in nodes],
         "remote": {"run": "ssh -o BatchMode=yes -o ConnectTimeout=10 -o ServerAliveInterval=30 {ip}",
                    "pre": "", "env": env, "venv": venv, "setup": None, "repo": None,
                    "shared_fs": False}}
    if os.path.exists(out):
        old = json.load(open(out))
        for key in ("machine_types", "remote"):          # keep hand edits
            if key in old:
                c[key] = old[key] if key == "machine_types" else {**c[key], **old[key]}
        print(f"updating {out} (kept its machine_types / remote settings)")
    json.dump(c, open(out, "w"), indent=2, ensure_ascii=False)
    open(out, "a").write("\n")
    load_cluster(out)   # validate
    mix = machine_num_dict(c)
    print(f"wrote {out}: host {host_ip}, {len(nodes)} workers {mix}")


def cmd_export_plan(c, layout, out):
    """cluster.json + config/ + layouts/<layout> + deploy/<layout> + used profiles -> one .tgz,
    with repo-relative paths (unpack with `cluster_ctl.py push-plan --bundle`)."""
    import tarfile
    from simulator.model_manager.qwen3_30b_a3b.qwen3_30b_a3b import get_profile_dir
    cfg = os.path.join(deploy_dir(layout), "real_sys_config.txt")
    assert os.path.exists(cfg), f"{cfg} not found: run `helix_cluster.py gen-config --layout {layout}` first"
    ex = "examples/real_sys_qwen3"
    prof_rel = "simulator/model_manager/qwen3_30b_a3b/profiles"
    with tarfile.open(out, "w:gz") as tar:
        tar.add("cluster.json", arcname=f"{ex}/cluster.json")
        tar.add("config", arcname=f"{ex}/config")
        tar.add(layout_dir(layout), arcname=f"{ex}/{os.path.normpath(layout_dir(layout))}")
        tar.add(deploy_dir(layout), arcname=f"{ex}/{os.path.normpath(deploy_dir(layout))}")
        for t in sorted(machine_num_dict(c)):       # the host's maxflow scheduler reads these
            tar.add(os.path.join(get_profile_dir(), t), arcname=f"{prof_rel}/{t}")
    print(f"wrote {out}. On the cluster's control node:  python cluster_ctl.py push-plan --bundle "
          f"{os.path.basename(out)}")


def cmd_init(c):
    from simulator.event_simulator.utils import gbps, MilliSec
    from simulator.initial_layout.fake_cluster_generator import FakeClusterGenerator
    from simulator.model_manager.qwen3_30b_a3b import model_card as card
    os.makedirs("./config", exist_ok=True)
    bw = float(c.get("network", {}).get("bandwidth_gbps", 10))
    lat = float(c.get("network", {}).get("latency_ms", 1))
    mix = machine_num_dict(c)

    # machine profiles (NIC speed = measured bandwidth, VRAM consistent with the GPU profiles)
    total_layers = 0
    lines = ["# generated by helix_cluster.py init from cluster.json (disk_speed is not used)"]
    for name, nic_in, nic_out in [("SourceNode", "-1", f"{bw} * gbps"), ("SinkNode", f"{bw} * gbps", "-1")]:
        lines += [f"[{name}]", f"inbound_nic_speed = {nic_in}", f"outbound_nic_speed = {nic_out}",
                  "disk_speed = -1", "vram_size = -1", ""]
    for mtype in sorted(mix):
        vram, max_layers = _vram_gb(c, mtype)
        total_layers += max_layers * mix[mtype]
        lines += [f"[{mtype}]", f"inbound_nic_speed = {bw} * gbps", f"outbound_nic_speed = {bw} * gbps",
                  "disk_speed = 1 * gbps", f"vram_size = {vram} * GB", ""]
        print(f"  {mtype:10s} x{mix[mtype]:<3d} VRAM {vram:g} GB, at most {max_layers} layers each")
    with open(MACHINE_PROFILE_INI, "w") as f:
        f.write("\n".join(lines))
    if total_layers < card.TOTAL_LAYERS:
        raise SystemExit(f"The cluster can hold at most {total_layers} layers in total, but "
                         f"Qwen3-30B-A3B has {card.TOTAL_LAYERS}. Add GPUs.")

    # full-mesh topology with uniform bandwidth (Helix's placement expects a complete graph)
    n = len(c["workers"])
    g = FakeClusterGenerator()
    g.set_node_statistics(num_compute_nodes=n, avg_degree=n - 1, source_degree=n, sink_degree=n,
                          node_type_percentage=mix)
    g.set_link_statistics(avg_bandwidth=bw * gbps, var_bandwidth=0, avg_latency=lat * MilliSec,
                          var_latency=0, fill_with_slow_link=True,
                          slow_link_avg_bandwidth=bw * gbps, slow_link_var_bandwidth=0,
                          slow_link_avg_latency=lat * MilliSec, slow_link_var_latency=0)
    g.generator_fake_cluster(file_name=CLUSTER_INI, seed=0)
    got = _run_qwen3().machine_num_dict(CLUSTER_NAME)
    assert got == mix, f"generated cluster has {got}, expected {mix}"
    print(f"wrote {CLUSTER_INI} ({n} workers, full mesh, {bw:g} Gb/s, {lat:g} ms) and {MACHINE_PROFILE_INI}")


def cmd_layout(c, method, max_run_time):
    assert os.path.exists(CLUSTER_INI), "run `helix_cluster.py init` first"
    if method == "swarm" and len(c["workers"]) < 8:
        raise SystemExit("swarm uses 8 pipeline stages and needs >= 8 workers; use petals instead.")
    _run_qwen3().layout(method, CLUSTER_NAME, max_run_time)


def cmd_simulate(mode, layout, duration, warm_up, rate):
    _run_qwen3().simulate(mode, CLUSTER_NAME, layout, duration, warm_up, rate)


def cmd_gen_config(c, layout):
    from llm_sys.gen_sys_config import gen_sys_config
    from simulator.event_simulator.cluster_simulator import ModelName
    lay = layout_dir(layout)
    sol = os.path.join(lay, f"{layout}_sol.ini")
    assert os.path.exists(sol), f"{sol} not found: run `helix_cluster.py layout {layout}` first"
    longest = _run_qwen3().check_max_hops(CLUSTER_NAME, layout)
    assert longest <= MAX_COMPUTE_HOPS, "pipeline too long for MAX_HOP, see the warning above"

    out = deploy_dir(layout)
    os.makedirs(out, exist_ok=True)
    gen_sys_config(host_ip=c["host_ip"], type2ips=type2ips(c),      # (a fresh copy: it is consumed)
                   machine_num_dict=machine_num_dict(c), model_name=ModelName.Qwen3_30B_A3B,
                   complete_cluster_file_name=CLUSTER_INI,
                   machine_profile_file_name=MACHINE_PROFILE_INI,
                   solution_file_name=sol,
                   simulator_cluster_file_name=os.path.join(lay, "simulator_cluster.ini"),
                   output_dir=out, output_file_name="real_sys_config.txt")
    cfg_file = os.path.join(out, "real_sys_config.txt")
    machines = parse_real_sys_config(cfg_file)
    summarize(c, machines, cfg_file)


def parse_real_sys_config(path):
    machines, cur = [], {}
    for line in open(path):
        line = line.strip()
        if not line:
            if cur:
                machines.append(cur)
                cur = {}
            continue
        k, _, v = line.partition(":")
        v = v.strip()
        cur[k] = [int(x) for x in v.split()] if k in ("in_nodes", "out_nodes") else (
            v if k == "ip_address" else int(v))
    if cur:
        machines.append(cur)
    return machines


def summarize(c, machines, cfg_file):
    ip2type = {w["ip"]: w["type"] for w in c["workers"]}
    covered = set()
    print(f"\nwrote {cfg_file}")
    print(f"{'id':>3}  {'ip':15s} {'type':9s} layers      in -> out")
    idle = []
    for m in machines:
        if m["machine_id"] == 0:
            print(f"{0:>3}  {m['ip_address']:15s} {'host':9s} {'-':11s} {m['in_nodes']} -> {m['out_nodes']}")
            continue
        rng = f"[{m['start_layer']}, {m['end_layer']})"
        covered.update(range(m["start_layer"], m["end_layer"]))
        print(f"{m['machine_id']:>3}  {m['ip_address']:15s} {ip2type[m['ip_address']]:9s} {rng:11s} "
              f"{m['in_nodes']} -> {m['out_nodes']}")
        if not m["in_nodes"] and not m["out_nodes"]:
            idle.append(m["ip_address"])
    assert covered == set(range(48)), "layout does not cover all 48 layers!"
    # host next to a worker (same IP): both bind <ip>:6000+<target> for their downstream nodes,
    # so they must not send to a common target
    host = next(m for m in machines if m["machine_id"] == 0)
    for m in machines:
        if m["machine_id"] != 0 and m["ip_address"] == host["ip_address"]:
            clash = sorted(set(host["out_nodes"]) & set(m["out_nodes"]))
            if clash:
                raise SystemExit(f"host and worker {m['machine_id']} share {host['ip_address']} and both send "
                                 f"to machine(s) {clash}: port clash on 6000+id. Put the host on another "
                                 f"node (helix_cluster.py from-hosts --host-node ...) and re-run gen-config.")
            print(f"\nhost runs on the same machine as worker {m['machine_id']} ({host['ip_address']}): "
                  f"no port clash in this placement")
    if idle:
        print(f"\nNOTE: {idle} hold layers but have no links in this placement (no traffic will "
              f"reach them); starting their workers is optional.")
    print("\nLaunch (same repo copy + conda env on every machine, from examples/real_sys_qwen3):")
    print(f"  host   {c['host_ip']}:  python step2_start_host.py online maxflow --layout <layout>")
    print("  worker (each IP above):  python step3_start_worker.py maxflow")
    print(f"Open TCP port {c.get('config_port', 5000)} on the host and ports 6000-{6000 + len(machines)} "
          f"on all machines.")


def main():
    cwd0 = os.getcwd()          # user paths (hosts.txt) are relative to where the command was run
    os.chdir(HERE)
    sys.path.insert(0, REPO)
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--cluster-json", default=CLUSTER_JSON)
    sub = ap.add_subparsers(dest="cmd", required=True)
    f = sub.add_parser("from-hosts", help="write cluster.json from a hosts.txt (NAME IP[:PORT] # TYPE)")
    f.add_argument("hosts_txt")
    f.add_argument("--host-ip", default=None, help="coordinator IP (not one of the workers)")
    f.add_argument("--host-node", default=None,
                   help="or: run the host on this node from hosts.txt, by name (N09) or IP (it stays a worker too)")
    f.add_argument("--host-only", action="store_true",
                   help="with --host-node: do not use that node's GPU as a worker")
    f.add_argument("--env", default="runtime", help="conda env name or path")
    f.add_argument("--venv", default=None, help="venv on top of --env (e.g. ~/helix-venv)")
    f.add_argument("--bandwidth-gbps", type=float, default=10)
    sub.add_parser("init")
    p = sub.add_parser("layout")
    p.add_argument("method", choices=["petals", "swarm", "ilp"])
    p.add_argument("--max-run-time", type=float, default=1800, help="MILP time budget (s)")
    s = sub.add_parser("simulate")
    s.add_argument("mode", choices=["offline", "online"])
    s.add_argument("--layout", default="ilp")
    s.add_argument("--duration", type=float, default=600)
    s.add_argument("--warm-up", type=float, default=60)
    s.add_argument("--rate", type=float, default=None)
    g = sub.add_parser("gen-config")
    g.add_argument("--layout", default="ilp")
    e = sub.add_parser("export-plan", help="pack the plan for the cluster (cluster_ctl.py push-plan --bundle)")
    e.add_argument("--layout", default="ilp")
    e.add_argument("--out", default="plan.tgz")
    a = ap.parse_args()
    if a.cmd == "from-hosts":
        cmd_from_hosts(os.path.join(cwd0, a.hosts_txt), a.cluster_json, a.host_ip, a.host_node, a.env, a.venv,
                       a.bandwidth_gbps, a.host_only)
        return
    c = load_cluster(a.cluster_json)
    if a.cmd == "init":
        cmd_init(c)
    elif a.cmd == "layout":
        cmd_layout(c, a.method, a.max_run_time)
    elif a.cmd == "simulate":
        cmd_simulate(a.mode, a.layout, a.duration, a.warm_up, a.rate)
    elif a.cmd == "export-plan":
        cmd_export_plan(c, a.layout, os.path.abspath(os.path.join(cwd0, a.out)))
    else:
        cmd_gen_config(c, a.layout)


if __name__ == "__main__":
    main()
