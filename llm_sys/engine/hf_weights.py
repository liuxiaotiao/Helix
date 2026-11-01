"""
Load real HuggingFace Qwen3-MoE safetensors weights into Helix Qwen3MoePipelineStage modules
(llm_sys/engine/qwen3_moe.py), one layer at a time. Only torch + safetensors are needed here
(no vLLM), so the mapping can be unit-tested without a GPU.

Checkpoint names (Qwen/Qwen3-30B-A3B)          -> Helix stage parameter
  model.layers.{i}.self_attn.{q,k,v}_proj.weight -> decoder_layer.self_attn.qkv_proj.weight  rows [q; k; v]
  model.layers.{i}.self_attn.o_proj.weight       -> decoder_layer.self_attn.o_proj.weight
  model.layers.{i}.self_attn.{q,k}_norm.weight   -> decoder_layer.self_attn.{q,k}_norm.weight
  model.layers.{i}.input_layernorm.weight        -> decoder_layer.input_layernorm.weight
  model.layers.{i}.post_attention_layernorm.weight -> decoder_layer.post_attention_layernorm.weight
  model.layers.{i}.mlp.gate.weight               -> decoder_layer.mlp.gate.weight            (router)
  model.layers.{i}.mlp.experts.{e}.gate_proj.weight -> decoder_layer.mlp.w13[e, :I]
  model.layers.{i}.mlp.experts.{e}.up_proj.weight   -> decoder_layer.mlp.w13[e, I:]
  model.layers.{i}.mlp.experts.{e}.down_proj.weight -> decoder_layer.mlp.w2[e]
  model.layers.{i}.mlp.{gate,up,down}_proj.weight   -> dense MLP (config.mlp_only_layers only)
  model.embed_tokens.weight                      -> embed_tokens.weight[:vocab]   (layer 0 only)
  model.norm.weight, lm_head.weight              -> norm.weight, lm_head.weight[:vocab] (last layer)
This is the packed layout checked against HF transformers in tests/qwen3_moe/test_ref_vs_hf.py.
Tensor parallelism is not supported here (tp = 1, as in all Helix deployments so far).

The checkpoint is bf16; Helix runs fp16 (Turing has no bf16). Values beyond the fp16 range
(|x| > 65504) would become inf: they are counted and reported, and clamped.
"""
import json
import os
import re
from collections import defaultdict
from typing import Dict, List

import torch

FP16_MAX = 65504.0


class WeightIndex:
    """model.safetensors.index.json of a (possibly partial) local checkpoint directory."""

    def __init__(self, weights_dir: str):
        self.dir = weights_dir
        path = os.path.join(weights_dir, "model.safetensors.index.json")
        if not os.path.exists(path):
            raise FileNotFoundError(f"{path} not found: download the weights first "
                                    f"(examples/real_sys_qwen3/cluster_ctl.py weights)")
        self.weight_map: Dict[str, str] = json.load(open(path))["weight_map"]

    def names_for_layer(self, layer_id: int, num_layers: int) -> List[str]:
        prefix = f"model.layers.{layer_id}."
        names = [n for n in self.weight_map if n.startswith(prefix)]
        if layer_id == 0:
            names.append("model.embed_tokens.weight")
        if layer_id == num_layers - 1:
            names += ["model.norm.weight", "lm_head.weight"]
        return names

    def read(self, names: List[str]) -> Dict[str, torch.Tensor]:
        """name -> CPU tensor, reading each shard once."""
        from safetensors import safe_open
        by_shard = defaultdict(list)
        for n in names:
            if n not in self.weight_map:
                raise KeyError(f"{n} is not in the checkpoint index")
            by_shard[self.weight_map[n]].append(n)
        out = {}
        for shard, ns in sorted(by_shard.items()):
            path = os.path.join(self.dir, shard)
            if not os.path.exists(path):
                raise FileNotFoundError(f"{path} is missing: this node has not downloaded the shard "
                                        f"holding {ns[0]} (run cluster_ctl.py weights for this layout)")
            with safe_open(path, framework="pt", device="cpu") as f:
                for n in ns:
                    out[n] = f.get_tensor(n)
        return out


def _copy(dst: torch.Tensor, src: torch.Tensor, name: str, stats: dict):
    if tuple(dst.shape) != tuple(src.shape):
        raise ValueError(f"{name}: checkpoint shape {tuple(src.shape)} != parameter slice {tuple(dst.shape)}")
    if dst.dtype == torch.float16:
        big = int((src.float().abs() > FP16_MAX).sum())
        if big:
            stats["fp16_overflow"][name] = big
            src = src.float().clamp(-FP16_MAX, FP16_MAX)
    dst.copy_(src.to(device=dst.device, dtype=dst.dtype))
    stats["copied"] += 1


@torch.no_grad()
def load_stage_weights(stage, index: WeightIndex) -> dict:
    """Fill one Qwen3MoePipelineStage (layer `stage.layer_id`) from the checkpoint.
    Returns {"layer", "copied", "fp16_overflow": {name: count}}; raises if anything is missing."""
    cfg = stage.config
    L = stage.layer_id
    num_layers = cfg.num_hidden_layers
    layer = stage.decoder_layer
    attn, mlp = layer.self_attn, layer.mlp
    hd = attn.head_dim
    q_size, kv_size = attn.total_num_heads * hd, attn.total_num_kv_heads * hd
    tensors = index.read(index.names_for_layer(L, num_layers))
    stats = {"layer": L, "copied": 0, "fp16_overflow": {}}
    p = f"model.layers.{L}."
    seen = set()

    def take(name):
        seen.add(name)
        return tensors[name]

    qkv = attn.qkv_proj.weight.data
    if qkv.shape[0] != q_size + 2 * kv_size:
        raise NotImplementedError("tensor parallelism is not supported by the HF weight loader")
    _copy(qkv[:q_size], take(p + "self_attn.q_proj.weight"), p + "q_proj", stats)
    _copy(qkv[q_size:q_size + kv_size], take(p + "self_attn.k_proj.weight"), p + "k_proj", stats)
    _copy(qkv[q_size + kv_size:], take(p + "self_attn.v_proj.weight"), p + "v_proj", stats)
    _copy(attn.o_proj.weight.data, take(p + "self_attn.o_proj.weight"), p + "o_proj", stats)
    _copy(attn.q_norm.weight.data, take(p + "self_attn.q_norm.weight"), p + "q_norm", stats)
    _copy(attn.k_norm.weight.data, take(p + "self_attn.k_norm.weight"), p + "k_norm", stats)
    _copy(layer.input_layernorm.weight.data, take(p + "input_layernorm.weight"), p + "input_layernorm", stats)
    _copy(layer.post_attention_layernorm.weight.data, take(p + "post_attention_layernorm.weight"),
          p + "post_attention_layernorm", stats)

    if hasattr(mlp, "w13"):    # sparse MoE block
        _copy(mlp.gate.weight.data, take(p + "mlp.gate.weight"), p + "mlp.gate", stats)
        inter = mlp.w2.shape[2]
        expert_re = re.compile(re.escape(p) + r"mlp\.experts\.(\d+)\.(gate_proj|up_proj|down_proj)\.weight$")
        got = set()
        for name, t in tensors.items():
            m = expert_re.match(name)
            if not m:
                continue
            e, kind = int(m.group(1)), m.group(2)
            seen.add(name)
            got.add((e, kind))
            if kind == "gate_proj":
                _copy(mlp.w13.data[e, :inter], t, name, stats)
            elif kind == "up_proj":
                _copy(mlp.w13.data[e, inter:], t, name, stats)
            else:
                _copy(mlp.w2.data[e], t, name, stats)
        missing = [(e, k) for e in range(mlp.num_experts) for k in ("gate_proj", "up_proj", "down_proj")
                   if (e, k) not in got]
        if missing:
            raise KeyError(f"layer {L}: {len(missing)} expert tensors missing, e.g. {missing[:3]}")
    else:                      # dense MLP (mlp_only_layers)
        gu = mlp.gate_up_proj.weight.data
        half = gu.shape[0] // 2
        _copy(gu[:half], take(p + "mlp.gate_proj.weight"), p + "mlp.gate_proj", stats)
        _copy(gu[half:], take(p + "mlp.up_proj.weight"), p + "mlp.up_proj", stats)
        _copy(mlp.down_proj.weight.data, take(p + "mlp.down_proj.weight"), p + "mlp.down_proj", stats)

    if getattr(stage, "is_first_layer", False):
        emb = take("model.embed_tokens.weight")
        _copy(stage.embed_tokens.weight.data[:emb.shape[0]], emb, "embed_tokens", stats)
    if getattr(stage, "is_last_layer", False):
        _copy(stage.norm.weight.data, take("model.norm.weight"), "model.norm", stats)
        head = take("lm_head.weight")
        _copy(stage.lm_head.weight.data[:head.shape[0]], head, "lm_head", stats)

    unused = sorted(set(tensors) - seen)
    if unused:
        raise KeyError(f"layer {L}: checkpoint tensors not mapped to any parameter: {unused[:5]}")
    return stats


def default_weights_dir(repo_root: str) -> str:
    """cluster.json "weights.dir" (examples/real_sys_qwen3), or $HELIX_WEIGHTS_DIR."""
    if os.environ.get("HELIX_WEIGHTS_DIR"):
        return os.environ["HELIX_WEIGHTS_DIR"]
    cj = os.path.join(repo_root, "examples", "real_sys_qwen3", "cluster.json")
    if os.path.exists(cj):
        d = json.load(open(cj)).get("weights", {}).get("dir")
        if d:
            return os.path.expanduser(d)
    raise SystemExit("no weights directory: pass --weights DIR, set HELIX_WEIGHTS_DIR, or set "
                     '"weights": {"dir": ...} in examples/real_sys_qwen3/cluster.json')
