"""
PLACEHOLDER Qwen3-30B-A3B profiles from a simple roofline model -- NOT MEASUREMENTS.

Purpose: exercise the simulator / MILP pipeline before real profiles exist (e.g. in CI or on a
laptop). Every meta.json written here has "placeholder": true and the simulator warns when it
loads one. Real numbers come from tools/profile_qwen3_moe.py on each GPU type.

Model per layer step (ms) = overhead + max(compute, memory):
  compute = tokens * 2 * active_params_per_token / effective_FLOPs
  memory  = (attention+router weights + distinct experts touched + KV read) / HBM bandwidth
with distinct experts touched by n tokens ~= E * (1 - (1 - k/E)^n) under uniform routing.

Usage: python tests/qwen3_moe/make_placeholder_profiles.py <out_dir> [A100 L4 T4 V100 ...]
"""
import importlib.util
import os
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, REPO)
from simulator.model_manager.qwen3_30b_a3b import model_card as card  # noqa: E402

_spec = importlib.util.spec_from_file_location(
    "profile_qwen3_moe", os.path.join(REPO, "tools", "profile_qwen3_moe.py"))
prof = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(prof)

# rough public numbers: HBM GB/s, dense fp16 tensor TFLOPs (x0.4 achievable), usable VRAM GB
GPUS = {
    "T4":   dict(bw=300, tflops=65 * 0.4, vram=15.0),
    "V100": dict(bw=900, tflops=125 * 0.4, vram=15.8),
    "L4":   dict(bw=300, tflops=121 * 0.4, vram=22.0),
    "A100": dict(bw=1555, tflops=312 * 0.4, vram=39.4),
    "A30":  dict(bw=933, tflops=165 * 0.4, vram=23.5),
    "RTX6000": dict(bw=672, tflops=130 * 0.4, vram=23.0),   # Quadro RTX 6000 (Turing)
}
OVERHEAD_MS = 1.2           # Helix per-layer step overhead (Python scheduling, kernel launches)
ACT_PEAK_GB = 1.0           # activation peak vLLM reserves during profiling

EXPERT_BYTES = 3 * card.HIDDEN_SIZE * card.MOE_INTERMEDIATE * card.DTYPE_BYTES
DENSE_BYTES = card.LAYER_PARAM_BYTES - card.NUM_EXPERTS * EXPERT_BYTES
ACTIVE_PARAMS = DENSE_BYTES / card.DTYPE_BYTES + card.TOP_K * EXPERT_BYTES / card.DTYPE_BYTES


def step_ms(gpu, n_tokens, kv_tokens=0):
    if n_tokens == 0:
        return 0.0
    experts = card.NUM_EXPERTS * (1 - (1 - card.TOP_K / card.NUM_EXPERTS) ** n_tokens)
    mem_bytes = DENSE_BYTES + experts * EXPERT_BYTES + kv_tokens * card.KV_BYTES_PER_TOKEN_LAYER
    compute_s = n_tokens * 2 * ACTIVE_PARAMS / (gpu["tflops"] * 1e12)
    memory_s = mem_bytes / (gpu["bw"] * 1e9)
    return OVERHEAD_MS + 1000 * max(compute_s, memory_s)


def main():
    out = sys.argv[1]
    names = sys.argv[2:] or list(GPUS)
    for name in names:
        g = GPUS[name]
        prompt = {t: step_ms(g, t) for t in prof.PROMPT_GRID}
        decode = {b: step_ms(g, b, kv_tokens=b * prof.DECODE_CONTEXT) for b in prof.DECODE_GRID}
        max_layers = prof.max_layers_for(name, card.LAYER_PARAM_BYTES)
        block_bytes = prof.BLOCK_SIZE * card.KV_BYTES_PER_TOKEN_LAYER
        kv = {k: int((g["vram"] * 0.8 - ACT_PEAK_GB - k * card.LAYER_PARAM_BYTES / 1e9) * 1e9
                     // block_bytes) for k in range(1, max_layers + 1)}
        d = prof.write_profile(out, name, prompt, decode, kv, max_layers,
                               {"note": "roofline placeholder, NOT measured"}, placeholder=True)
        print(f"wrote placeholder {d}: max_layers={max_layers}, "
              f"decode256={decode[256]:.2f}ms prompt4096={prompt[4096]:.2f}ms per layer")


if __name__ == "__main__":
    main()
