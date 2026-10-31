"""
Pure-PyTorch reference for one Qwen3-MoE decoder layer (torch only, runs on CPU or GPU).

Used as ground truth for the Helix stage:
  * test_ref_vs_hf.py checks this reference against HF transformers' Qwen3MoeDecoderLayer
  * test_gpu_stage.py checks the Helix/vLLM stage (fused kernels, paged KV cache) against it

All math is done in float32. `layer_output` returns the full residual stream after the layer
(attention + MoE + both residual adds), i.e. what one Helix node should send to the next.
"""
from typing import Dict

import torch
import torch.nn.functional as F


def rms_norm(x: torch.Tensor, w: torch.Tensor, eps: float) -> torch.Tensor:
    x = x.float()
    return x * torch.rsqrt(x.pow(2).mean(-1, keepdim=True) + eps) * w.float()


def rope_neox(x: torch.Tensor, positions: torch.Tensor, theta: float) -> torch.Tensor:
    """x: [T, n_heads, head_dim]; neox / HF 'rotate_half' style."""
    d = x.shape[-1]
    inv_freq = 1.0 / (theta ** (torch.arange(0, d, 2, device=x.device, dtype=torch.float32) / d))
    freqs = positions.float()[:, None] * inv_freq[None, :]          # [T, d/2]
    cos = torch.cat([freqs, freqs], -1).cos()[:, None, :]            # [T, 1, d]
    sin = torch.cat([freqs, freqs], -1).sin()[:, None, :]
    x1, x2 = x[..., : d // 2], x[..., d // 2:]
    rotated = torch.cat([-x2, x1], -1)
    return x * cos + rotated * sin


def extract_stage_weights(stage) -> Dict[str, torch.Tensor]:
    """Pull weights out of a Qwen3MoePipelineStage (Helix/vLLM module) as float32 tensors."""
    layer = stage.decoder_layer
    attn, mlp = layer.self_attn, layer.mlp
    return {
        "qkv": attn.qkv_proj.weight.detach().float(),
        "o": attn.o_proj.weight.detach().float(),
        "q_norm": attn.q_norm.weight.detach().float(),
        "k_norm": attn.k_norm.weight.detach().float(),
        "ln1": layer.input_layernorm.weight.detach().float(),
        "ln2": layer.post_attention_layernorm.weight.detach().float(),
        "router": mlp.gate.weight.detach().float(),
        "w13": mlp.w13.detach().float(),
        "w2": mlp.w2.detach().float(),
    }


def layer_output(w: Dict[str, torch.Tensor], x: torch.Tensor, positions: torch.Tensor, *,
                 num_heads: int, num_kv_heads: int, head_dim: int, top_k: int,
                 norm_topk_prob: bool, rope_theta: float, eps: float) -> torch.Tensor:
    """
    x: [T, hidden] residual stream entering the layer (one sequence, causal attention over
    all T tokens). Returns [T, hidden] float32 residual stream leaving the layer.
    """
    x = x.float()
    T = x.shape[0]
    q_size, kv_size = num_heads * head_dim, num_kv_heads * head_dim

    # --- attention ---
    h = rms_norm(x, w["ln1"], eps)
    qkv = h @ w["qkv"].t()
    q, k, v = qkv.split([q_size, kv_size, kv_size], dim=-1)
    q = rms_norm(q.view(T, num_heads, head_dim), w["q_norm"], eps)     # QK-Norm per head
    k = rms_norm(k.view(T, num_kv_heads, head_dim), w["k_norm"], eps)
    v = v.view(T, num_kv_heads, head_dim)
    q, k = rope_neox(q, positions, rope_theta), rope_neox(k, positions, rope_theta)
    rep = num_heads // num_kv_heads                                     # GQA
    k, v = k.repeat_interleave(rep, dim=1), v.repeat_interleave(rep, dim=1)
    scores = torch.einsum("qhd,khd->hqk", q, k) * head_dim ** -0.5
    causal = torch.ones(T, T, dtype=torch.bool, device=x.device).tril()
    scores = scores.masked_fill(~causal, float("-inf"))
    attn = torch.einsum("hqk,khd->qhd", scores.softmax(-1), v).reshape(T, q_size)
    x = x + attn @ w["o"].t()

    # --- MoE ---
    h = rms_norm(x, w["ln2"], eps)
    probs = F.softmax(h @ w["router"].t(), dim=-1)
    topw, topi = probs.topk(top_k, dim=-1)
    if norm_topk_prob:
        topw = topw / topw.sum(-1, keepdim=True)
    inter = w["w2"].shape[2]
    out = torch.zeros_like(h)
    for e in topi.unique().tolist():
        rows, slot = (topi == e).nonzero(as_tuple=True)
        gate_up = h[rows] @ w["w13"][e].t()
        act = F.silu(gate_up[:, :inter]) * gate_up[:, inter:]
        out[rows] += (act @ w["w2"][e].t()) * topw[rows, slot][:, None]
    return x + out
