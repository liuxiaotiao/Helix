"""
Validate tests/qwen3_moe/reference.py against HuggingFace transformers' official
Qwen3MoeDecoderLayer (needs transformers >= 4.51; CPU is fine).

Uses a reduced but structurally faithful config: head_dim != hidden_size / num_heads (as in
Qwen3-30B-A3B), GQA, QK-Norm, many experts with top-k routing and renormalisation.
Weights are copied in the same packed layout the Helix stage uses (qkv, w13 = [gate; up], w2).

Run:  python tests/qwen3_moe/test_ref_vs_hf.py
"""
import os
import sys

import torch

sys.path.insert(0, os.path.dirname(__file__))
from reference import layer_output  # noqa: E402

from transformers import Qwen3MoeConfig  # noqa: E402
from transformers.models.qwen3_moe.modeling_qwen3_moe import (  # noqa: E402
    Qwen3MoeDecoderLayer, Qwen3MoeRotaryEmbedding)


def run_case(T: int, norm_topk_prob: bool, seed: int):
    torch.manual_seed(seed)
    cfg = Qwen3MoeConfig(hidden_size=256, num_attention_heads=8, num_key_value_heads=2,
                         head_dim=64, intermediate_size=512, moe_intermediate_size=64,
                         num_experts=16, num_experts_per_tok=4, norm_topk_prob=norm_topk_prob,
                         decoder_sparse_step=1, mlp_only_layers=[], rms_norm_eps=1e-6,
                         rope_theta=1000000.0, max_position_embeddings=4096,
                         attention_bias=False, num_hidden_layers=2)
    cfg._attn_implementation = "eager"
    H, nh, nkv, hd, E, I = 256, 8, 2, 64, 16, 64

    # random weights in the Helix stage's packed layout
    s = 0.05
    w = {
        "qkv": torch.randn(nh * hd + 2 * nkv * hd, H) * s,
        "o": torch.randn(H, nh * hd) * s,
        "q_norm": 1 + 0.1 * torch.randn(hd), "k_norm": 1 + 0.1 * torch.randn(hd),
        "ln1": 1 + 0.1 * torch.randn(H), "ln2": 1 + 0.1 * torch.randn(H),
        "router": torch.randn(E, H) * 0.2,
        "w13": torch.randn(E, 2 * I, H) * s, "w2": torch.randn(E, H, I) * s,
    }

    # load the same weights into HF's layer
    layer = Qwen3MoeDecoderLayer(cfg, layer_idx=0).eval()
    with torch.no_grad():
        a = layer.self_attn
        a.q_proj.weight.copy_(w["qkv"][: nh * hd])
        a.k_proj.weight.copy_(w["qkv"][nh * hd: nh * hd + nkv * hd])
        a.v_proj.weight.copy_(w["qkv"][nh * hd + nkv * hd:])
        a.o_proj.weight.copy_(w["o"])
        a.q_norm.weight.copy_(w["q_norm"]); a.k_norm.weight.copy_(w["k_norm"])
        layer.input_layernorm.weight.copy_(w["ln1"])
        layer.post_attention_layernorm.weight.copy_(w["ln2"])
        layer.mlp.gate.weight.copy_(w["router"])
        for e, expert in enumerate(layer.mlp.experts):
            expert.gate_proj.weight.copy_(w["w13"][e, :I])
            expert.up_proj.weight.copy_(w["w13"][e, I:])
            expert.down_proj.weight.copy_(w["w2"][e])

    x = torch.randn(1, T, H)
    pos = torch.arange(T)[None]
    rope = Qwen3MoeRotaryEmbedding(cfg)
    cos, sin = rope(x, pos)
    mask = torch.full((T, T), float("-inf")).triu(1)[None, None]
    with torch.no_grad():
        hf_out = layer(x, attention_mask=mask, position_ids=pos,
                       position_embeddings=(cos, sin))[0][0]
        ref_out = layer_output(w, x[0], pos[0], num_heads=nh, num_kv_heads=nkv, head_dim=hd,
                               top_k=4, norm_topk_prob=norm_topk_prob,
                               rope_theta=1000000.0, eps=1e-6)
    err = (hf_out - ref_out).abs().max().item()
    rel = err / hf_out.abs().max().item()
    print(f"T={T:3d} norm_topk_prob={norm_topk_prob}: max|diff|={err:.2e} (rel {rel:.2e})")
    assert rel < 1e-5, "reference disagrees with HF Qwen3MoeDecoderLayer"


if __name__ == "__main__":
    for T, norm, seed in [(1, True, 0), (7, True, 1), (64, True, 2), (33, False, 3)]:
        run_case(T, norm, seed)
    print("REFERENCE MATCHES HF Qwen3MoeDecoderLayer")
