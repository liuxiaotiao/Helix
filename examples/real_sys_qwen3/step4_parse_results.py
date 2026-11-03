"""
Summarise a real-system run (latency + decode throughput), reusing examples/real_sys's parser.

  python step4_parse_results.py ./result/maxflow_offline_ilp/ [--warm-up 60] [--finish 300]

Also prints the exact total (prompt + generated) token throughput counted from the events, so it is
right for any prompt mix (dataset prompts included), and for an offline run the online --rate to
use next (paper setup: 75% of peak, in total tokens/s, which is what step2's --rate expects).
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


def _pct(xs, q):
    xs = sorted(xs)
    return xs[min(len(xs) - 1, int(q / 100.0 * len(xs)))] if xs else float("nan")


def _mean(xs):
    return sum(xs) / len(xs) if xs else float("nan")


def gpu_summary(result_dir, t0, t1):
    """per-node GPU samples (step2_start_host.py, <result dir>/gpu/<ip>.csv: epoch, util %, used MiB,
    total MiB, power W) inside the measurement window -> {ip: stats}"""
    gdir, info = os.path.join(result_dir, "gpu"), os.path.join(result_dir, "run_info.json")
    if not (os.path.isdir(gdir) and os.path.exists(info)):
        return {}
    import json
    gz = json.load(open(info))["ground_zero"]
    out = {}
    for f in sorted(os.listdir(gdir)):
        if not f.endswith(".csv"):
            continue
        rows = []
        for line in open(os.path.join(gdir, f)):
            parts = [x.strip() for x in line.split(",")]
            if len(parts) < 5:
                continue
            try:
                t = float(parts[0]) - gz
                util, used, total = float(parts[1]), float(parts[2]), float(parts[3])
                power = float(parts[4]) if parts[4].replace(".", "", 1).isdigit() else float("nan")
            except ValueError:
                continue
            if t0 <= t <= t1:
                rows.append((util, used, total, power))
        if rows:
            pw = [r[3] for r in rows if r[3] == r[3]]
            out[f[:-4]] = {"samples": len(rows), "util": _mean([r[0] for r in rows]),
                           "peak_mem": max(r[1] for r in rows), "total_mem": max(r[2] for r in rows),
                           "power": _mean(pw) if pw else float("nan")}
    return out


def extended_metrics(result_dir, events, t0, t1):
    """The per-request / throughput / GPU table (also saved as summary.csv / summary.json).
    Latencies are measured from the moment the host sends a request's prompt into the cluster:
    the Helix host has no admission queue of its own (online: sent on arrival; offline: created
    when sent), so they exclude queueing before the cluster; waiting inside the cluster (behind
    other batches on a GPU) is part of them and cannot be separated from the events."""
    import json
    p_out, ttft_at, last_in, n_in = {}, {}, {}, {}
    for t, q, io_, ph, ctx, n in events:
        if io_ == "out" and ph == "prompt":
            p_out[q] = t
        elif io_ == "in":
            n_in[q] = n_in.get(q, 0) + 1
            last_in[q] = t
            if ph == "prompt":
                ttft_at[q] = t
    # which requests completed: generations.jsonl (real runs, may end at EOS) or planned length
    finished = {}
    gen = os.path.join(result_dir, "generations.jsonl")
    if os.path.exists(gen):
        for line in open(gen):
            r = json.loads(line)
            finished[r["query_id"]] = bool(r.get("finished"))
    else:
        routes = os.path.join(result_dir, "query_route.txt")
        for line in open(routes):
            if line.strip():
                q = eval(line)
                finished[q[0]] = n_in.get(q[0], 0) >= q[2]
    done = [q for q, ok in finished.items() if ok and q in p_out and q in ttft_at and t0 <= last_in[q] <= t1]
    e2e = [last_in[q] - p_out[q] for q in done]
    ttft = [ttft_at[q] - p_out[q] for q in done]
    tpot = [(last_in[q] - ttft_at[q]) / (n_in[q] - 1) for q in done if n_in[q] > 1]
    outl = [n_in[q] for q in done]
    per_req = [n_in[q] / (last_in[q] - p_out[q]) for q in done if last_in[q] > p_out[q]]
    span = max(t1 - t0, 1e-9)
    gen_w = sum(1 for e in events if e[2] == "in" and t0 <= e[0] <= t1)
    prm_w = sum(e[5] - 1 for e in events if e[2] == "in" and e[3] == "prompt" and t0 <= e[0] <= t1)
    gpus = gpu_summary(result_dir, t0, t1)
    tpot_ms = 1000 * _mean(tpot)
    rows = [
        ("E2E (excl. queue) ms", 1000 * _mean(e2e), 1000 * _pct(e2e, 50), 1000 * _pct(e2e, 99)),
        ("TTFT (excl. queue) ms", 1000 * _mean(ttft), 1000 * _pct(ttft, 50), 1000 * _pct(ttft, 99)),
        ("TPOT ms/token", tpot_ms, 1000 * _pct(tpot, 50), 1000 * _pct(tpot, 99)),
        ("Output length (tokens)", _mean(outl), _pct(outl, 50), _pct(outl, 99)),
        ("Per-request tok/s (excl. queue)", _mean(per_req), _pct(per_req, 50), _pct(per_req, 99)),
        ("Decode tok/s (1000/TPOT)", 1000.0 / tpot_ms if tpot_ms == tpot_ms and tpot_ms > 0 else float("nan"), None, None),
        ("Throughput: output tok/s", gen_w / span, None, None),
        ("Throughput: incl. prompt tok/s", (gen_w + prm_w) / span, None, None),
        ("Throughput: requests/min", 60.0 * len(done) / span, None, None),
        ("Total output tokens", float(gen_w), None, None),
        ("Mean GPU utilization %", _mean([g["util"] for g in gpus.values()]) if gpus else float("nan"), None, None),
        ("Total peak GPU memory (MB)", sum(g["peak_mem"] for g in gpus.values()) if gpus else float("nan"), None, None),
        ("Total GPU memory (MB)", sum(g["total_mem"] for g in gpus.values()) if gpus else float("nan"), None, None),
        ("Total power (W)", sum(g["power"] for g in gpus.values() if g["power"] == g["power"]) if gpus else float("nan"),
         None, None),
    ]
    print(f"\n=== Metrics, t={t0:g}..{t1:.0f}s ({len(done)} requests completed in the window"
          f"{'' if gpus else '; no GPU samples: run step2 without --no-gpu-monitor'}) ===")
    print(f"  {'Metric':34s} {'mean / value':>14s} {'p50':>10s} {'p99':>10s}")

    def fmt(v):
        return "" if v is None else ("n/a" if v != v else (f"{v:,.0f}" if abs(v) >= 1000 else f"{v:.2f}"))
    for name, v, p50, p99 in rows:
        print(f"  {name:34s} {fmt(v):>14s} {fmt(p50):>10s} {fmt(p99):>10s}")
    if gpus:
        print(f"  per GPU ({'node':15s}  util %  peak MiB / total MiB  power W  samples)")
        for ip, g in sorted(gpus.items()):
            print(f"    {ip:15s} {g['util']:7.1f}  {g['peak_mem']:8.0f} / {g['total_mem']:<8.0f}  "
                  f"{g['power']:7.1f}  {g['samples']}")
    with open(os.path.join(result_dir, "summary.csv"), "w") as f:
        f.write("metric,value,p50,p99\n")
        for name, v, p50, p99 in rows:
            f.write(f"{name},{'' if v != v else round(v, 4)},{'' if p50 is None else round(p50, 4)},"
                    f"{'' if p99 is None else round(p99, 4)}\n")
    json.dump({"window": [t0, t1], "requests_completed": len(done),
               "metrics": {name: {"value": v, "p50": p50, "p99": p99} for name, v, p50, p99 in rows},
               "gpus": gpus}, open(os.path.join(result_dir, "summary.json"), "w"), indent=1, default=str)
    print(f"  saved: {os.path.join(result_dir, 'summary.csv')} (and summary.json)")


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
    prompt_in_window = [e for e in events if e[2] == "in" and e[3] == "prompt" and a.warm_up <= e[0] <= a.finish]
    print(f"{events_file}: {len(events)} events, last at t={last_t:.1f}s; "
          + ", ".join(f"{k[1]} {k[0]}={v}" for k, v in sorted(kinds.items())))
    stuck = kinds.get(("out", "prompt"), 0) - kinds.get(("in", "prompt"), 0)
    if stuck > 0 and last_t < a.finish:
        print(f"WARNING: {stuck} prompts never came back and nothing arrived after t={last_t:.1f}s: "
              f"a worker on their paths probably died (check `DEAD` / Traceback in logs/worker_<ip>.log).")
    if len(in_window) < 2 or not prompt_in_window:
        print("Decode results received back at the host, per 30 s:")
        for t0 in range(0, int(max(last_t, a.finish)) + 30, 30):
            n = sum(1 for t in dec_in if t0 <= t < t0 + 30)
            print(f"  t={t0:4d}-{t0 + 30:<4d}s  {n}")
        raise SystemExit(f"{len(prompt_in_window)} prompt and {len(in_window)} decode results came back "
                         f"between t={a.warm_up:g}s and "
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

    # exact token accounting from the events (works for any prompt / output length mix, e.g.
    # dataset prompts): a returned prompt = input_len prompt tokens + its first generated token,
    # a returned decode = one generated token
    t0, t1 = a.warm_up, min(a.finish, last_t)
    span = max(t1 - t0, 1e-9)
    p_in = [e for e in events if e[2] == "in" and e[3] == "prompt" and t0 <= e[0] <= t1]
    d_in = [e for e in events if e[2] == "in" and e[3] == "decode" and t0 <= e[0] <= t1]
    prompt_tokens = sum(e[5] - 1 for e in p_in)
    generated = len(p_in) + len(d_in)
    total = (prompt_tokens + generated) / span
    # per request: input length from its prompt event, output = results that came back for it
    # (requests that end at EOS generate fewer tokens than the planned length in query_route.txt)
    in_len, n_out = {}, {}
    for e in events:
        if e[2] == "in":
            n_out[e[1]] = n_out.get(e[1], 0) + 1
            if e[3] == "prompt":
                in_len[e[1]] = e[5] - 1
    routes = os.path.join(a.result_dir, "query_route.txt")
    planned = {q[0]: q[2] for q in (eval(x) for x in open(routes) if x.strip())} if os.path.exists(routes) else {}
    done = [q for q in in_len if planned.get(q) is not None and n_out[q] >= 1]
    avg = ""
    if in_len:
        avg = (f"  (requests avg in {sum(in_len.values()) / len(in_len):.0f} / generated "
               f"{sum(n_out[q] for q in in_len) / len(in_len):.0f}"
               + (f", planned out {sum(planned[q] for q in done) / len(done):.0f})" if done else ")"))
    print(f"Exact, t={t0:g}..{t1:.0f}s: {len(p_in) / span:.2f} requests/s, prompt {prompt_tokens / span:.1f} + "
          f"generated {generated / span:.1f} = total {total:.1f} tokens/s" + avg)
    if m and "offline" in os.path.basename(os.path.normpath(a.result_dir)):
        print(f"Next, online at 75% of peak:  python step2_start_host.py online <method> "
              f"--layout <layout> --rate {0.75 * total:.0f}")
    extended_metrics(a.result_dir, events, t0, t1)


if __name__ == "__main__":
    main()
