"""
CPU tests for real generation bookkeeping, no GPU / vLLM / ZeroMQ needed:
  * llm_sys/real_tokens.py: prompt sources, token feedback, EOS cut, generations.jsonl,
    and that real=False reproduces Helix's placeholder tokens exactly
  * llm_sys/worker.py helpers: the first stage embeds the token the host sent back, the last
    stage reports the token it sampled

    python tests/qwen3_moe/test_real_tokens.py
"""
import json
import os
import sys
import tempfile
import types

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, REPO)
from llm_sys.real_tokens import (FilePromptSource, RandomPromptSource, TokenIO,  # noqa: E402
                                 QWEN_FIRST_SPECIAL_ID)


class FakeTok:
    """word-level stand-in for a tokenizers.Tokenizer"""
    def __init__(self):
        self.vocab = {}

    def encode(self, text):
        ids = [self.vocab.setdefault(w, len(self.vocab) + 10) for w in text.split()]
        return types.SimpleNamespace(ids=ids)

    def decode(self, ids, skip_special_tokens=False):
        inv = {v: k for k, v in self.vocab.items()}
        return " ".join(inv.get(i, f"<{i}>") for i in ids)


def check(cond, msg):
    print(f"  {'ok ' if cond else 'BAD'} {msg}")
    return bool(cond)


def simulate_host(tio, n_queries, lengths, model_next_token):
    """the token flow of llm_sys/maxflow_host.py: prompt -> first token -> decode ... -> finish"""
    sent = {}          # qid -> list of token lists given to the first stage, in order
    for qid in range(n_queries):
        ids, i, o = tio.make_prompt(qid, *lengths[qid])
        sent[qid] = [ids]
        context = list(ids)
        produced = 0
        while True:
            tok = model_next_token(context)            # last stage samples
            tio.on_token(qid, tok)
            produced += 1
            if produced == o:                           # processed == input + output
                tio.finish(qid)
                break
            nxt = tio.decode_input(qid)                 # host -> first stage
            sent[qid].append(nxt)
            context.append(nxt[0])
    return sent


def main():
    ok = True
    print("dummy mode (real=False) = original Helix")
    tio = TokenIO(real=False)
    ids, i, o = tio.make_prompt(5, 7, 3)
    ok &= check(ids == list(range(7)) and (i, o) == (7, 3), "prompt tokens are [0..n), lengths unchanged")
    sent = simulate_host(tio, 2, {0: (4, 3), 1: (2, 2)}, lambda ctx: 123)
    ok &= check(all(s == [-1] for q in sent for s in sent[q][1:]), "every decode step sends [-1]")
    ok &= check(tio.save(tempfile.mkdtemp()) is None, "nothing saved")

    print("real mode, random prompts")
    src = RandomPromptSource(seed=1)
    a1, _, _, _ = src.make(3, 50, 10)
    a2, _, _, _ = src.make(3, 50, 10)
    b, _, _, _ = src.make(4, 50, 10)
    ok &= check(a1 == a2 and a1 != b, "same qid -> same prompt (retries after a scheduling miss), "
                                      "different qid -> different prompt")
    ok &= check(all(0 <= t < QWEN_FIRST_SPECIAL_ID for t in a1), "no special tokens in random prompts")
    tok = FakeTok()
    tio = TokenIO(real=True, source=src, tokenizer=tok, eos=(7,))
    # toy "model": next token = (last token * 31 + 3) % 1000, and EOS (7) after 4 steps for q1
    steps = {}

    def model(ctx):
        steps[id(ctx)] = steps.get(id(ctx), 0) + 1
        return (ctx[-1] * 31 + 3) % 1000

    sent = simulate_host(tio, 2, {0: (5, 4), 1: (6, 3)}, model)
    gen0 = tio.generated[0]
    ok &= check([s[0] for s in sent[0][1:]] == gen0[:-1],
                "each decode step feeds the token generated in the previous step")
    ok &= check(len(gen0) == 4 and len(tio.generated[1]) == 3, "one token per prompt/decode result")
    d = tempfile.mkdtemp()
    tio.on_token(1, 0)                                     # (ignored: query 1 already finished)
    tio.generated[1][1] = 7                                # put an EOS in the middle
    path = tio.save(d)
    recs = [json.loads(x) for x in open(path)]
    ok &= check(len(recs) == 2 and recs[0]["finished"] and recs[0]["output_token_ids"] == gen0,
                "generations.jsonl has prompt + generated tokens")
    ok &= check(recs[1]["eos_at"] == 1 and recs[1]["output_text"].count(" ") == 0,
                "text is cut at the first EOS")

    print("real mode, prompt file")
    d = tempfile.mkdtemp()
    f = os.path.join(d, "p.jsonl")
    with open(f, "w") as fh:
        fh.write(json.dumps({"prompt": "hello world how are you", "max_tokens": 5}) + "\n")
        fh.write(json.dumps({"messages": [{"role": "user", "content": "what is Helix"}]}) + "\n")
        fh.write("\n")
        fh.write(json.dumps({"prompt": " ".join(f"w{k}" for k in range(50)), "max_tokens": 4000}) + "\n")
    src = FilePromptSource(f, tok, max_input=20, max_total=30)
    ids, i, o, info = src.make(0, 999, 999)
    ok &= check(i == 5 and o == 5 and info["prompt_index"] == 0, "lengths come from the prompt and max_tokens")
    ids, i, o, _ = src.make(1, 999, 77)
    text = tok.decode(ids)
    ok &= check("<|im_start|>user" in text and text.rstrip().endswith("assistant") and o == 30 - i,
                "messages are wrapped in the chat template; trace output length capped to max_total")
    ids, i, o, _ = src.make(2, 999, 999)
    ok &= check(i == 20 and o == 10 and tok.decode(ids).split()[-1] == "w49",
                "long prompts keep their last max_input tokens; prompt + output <= max_total")
    ok &= check(src.make(3, 1, 1)[3]["prompt_index"] == 0, "query k uses line k % N")

    print("worker helpers")
    try:
        import llm_sys.worker as w  # needs llm_worker / torch / vllm: only on the cluster
        sampled, set_tok = w._sampled_token, w._set_input_token
    except Exception:  # noqa: BLE001
        src_txt = open(os.path.join(REPO, "llm_sys", "worker.py")).read()
        ns = {}
        start = src_txt.index("def _sampled_token")
        end = src_txt.index("def load_real_weights")
        exec(src_txt[start:end], ns)
        sampled, set_tok = ns["_sampled_token"], ns["_set_input_token"]
    ro = types.SimpleNamespace(outputs=[types.SimpleNamespace(token_ids=[11, 22, 33])])
    ok &= check(sampled(ro) == 33, "last stage reports the token it sampled")
    ok &= check(sampled(types.SimpleNamespace(outputs=[])) == 1, "falls back to the old placeholder")
    seq = types.SimpleNamespace(data=types.SimpleNamespace(output_token_ids=[5, 2]))
    group = types.SimpleNamespace(get_seqs=lambda: [seq])
    eng = types.SimpleNamespace(scheduler=types.SimpleNamespace(seq_groups={("42", 0): group}))
    set_tok(eng, 0, 42, 999)
    ok &= check(seq.data.output_token_ids == [5, 999], "first stage replaces the placeholder with the real token")

    print("ALL REAL-TOKEN TESTS PASSED" if ok else "FAILED")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
