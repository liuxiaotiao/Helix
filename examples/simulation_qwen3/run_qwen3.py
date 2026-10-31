"""
Helix simulator workflow for Qwen3-30B-A3B (counterpart of examples/simulation/step1-3).

  python run_qwen3.py gen-cluster                       # config/single24.ini, config/small9.ini
  python run_qwen3.py layout petals --cluster single24  # heuristic placements (fast)
  python run_qwen3.py layout swarm  --cluster single24
  python run_qwen3.py layout ilp    --cluster single24  # Helix MILP (Gurobi), bootstrapped by petals
  python run_qwen3.py simulate offline --cluster single24 --layout ilp [--duration 600]
  python run_qwen3.py simulate online  --cluster single24 --layout ilp   # needs the offline run

Needs measured profiles for every GPU type in the cluster (tools/profile_qwen3_moe.py), or
HELIX_QWEN3_PROFILE_DIR pointing at placeholder profiles for pipeline testing only.
Run from this directory (paths below are relative, as in examples/simulation).
"""
import argparse
import json
import os
import re
from collections import Counter
from configparser import ConfigParser

from simulator.event_simulator.cluster_simulator import ClusterSimulator, ModelName, SchedulingMethod, RequestPhase
from simulator.event_simulator.utils import gbps, mbps, MilliSec
from simulator.initial_layout.fake_cluster_generator import FakeClusterGenerator
from simulator.initial_layout.layout_synthesizer import LayoutMethod, LayoutSynthesizer
from simulator.scheduler.global_maxflow.global_maxflow_scheduler import KVParameters, SchedulingMode
from simulator.trace_generator.simulator_query_feeder import OfflineRequestFeeder, OnlineRequestFeeder

MODEL = ModelName.Qwen3_30B_A3B
MACHINE_PROFILE = "./config/machine_profile.ini"
CLUSTERS = {
    # same cluster as the paper's single-cluster setup (4 A100 + 8 L4 + 12 T4, 1 Gb/s mesh)
    "single24": {"A100": 4, "L4": 8, "T4": 12},
    # small cluster: fits Gurobi's free size-limited licence, useful for quick ILP checks
    "small9": {"A100": 2, "L4": 3, "T4": 4},
}


def cluster_file(name):
    return f"./config/{name}.ini"


def machine_num_dict(name):
    """Count machine types directly from the cluster file."""
    cfg = ConfigParser()
    cfg.read(cluster_file(name))
    types = [cfg[s]["type"] for s in cfg.sections() if re.fullmatch(r"ComputeNode-\d+", s)]
    return dict(Counter(types))


def gen_cluster():
    os.makedirs("./config", exist_ok=True)
    for name, mix in CLUSTERS.items():
        n = sum(mix.values())
        g = FakeClusterGenerator()
        g.set_node_statistics(num_compute_nodes=n, avg_degree=n - 1, source_degree=n,
                              sink_degree=n, node_type_percentage=mix)
        g.set_link_statistics(avg_bandwidth=1 * gbps, var_bandwidth=0, avg_latency=1 * MilliSec,
                              var_latency=0, fill_with_slow_link=True,
                              slow_link_avg_bandwidth=1 * gbps, slow_link_var_bandwidth=0,
                              slow_link_avg_latency=1 * MilliSec, slow_link_var_latency=0)
        g.generator_fake_cluster(file_name=cluster_file(name), seed=0)
        print(f"wrote {cluster_file(name)}: {mix}")


def layout(method, cluster, max_run_time):
    ws = f"./layouts/{cluster}/{method}"
    synth = LayoutSynthesizer(complete_cluster_file_name=cluster_file(cluster),
                              machine_profile_name=MACHINE_PROFILE, model_name=MODEL,
                              workspace_path=ws, layout_method={"petals": LayoutMethod.Petals,
                                                                "swarm": LayoutMethod.Swarm,
                                                                "ilp": LayoutMethod.ILP}[method],
                              machine_num_dict=machine_num_dict(cluster))
    if method == "petals":
        args = {"seed": 0, "max_out_links_per_node": 24}
    elif method == "swarm":
        args = {"seed": 0, "num_stages": 8, "max_out_links_per_node": 24}  # 48 layers / 6 (T4 max)
    else:
        # Bootstrap the MILP from the best existing heuristic placement (by max flow), as the
        # paper does with Petals / Swarm / SP hints. Starting from a weak hint can leave the
        # MILP below a better heuristic within a limited time budget.
        flows = {h: layout_max_flow(cluster, h) for h in ["petals", "swarm"]
                 if os.path.exists(f"./layouts/{cluster}/{h}/{h}_sol.ini")}
        assert flows, "run `layout petals` and/or `layout swarm` first (the MILP starts from one)"
        best = max(flows, key=flows.get)
        print(f"heuristic max flows: {flows} -> MILP starts from {best}")
        args = {"enable_pruning": False, "min_keep": 12, "max_keep": 12,
                "keep_bandwidth_threshold": 1 * mbps, "use_existing_sol": False,
                "allow_partial_inference": False, "remove_redundant": True,
                "max_run_time": max_run_time, "early_stop_time": 100, "early_stop_threshold": 0.95,
                "existing_sol_path": "", "start_from_heuristic": True,
                "heuristic_sol_path": f"./layouts/{cluster}/{best}/{best}_sol.ini"}
    synth.synthesize(args=args)
    print(f"{method} layout written to {ws}")
    check_max_hops(cluster, method)


# llm_sys/comm/src/const.h: MAX_HOP = 32 stages per request header, one of which is the final
# hop back to the coordinator -> at most 31 compute nodes on any per-request pipeline.
REAL_SYSTEM_MAX_COMPUTE_HOPS = 31


def check_max_hops(cluster, layout_name):
    """Longest source->sink path (in compute nodes) over the layout's valid links."""
    import networkx as nx
    cfg = ConfigParser()
    cfg.read(f"./layouts/{cluster}/{layout_name}/simulator_cluster.ini")
    g = nx.DiGraph()
    for name in eval(cfg["Links"]["names"]):
        g.add_edge(cfg[name]["in"], cfg[name]["out"])
    longest = len(nx.dag_longest_path(g)) - 2   # drop source and sink
    status = "ok" if longest <= REAL_SYSTEM_MAX_COMPUTE_HOPS else "TOO LONG for the real system"
    print(f"Longest per-request pipeline: {longest} compute nodes "
          f"(real-system limit {REAL_SYSTEM_MAX_COMPUTE_HOPS}): {status}")
    if longest > REAL_SYSTEM_MAX_COMPUTE_HOPS:
        print("WARNING: requests may exceed MAX_HOP in llm_sys/comm/src/const.h and crash the "
              "prototype (Header::add_stage). Raise MAX_HOP and rebuild llm_sys/comm, or use "
              "fewer / bigger nodes.")
    return longest


def build_simulator(cluster, layout_name, workspace, mode="offline"):
    mix = machine_num_dict(cluster)
    lay = f"./layouts/{cluster}/{layout_name}"
    synth = LayoutSynthesizer(complete_cluster_file_name=cluster_file(cluster),
                              machine_profile_name=MACHINE_PROFILE, model_name=MODEL,
                              workspace_path=workspace, layout_method=LayoutMethod.LoadExisting,
                              machine_num_dict=mix)
    cluster_path = synth.synthesize(args={
        "solution_file_name": os.path.join(lay, f"{layout_name}_sol.ini"),
        "simulator_cluster_file_name": os.path.join(lay, "simulator_cluster.ini")})
    sim = ClusterSimulator(model_name=MODEL, machine_num_dict=mix)
    sim.from_ini_file(config_file_name=cluster_path)
    kv = (KVParameters(expected_kv_hwm=0.85, expected_output_length_ratio=1) if mode == "offline"
          else KVParameters(expected_kv_hwm=0.9, expected_output_length_ratio=0.6))
    sim.init_scheduler(scheduling_method=SchedulingMethod.MaxFlow,
                       args={"kv_param": kv, "scheduling_mode": SchedulingMode.Offline
                             if mode == "offline" else SchedulingMode.Online})
    sim.init_query_manager()
    sim.mark_as_ready()
    t0 = synth.set_layout(simulator=sim)
    sim.update_scheduler()
    return sim, synth, t0


def layout_max_flow(cluster, layout_name):
    import contextlib
    import io
    import shutil
    ws = f"./tmp_maxflow_{layout_name}"
    with contextlib.redirect_stdout(io.StringIO()):
        sim, _, _ = build_simulator(cluster, layout_name, ws)
    shutil.rmtree(ws, ignore_errors=True)
    return round(sim.scheduler.core.flow_graph.flow_value, 1)


def offline_result_file(cluster, layout_name):
    return f"./sim_files/{cluster}_{layout_name}_offline/result.json"


def simulate(mode, cluster, layout_name, duration, warm_up, rate=None):
    check_max_hops(cluster, layout_name)
    if mode == "online" and rate is None:
        # Paper (Sec. 6.2): online arrival rate = 75% of the cluster's peak throughput, i.e. the
        # measured offline total token throughput -- not the max-flow estimate, which can be far
        # off. Online mode cannot reject requests: overload ends in an assertion failure.
        f = offline_result_file(cluster, layout_name)
        if not os.path.exists(f):
            raise SystemExit(f"Run `simulate offline` for this layout first (needs {f}), "
                             f"or pass --rate <total tokens/s>.")
        rate = 0.75 * json.load(open(f))["total_token_throughput"]
        print(f"Online arrival rate = 75% of offline throughput = {rate:.1f} tokens/s")
    ws = f"./sim_files/{cluster}_{layout_name}_{mode}/"
    os.makedirs(ws, exist_ok=True)
    sim, synth, t0 = build_simulator(cluster, layout_name, ws, mode)
    max_flow = sim.scheduler.core.flow_graph.flow_value
    print(f"Max compute throughput = {synth.layout_synthesizer.get_flow_upper_bound():.1f} tokens/s")
    print(f"Max flow               = {max_flow:.1f} tokens/s")

    if mode == "offline":
        feeder = OfflineRequestFeeder(initial_query_count=20, start_time=t0,
                                      duration=warm_up + duration, stop_at_duration=True,
                                      feed_hwm=0.8, seed=0)
    else:
        # Helix's arrival-rate sampler asserts the trace length is a multiple of 3 seconds
        total = warm_up + duration
        if total % 3:
            extra = 3 - total % 3
            duration += extra
            print(f"Online mode: extending the measured window by {extra:g}s so that warm-up + "
                  f"duration ({total + extra:g}s) is a multiple of 3")
        feeder = OnlineRequestFeeder(cluster_token_throughput=rate, start_time=t0,
                                     duration=warm_up + duration, seed=0)
    feeder.auto_simulate(simulator=sim, watch_items=["all"], watch_interval=max(10, duration))

    a0, a1 = t0 + warm_up, t0 + warm_up + duration
    decode_tokens, prompt_tokens, prompt_lat, decode_lat = 0, 0, [], []
    for _, (t, req) in sim.finished_requests.items():
        if not (a0 <= t <= a1):
            continue
        lat = req.location_history[-1][1] - req.location_history[0][1]
        if req.phase == RequestPhase.Initialization:
            prompt_tokens += req.token_seq_length
            prompt_lat.append(lat)
        else:
            decode_tokens += req.token_seq_length
            decode_lat.append(lat)
    total = (prompt_tokens + decode_tokens) / duration
    print("# ------------------------------------------------------------- #")
    print(f"Qwen3-30B-A3B {mode} on {cluster} with {layout_name} placement ({a0:.0f}s - {a1:.0f}s)")
    print(f"Avg decode speed:   {decode_tokens / duration:.1f} tokens/s")
    print(f"Total token speed:  {total:.1f} tokens/s (prompt + decode; max flow {max_flow:.1f})")
    if prompt_lat:
        print(f"Avg prompt latency: {sum(prompt_lat) / len(prompt_lat):.3f}s")
    if decode_lat:
        print(f"Avg decode latency: {sum(decode_lat) / len(decode_lat):.3f}s")
    print("# ------------------------------------------------------------- #")
    if mode == "offline":
        with open(offline_result_file(cluster, layout_name), "w") as f:
            json.dump({"decode_token_throughput": decode_tokens / duration,
                       "total_token_throughput": total, "max_flow": max_flow,
                       "duration": duration, "warm_up": warm_up}, f, indent=2)
    return decode_tokens / duration, max_flow


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("gen-cluster")
    p = sub.add_parser("layout")
    p.add_argument("method", choices=["petals", "swarm", "ilp"])
    p.add_argument("--cluster", default="single24")
    p.add_argument("--max-run-time", type=float, default=36000)
    s = sub.add_parser("simulate")
    s.add_argument("mode", choices=["offline", "online"])
    s.add_argument("--cluster", default="single24")
    s.add_argument("--layout", default="ilp")
    s.add_argument("--duration", type=float, default=600)
    s.add_argument("--warm-up", type=float, default=60)
    s.add_argument("--rate", type=float, default=None,
                   help="online only: total token arrival rate; default 75%% of offline result")
    a = ap.parse_args()
    if a.cmd == "gen-cluster":
        gen_cluster()
    elif a.cmd == "layout":
        layout(a.method, a.cluster, a.max_run_time)
    else:
        simulate(a.mode, a.cluster, a.layout, a.duration, a.warm_up, a.rate)


if __name__ == "__main__":
    main()
