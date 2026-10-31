"""
Network-only Helix worker: same protocol as llm_sys/worker.py, but no GPU and no vLLM. It answers
every request with correctly-shaped dummy outputs (activations for intermediate stages, one token
id for the last stage), so a real host can run its scheduler end to end. Use it to test the
cluster's network, ports and routing before spending GPU time.

  HELIX_COMM_CPU_TENSORS=1 python tools/fake_worker.py --ip 10.0.0.11 --host tcp://10.0.0.1:5000

(examples/real_sys_qwen3/cluster_ctl.py net-test starts these on every worker.)
"""
import argparse
import os
import time

import llm_worker  # must be imported before torch (as in llm_sys/worker.py)
import torch


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ip", required=True, help="this worker's IP as in real_sys_config.txt")
    ap.add_argument("--host", required=True, help="config broadcast address, tcp://<host_ip>:<port>")
    ap.add_argument("--method", default="maxflow", choices=["maxflow", "swarm", "random"])
    ap.add_argument("--hidden", type=int, default=2048, help="hidden size (Qwen3-30B-A3B: 2048)")
    ap.add_argument("--step-ms", type=float, default=2.0, help="pretend compute time per batch")
    a = ap.parse_args()
    assert os.environ.get("HELIX_COMM_CPU_TENSORS") == "1", "set HELIX_COMM_CPU_TENSORS=1 (no GPU here)"

    llm_worker.start_network_threads(a.host, a.ip, a.method)
    start, end, is_last = llm_worker.get_model_start_end_idx()
    print(f"[fake_worker] {a.ip}: cluster initialization finished, layers [{start}, {end}), "
          f"last={is_last}", flush=True)

    served, last_log = 0, time.time()
    while True:
        (ids, is_prompt, _s, _e, num_tokens, _max, _off, _len, _is_tok, _tok,
         _act) = llm_worker.fetch_new_requests()
        if not ids:
            time.sleep(0.001)
            continue
        time.sleep(a.step_ms / 1000)
        offsets, lengths = [], []
        if is_last:
            out = torch.ones(len(ids), dtype=torch.int32)
            offsets, lengths = list(range(len(ids))), [1] * len(ids)
        else:
            pos = 0
            for prompt, n in zip(is_prompt, num_tokens):
                rows = n if prompt else 1
                offsets.append(pos * a.hidden)
                lengths.append(rows * a.hidden)
                pos += rows
            out = torch.zeros(pos * a.hidden, dtype=torch.float16)
        llm_worker.submit_requests([int(i) for i in ids], offsets, lengths, out)
        served += len(ids)
        if time.time() - last_log > 5:
            last_log = time.time()
            print(f"[fake_worker] {a.ip}: {served} request-steps served", flush=True)


if __name__ == "__main__":
    main()
