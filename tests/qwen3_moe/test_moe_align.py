"""
moe_align_block_size: the PyTorch fallback in llm_sys/engine/qwen3_moe.py must give exactly what
vLLM 0.4.0's CUDA kernel gives (Turing GPUs cannot run that kernel with 128 experts).

  python tests/qwen3_moe/test_moe_align.py

  1. vs. a line-by-line Python port of csrc/moe_align_block_size_kernels.cu (v0.4.0.post1)
  2. a simulated fused_moe that consumes the outputs exactly like the Triton kernel == dense MoE
  3. on a GPU whose CUDA kernel works (e.g. A30): torch fallback == the real kernel
  4. dispatch: torch fallback only where the kernel's shared memory does not fit
Runs on CPU; parts 3 needs a GPU.
"""
import math
import os
import random
import sys

import torch

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, REPO)
sys.path.insert(0, os.path.dirname(__file__))
from test_cpu_structure import stub_cuda_extension_if_needed  # noqa: E402

stub_cuda_extension_if_needed()
import llm_sys.engine.qwen3_moe as q  # noqa: E402


def kernel_reference(topk_ids, block_size, num_experts):
    """Python port of moe_align_block_size_kernel (one block, num_experts threads)."""
    flat = topk_ids.flatten().tolist()
    numel = len(flat)
    threads = num_experts
    tpt = math.ceil(numel / threads)
    cnts = [[0] * num_experts for _ in range(threads + 1)]          # tokens_cnts[t + 1][e]
    for t in range(threads):
        for i in range(t * tpt, min(numel, (t + 1) * tpt)):
            cnts[t + 1][flat[i]] += 1
    for e in range(num_experts):                                    # prefix over threads
        cnts[0][e] = 0
        for t in range(1, threads + 1):
            cnts[t][e] += cnts[t - 1][e]
    cumsum = [0] * (num_experts + 1)
    for e in range(1, num_experts + 1):
        cumsum[e] = cumsum[e - 1] + math.ceil(cnts[threads][e - 1] / block_size) * block_size
    sorted_ids = [numel] * (numel + num_experts * (block_size - 1))
    expert_ids = [None] * (numel + num_experts)                     # untouched -> undefined
    for e in range(num_experts):
        for i in range(cumsum[e], cumsum[e + 1], block_size):
            expert_ids[i // block_size] = e
    for t in range(threads):
        for i in range(t * tpt, min(numel, (t + 1) * tpt)):
            e = flat[i]
            sorted_ids[cnts[t][e] + cumsum[e]] = i
            cnts[t][e] += 1
    return sorted_ids, expert_ids, cumsum[num_experts]


def random_topk(tokens, top_k, num_experts, gen, skew=False):
    if skew:   # a few hot experts, many unused ones
        w = torch.rand(num_experts, generator=gen) ** 8
    else:
        w = torch.ones(num_experts)
    return torch.stack([torch.multinomial(w, top_k, generator=gen) for _ in range(tokens)]).int()


def check_against_kernel():
    gen = torch.Generator().manual_seed(0)
    n = 0
    for num_experts in (4, 8, 60, 128):
        for top_k in (1, 2, 8):
            if top_k > num_experts:
                continue
            for tokens in (1, 3, 17, 256, 1500):
                for block_size in (16, 32, 64, 128):
                    for skew in (False, True):
                        ids = random_topk(tokens, top_k, num_experts, gen, skew)
                        s, e, t = q.moe_align_block_size_torch(ids, block_size, num_experts)
                        rs, re_, rt = kernel_reference(ids, block_size, num_experts)
                        assert int(t) == rt, (num_experts, top_k, tokens, block_size)
                        assert s.tolist() == rs, (num_experts, top_k, tokens, block_size)
                        nb = rt // block_size
                        assert e[:nb].tolist() == re_[:nb], (num_experts, top_k, tokens, block_size)
                        n += 1
    print(f"[ok] torch fallback == CUDA kernel semantics on {n} cases")


def simulated_fused_moe(x, w, topk_ids, topk_w, block_size, num_experts, align):
    """Consumes (sorted_ids, expert_ids, total) like fused_moe_kernel: block b handles rows
    sorted_ids[b*BS:(b+1)*BS] with expert expert_ids[b]; ids >= numel are padding."""
    sorted_ids, expert_ids, total = align(topk_ids, block_size, num_experts)
    numel, top_k = topk_ids.numel(), topk_ids.shape[1]
    out = torch.zeros(x.shape[0], top_k, w.shape[1], dtype=x.dtype)
    for b in range(int(total) // block_size):
        ex = int(expert_ids[b])
        for slot in sorted_ids[b * block_size:(b + 1) * block_size].tolist():
            if slot >= numel:
                continue
            tok, k = divmod(slot, top_k)
            out[tok, k] = (w[ex] @ x[tok]) * topk_w[tok, k]
    return out.sum(1)


def check_moe_semantics():
    gen = torch.Generator().manual_seed(1)
    for num_experts, top_k, tokens, block_size in [(128, 8, 37, 16), (128, 8, 5, 64), (8, 2, 40, 16)]:
        x = torch.randn(tokens, 6, generator=gen, dtype=torch.float64)
        w = torch.randn(num_experts, 4, 6, generator=gen, dtype=torch.float64)
        ids = random_topk(tokens, top_k, num_experts, gen, skew=True)
        tw = torch.rand(tokens, top_k, generator=gen, dtype=torch.float64)
        dense = torch.stack([sum(tw[t, k] * (w[ids[t, k]] @ x[t]) for k in range(top_k))
                             for t in range(tokens)])
        got = simulated_fused_moe(x, w, ids, tw, block_size, num_experts, q.moe_align_block_size_torch)
        assert torch.allclose(got, dense), (num_experts, top_k, tokens, block_size)
    print("[ok] simulated fused_moe on the fallback's outputs == dense MoE")


def check_on_gpu():
    if not torch.cuda.is_available():
        print("[skip] no GPU: real-kernel comparison")
        return
    dev = torch.device("cuda")
    cap = torch.cuda.get_device_capability(dev)
    gen = torch.Generator().manual_seed(2)
    use_torch = q._use_torch_align(dev, 128)
    print(f"[info] {torch.cuda.get_device_name()} sm_{cap[0]}{cap[1]}: 128 experts -> "
          f"{'torch fallback' if use_torch else 'CUDA kernel'}")
    for tokens, block_size in [(1, 16), (9, 16), (300, 64), (4096, 64)]:
        ids = random_topk(tokens, 8, 128, gen).to(dev)
        s, e, t = q.moe_align_block_size_torch(ids, block_size, 128)
        rs, re_, rt = kernel_reference(ids.cpu(), block_size, 128)
        assert s.cpu().tolist() == rs and int(t) == rt
        if not use_torch:   # this GPU can run the real kernel: compare with it directly
            ks, ke, kt = q._cuda_moe_align_block_size(ids, block_size, 128)
            nb = int(kt) // block_size
            assert int(kt) == int(t) and ks.tolist() == s.tolist() and ke[:nb].tolist() == e[:nb].tolist()
    print("[ok] fallback on GPU" + ("" if use_torch else " == real CUDA kernel"))


def check_dispatch():
    real = torch.cuda.get_device_capability
    try:
        for cap, experts, want in [((7, 5), 128, True), ((7, 5), 8, False), ((8, 0), 128, False),
                                   ((8, 6), 128, False), ((7, 0), 128, False), ((6, 1), 128, True)]:
            q._use_torch_align_cache.clear()
            torch.cuda.get_device_capability = lambda d=None, c=cap: c
            got = q._use_torch_align(torch.device("cuda", 0), experts)
            assert got == want, (cap, experts, got)
    finally:
        torch.cuda.get_device_capability = real
        q._use_torch_align_cache.clear()
    assert q._fused_moe_module.moe_align_block_size is q._moe_align_block_size_dispatch
    print("[ok] dispatch: fallback only where the kernel's shared memory does not fit "
          "(sm_75 with 128 experts), fused_moe patched")


if __name__ == "__main__":
    random.seed(0)
    check_against_kernel()
    check_moe_semantics()
    check_dispatch()
    check_on_gpu()
    print("ALL MOE-ALIGN TESTS PASSED")
