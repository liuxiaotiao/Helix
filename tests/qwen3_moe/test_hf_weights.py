"""
CPU test of llm_sys/engine/hf_weights.py (the real-weight loader), no GPU / vLLM needed.

A tiny Qwen3-MoE checkpoint with HuggingFace tensor names is written as two safetensors shards
+ index; it is loaded into stand-ins for Helix's Qwen3MoePipelineStage (same attribute names and
packed layouts), and then
  1. one layer computed with the HF layout directly (per-expert gate/up/down, separate q/k/v,
     the way transformers' Qwen3MoeDecoderLayer is written) must equal tests/qwen3_moe/
     reference.py run on the weights extracted from the loaded stage;
  2. embedding / final norm / lm_head land in the right (vocab-padded) slices;
  3. missing shards / experts and values beyond the fp16 range are reported.

    python tests/qwen3_moe/test_hf_weights.py
"""
import json
import os
import sys
import tempfile
from types import SimpleNamespace

import torch
import torch.nn.functional as F

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, REPO)
sys.path.insert(0, HERE)
from llm_sys.engine.hf_weights import WeightIndex, load_stage_weights  # noqa: E402
from reference import extract_stage_weights, layer_output  # noqa: E402

CFG = SimpleNamespace(num_hidden_layers=3, hidden_size=32, num_attention_heads=4, num_key_value_heads=2,
                      head_dim=16, num_experts=8, num_experts_per_tok=2, moe_intermediate_size=12,
                      norm_topk_prob=True, rope_theta=10000.0, rms_norm_eps=1e-6, vocab_size=50)
VOCAB_PADDED = 64


def P(*shape):
    return torch.zeros(*shape, dtype=torch.float16)


def fake_stage(layer_id):
    c = CFG
    hd, nh, nkv, H, E, I = c.head_dim, c.num_attention_heads, c.num_key_value_heads, c.hidden_size, \
        c.num_experts, c.moe_intermediate_size
    attn = SimpleNamespace(head_dim=hd, total_num_heads=nh, total_num_kv_heads=nkv,
                           qkv_proj=SimpleNamespace(weight=P((nh + 2 * nkv) * hd, H)),
                           o_proj=SimpleNamespace(weight=P(H, nh * hd)),
                           q_norm=SimpleNamespace(weight=P(hd)), k_norm=SimpleNamespace(weight=P(hd)))
    mlp = SimpleNamespace(num_experts=E, gate=SimpleNamespace(weight=P(E, H)), w13=P(E, 2 * I, H), w2=P(E, H, I))
    layer = SimpleNamespace(self_attn=attn, mlp=mlp, input_layernorm=SimpleNamespace(weight=P(H)),
                            post_attention_layernorm=SimpleNamespace(weight=P(H)))
    st = SimpleNamespace(config=c, layer_id=layer_id, decoder_layer=layer,
                         is_first_layer=layer_id == 0, is_last_layer=layer_id == c.num_hidden_layers - 1)
    if st.is_first_layer:
        st.embed_tokens = SimpleNamespace(weight=P(VOCAB_PADDED, H))
    if st.is_last_layer:
        st.norm = SimpleNamespace(weight=P(H))
        st.lm_head = SimpleNamespace(weight=P(VOCAB_PADDED, H))
    return st


def make_checkpoint(d, drop=None, big=False):
    from safetensors.torch import save_file
    c = CFG
    g = torch.Generator().manual_seed(0)
    hd, nh, nkv, H, E, I = c.head_dim, c.num_attention_heads, c.num_key_value_heads, c.hidden_size, \
        c.num_experts, c.moe_intermediate_size

    def r(*s, scale=0.2, mean=0.0):
        return (torch.randn(*s, generator=g) * scale + mean).to(torch.bfloat16)

    t = {"model.embed_tokens.weight": r(c.vocab_size, H, scale=1.0),
         "model.norm.weight": r(H, scale=0.1, mean=1.0), "lm_head.weight": r(c.vocab_size, H)}
    for L in range(c.num_hidden_layers):
        p = f"model.layers.{L}."
        t.update({p + "self_attn.q_proj.weight": r(nh * hd, H), p + "self_attn.k_proj.weight": r(nkv * hd, H),
                  p + "self_attn.v_proj.weight": r(nkv * hd, H), p + "self_attn.o_proj.weight": r(H, nh * hd),
                  p + "self_attn.q_norm.weight": r(hd, scale=0.1, mean=1.0),
                  p + "self_attn.k_norm.weight": r(hd, scale=0.1, mean=1.0),
                  p + "input_layernorm.weight": r(H, scale=0.1, mean=1.0),
                  p + "post_attention_layernorm.weight": r(H, scale=0.1, mean=1.0),
                  p + "mlp.gate.weight": r(E, H, scale=0.5)})
        for e in range(E):
            t[p + f"mlp.experts.{e}.gate_proj.weight"] = r(I, H)
            t[p + f"mlp.experts.{e}.up_proj.weight"] = r(I, H)
            t[p + f"mlp.experts.{e}.down_proj.weight"] = r(H, I)
    if big:
        t["model.layers.1.self_attn.o_proj.weight"][0, 0] = 1e5     # beyond fp16
    if drop:
        t.pop(drop)
    names = sorted(t)
    half = len(names) // 2
    wm = {}
    for i, chunk in enumerate([names[:half], names[half:]]):
        fn = f"model-0000{i + 1}-of-00002.safetensors"
        save_file({n: t[n].contiguous() for n in chunk}, os.path.join(d, fn))
        wm.update({n: fn for n in chunk})
    json.dump({"metadata": {}, "weight_map": wm}, open(os.path.join(d, "model.safetensors.index.json"), "w"))
    return {k: v.float() for k, v in t.items()}


def hf_style_layer(t, L, x, pos):
    """One Qwen3-MoE decoder layer written directly against HF tensor names (fp32)."""
    c = CFG
    p = f"model.layers.{L}."
    hd, nh, nkv = c.head_dim, c.num_attention_heads, c.num_key_value_heads

    def rms(v, w):
        return v * torch.rsqrt(v.pow(2).mean(-1, keepdim=True) + c.rms_norm_eps) * w

    def rope(v):
        inv = 1.0 / (c.rope_theta ** (torch.arange(0, hd, 2).float() / hd))
        f = pos.float()[:, None] * inv[None]
        cos, sin = torch.cat([f, f], -1).cos()[:, None], torch.cat([f, f], -1).sin()[:, None]
        return v * cos + torch.cat([-v[..., hd // 2:], v[..., :hd // 2]], -1) * sin

    T = x.shape[0]
    h = rms(x, t[p + "input_layernorm.weight"])
    q = rope(rms((h @ t[p + "self_attn.q_proj.weight"].t()).view(T, nh, hd), t[p + "self_attn.q_norm.weight"]))
    k = rope(rms((h @ t[p + "self_attn.k_proj.weight"].t()).view(T, nkv, hd), t[p + "self_attn.k_norm.weight"]))
    v = (h @ t[p + "self_attn.v_proj.weight"].t()).view(T, nkv, hd)
    k, v = k.repeat_interleave(nh // nkv, 1), v.repeat_interleave(nh // nkv, 1)
    s = torch.einsum("qhd,khd->hqk", q, k) / hd ** 0.5
    s = s.masked_fill(~torch.ones(T, T, dtype=torch.bool).tril(), float("-inf"))
    a = torch.einsum("hqk,khd->qhd", s.softmax(-1), v).reshape(T, nh * hd)
    x = x + a @ t[p + "self_attn.o_proj.weight"].t()
    h = rms(x, t[p + "post_attention_layernorm.weight"])
    probs = F.softmax(h @ t[p + "mlp.gate.weight"].t(), -1)
    w, idx = probs.topk(c.num_experts_per_tok, -1)
    w = w / w.sum(-1, keepdim=True)
    out = torch.zeros_like(h)
    for tok in range(T):
        for j in range(c.num_experts_per_tok):
            e = int(idx[tok, j])
            q_ = p + f"mlp.experts.{e}."
            y = (F.silu(h[tok] @ t[q_ + "gate_proj.weight"].t()) * (h[tok] @ t[q_ + "up_proj.weight"].t())) \
                @ t[q_ + "down_proj.weight"].t()
            out[tok] += w[tok, j] * y
    return x + out


def main():
    ok = True
    with tempfile.TemporaryDirectory() as d:
        t = make_checkpoint(d)
        idx = WeightIndex(d)
        for L in range(CFG.num_hidden_layers):
            st = fake_stage(L)
            stats = load_stage_weights(st, idx)
            W = extract_stage_weights(st)
            x = torch.randn(7, CFG.hidden_size)
            pos = torch.arange(7)
            got = layer_output(W, x, pos, num_heads=CFG.num_attention_heads, num_kv_heads=CFG.num_key_value_heads,
                               head_dim=CFG.head_dim, top_k=CFG.num_experts_per_tok, norm_topk_prob=True,
                               rope_theta=CFG.rope_theta, eps=CFG.rms_norm_eps)
            # the stage holds fp16 copies of bf16 weights: compare against the HF-layout layer on
            # the same (fp16-rounded) values
            t16 = {k: v.half().float() for k, v in t.items()}
            want = hf_style_layer(t16, L, x, pos)
            err = ((got - want).abs().max() / want.abs().max()).item()
            good = err < 1e-4 and not stats["fp16_overflow"]
            ok &= good
            print(f"  {'ok ' if good else 'BAD'} layer {L}: {stats['copied']} tensors, packed-layout layer "
                  f"== HF-layout layer (rel err {err:.1e})")
            if L == 0:
                e_ok = torch.equal(st.embed_tokens.weight[:CFG.vocab_size].float(), t16["model.embed_tokens.weight"]) \
                    and st.embed_tokens.weight[CFG.vocab_size:].abs().sum() == 0
                print(f"  {'ok ' if e_ok else 'BAD'} embedding in rows [0, vocab), padding untouched")
                ok &= bool(e_ok)
            if L == CFG.num_hidden_layers - 1:
                h_ok = torch.equal(st.lm_head.weight[:CFG.vocab_size].float(), t16["lm_head.weight"]) and \
                    torch.equal(st.norm.weight.float(), t16["model.norm.weight"])
                print(f"  {'ok ' if h_ok else 'BAD'} final norm + lm_head")
                ok &= bool(h_ok)

    with tempfile.TemporaryDirectory() as d:
        make_checkpoint(d, big=True)
        stats = load_stage_weights(fake_stage(1), WeightIndex(d))
        good = stats["fp16_overflow"] == {"model.layers.1.o_proj": 1}
        print(f"  {'ok ' if good else 'BAD'} fp16 overflow reported + clamped: {stats['fp16_overflow']}")
        ok &= good

    for case, kw in [("missing expert tensor", {"drop": "model.layers.2.mlp.experts.5.up_proj.weight"}),
                     ("missing shard", {})]:
        with tempfile.TemporaryDirectory() as d:
            make_checkpoint(d, **kw)
            if case == "missing shard":
                os.remove(os.path.join(d, "model-00001-of-00002.safetensors"))
            try:
                for L in range(CFG.num_hidden_layers):
                    load_stage_weights(fake_stage(L), WeightIndex(d))
                print(f"  BAD {case}: not detected")
                ok = False
            except (KeyError, FileNotFoundError) as e:
                print(f"  ok  {case} detected: {type(e).__name__}: {str(e)[:90]}")
    print("ALL HF-WEIGHT LOADER TESTS PASSED" if ok else "FAILED")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
