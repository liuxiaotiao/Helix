"""
Start Helix's host (coordinator) for Qwen3-30B-A3B. Run on the machine whose IP is host_ip in
cluster.json, from this directory:

  python step2_start_host.py offline maxflow --layout ilp              # peak throughput
  python step2_start_host.py online  maxflow --layout ilp --rate 900   # Azure-Conversation arrivals
  python step2_start_host.py offline swarm   --layout swarm            # baselines: swarm | random
  python step2_start_host.py offline maxflow --real                    # real weights, greedy, random prompts
  python step2_start_host.py offline maxflow --real --prompts my_prompts.jsonl

--real: workers load the real Qwen3 weights (start them with `cluster_ctl.py start-workers maxflow
--real`); the host feeds each generated token back into the next decode step and saves prompts,
generated tokens and text in <result dir>/generations.jsonl. --prompts: "random" (random token
ids with the trace's lengths) or a JSONL file, one {"prompt": "..."} / {"messages": [...]} per
line (see llm_sys/real_tokens.py). maxflow scheduling only.

--rate is the average *total* (prompt + output) token arrival rate, as in the paper's online
setup (75% of peak). step4_parse_results.py prints a suggested value from an offline run.
Workers (step3_start_worker.py) must use the same scheduling method; start order does not matter.
"""
import argparse
import json
import os
import sys

HERE = os.path.dirname(os.path.realpath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, REPO)
os.chdir(HERE)
import helix_cluster as hc  # noqa: E402  (light: no simulator / torch import)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("mode", choices=["online", "offline"])
    ap.add_argument("method", choices=["maxflow", "swarm", "random"])
    ap.add_argument("--layout", default="ilp", help="placement from helix_cluster.py (ilp|petals|swarm)")
    ap.add_argument("--duration", type=int, default=300, help="seconds of request generation")
    ap.add_argument("--real", action="store_true", help="real weights / real tokens (workers need --real)")
    ap.add_argument("--prompts", default="random", help='with --real: "random" or a JSONL file of prompts')
    ap.add_argument("--seed", type=int, default=0, help="seed of the random prompts")
    ap.add_argument("--init-wait", type=float, default=None,
                    help="seconds to wait after sending the config before the first request "
                         "(default 20; 120 with --real, while workers load their weights)")
    ap.add_argument("--rate", type=float, default=None, help="online: avg total tokens/s")
    ap.add_argument("--result-dir", default=None, help="default ./result/<method>_<mode>_<layout>/")
    ap.add_argument("--initial-launch", type=int, default=None,
                    help="offline: requests launched at start (default 20 maxflow / 50 heuristics)")
    a = ap.parse_args()

    c = hc.load_cluster()
    cfg = os.path.join(hc.deploy_dir(a.layout), "real_sys_config.txt")
    lay = hc.layout_dir(a.layout)
    assert os.path.exists(cfg), f"{cfg} not found: run `helix_cluster.py gen-config --layout {a.layout}`"

    # host address: config broadcast socket + this machine's identity (machine 0)
    os.environ.setdefault("HELIX_CONFIG_BROADCAST_ADDR", hc.broadcast_addr(c))
    if not os.environ.get("HELIX_LOCAL_IP"):
        if not hc.local_ips_among([c["host_ip"]]):
            raise SystemExit(f"This machine does not own host_ip {c['host_ip']} (cluster.json). Run the "
                             f"host there, or set HELIX_LOCAL_IP if the address is NATed.")
        os.environ["HELIX_LOCAL_IP"] = c["host_ip"]
    print(f"[host] {os.environ['HELIX_LOCAL_IP']}, config broadcast at "
          f"{os.environ['HELIX_CONFIG_BROADCAST_ADDR']}, layout '{a.layout}', {a.method} + {a.mode}")

    if a.mode == "online" and a.rate is None:
        sim = f"./sim_files/{hc.CLUSTER_NAME}_{a.layout}_offline/result.json"
        if not os.path.exists(sim):
            raise SystemExit("online mode needs --rate <total tokens/s> (e.g. 0.75 x the offline result "
                             "suggested by step4_parse_results.py)")
        a.rate = 0.75 * json.load(open(sim))["total_token_throughput"]
        print(f"[host] --rate not given: using 75% of the SIMULATED offline throughput = {a.rate:.1f}")

    result_dir = a.result_dir or f"./result/{a.method}_{a.mode}_{a.layout}/"
    os.makedirs(result_dir, exist_ok=True)

    # import only now: llm_sys.utils reads HELIX_* at import time
    from simulator.event_simulator.cluster_simulator import ModelName
    if a.real and a.method != "maxflow":
        raise SystemExit("--real is implemented for maxflow scheduling only")
    if a.method == "maxflow":
        from llm_sys.maxflow_host import run_maxflow_host_online, run_maxflow_host_offline
        from llm_sys.real_tokens import make_token_io
        weights_dir = os.path.expanduser((c.get("weights") or {}).get("dir") or "") if a.real else None
        if a.real and a.prompts != "random" and not os.path.exists(a.prompts):
            raise SystemExit(f"--prompts {a.prompts}: no such file")
        token_io = make_token_io(a.real, a.prompts, weights_dir, seed=a.seed)
        init_wait = a.init_wait if a.init_wait is not None else (120 if a.real else 20)
        if a.real:
            print(f"[host] REAL generation: greedy, prompts={a.prompts}, tokenizer {weights_dir}, "
                  f"waiting {init_wait:g}s for the workers to load weights", flush=True)
        common = dict(machine_num_dict=hc.machine_num_dict(c), model_name=ModelName.Qwen3_30B_A3B,
                      complete_cluster_file_name=hc.CLUSTER_INI,
                      machine_profile_name=hc.MACHINE_PROFILE_INI,
                      solution_file_name=os.path.join(lay, f"{a.layout}_sol.ini"),
                      simulator_cluster_file_name=os.path.join(lay, "simulator_cluster.ini"),
                      real_sys_config_file_name=cfg, duration=a.duration,
                      result_logging_dir=result_dir, token_io=token_io, init_wait=init_wait)
        if a.mode == "offline":
            run_maxflow_host_offline(initial_launch_num=a.initial_launch or 20, feeding_hwm=0.8, **common)
        else:
            run_maxflow_host_online(avg_throughput=a.rate, **common)
    else:
        from llm_sys.heuristic_host import run_heuristic_host_online, run_heuristic_host_offline
        if a.mode == "offline":
            run_heuristic_host_offline(scheduler_name=a.method, real_sys_config_file_name=cfg,
                                       initial_launch_num=a.initial_launch or 50, duration=a.duration,
                                       result_logging_dir=result_dir)
        else:
            run_heuristic_host_online(scheduler_name=a.method, real_sys_config_file_name=cfg,
                                      avg_throughput=a.rate, duration=a.duration,
                                      result_logging_dir=result_dir)
    print(f"[host] done; logs in {result_dir} -> python step4_parse_results.py {result_dir}", flush=True)
    # the C++ network threads are detached and still blocked in ZeroMQ calls; a normal interpreter
    # exit tears the ZeroMQ context down under them and aborts. Results are written: leave now.
    os._exit(0)


if __name__ == "__main__":
    main()
