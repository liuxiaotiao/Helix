"""
Build prompt files for real-generation runs (step2_start_host.py --real --prompts FILE) from
public datasets, via the Hugging Face dataset viewer API (no `datasets` package needed):

    python tools/make_prompts.py                          # gsm8k, mbpp, no_robots + mix
    python tools/make_prompts.py --datasets gsm8k --limit 300 --think

Writes <out-dir>/{gsm8k,mbpp,no_robots,mix}.jsonl (default examples/real_sys_qwen3/prompts/),
one request per line in llm_sys/real_tokens.py's FilePromptSource format:
    {"dataset": "gsm8k", "id": "...", "messages": [{"role": "user", "content": "..."}], "max_tokens": 1024}

  gsm8k      openai/gsm8k (main, test, 1319): the question + "reason step by step, put the final
             answer within \\boxed{}" (Qwen's math prompt)
  mbpp       google-research-datasets/mbpp (full, test): the task + its assert tests, in the
             MBPP paper's prompt
  no_robots  HuggingFaceH4/no_robots (test): the conversation up to its last user turn
             (system / earlier turns kept)
  mix        all of the above, shuffled together

Qwen3's thinking mode is switched off ("/no_think" appended to the last user turn) unless
--think: thinking traces run to thousands of tokens and do not fit Helix's 4096-token context.
max_tokens is only a cap here; see tools/calibrate_lengths.py for the real output lengths.
"""
import argparse
import json
import os
import random
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

API = os.environ.get("HF_DATASETS_SERVER", "https://datasets-server.huggingface.co")
REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
DEFAULT_OUT = os.path.join(REPO, "examples", "real_sys_qwen3", "prompts")

DATASETS = {
    #  name        hf dataset id                        config     preferred splits
    "gsm8k": ("openai/gsm8k", "main", ["test"]),
    "mbpp": ("google-research-datasets/mbpp", "full", ["test"]),
    "no_robots": ("HuggingFaceH4/no_robots", "default", ["test", "test_sft"]),
}


def _get(path, params, retries=6):
    url = f"{API}/{path}?{urllib.parse.urlencode(params)}"
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "helix-prompts"}),
                                        timeout=60) as r:
                return json.loads(r.read().decode())
        except urllib.error.HTTPError as e:
            if e.code in (429, 500, 502, 503, 504) and attempt < retries - 1:
                time.sleep(5 * (attempt + 1))
                continue
            raise SystemExit(f"{url}: HTTP {e.code} {e.read()[:200]!r}")
        except urllib.error.URLError as e:
            if attempt < retries - 1:
                time.sleep(5 * (attempt + 1))
                continue
            raise SystemExit(f"{url}: {e} (no internet? set HF_DATASETS_SERVER to a mirror)")


def pick_split(dataset, config, preferred, split=None):
    have = [s["split"] for s in _get("splits", {"dataset": dataset})["splits"] if s["config"] == config]
    if split:
        if split not in have:
            raise SystemExit(f"{dataset}/{config} has splits {have}, not {split!r}")
        return split
    for s in preferred:
        if s in have:
            return s
    raise SystemExit(f"{dataset}/{config}: none of {preferred} in {have}; pass --split")


def fetch_rows(dataset, config, split, limit=None):
    rows, offset, total = [], 0, None
    while total is None or offset < total:
        n = 100 if limit is None else min(100, limit - len(rows))
        if n <= 0:
            break
        page = _get("rows", {"dataset": dataset, "config": config, "split": split, "offset": offset, "length": n})
        total = page["num_rows_total"]
        rows += [r["row"] for r in page["rows"]]
        if not page["rows"]:
            break
        offset += len(page["rows"])
    return rows


# ---------------------------------------------------------------------------------------------- #
def _no_think(messages, think):
    if not think:
        last = max(i for i, m in enumerate(messages) if m["role"] == "user")
        messages[last] = {**messages[last], "content": messages[last]["content"].rstrip() + " /no_think"}
    return messages


def gsm8k_item(row, i, think, max_tokens):
    q = row["question"].strip()
    content = f"{q}\nPlease reason step by step, and put your final answer within \\boxed{{}}."
    return {"dataset": "gsm8k", "id": f"gsm8k-{i}", "reference": row.get("answer"),
            "messages": _no_think([{"role": "user", "content": content}], think), "max_tokens": max_tokens}


def mbpp_item(row, i, think, max_tokens):
    tests = "\n".join(row.get("test_list") or [])
    content = (f"You are an expert Python programmer, and here is your task: {row['text'].strip()} "
               f"Your code should pass these tests:\n\n{tests}\n")
    return {"dataset": "mbpp", "id": f"mbpp-{row.get('task_id', i)}", "reference": row.get("code"),
            "messages": _no_think([{"role": "user", "content": content}], think), "max_tokens": max_tokens}


def no_robots_item(row, i, think, max_tokens):
    msgs = [{"role": m["role"], "content": m["content"]} for m in row["messages"]]
    users = [k for k, m in enumerate(msgs) if m["role"] == "user"]
    if not users:
        return None
    msgs = msgs[:users[-1] + 1]                     # up to (incl.) the last user turn
    reference = next((m["content"] for m in row["messages"][users[-1] + 1:] if m["role"] == "assistant"), None)
    return {"dataset": "no_robots", "id": f"no_robots-{row.get('prompt_id', i)}", "category": row.get("category"),
            "reference": reference, "messages": _no_think(msgs, think), "max_tokens": max_tokens}


BUILDERS = {"gsm8k": gsm8k_item, "mbpp": mbpp_item, "no_robots": no_robots_item}


def build(name, rows, think, max_tokens):
    items = [BUILDERS[name](r, i, think, max_tokens) for i, r in enumerate(rows)]
    return [it for it in items if it is not None]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--datasets", nargs="+", default=list(DATASETS), choices=list(DATASETS))
    ap.add_argument("--split", default=None, help="override the split (same for every dataset given)")
    ap.add_argument("--limit", type=int, default=None, help="at most this many prompts per dataset")
    ap.add_argument("--max-tokens", type=int, default=1024, help="output cap per request")
    ap.add_argument("--think", action="store_true", help="keep Qwen3's thinking mode on")
    ap.add_argument("--seed", type=int, default=0, help="shuffle seed (each file and the mix)")
    ap.add_argument("--out-dir", default=DEFAULT_OUT)
    a = ap.parse_args()

    os.makedirs(a.out_dir, exist_ok=True)
    everything = []
    for name in a.datasets:
        ds, config, preferred = DATASETS[name]
        split = pick_split(ds, config, preferred, a.split)
        rows = fetch_rows(ds, config, split, a.limit)
        items = build(name, rows, a.think, a.max_tokens)
        random.Random(a.seed).shuffle(items)
        path = os.path.join(a.out_dir, f"{name}.jsonl")
        with open(path, "w") as f:
            for it in items:
                f.write(json.dumps(it, ensure_ascii=False) + "\n")
        print(f"{name:10s} {ds}/{config}/{split}: {len(items)} prompts -> {path}")
        everything += items
    if len(a.datasets) > 1:
        random.Random(a.seed + 1).shuffle(everything)
        path = os.path.join(a.out_dir, "mix.jsonl")
        with open(path, "w") as f:
            for it in everything:
                f.write(json.dumps(it, ensure_ascii=False) + "\n")
        print(f"{'mix':10s} {len(everything)} prompts -> {path}")
    print("next: calibrate output lengths, see tools/calibrate_lengths.py")


if __name__ == "__main__":
    sys.exit(main())
