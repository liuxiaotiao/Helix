"""
CPU tests for dataset prompts (tools/make_prompts.py) and length calibration
(tools/calibrate_lengths.py); the Hugging Face dataset viewer API is mocked.

    python tests/qwen3_moe/test_dataset_prompts.py
"""
import importlib.util
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))


def load(name):
    spec = importlib.util.spec_from_file_location(name, os.path.join(REPO, "tools", f"{name}.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def check(cond, msg):
    print(f"  {'ok ' if cond else 'BAD'} {msg}")
    return bool(cond)


def main():
    mp, cal = load("make_prompts"), load("calibrate_lengths")
    ok = True

    print("prompt builders")
    g = mp.gsm8k_item({"question": "Tom has 3 apples. ", "answer": "#### 3"}, 0, False, 512)
    u = g["messages"][-1]["content"]
    ok &= check(g["messages"][0]["role"] == "user" and "\\boxed{}" in u and u.endswith("/no_think")
                and g["max_tokens"] == 512, "gsm8k: question + boxed instruction, thinking off")
    m = mp.mbpp_item({"task_id": 11, "text": "Write a function to add.", "test_list": ["assert add(1,2)==3",
                                                                                   "assert add(0,0)==0"]}, 0, True, 256)
    u = m["messages"][-1]["content"]
    ok &= check(m["id"] == "mbpp-11" and "assert add(0,0)==0" in u and not u.endswith("/no_think"),
                "mbpp: task + tests (--think keeps thinking on)")
    conv = {"prompt_id": "p1", "category": "Chat", "messages": [
        {"role": "system", "content": "Be brief."}, {"role": "user", "content": "Hi"},
        {"role": "assistant", "content": "Hello!"}, {"role": "user", "content": "Tell a joke"},
        {"role": "assistant", "content": "No."}]}
    n = mp.no_robots_item(conv, 0, False, 1024)
    ok &= check([x["role"] for x in n["messages"]] == ["system", "user", "assistant", "user"]
                and n["messages"][-1]["content"].endswith("/no_think") and n["reference"] == "No.",
                "no_robots: conversation up to the last user turn; its answer kept as reference")
    ok &= check(mp.no_robots_item({"messages": [{"role": "system", "content": "x"}]}, 0, False, 9) is None,
                "no_robots: conversations without a user turn are skipped")

    print("dataset viewer API (mocked): split choice and paging")
    calls = []

    def fake_get(path, params, retries=6):
        calls.append((path, dict(params)))
        if path == "splits":
            return {"splits": [{"dataset": params["dataset"], "config": "default", "split": s}
                               for s in ("train_sft", "test_sft")]}
        total, off, n = 250, params["offset"], params["length"]
        return {"num_rows_total": total, "rows": [{"row_idx": i, "row": {"i": i}}
                                                  for i in range(off, min(total, off + n))]}
    mp._get = fake_get
    ok &= check(mp.pick_split("HuggingFaceH4/no_robots", "default", ["test", "test_sft"]) == "test_sft",
                "older no_robots split names (test_sft) are found")
    rows = mp.fetch_rows("x", "default", "test_sft")
    ok &= check([r["i"] for r in rows] == list(range(250)) and len([c for c in calls if c[0] == "rows"]) == 3,
                "all 250 rows in pages of 100")
    ok &= check(len(mp.fetch_rows("x", "default", "test_sft", limit=120)) == 120, "--limit")

    print("length calibration")
    prompts = [{"id": f"q{k}", "messages": [{"role": "user", "content": "x"}], "max_tokens": 100} for k in range(4)]
    gens = [{"prompt_index": 0, "finished": True, "eos_at": 41, "generated_len": 100, "input_len": 30, "source": "file"},
            {"prompt_index": 1, "finished": True, "eos_at": None, "generated_len": 100, "input_len": 20, "source": "file"},
            {"prompt_index": 2, "finished": False, "eos_at": 5, "generated_len": 7, "input_len": 10, "source": "file"}]
    out, st = cal.calibrate(prompts, gens)
    ok &= check(out[0]["max_tokens"] == 42 and out[0]["natural_length"], "EOS at index 41 -> 42 output tokens")
    ok &= check(out[1]["max_tokens"] == 100 and out[1]["hit_cap"], "no EOS within the cap -> keeps the cap")
    ok &= check(len(out) == 2 and st["missing"] == 2, "unfinished / not-run prompts dropped")
    out, st = cal.calibrate(prompts, gens, keep_missing=True)
    ok &= check(len(out) == 4 and out[3]["max_tokens"] == 100, "--keep-missing keeps them with the cap")

    print("ALL DATASET-PROMPT TESTS PASSED" if ok else "FAILED")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
