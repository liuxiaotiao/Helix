"""
Oracle output lengths for dataset prompts: write a prompt file whose "max_tokens" is the length
at which each prompt's greedy generation actually ended (its first EOS).

Runs with a prompt file already end each request at its first EOS (step2_start_host.py, default;
llm_sys/real_tokens.py). But the host's scheduler admits requests by their *planned* length, i.e.
"max_tokens", and reserves KV for it. With this file the planned length is the real one, which
is the "known output lengths" setting. Greedy decoding is deterministic, so a run with the
calibrated file generates the same tokens and ends at the same EOS.

    python step2_start_host.py offline maxflow --real --prompts prompts/mix.jsonl --prompts-once \
        --duration 3600 --result-dir result/mix_offline_ilp/
    python ../../tools/calibrate_lengths.py prompts/mix.jsonl result/mix_offline_ilp/generations.jsonl
    #    -> prompts/mix.calibrated.jsonl

Prompts that did not reach EOS within the cap keep the cap ("hit_cap": true); prompts that did
not run at all are dropped (--keep-missing keeps them with the cap).
"""
import argparse
import json
import os
import statistics
import sys


def calibrate(prompt_lines, generations, keep_missing=False):
    by_index = {}
    for g in generations:
        k = g.get("prompt_index")
        if k is None or not g.get("finished"):
            continue
        by_index[k] = g
    out, stats = [], {"calibrated": 0, "hit_cap": 0, "missing": 0, "lengths": []}
    for k, item in enumerate(prompt_lines):
        g = by_index.get(k)
        if g is None:
            stats["missing"] += 1
            if keep_missing:
                out.append(dict(item))
            continue
        new = dict(item)
        if g.get("eos_at") is not None:
            new["max_tokens"] = int(g["eos_at"]) + 1            # include the EOS token itself
            new["natural_length"] = True
            stats["calibrated"] += 1
        else:
            new["max_tokens"] = int(g["generated_len"])
            new["hit_cap"] = True
            stats["hit_cap"] += 1
        new["prompt_tokens"] = int(g["input_len"])
        stats["lengths"].append(new["max_tokens"])
        out.append(new)
    return out, stats


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("prompts", help="the prompt file the run used")
    ap.add_argument("generations", help="<result dir>/generations.jsonl of a --prompts-once run")
    ap.add_argument("--out", default=None, help="default: <prompts>.calibrated.jsonl")
    ap.add_argument("--keep-missing", action="store_true")
    a = ap.parse_args()

    prompts = [json.loads(x) for x in open(a.prompts) if x.strip()]
    gens = [json.loads(x) for x in open(a.generations) if x.strip()]
    srcs = {g.get("source") for g in gens}
    if srcs - {"file"}:
        raise SystemExit(f"{a.generations} comes from a {srcs} run, not from a prompt file")
    out, st = calibrate(prompts, gens, a.keep_missing)
    path = a.out or (a.prompts[:-6] if a.prompts.endswith(".jsonl") else a.prompts) + ".calibrated.jsonl"
    with open(path, "w") as f:
        for it in out:
            f.write(json.dumps(it, ensure_ascii=False) + "\n")
    L = st["lengths"]
    ins = [it["prompt_tokens"] for it in out if "prompt_tokens" in it]
    print(f"{len(out)} prompts -> {path}")
    print(f"  ended at EOS: {st['calibrated']}, hit the cap: {st['hit_cap']}, not run: {st['missing']}")
    if L:
        print(f"  output tokens: mean {statistics.mean(L):.0f}, median {statistics.median(L):.0f}, max {max(L)}")
        print(f"  input tokens : mean {statistics.mean(ins):.0f}, median {statistics.median(ins):.0f}, max {max(ins)}")
    if st["hit_cap"] > 0.05 * max(1, len(out)):
        print("  NOTE: many prompts hit the cap; raise max_tokens (tools/make_prompts.py --max-tokens) "
              "if you want their full answers")


if __name__ == "__main__":
    sys.exit(main())
