"""
Real vs. dummy weights on ONE GPU node: how far are Helix's dummy-weight timings from the real
model? Run on a node that holds layer 0 (it needs the embedding to feed real tokens), e.g. the
nodes with layers [0, 6) in the ilp layout (192.168.2.4 A30, 192.168.4.2 RTX6000).

    python tools/bench_real_weights.py                       # layers from the node's download
    python tools/bench_real_weights.py --layers 0 6 --weights /path/to/weights --repeats 3

Both runs use Helix's own engine exactly as llm_sys/worker.py builds it (paged KV cache, vLLM
kernels, fused_moe, gpu_memory_utilization 0.8), the same layers [0, k) chained on this GPU, and
the same REAL text tokens (prompts from public-domain books; decode steps teacher-forced with the
text's next tokens). The only difference: "dummy" keeps vLLM's random init (what Helix normally
runs), "real" loads the HF safetensors. So differences come from the data-dependent part:
MoE routing (which experts, how unbalanced) and anything numeric.

Measured (per layer, wall clock incl. Helix's per-layer Python overhead, like the profiler):
  * prompt steps of 256 .. 4096 tokens, decode steps of 1 .. 256 requests at context ~870
  * routing per MoE call: experts used, max tokens on one expert, block padding of fused_moe
  * real run only: fp16 health (finite, max |activation|), and each layer's output vs. an fp32
    CPU reference on the same input (catches fp16 overflow on Turing and loader mistakes)
Results: a comparison table, and JSON in ~/.helix/bench_real/<host>.json

Needs: a free GPU (stop the Helix workers first), the weights downloaded by
`cluster_ctl.py weights`, internet once (to fetch the book texts; or pass --text FILE).
"""
import argparse
import json
import os
import socket
import statistics
import subprocess
import sys
import time
import urllib.request

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, REPO)
sys.path.insert(0, os.path.join(REPO, "tests", "qwen3_moe"))
MODEL_DIR = os.path.join(REPO, "examples", "real_sys_qwen3", "model")
PROMPT_GRID = [256, 512, 1024, 2048, 4096]
DECODE_GRID = [1, 8, 32, 64, 128, 256]
DECODE_CONTEXT = 870                     # same as tools/profile_qwen3_moe.py
BOOKS = [1342, 2701, 1661, 98, 84, 1080, 345, 11]   # Project Gutenberg ids (public domain)
TEXT_CACHE = os.path.expanduser("~/.helix/bench_text.txt")
OUT_DIR = os.path.expanduser("~/.helix/bench_real")


# ------------------------------------------------------------------------------------------- #
def get_text(paths):
    if paths:
        return "\n".join(open(p, errors="replace").read() for p in paths)
    if os.path.exists(TEXT_CACHE) and os.path.getsize(TEXT_CACHE) > 1_000_000:
        return open(TEXT_CACHE, errors="replace").read()
    parts = []
    for b in BOOKS:
        url = f"https://www.gutenberg.org/cache/epub/{b}/pg{b}.txt"
        try:
            with urllib.request.urlopen(url, timeout=60) as r:
                parts.append(r.read().decode("utf-8", errors="replace"))
            print(f"  fetched book {b} ({len(parts[-1]) / 1e6:.1f} MB)", file=sys.stderr, flush=True)
        except Exception as e:  # noqa: BLE001
            print(f"  could not fetch {url}: {e}", file=sys.stderr)
    if sum(map(len, parts)) < 1_000_000:   # offline fallback: this repo's docs and code
        for root, _, files in os.walk(REPO):
            if "/." in root:
                continue
            for f in files:
                if f.endswith((".md", ".py")):
                    parts.append(open(os.path.join(root, f), errors="replace").read())
    text = "\n\n".join(parts)
    os.makedirs(os.path.dirname(TEXT_CACHE), exist_ok=True)
    with open(TEXT_CACHE, "w") as f:
        f.write(text)
    return text


class Corpus:
    """Hands out disjoint stretches of real token ids (wrapping around if the text runs out)."""

    def __init__(self, ids):
        self.ids, self.pos = ids, 0

    def take(self, n):
        if self.pos + n > len(self.ids):
            self.pos = 0
        out = self.ids[self.pos:self.pos + n]
        self.pos += n
        return out


# ------------------------------------------------------------------------------------------- #
def worker(mode, layers, wdir, repeats):
    import torch
    from vllm import SamplingParams
    import llm_sys.engine.llama  # noqa: F401  (same imports as llm_sys/worker.py)
    import llm_sys.engine.qwen3_moe as q
    from vllm.engine.arg_utils import EngineArgs
    from llm_sys.engine.exec_engine import PipelineStageEngine
    from llm_sys.engine.hf_weights import WeightIndex, load_stage_weights
    from tokenizers import Tokenizer

    S = layers[0]
    engine = PipelineStageEngine.from_engine_args(
        EngineArgs(model=MODEL_DIR, block_size=16, load_format="dummy", enforce_eager=True, swap_space=4,
                   max_num_batched_tokens=4096, gpu_memory_utilization=0.8), layers)
    runner = engine.model_executor.driver_worker.model_runner
    cfg = runner.models[S].config
    res = {"mode": mode, "layers": layers, "gpu": torch.cuda.get_device_name(),
           "kv_blocks": int(engine.cache_config.num_gpu_blocks)}

    if mode == "real":
        idx = WeightIndex(wdir)
        t0 = time.time()
        res["load"] = [load_stage_weights(runner.models[L], idx) for L in layers]
        print(f"  loaded real weights for layers {layers} in {time.time() - t0:.0f}s", file=sys.stderr, flush=True)
        overflow = {k: v for s in res["load"] for k, v in s["fp16_overflow"].items()}
        if overflow:
            print(f"  WARNING fp16 overflow in weights (clamped): {overflow}", file=sys.stderr)

    tok = Tokenizer.from_file(os.path.join(wdir if os.path.exists(os.path.join(wdir, "tokenizer.json"))
                                           else MODEL_DIR, "tokenizer.json"))
    corpus = Corpus(tok.encode(get_text(ARGS.text)).ids)
    res["corpus_tokens"] = len(corpus.ids)
    sp = SamplingParams(ignore_eos=True, max_tokens=100_000)
    next_rid = [1000]
    stream = {}          # rid -> remaining real tokens (teacher forcing for decode)

    def add(n, extra=0):
        rid = next_rid[0]
        next_rid[0] += 1
        ids = corpus.take(n + extra)
        stream[rid] = ids[n:]
        engine.add_request(f"{rid}", "", sp, local_layers=(S, layers[-1]), seq_id=rid, input_tensor=None,
                           prompt_token_ids=ids[:n])
        return rid

    def run_layers():
        times, out = {}, None
        for L in layers:
            torch.cuda.synchronize()
            t = time.perf_counter()
            out = engine.step(layer_id=L, finished_seq_infos=[], force_decode=False)
            torch.cuda.synchronize()
            times[L] = (time.perf_counter() - t) * 1000.0
        return times, out

    def prompt_once(total):
        sizes = [2048] * (total // 2048) + ([total % 2048] if total % 2048 else [])
        for n in sizes:
            add(n)
        times, out = run_layers()
        rows = sum(e - b for _, b, e in out[0])
        assert rows == total, f"prompt step at the last layer processed {rows} tokens, expected {total}"
        return times

    def set_next_token(rid):
        # Helix appends a placeholder token after every step; replace it with the text's next
        # token so layer 0 embeds real text during decode (teacher forcing)
        sg = engine.scheduler.seq_groups[(f"{rid}", S)]
        nxt = stream[rid].pop(0) if stream[rid] else 2
        for seq in sg.get_seqs():
            if seq.data.output_token_ids:
                seq.data.output_token_ids[-1] = nxt
            else:
                seq.data.prompt_token_ids[-1] = nxt

    def decode_once(rids):
        for r in rids:
            set_next_token(r)
            engine.scheduler.update_req_data(S, (f"{r}", S), {(r, S): None})
        times, out = run_layers()
        assert out[2] is False and len(out[0]) == len(rids), (len(rids), out[2], len(out[0]))
        return times

    def med(samples):
        return {L: statistics.median(s[L] for s in samples) for L in layers}

    # ---------------- timing ----------------
    for t in [512, 4096, 256]:          # warm-up (kernels, allocator, Triton autotune)
        prompt_once(t)
    res["prompt_ms"] = {}
    for t in PROMPT_GRID:
        res["prompt_ms"][t] = med([prompt_once(t) for _ in range(repeats)])
        print(f"  [{mode}] prompt {t:5d} tok: {statistics.mean(res['prompt_ms'][t].values()):7.2f} ms/layer",
              file=sys.stderr, flush=True)

    n_max = max(DECODE_GRID)
    rids = []
    while len(rids) < n_max:            # prefill with real text, 4 x 870 tokens per step
        batch = [add(DECODE_CONTEXT, extra=400) for _ in range(min(4, n_max - len(rids)))]
        run_layers()
        rids += batch
    for b in [1, 64, 256]:
        decode_once(rids[:b])
    res["decode_ms"] = {}
    for b in DECODE_GRID:
        res["decode_ms"][b] = med([decode_once(rids[:b]) for _ in range(repeats)])
        print(f"  [{mode}] decode {b:4d} req: {statistics.mean(res['decode_ms'][b].values()):7.2f} ms/layer",
              file=sys.stderr, flush=True)

    # ---------------- routing statistics (separate, untimed pass) ----------------
    routing, recording = [], [None]
    orig = q._fused_moe_module.moe_align_block_size

    def recorder(topk_ids, block_size, num_experts):
        if recording[0]:
            cnt = torch.bincount(topk_ids.flatten().long(), minlength=num_experts)
            padded = int(((cnt + block_size - 1) // block_size * block_size).sum())
            routing.append({"phase": recording[0], "tokens": int(topk_ids.shape[0]),
                            "experts_used": int((cnt > 0).sum()), "max_per_expert": int(cnt.max()),
                            "mean_per_used": float(cnt[cnt > 0].float().mean()),
                            "pad_ratio": padded / max(1, topk_ids.numel())})
        return orig(topk_ids, block_size, num_experts)

    q._fused_moe_module.moe_align_block_size = recorder

    # numeric health + fp32 reference per layer (real run): capture each layer's input/output
    captured = {}

    def hook(L):
        def fn(module, args, kwargs, output):
            if recording[0] == "prompt-check":
                inp = kwargs.get("hidden_states")
                if inp is None:
                    inp = module.get_input_embeddings(kwargs["input_ids"])
                captured[L] = (inp.detach().float().cpu(), output.detach().float().cpu())
        return fn

    handles = [runner.models[L].register_forward_hook(hook(L), with_kwargs=True) for L in layers]
    recording[0] = "prompt-check"
    add(256)
    run_layers()
    recording[0] = "prompt-2048"
    add(2048)
    run_layers()
    for b in (32, 128):
        recording[0] = f"decode-{b}"
        decode_once(rids[:b])
    recording[0] = None
    for h in handles:
        h.remove()
    q._fused_moe_module.moe_align_block_size = orig
    res["routing"] = routing

    from reference import layer_output

    def cpu_weights(stage):
        # like reference.extract_stage_weights, but copied to the CPU before the fp32 cast: an
        # fp32 copy of one layer's experts (2.4 GB) may not fit next to the KV cache on the GPU
        layer = stage.decoder_layer
        a_, m_ = layer.self_attn, layer.mlp
        src = {"qkv": a_.qkv_proj.weight, "o": a_.o_proj.weight, "q_norm": a_.q_norm.weight,
               "k_norm": a_.k_norm.weight, "ln1": layer.input_layernorm.weight,
               "ln2": layer.post_attention_layernorm.weight, "router": m_.gate.weight,
               "w13": m_.w13, "w2": m_.w2}
        return {k: v.detach().cpu().float() for k, v in src.items()}

    checks = []
    for L in layers:
        if L not in captured or runner.models[L].is_last_layer:
            continue
        x, got = captured[L]
        W = cpu_weights(runner.models[L])
        with torch.no_grad():
            ref = layer_output(W, x, torch.arange(x.shape[0]), num_heads=cfg.num_attention_heads,
                               num_kv_heads=cfg.num_key_value_heads, head_dim=cfg.head_dim,
                               top_k=cfg.num_experts_per_tok, norm_topk_prob=cfg.norm_topk_prob,
                               rope_theta=cfg.rope_theta, eps=cfg.rms_norm_eps)
        del W
        finite = bool(torch.isfinite(got).all())
        rel = ((got - ref).abs().max() / ref.abs().max()).item() if finite else float("inf")
        cos = torch.nn.functional.cosine_similarity(got, ref, dim=-1) if finite else torch.zeros(1)
        # a few tokens may legitimately pick a different expert in fp16 than in fp32 (near-tied
        # router scores), so judge by the mean and by how many tokens deviate, not by the minimum
        checks.append({"layer": L, "finite": finite, "max_abs": float(got.abs().max()),
                       "rel_err": rel, "min_cos": cos.min().item(), "mean_cos": cos.mean().item(),
                       "frac_tokens_cos_below_0.99": (cos < 0.99).float().mean().item()})
    res["numerics"] = checks
    return res


def run_mode(mode, layers, wdir, repeats):
    cmd = [sys.executable, os.path.abspath(__file__), "--worker", mode, "--layers", str(layers[0]),
           str(layers[-1] + 1), "--weights", wdir, "--repeats", str(repeats)]
    for t in ARGS.text or []:
        cmd += ["--text", t]
    r = subprocess.run(cmd, cwd=REPO, stdout=subprocess.PIPE, text=True)
    lines = [x for x in r.stdout.splitlines() if x.startswith("RESULT ")]
    for x in r.stdout.splitlines():
        if not x.startswith("RESULT "):
            print(x, file=sys.stderr)
    if r.returncode != 0 or not lines:
        raise SystemExit(f"{mode} run failed (exit {r.returncode}); see the output above")
    return json.loads(lines[-1][len("RESULT "):])


def mean_layers(d):
    return statistics.mean(float(v) for v in d.values())


def report(dummy, real):
    print(f"\n=== {real['gpu']}, layers {real['layers'][0]}..{real['layers'][-1]}, real text "
          f"({real['corpus_tokens']} tokens) ===")
    print(f"{'':22s}{'dummy ms/layer':>15s}{'real ms/layer':>15s}{'real/dummy':>12s}")
    rows = []
    for kind, grid in [("prompt", PROMPT_GRID), ("decode", DECODE_GRID)]:
        for x in grid:
            dm = mean_layers(dummy[f"{kind}_ms"][str(x)])
            rm = mean_layers(real[f"{kind}_ms"][str(x)])
            rows.append((kind, x, dm, rm))
            unit = "tokens" if kind == "prompt" else "requests"
            print(f"  {kind} {x:5d} {unit:9s}{dm:12.2f}{rm:15.2f}{rm / dm:12.2f}x")
    print("\nMoE routing per layer call (mean over layers):")
    print(f"  {'':16s}{'experts used':>26s}{'max tok/expert':>22s}{'fused_moe padding':>22s}")
    print(f"  {'':16s}{'dummy':>13s}{'real':>13s}{'dummy':>11s}{'real':>11s}{'dummy':>11s}{'real':>11s}")
    for phase in ["prompt-2048", "decode-32", "decode-128"]:
        def avg(r, k):
            xs = [x[k] for x in r["routing"] if x["phase"] == phase]
            return statistics.mean(xs) if xs else float("nan")
        print(f"  {phase:16s}{avg(dummy, 'experts_used'):13.1f}{avg(real, 'experts_used'):13.1f}"
              f"{avg(dummy, 'max_per_expert'):11.1f}{avg(real, 'max_per_expert'):11.1f}"
              f"{avg(dummy, 'pad_ratio'):10.2f}x{avg(real, 'pad_ratio'):10.2f}x")
    print("\nReal weights, fp16 health and per-layer check against an fp32 CPU reference:")
    for c in real["numerics"]:
        low = c["frac_tokens_cos_below_0.99"]
        good = c["finite"] and c["mean_cos"] > 0.999 and low < 0.02
        print(f"  {'ok ' if good else 'BAD'} layer {c['layer']:2d}: finite={c['finite']}, max|x|={c['max_abs']:9.1f}, "
              f"mean_cos={c['mean_cos']:.5f}, min_cos={c['min_cos']:.4f}, tokens off (<0.99): {100 * low:.1f}%")
    overflow = {k: v for s in real.get("load", []) for k, v in s["fp16_overflow"].items()}
    print(f"  weights beyond fp16 range: {overflow or 'none'}")
    p = [r for r in rows if r[0] == "prompt"]
    d = [r for r in rows if r[0] == "decode"]
    print(f"\nsummary: prompt real/dummy {statistics.mean(r[3] / r[2] for r in p):.2f}x, "
          f"decode real/dummy {statistics.mean(r[3] / r[2] for r in d):.2f}x (mean over the grid)")


def main():
    global ARGS
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--weights", default=None, help="weights dir (default: cluster.json weights.dir)")
    ap.add_argument("--layers", nargs=2, type=int, default=None, metavar=("START", "END"),
                    help="layers [START, END) to chain on this GPU; START must be 0 (default: this "
                         "node's downloaded range, capped at 6 layers)")
    ap.add_argument("--repeats", type=int, default=3)
    ap.add_argument("--text", action="append", help="text file(s) to take tokens from")
    ap.add_argument("--only", choices=["real", "dummy"], help="run one mode only (debugging)")
    ap.add_argument("--worker", default=None, help=argparse.SUPPRESS)
    ARGS = ap.parse_args()
    from llm_sys.engine.hf_weights import default_weights_dir
    wdir = os.path.expanduser(ARGS.weights) if ARGS.weights else default_weights_dir(REPO)

    if ARGS.layers is None:
        man = os.path.join(wdir, ".helix_weights.json")
        rng = json.load(open(man)).get("layers") if os.path.exists(man) else None
        if not rng:
            raise SystemExit(f"cannot tell which layers {wdir} holds: pass --layers 0 K")
        s, e = rng[0]
        ARGS.layers = [s, min(e, s + 6)]
    s, e = ARGS.layers
    if s != 0:
        raise SystemExit(f"layers start at {s}: real routing needs real inputs, i.e. layer 0 (the "
                         f"embedding). Run this on a node that downloaded layers [0, k).")
    layers = list(range(s, e))

    if ARGS.worker:
        import torch
        with torch.no_grad():
            res = worker(ARGS.worker, layers, wdir, ARGS.repeats)
        print("RESULT " + json.dumps(res), flush=True)
        return

    print(f"[bench] {socket.gethostname()}: layers {layers}, weights {wdir}", flush=True)
    get_text(ARGS.text)    # fetch once, before the GPU runs
    results = {}
    for mode in ([ARGS.only] if ARGS.only else ["dummy", "real"]):
        print(f"[bench] {mode} weights ...", flush=True)
        results[mode] = run_mode(mode, layers, wdir, ARGS.repeats)
    os.makedirs(OUT_DIR, exist_ok=True)
    out = os.path.join(OUT_DIR, f"{socket.gethostname()}.json")
    with open(out, "w") as f:
        json.dump(results, f, indent=1)
    if len(results) == 2:
        report(results["dummy"], results["real"])
    print(f"\nraw results: {out}")


ARGS = None
if __name__ == "__main__":
    main()
