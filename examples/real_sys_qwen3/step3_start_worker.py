"""
Start one Helix worker (one GPU) for Qwen3-30B-A3B. Run on every worker machine listed in
cluster.json, from this directory:

  python step3_start_worker.py maxflow          # or swarm | random, same as the host

The worker finds its own IP among cluster.json's workers (or uses HELIX_LOCAL_IP), fetches its
layers from the host, and serves them with dummy weights. On a multi-GPU machine only one GPU is
used (pick it with CUDA_VISIBLE_DEVICES): Helix identifies workers by IP.
"""
import argparse
import os
import sys

HERE = os.path.dirname(os.path.realpath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, REPO)
import helix_cluster as hc  # noqa: E402  (light: no simulator / torch import)

PROFILED_VRAM_USAGE = 0.8   # tools/profile_qwen3_moe.py measures KV capacity at this setting


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("method", choices=["maxflow", "swarm", "random"])
    ap.add_argument("--vram-usage", type=float, default=PROFILED_VRAM_USAGE,
                    help="vLLM gpu_memory_utilization (keep equal to the profiling value)")
    a = ap.parse_args()

    c = hc.load_cluster()
    os.environ.setdefault("HELIX_CONFIG_BROADCAST_ADDR", hc.broadcast_addr(c))
    ip2type = {w["ip"]: w["type"] for w in c["workers"]}
    if not os.environ.get("HELIX_LOCAL_IP"):
        mine = hc.local_ips_among(ip2type)
        if len(mine) != 1:
            raise SystemExit(f"This machine owns {len(mine)} of the worker IPs in cluster.json "
                             f"({mine or 'none'}). Set HELIX_LOCAL_IP=<this worker's IP>.")
        os.environ["HELIX_LOCAL_IP"] = mine[0]
    ip = os.environ["HELIX_LOCAL_IP"]
    if ip not in ip2type:
        raise SystemExit(f"HELIX_LOCAL_IP={ip} is not a worker in cluster.json")
    if a.vram_usage != PROFILED_VRAM_USAGE:
        print(f"[worker] WARNING: --vram-usage {a.vram_usage} differs from the profiled "
              f"{PROFILED_VRAM_USAGE}; the planner's KV-capacity assumptions will be off.")
    print(f"[worker] {ip} ({ip2type[ip]}), host {os.environ['HELIX_CONFIG_BROADCAST_ADDR']}, "
          f"scheduling '{a.method}'")

    # import only now: llm_sys.utils reads HELIX_* at import time
    from llm_sys.worker import run_worker
    run_worker(scheduling_method=a.method, model_name=os.path.join(HERE, "model"),
               vram_usage=a.vram_usage)


if __name__ == "__main__":
    main()
