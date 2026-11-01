"""
Host-side token bookkeeping for REAL generation (Qwen3 with real weights, greedy decoding).

Helix's prototype sends placeholder tokens: prompts are [0, 1, ..., n-1] and every decode step
feeds token -1 (the worker then embeds a constant). With TokenIO(real=True) the host instead
  * builds each prompt from a pluggable PromptSource (random token ids now; a JSONL file of
    texts later),
  * remembers the token the last pipeline stage sampled for every request and feeds it to the
    first stage in the next decode step,
  * writes every request's prompt and generated tokens/text to <result_dir>/generations.jsonl.
Request lengths keep coming from the workload trace (Azure-Conversation lengths), so the
scheduler, the KV accounting and the throughput numbers mean the same as in dummy runs; with
a file source the prompt's real length is used instead. Generation always runs to the planned
output length (workers free a request's KV cache only there); the saved text is cut at the
first EOS token.

TokenIO(real=False) reproduces the original behaviour exactly.
Only needs the `tokenizers` package (no torch / vLLM).
"""
import json
import os
import random
from typing import Dict, List, Optional, Tuple

QWEN_FIRST_SPECIAL_ID = 151643          # ids >= this are special tokens in Qwen2/3 vocabularies
DEFAULT_EOS_IDS = (151643, 151645)      # <|endoftext|>, <|im_end|>


def load_tokenizer(weights_dir: str):
    """The checkpoint's real tokenizer.json. Recent files store BPE merges as [a, b] pairs, which
    the `tokenizers` version pinned with transformers 4.40 cannot parse: converted in memory.
    (examples/real_sys_qwen3/model/tokenizer.json is a placeholder and is never used here.)"""
    from tokenizers import Tokenizer
    p = os.path.join(weights_dir, "tokenizer.json")
    if not os.path.exists(p):
        raise SystemExit(f"{p} not found: run cluster_ctl.py weights (it downloads the tokenizer)")
    try:
        tok = Tokenizer.from_file(p)
    except Exception:  # noqa: BLE001
        obj = json.load(open(p))
        merges = obj.get("model", {}).get("merges", [])
        if merges and isinstance(merges[0], list):
            obj["model"]["merges"] = [" ".join(m) for m in merges]
        obj["model"].pop("ignore_merges", None)
        tok = Tokenizer.from_str(json.dumps(obj))
    ids = tok.encode("The quick brown fox jumps over the lazy dog.").ids
    if len(set(ids)) < 5:
        raise SystemExit(f"{p} does not look like a real tokenizer (test sentence -> {ids})")
    return tok


def eos_ids(weights_dir: Optional[str]) -> Tuple[int, ...]:
    ids = set(DEFAULT_EOS_IDS)
    if weights_dir:
        for name in ("generation_config.json", "config.json"):
            p = os.path.join(weights_dir, name)
            if os.path.exists(p):
                e = json.load(open(p)).get("eos_token_id")
                ids.update(e if isinstance(e, list) else [e] if isinstance(e, int) else [])
    return tuple(sorted(ids))


# ------------------------------------------------------------------------------------------- #
class PromptSource:
    """Interface: prompt for query `qid`, given the lengths the trace sampled for it.
    Must be a pure function of its arguments: the host may ask again for the same qid when the
    scheduler could not place the request the first time."""
    name = "base"

    def make(self, qid: int, input_len: int, output_len: int) -> Tuple[List[int], int, int, dict]:
        """-> (prompt token ids, input_len, output_len, extra info saved with the generation)"""
        raise NotImplementedError


class RandomPromptSource(PromptSource):
    """Random non-special token ids, with exactly the trace's lengths (reproducible per qid)."""
    name = "random"

    def __init__(self, seed: int = 0, vocab_limit: int = QWEN_FIRST_SPECIAL_ID):
        self.seed, self.vocab_limit = seed, vocab_limit

    def make(self, qid, input_len, output_len):
        rng = random.Random(self.seed * 1_000_003 + qid)
        return [rng.randrange(self.vocab_limit) for _ in range(input_len)], input_len, output_len, {}


class FilePromptSource(PromptSource):
    """JSONL, one prompt per line: {"prompt": "text"} or {"messages": [{"role":..,"content":..}]},
    optional "max_tokens". Query k gets line k % N. "messages" (and "chat": true with "prompt")
    are wrapped in Qwen's chat template. Lengths are the prompt's real length (the last
    max_input tokens if longer) and "max_tokens" (else the trace's output length), capped so
    that prompt + output <= max_total."""
    name = "file"

    def __init__(self, path: str, tokenizer, max_input: int = 2048, max_total: int = 4096):
        self.path = path
        self.items = [json.loads(line) for line in open(path) if line.strip()]
        if not self.items:
            raise SystemExit(f"{path}: no prompts")
        self.tok, self.max_input, self.max_total = tokenizer, max_input, max_total
        self._cache: Dict[int, List[int]] = {}

    @staticmethod
    def chat_text(messages) -> str:
        out = "".join(f"<|im_start|>{m['role']}\n{m['content']}<|im_end|>\n" for m in messages)
        return out + "<|im_start|>assistant\n"

    def _ids(self, k):
        if k not in self._cache:
            it = self.items[k]
            if "messages" in it:
                text = self.chat_text(it["messages"])
            elif it.get("chat"):
                text = self.chat_text([{"role": "user", "content": it["prompt"]}])
            else:
                text = it["prompt"]
            self._cache[k] = self.tok.encode(text).ids[-self.max_input:]
        return self._cache[k]

    def make(self, qid, input_len, output_len):
        k = qid % len(self.items)
        ids = self._ids(k)
        out = int(self.items[k].get("max_tokens", output_len))
        out = max(1, min(out, self.max_total - len(ids)))
        return list(ids), len(ids), out, {"prompt_index": k}


# ------------------------------------------------------------------------------------------- #
class TokenIO:
    def __init__(self, real: bool = False, source: Optional[PromptSource] = None, tokenizer=None,
                 eos: Tuple[int, ...] = DEFAULT_EOS_IDS):
        self.real = real
        self.source = source if source is not None else RandomPromptSource()
        self.tok = tokenizer
        self.eos = set(eos)
        self.prompts: Dict[int, List[int]] = {}
        self.info: Dict[int, dict] = {}
        self.generated: Dict[int, List[int]] = {}
        self.finished: Dict[int, bool] = {}

    def make_prompt(self, qid: int, input_len: int, output_len: int) -> Tuple[List[int], int, int]:
        if not self.real:
            return list(range(input_len)), input_len, output_len      # original Helix
        ids, i, o, info = self.source.make(qid, input_len, output_len)
        self.prompts[qid], self.info[qid] = ids, {**info, "output_len": o}
        return ids, i, o

    def on_token(self, qid: int, token: int) -> None:
        """a result came back from the last stage (after the prompt or a decode step)"""
        if self.real:
            self.generated.setdefault(qid, []).append(int(token))

    def decode_input(self, qid: int) -> List[int]:
        if not self.real:
            return [-1]                                                # original Helix
        return [self.generated[qid][-1]]

    def finish(self, qid: int) -> None:
        if self.real:
            self.finished[qid] = True

    def save(self, result_dir: str) -> Optional[str]:
        if not self.real:
            return None
        path = os.path.join(result_dir, "generations.jsonl")
        with open(path, "w") as f:
            for qid in sorted(self.prompts):
                gen = self.generated.get(qid, [])
                cut = next((i for i, t in enumerate(gen) if t in self.eos), None)
                rec = {"query_id": qid, "finished": self.finished.get(qid, False),
                       "source": self.source.name, **self.info.get(qid, {}),
                       "input_len": len(self.prompts[qid]), "generated_len": len(gen),
                       "eos_at": cut, "prompt_token_ids": self.prompts[qid], "output_token_ids": gen}
                if self.tok is not None:
                    rec["prompt_text"] = self.tok.decode(self.prompts[qid], skip_special_tokens=False)
                    rec["output_text"] = self.tok.decode(gen[:cut] if cut is not None else gen,
                                                         skip_special_tokens=False)
                f.write(json.dumps(rec, ensure_ascii=False) + "\n")
        return path


def make_token_io(real: bool, prompts: str, weights_dir: Optional[str], seed: int = 0) -> TokenIO:
    """prompts: "random" or a path to a JSONL file (see FilePromptSource)."""
    if not real:
        return TokenIO(real=False)
    tok = load_tokenizer(weights_dir)
    source = RandomPromptSource(seed=seed) if prompts == "random" else FilePromptSource(prompts, tok)
    return TokenIO(real=True, source=source, tokenizer=tok, eos=eos_ids(weights_dir))
