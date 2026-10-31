"""
Profile Qwen3-30B-A3B on ONE GPU with Helix's own runtime engine and write the profile directory
that the simulator / MILP planner reads (simulator/model_manager/qwen3_30b_a3b/).

    python tools/profile_qwen3_moe.py --machine L4            # on an L4 machine
    python tools/profile_qwen3_moe.py --machine A100 --out <dir>

Output: <out>/<MACHINE>/{prompt_bs2time.csv, decode_bs2time.csv, meta.json}

What is measured (all with llm_sys/engine exactly as llm_sys/worker.py builds it: dummy weights,
block_size 16, enforce_eager, max_num_batched_tokens 4096, gpu_memory_utilization 0.8):
  1. per-layer prompt time vs. #prompt tokens in the batch   (single-layer engine)
  2. per-layer decode time vs. #decode requests in the batch (context ~= dataset average)
  3. Helix's unified KV page pool size when k layers are loaded, for k = 1, middle, max
     (linear fit for the other k; the fit is checked against the middle point). Layers [0, k)
     are loaded, so the embedding is included and the pool size is conservative.
Each measurement runs in its own subprocess because vLLM 0.4.0 can only initialise once
per process. Times include Helix's per-layer Python/scheduling overhead, as in the real system.

Requires: a GPU, vllm==0.4.0.post1, transformers==4.40.2, this repo (no ZeroMQ needed).
"""
import argparse
import datetime
import json
import os
import statistics
import subprocess
import sys
import time

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, REPO)
MODEL_DIR = os.path.join(REPO, "examples", "real_sys_qwen3", "model")
DEFAULT_OUT = os.path.join(REPO, "simulator", "model_manager", "qwen3_30b_a3b", "profiles")

# Nominal VRAM per Helix machine type, same values as the machine-profile .ini files (GB=1e9).
# Helix keeps half of VRAM for parameters (asserted in ilp_layout.py), which bounds #layers.
NOMINAL_VRAM_GB = {"T4": 16, "V100": 16, "L4": 24, "A100": 40, "A100-80G": 80, "H100": 80,
                   "L40S": 48, "A10G": 24, "A30": 24,
                   "RTX6000": 24,     # Quadro RTX 6000 (Turing, 24 GB) -- not the RTX A6000
                   "A6000": 48}       # RTX A6000 (Ampere, 48 GB)

# Engine limits of llm_sys/worker.py:init_engine -> batch limits the simulator may use.
ENGINE_MAX_BATCHED_TOKENS = 4096        # -> prompt_max_requests = 4096 // MAX_INPUT_LEN = 2
ENGINE_MAX_NUM_SEQS = 256               # vLLM 0.4.0 default -> decode_max_tokens = 256
BLOCK_SIZE = 16
PROMPT_GRID = [16, 32, 64, 128, 256, 384, 512, 768, 1024, 1536, 2048, 2560, 3072, 3584, 4096]
DECODE_GRID = [1, 2, 4, 8, 16, 24, 32, 48, 64, 96, 128, 160, 192, 224, 256]
DECODE_CONTEXT = 750 + 240 // 2         # AVG_INPUT_LEN + AVG_OUTPUT_LEN / 2 (simulator utils)
TIMING_LAYER = 23                       # a middle layer: no embedding / lm_head


# ------------------------------------------------------------------------------------------- #
#                         pure-python helpers (unit-tested without a GPU)                      #
# ------------------------------------------------------------------------------------------- #
def max_layers_for(machine: str, layer_param_bytes: int, vram_gb: float = None) -> int:
    vram = (vram_gb if vram_gb is not None else NOMINAL_VRAM_GB[machine]) * 1e9
    return int((vram / 2) // layer_param_bytes)


def fit_kv_blocks(points: dict, max_layers: int, tolerance: float = 0.03) -> dict:
    """points: {k: total_pool_blocks}. Linear fit through the smallest and largest k, checked
    against every other measured point. Returns {k: blocks} for k = 1..max_layers."""
    ks = sorted(points)
    k0, k1 = ks[0], ks[-1]
    slope = (points[k1] - points[k0]) / (k1 - k0) if k1 != k0 else 0.0
    fit = {k: int(points[k0] + slope * (k - k0)) for k in range(1, max_layers + 1)}
    for k in ks:
        err = abs(fit[k] - points[k]) / max(1, points[k])
        if err > tolerance:
            raise RuntimeError(f"KV pool size is not linear in #layers (k={k}: measured "
                               f"{points[k]}, fit {fit[k]}); rerun with --kv-all")
        fit[k] = points[k]  # keep exact measurements where we have them
    return fit


def write_profile(out_dir: str, machine: str, prompt_ms: dict, decode_ms: dict,
                  kv_blocks: dict, max_layers: int, extra_meta: dict,
                  prompt_max_requests: int = ENGINE_MAX_BATCHED_TOKENS // 2048,
                  decode_max_tokens: int = ENGINE_MAX_NUM_SEQS, placeholder: bool = False) -> str:
    d = os.path.join(out_dir, machine)
    os.makedirs(d, exist_ok=True)
    for name, table in [("prompt_bs2time.csv", prompt_ms), ("decode_bs2time.csv", decode_ms)]:
        table = {int(k): float(v) for k, v in table.items()}   # JSON round-trip gives str keys
        table[0] = 0.0
        with open(os.path.join(d, name), "w") as f:
            for bs in sorted(table):
                f.write(f"{int(bs)},{table[bs]:.4f}\n")
    meta = {
        "machine_name": machine,
        "placeholder": placeholder,
        "max_num_layers": max_layers,
        "block_size": BLOCK_SIZE,
        "kv_cache_blocks": {str(k): int(kv_blocks[k]) for k in range(1, max_layers + 1)},
        "prompt_max_requests": prompt_max_requests,
        "decode_max_tokens": decode_max_tokens,
        "profiling": extra_meta,
    }
    with open(os.path.join(d, "meta.json"), "w") as f:
        json.dump(meta, f, indent=2)
    return d


# ------------------------------------------------------------------------------------------- #
#                                   GPU workers (subprocesses)                                  #
# ------------------------------------------------------------------------------------------- #
def build_engine(layer_ids):
    import llm_sys.engine.llama  # noqa: F401   (same imports as llm_sys/worker.py)
    import llm_sys.engine.qwen3_moe  # noqa: F401
    from vllm.engine.arg_utils import EngineArgs
    from llm_sys.engine.exec_engine import PipelineStageEngine
    args = EngineArgs(model=MODEL_DIR, block_size=BLOCK_SIZE, load_format="dummy",
                      enforce_eager=True, swap_space=4,
                      max_num_batched_tokens=ENGINE_MAX_BATCHED_TOKENS,
                      gpu_memory_utilization=0.8)
    return PipelineStageEngine.from_engine_args(args, layer_ids)


def _free(engine, layer, rids):
    from vllm.sequence import SequenceStatus
    engine.scheduler.context_switch(layer)
    engine.scheduler.finish_requests(
        [(str(r), ((r, SequenceStatus.FINISHED_STOPPED),)) for r in rids])


def worker_timing(repeats: int):
    import torch
    from vllm import SamplingParams
    layer = TIMING_LAYER
    engine = build_engine([layer])
    H = engine.model_config.get_hidden_size()
    sp = SamplingParams(ignore_eos=True, max_tokens=10_000)
    next_id = [1]

    def new_ids(n):
        ids = list(range(next_id[0], next_id[0] + n))
        next_id[0] += n
        return ids

    def add_prompt(rid, n):
        engine.add_request(f"{rid}", "", sp, local_layers=(layer, layer), seq_id=rid,
                           input_tensor=torch.randn(n, H, device="cuda", dtype=torch.float16),
                           prompt_token_ids=[1] * n)

    def timed_step():
        # wall-clock of one Helix layer step (GPU work + Helix's per-layer Python overhead)
        torch.cuda.synchronize()
        w0 = time.perf_counter()
        out = engine.step(layer_id=layer, finished_seq_infos=[], force_decode=False)
        torch.cuda.synchronize()
        return (time.perf_counter() - w0) * 1000.0, out

    def prompt_once(total):
        sizes = [2048] * (total // 2048) + ([total % 2048] if total % 2048 else [])
        rids = new_ids(len(sizes))
        for r, n in zip(rids, sizes):
            add_prompt(r, n)
        ms, out = timed_step()
        rows = sum(e - b for _, b, e in out[0])
        assert rows == total, f"prompt step processed {rows} tokens, expected {total}"
        _free(engine, layer, rids)
        return ms

    # warm-up (kernels, allocator, Triton autotune of fused_moe)
    for t in [512, 4096, 16]:
        prompt_once(t)

    prompt_ms = {}
    for t in PROMPT_GRID:
        prompt_once(t)
        prompt_ms[t] = statistics.median(prompt_once(t) for _ in range(repeats))
        print(f"  prompt {t:5d} tokens: {prompt_ms[t]:8.3f} ms/layer", file=sys.stderr, flush=True)

    # decode: prefill max(DECODE_GRID) requests with the average context, then decode subsets
    n_max = max(DECODE_GRID)
    rids = new_ids(n_max)
    per_step = max(1, ENGINE_MAX_BATCHED_TOKENS // DECODE_CONTEXT)
    for i in range(0, n_max, per_step):
        for r in rids[i:i + per_step]:
            add_prompt(r, DECODE_CONTEXT)
        engine.step(layer_id=layer, finished_seq_infos=[], force_decode=False)

    def decode_once(b):
        for r in rids[:b]:
            engine.scheduler.update_req_data(
                layer, (f"{r}", layer),
                {(r, layer): torch.randn(1, H, device="cuda", dtype=torch.float16)})
        ms, out = timed_step()
        assert out[2] is False and len(out[0]) == b, (b, len(out[0]))
        return ms

    for b in [1, 64, 256]:
        decode_once(b)
    decode_ms = {}
    for b in DECODE_GRID:
        decode_once(b)
        decode_ms[b] = statistics.median(decode_once(b) for _ in range(repeats))
        print(f"  decode {b:4d} reqs:    {decode_ms[b]:8.3f} ms/layer", file=sys.stderr, flush=True)

    return {"prompt_ms": prompt_ms, "decode_ms": decode_ms,
            "gpu_name": torch.cuda.get_device_name(),
            "gpu_total_mem_gb": torch.cuda.get_device_properties(0).total_memory / 1e9}


def worker_kv(k: int):
    # Layers [0, k): includes layer 0's embedding (151936 x 2048 fp16 = 0.62 GB, about half a
    # layer). Nodes holding the first layer (embedding) or the last one (lm_head, same size)
    # really have this much less KV space, so measuring with it gives a conservative pool size
    # for every node instead of an optimistic one for the first/last-layer nodes.
    engine = build_engine(list(range(0, k)))
    return {"k": k, "num_gpu_blocks": int(engine.cache_config.num_gpu_blocks)}


def run_worker(args_list):
    cmd = [sys.executable, os.path.abspath(__file__), "--worker"] + args_list
    r = subprocess.run(cmd, cwd=REPO, stdout=subprocess.PIPE, text=True)
    lines = [l for l in r.stdout.splitlines() if l.startswith("RESULT ")]
    for l in r.stdout.splitlines():           # vLLM logs to stdout: keep them visible
        if not l.startswith("RESULT "):
            print(l, file=sys.stderr)
    if r.returncode != 0 or not lines:
        return None
    return json.loads(lines[-1][len("RESULT "):])


# ------------------------------------------------------------------------------------------- #
def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    ap.add_argument("--machine", help=f"Helix machine type name, one of {sorted(NOMINAL_VRAM_GB)}")
    ap.add_argument("--out", default=DEFAULT_OUT)
    ap.add_argument("--repeats", type=int, default=5)
    ap.add_argument("--max-layers", type=int, default=None,
                    help="override the half-VRAM rule (must still satisfy 2*k*layer <= VRAM)")
    ap.add_argument("--kv-all", action="store_true", help="measure KV pool for every k")
    ap.add_argument("--force", action="store_true", help="skip the GPU-memory sanity check")
    ap.add_argument("--vram-gb", type=float, default=None,
                    help="nominal VRAM (GB, 1e9 B) for a machine type not in the built-in table; "
                         "must equal machine_types.<type>.vram_gb in cluster.json")
    ap.add_argument("--worker", nargs="+", help=argparse.SUPPRESS)
    args = ap.parse_args()

    if args.worker:
        sys.path.insert(0, REPO)
        kind = args.worker[0]
        res = worker_timing(int(args.worker[1])) if kind == "timing" else worker_kv(int(args.worker[1]))
        print("RESULT " + json.dumps(res), flush=True)
        return

    from simulator.model_manager.qwen3_30b_a3b.model_card import LAYER_PARAM_BYTES
    assert args.machine, "--machine is required"
    if args.vram_gb is not None:
        NOMINAL_VRAM_GB[args.machine] = args.vram_gb
    assert args.machine in NOMINAL_VRAM_GB, \
        f"--machine must be one of {sorted(NOMINAL_VRAM_GB)}, or give its VRAM with --vram-gb"
    max_layers = args.max_layers or max_layers_for(args.machine, LAYER_PARAM_BYTES)
    assert 2 * max_layers * LAYER_PARAM_BYTES <= NOMINAL_VRAM_GB[args.machine] * 1e9 + 1, \
        "violates Helix's half-VRAM-for-parameters rule (ilp_layout.py would assert)"

    print(f"[1/2] timing one layer on {args.machine} ...", flush=True)
    timing = run_worker(["timing", str(args.repeats)])
    assert timing is not None, "timing worker failed (see stderr above)"
    if args.machine.split("-")[0].lower() not in timing["gpu_name"].lower():
        print(f"WARNING: --machine {args.machine} but this GPU is '{timing['gpu_name']}'")
    # the KV pool is measured on the real card: a 40 GB "A100" profile must not come from an
    # 80 GB card (or "L4" from an L40S), otherwise KV capacity is silently wrong
    ratio = timing["gpu_total_mem_gb"] / NOMINAL_VRAM_GB[args.machine]
    if not 0.85 <= ratio <= 1.15 and not args.force:
        raise SystemExit(f"GPU memory {timing['gpu_total_mem_gb']:.1f} GB does not match "
                         f"--machine {args.machine} ({NOMINAL_VRAM_GB[args.machine]} GB). Pick "
                         f"the right machine type (e.g. A100-80G) or pass --force.")

    print(f"[2/2] KV page pool for 1..{max_layers} layers ...", flush=True)
    ks = list(range(1, max_layers + 1)) if args.kv_all else sorted({1, (1 + max_layers) // 2, max_layers})
    points = {}
    for k in ks:
        res = run_worker(["kv", str(k)])
        if res is None or res["num_gpu_blocks"] <= 0:
            raise RuntimeError(f"engine with {k} layers failed or has no KV space; "
                               f"rerun with --max-layers {k - 1}")
        points[k] = res["num_gpu_blocks"]
        print(f"  {k:2d} layers: {points[k]} blocks of {BLOCK_SIZE} tokens", flush=True)
    kv_blocks = fit_kv_blocks(points, max_layers)

    extra = {
        "gpu_name": timing["gpu_name"], "gpu_total_mem_gb": round(timing["gpu_total_mem_gb"], 2),
        "date": datetime.datetime.now().isoformat(timespec="seconds"),
        "engine": "Helix llm_sys/engine (vLLM 0.4.0.post1), dummy weights, fp16, enforce_eager",
        "gpu_memory_utilization": 0.8, "timing_layer": TIMING_LAYER,
        "decode_context_len": DECODE_CONTEXT, "repeats": args.repeats,
        # each decode step appends one token to the requests it runs; the first requests run in
        # every step, so their context grows by up to this many tokens during the sweep
        "decode_context_max_drift": 3 + len(DECODE_GRID) * (1 + args.repeats),
        "kv_measured_points": {str(k): v for k, v in points.items()},
        "kv_measured_with_layers": "[0, k): includes the embedding -> conservative",
    }
    d = write_profile(args.out, args.machine, timing["prompt_ms"], timing["decode_ms"],
                      kv_blocks, max_layers, extra)
    print(f"Wrote {d}")


if __name__ == "__main__":
    main()
