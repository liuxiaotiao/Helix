"""
Summarise a real-system run (latency + decode throughput), reusing examples/real_sys's parser.

  python step4_parse_results.py ./result/maxflow_offline_ilp/ [--warm-up 60] [--finish 300]

For an offline run it also prints the online --rate to use next (paper setup: 75% of peak,
expressed in total = prompt + output tokens/s, which is what step2's --rate expects).
"""
import argparse
import contextlib
import importlib.util
import io
import os
import re
import sys

HERE = os.path.dirname(os.path.realpath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, REPO)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("result_dir")
    ap.add_argument("--warm-up", type=float, default=60)
    ap.add_argument("--finish", type=float, default=300)
    a = ap.parse_args()

    # sanity check first: the original parser crashes (IndexError) when nothing came back
    events_file = os.path.join(a.result_dir, "events.txt")
    with open(events_file) as f:
        events = [eval(line) for line in f if line.strip()]
    kinds = {}
    for e in events:
        kinds[(e[2], e[3])] = kinds.get((e[2], e[3]), 0) + 1
    last_t = max((e[0] for e in events), default=0)
    dec_in = [e[0] for e in events if e[2] == "in" and e[3] == "decode"]
    in_window = [t for t in dec_in if a.warm_up <= t <= a.finish]
    print(f"{events_file}: {len(events)} events, last at t={last_t:.1f}s; "
          + ", ".join(f"{k[1]} {k[0]}={v}" for k, v in sorted(kinds.items())))
    if len(in_window) < 2:
        print("Decode results received back at the host, per 30 s:")
        for t0 in range(0, int(max(last_t, a.finish)) + 30, 30):
            n = sum(1 for t in dec_in if t0 <= t < t0 + 30)
            print(f"  t={t0:4d}-{t0 + 30:<4d}s  {n}")
        raise SystemExit(f"Only {len(in_window)} decode results came back between t={a.warm_up:g}s and "
                         f"t={a.finish:g}s, so there is nothing to measure. If they stop at some point, a "
                         f"worker most likely died or hung then: check logs/worker_<ip>.log on the nodes. "
                         f"If the run was short, lower --warm-up / --finish.")

    spec = importlib.util.spec_from_file_location(
        "real_sys_step4", os.path.join(REPO, "examples", "real_sys", "step4_parse_results.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        mod.parse_result(file_name=os.path.join(a.result_dir, "events.txt"),
                         warm_up_time=a.warm_up, finish_time=a.finish)
    print(buf.getvalue(), end="")
    m = re.search(r"Throughput: ([0-9.]+) Tokens/s", buf.getvalue())

    if m and "offline" in os.path.basename(os.path.normpath(a.result_dir)):
        # decode tokens/s -> total tokens/s for the Azure-Conversation length distribution
        from simulator.trace_generator.trace_generator import LengthSampler, Dataset
        ls = LengthSampler(dataset=Dataset.AzureConversation, seed=0)
        scale = ls.get_average_length() / ls.average_output_length
        total = float(m.group(1)) * scale
        print(f"Total-token throughput ~= {total:.1f} tokens/s (decode x {scale:.2f}; Azure-Conv avg "
              f"in {ls.average_input_length:.0f} / out {ls.average_output_length:.0f})")
        print(f"Next, online at 75% of peak:  python step2_start_host.py online <method> "
              f"--layout <layout> --rate {0.75 * total:.0f}")


if __name__ == "__main__":
    main()
