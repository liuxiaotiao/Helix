"""
CPU "wiring" test: runs the real Qwen3MoePipelineStage forward on CPU (float32) and compares
it with reference.py. Only the CUDA-only kernels are swapped for exact PyTorch equivalents:
  * RMSNorm / RotaryEmbedding -> vLLM 0.4.0's own `_forward` (pure torch) implementations
  * fused_moe (Triton)        -> torch version with the same semantics
                                 (softmax -> top-k -> renormalize, silu(w13[:I]) * w13[I:])
  * paged Attention           -> causal SDPA with GQA (prompt only, no KV cache)
Everything else (linear layers, splits, QK-Norm reshapes, RoPE call order, embeddings, residual
handling, final norm, lm_head) is the stage's real code. Kernel numerics, the paged KV cache
and decode are covered by test_gpu_stage.py on a GPU.

Uses a reduced config (hidden 256, 8 heads / 2 kv heads, head_dim 64 != 256/8, 16 experts,
top-4) so it runs in seconds.

Run from the repo root:  python tests/qwen3_moe/test_cpu_wiring.py
"""
import os
import sys

import torch
import torch.nn.functional as F

HERE = os.path.dirname(__file__)
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, REPO)
sys.path.insert(0, HERE)
from test_cpu_structure import (MODEL_DIR, force_xformers_backend,  # noqa: E402
                                init_single_process_tp, stub_cuda_extension_if_needed)


def torch_fused_moe(hidden_states, w1, w2, gating_output, topk, renormalize, inplace=False,
                    **_):
    probs = torch.softmax(gating_output.float(), dim=-1)
    topk_w, topk_ids = torch.topk(probs, topk, dim=-1)
    if renormalize:
        topk_w = topk_w / topk_w.sum(dim=-1, keepdim=True)
    n = w2.shape[2]
    out = torch.zeros_like(hidden_states)
    for e in topk_ids.unique().tolist():
        rows, slot = (topk_ids == e).nonzero(as_tuple=True)
        h = hidden_states[rows] @ w1[e].t()
        h = F.silu(h[:, :n]) * h[:, n:]
        out[rows] += (h @ w2[e].t()) * topk_w[rows, slot][:, None].to(h.dtype)
    return out


class CausalSDPA(torch.nn.Module):
    def __init__(self, num_heads, head_dim, num_kv_heads, scale):
        super().__init__()
        self.nh, self.hd, self.nkv, self.scale = num_heads, head_dim, num_kv_heads, scale

    def forward(self, q, k, v, kv_cache, attn_metadata):
        T = q.shape[0]
        q = q.view(T, self.nh, self.hd).transpose(0, 1)
        k = k.reshape(T, self.nkv, self.hd).transpose(0, 1)
        v = v.reshape(T, self.nkv, self.hd).transpose(0, 1)
        rep = self.nh // self.nkv
        k, v = k.repeat_interleave(rep, 0), v.repeat_interleave(rep, 0)
        o = F.scaled_dot_product_attention(q, k, v, is_causal=True, scale=self.scale)
        return o.transpose(0, 1).reshape(T, self.nh * self.hd)


def main():
    stub_cuda_extension_if_needed()
    init_single_process_tp()
    force_xformers_backend()

    import llm_sys.engine.qwen3_moe as q3
    from vllm.config import ModelConfig
    from vllm.model_executor.layers.layernorm import RMSNorm
    from vllm.model_executor.layers.rotary_embedding import RotaryEmbedding
    from reference import extract_stage_weights, layer_output, rms_norm

    RMSNorm.forward = RMSNorm._forward

    # vLLM 0.4.0's torch RoPE fallback assumes [batch, seq] positions; the CUDA op (and
    # Helix's model runner) use flat [num_tokens] positions, so add/remove a batch dim here.
    def rope_forward(self, positions, query, key, offsets=None):
        q, k = RotaryEmbedding._forward(self, positions[None], query[None], key[None])
        return q[0], k[0]
    RotaryEmbedding.forward = rope_forward
    q3.fused_moe = torch_fused_moe

    mc = ModelConfig(model=MODEL_DIR, tokenizer=MODEL_DIR, tokenizer_mode="auto",
                     trust_remote_code=False, download_dir=None, load_format="dummy",
                     dtype="auto", seed=0)
    cfg = mc.hf_config
    # reduced but structurally identical config
    cfg.hidden_size, cfg.num_attention_heads, cfg.num_key_value_heads, cfg.head_dim = 256, 8, 2, 64
    cfg.num_experts, cfg.num_experts_per_tok, cfg.moe_intermediate_size = 16, 4, 64
    cfg.vocab_size, cfg.num_hidden_layers = 1000, 4
    kw = dict(num_heads=8, num_kv_heads=2, head_dim=64, top_k=4, norm_topk_prob=True,
              rope_theta=cfg.rope_theta, eps=cfg.rms_norm_eps)

    torch.manual_seed(0)
    T = 23
    positions = torch.arange(T)
    all_ok = True
    for layer_id in [0, 1, 3]:
        cfg.layer_id = layer_id
        stage = q3.Qwen3MoePipelineStage(cfg, None).float()
        for name, p in stage.named_parameters():
            with torch.no_grad():
                if name.endswith("norm.weight"):
                    p.copy_(1 + 0.1 * torch.randn_like(p))
                elif name.endswith("mlp.gate.weight"):
                    p.copy_(0.2 * torch.randn_like(p))
                elif "embed_tokens" in name:
                    p.copy_(torch.randn_like(p))
                else:
                    p.copy_(0.05 * torch.randn_like(p))
        a = stage.decoder_layer.self_attn
        a.attn = CausalSDPA(a.num_heads, a.head_dim, a.num_kv_heads, a.scaling)
        W = extract_stage_weights(stage)

        kwargs = dict(positions=positions, kv_cache=None, attn_metadata=None, residual=None)
        if layer_id == 0:
            ids = torch.randint(0, cfg.vocab_size, (T,))
            kwargs["input_ids"] = ids
            x_in = stage.embed_tokens.weight[ids]
        else:
            x_in = torch.randn(T, cfg.hidden_size)
            kwargs["hidden_states"] = x_in.clone()

        with torch.no_grad():
            got = stage(**kwargs)
            ref = layer_output(W, x_in, positions, **kw)
            if layer_id == cfg.num_hidden_layers - 1:
                ref = rms_norm(ref, stage.norm.weight, cfg.rms_norm_eps)
                logits_got = got @ stage.lm_head.weight[:cfg.vocab_size].t()
                logits_ref = ref @ stage.lm_head.weight[:cfg.vocab_size].t()
                assert torch.equal(logits_got.argmax(-1), logits_ref.argmax(-1))
        rel = ((got - ref).abs().max() / ref.abs().max()).item()
        kind = {0: "first (embedding)", 3: "last (final norm)"}.get(layer_id, "middle")
        ok = rel < 1e-5
        all_ok &= ok
        print(f"[{'ok' if ok else 'BAD'}] layer {layer_id} {kind:<18} rel_max_err={rel:.2e}")

    # Also confirm the residual stream is what gets sent on (not just the MLP output).
    assert all_ok, "stage disagrees with reference"
    print("STAGE WIRING MATCHES REFERENCE")


if __name__ == "__main__":
    main()
