"""
CPU-only structural test for the Helix Qwen3-MoE stage (no GPU needed).

Builds Qwen3MoePipelineStage for the first / a middle / the last layer on the `meta` device
with vLLM 0.4.0.post1 and checks:
  * vLLM's model registry resolves Qwen3MoeForCausalLM to our stage class
  * the config in examples/real_sys_qwen3/model is parsed as Helix/vLLM expect
  * every parameter has the expected shape, and the totals add up to Qwen3-30B-A3B (~30.5B)
  * vLLM's dummy-weight init (state_dict based) touches the packed expert tensors and does
    not touch the RoPE cos/sin cache

Run from the repo root:  python tests/qwen3_moe/test_cpu_structure.py
"""
import os
import sys
import tempfile

import torch

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, REPO)
MODEL_DIR = os.path.join(REPO, "examples", "real_sys_qwen3", "model")


def stub_cuda_extension_if_needed():
    # vllm._C (vLLM's CUDA kernels) needs the NVIDIA driver (libcuda.so.1) just to import.
    # This test only runs module constructors, never kernels, so on a GPU-less machine we
    # replace it with an empty placeholder. On a GPU machine the real extension is used.
    try:
        import vllm._C  # noqa: F401
    except ImportError:
        import types
        stub = types.ModuleType("vllm._C")
        stub.ops = types.SimpleNamespace()
        stub.cache_ops = types.SimpleNamespace()
        stub.custom_ar = types.SimpleNamespace()
        sys.modules["vllm._C"] = stub
        print("[info] no CUDA driver: using a placeholder for vllm._C (constructors only)")


def init_single_process_tp():
    from vllm.model_executor.parallel_utils import parallel_state
    if not torch.distributed.is_initialized():
        init_file = tempfile.NamedTemporaryFile(delete=False).name
        torch.distributed.init_process_group("gloo", init_method=f"file://{init_file}",
                                             world_size=1, rank=0)
    parallel_state.initialize_model_parallel(1, 1)


def force_xformers_backend():
    # vLLM 0.4.0 queries the CUDA device to choose an attention backend; on a CPU-only box we
    # pick XFormers (what T4/V100 use). Only the module constructor runs here.
    import vllm.attention.selector as selector
    selector._can_use_flash_attn = lambda dtype: False


def expected_layer_shapes(cfg):
    H, nh, nkv, hd = cfg.hidden_size, cfg.num_attention_heads, cfg.num_key_value_heads, cfg.head_dim
    E, I = cfg.num_experts, cfg.moe_intermediate_size
    return {
        "decoder_layer.self_attn.qkv_proj.weight": (nh * hd + 2 * nkv * hd, H),
        "decoder_layer.self_attn.o_proj.weight": (H, nh * hd),
        "decoder_layer.self_attn.q_norm.weight": (hd,),
        "decoder_layer.self_attn.k_norm.weight": (hd,),
        "decoder_layer.mlp.gate.weight": (E, H),
        "decoder_layer.mlp.w13": (E, 2 * I, H),
        "decoder_layer.mlp.w2": (E, H, I),
        "decoder_layer.input_layernorm.weight": (H,),
        "decoder_layer.post_attention_layernorm.weight": (H,),
    }


def main():
    stub_cuda_extension_if_needed()
    init_single_process_tp()
    force_xformers_backend()

    import llm_sys.engine.qwen3_moe as q3  # noqa: F401  (registers the architecture)
    from vllm.config import ModelConfig
    from vllm.model_executor.models import ModelRegistry

    # 1) registry
    cls = ModelRegistry.load_model_cls("Qwen3MoeForCausalLM")
    assert cls is q3.Qwen3MoePipelineStage, cls
    print("[ok] registry: Qwen3MoeForCausalLM ->", cls.__name__)

    # 2) config as seen by vLLM
    mc = ModelConfig(model=MODEL_DIR, tokenizer=MODEL_DIR, tokenizer_mode="auto",
                     trust_remote_code=False, download_dir=None, load_format="dummy",
                     dtype="auto", seed=0)
    cfg = mc.hf_config
    assert mc.get_head_size() == 128 and mc.dtype == torch.float16 and mc.max_model_len == 4096
    assert cfg.num_hidden_layers == 48 and cfg.num_experts == 128 and cfg.num_experts_per_tok == 8
    assert mc.get_sliding_window() is None
    print(f"[ok] config: head_dim={mc.get_head_size()} dtype={mc.dtype} "
          f"max_model_len={mc.max_model_len} layers={cfg.num_hidden_layers}")

    # 3) build stages and check shapes / counts
    expected = expected_layer_shapes(cfg)
    total = 0
    per_layer = None
    for layer_id in [0, 23, cfg.num_hidden_layers - 1]:
        cfg.layer_id = layer_id
        with torch.device("meta"):
            torch.set_default_dtype(torch.float16)
            stage = cls(cfg, None)
            torch.set_default_dtype(torch.float32)
        params = dict(stage.named_parameters())
        for name, shape in expected.items():
            assert tuple(params[name].shape) == shape, (layer_id, name, params[name].shape, shape)
        assert params["decoder_layer.mlp.w13"].dtype == torch.float16
        layer_params = sum(p.numel() for n, p in params.items() if n.startswith("decoder_layer."))
        extra = {n: tuple(p.shape) for n, p in params.items() if not n.startswith("decoder_layer.")}
        if per_layer is None:
            per_layer = layer_params
        assert layer_params == per_layer
        if layer_id == 0:
            assert set(extra) == {"embed_tokens.weight"}, extra
        elif layer_id == cfg.num_hidden_layers - 1:
            assert set(extra) == {"norm.weight", "lm_head.weight"}, extra
        else:
            assert extra == {}, extra
        total_extra = sum(params[n].numel() for n in extra)
        total += total_extra
        sd_keys = list(stage.state_dict().keys())
        assert "decoder_layer.mlp.w13" in sd_keys and "decoder_layer.mlp.w2" in sd_keys
        assert not any("cos_sin_cache" in k for k in sd_keys), "RoPE cache would be overwritten"
        print(f"[ok] layer {layer_id:2d}: {layer_params / 1e6:.2f}M layer params, "
              f"extra={extra}")

    total += per_layer * cfg.num_hidden_layers
    hand_count = (
        (cfg.num_attention_heads * 128 + 2 * cfg.num_key_value_heads * 128) * 2048  # qkv
        + 2048 * cfg.num_attention_heads * 128                                          # o
        + 2 * 128 + 2 * 2048                                                             # norms
        + cfg.num_experts * 2048                                                         # router
        + cfg.num_experts * 3 * 2048 * cfg.moe_intermediate_size                         # experts
    )
    assert per_layer == hand_count, (per_layer, hand_count)
    print(f"[ok] per-layer params = {per_layer:,} (= {per_layer * 2 / 2**30:.3f} GiB fp16)")
    print(f"[ok] whole model      = {total:,} (~{total / 1e9:.2f}B; Qwen3-30B-A3B is 30.5B)")
    assert 30.4e9 < total < 30.6e9
    print("ALL CPU STRUCTURE CHECKS PASSED")


if __name__ == "__main__":
    main()
