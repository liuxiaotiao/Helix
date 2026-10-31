"""
Qwen3-MoE (e.g. Qwen/Qwen3-30B-A3B) pipeline stage for Helix's layer-wise engine.

Helix runs every transformer layer as an independent "model" object (one per layer id, see
LayerwiseModelRunner.load_model), so this file mirrors llm_sys/engine/llama.py: a
Qwen3MoePipelineStage holds exactly one decoder layer, plus the embedding (layer 0) or the
final norm / lm_head / sampler (last layer).

Built on vLLM 0.4.0.post1 primitives. Differences from vLLM 0.4.0's Qwen2-MoE that matter
for Qwen3-MoE:
  * head_dim is read from the config (128 for Qwen3-30B-A3B, != hidden_size / num_heads = 64)
  * no QKV bias (config.attention_bias, default False)
  * QK-Norm: per-head RMSNorm on q and k before RoPE
  * no shared expert; router = softmax -> top-k -> renormalize (config.norm_topk_prob)
  * experts stored as two packed tensors and executed with vLLM's fused_moe Triton kernel

Unlike llama.py, the stage returns the full residual stream (mlp_out + residual) so that the
activations passed between Helix nodes are mathematically correct. llama.py drops the
residual (it only matters for output quality, not for compute cost).

Weights: like llama.py, only load_format="dummy" is supported.
"""
from typing import Any, Dict, List, Optional

import torch
from torch import nn
from transformers import PretrainedConfig

from vllm.attention import Attention, AttentionMetadata
from vllm.model_executor.layers.activation import SiluAndMul
from vllm.model_executor.layers.fused_moe import fused_moe
from vllm.model_executor.layers.layernorm import RMSNorm
from vllm.model_executor.layers.linear import (LinearMethodBase,
                                               MergedColumnParallelLinear,
                                               QKVParallelLinear,
                                               ReplicatedLinear,
                                               RowParallelLinear)
from vllm.model_executor.layers.logits_processor import LogitsProcessor
from vllm.model_executor.layers.rotary_embedding import get_rope
from vllm.model_executor.layers.sampler import Sampler
from vllm.model_executor.layers.vocab_parallel_embedding import (
    DEFAULT_VOCAB_PADDING_SIZE, ParallelLMHead, VocabParallelEmbedding)
from vllm.model_executor.parallel_utils.communication_op import (
    tensor_model_parallel_all_reduce)
from vllm.model_executor.parallel_utils.parallel_state import (
    get_tensor_model_parallel_world_size)
from vllm.model_executor.sampling_metadata import SamplingMetadata
from vllm.sequence import SamplerOutput

import importlib
import os

# --------------------------------------------------------------------------------------------- #
# moe_align_block_size on GPUs with little shared memory (Turing: T4, Quadro RTX 6000, ...)
#
# vLLM 0.4.0's CUDA kernel puts a ((E + 1) * E + E + 1) int32 table in shared memory and raises
# "CUDA error: invalid argument" when that exceeds the GPU's per-block limit. With Qwen3-MoE's
# E = 128 experts it needs 66,564 B; Turing (sm_75) allows 65,536 B (Ampere: up to 163 KB).
# On such GPUs we use an equivalent PyTorch implementation that produces the same
# (sorted_token_ids, expert_ids, num_tokens_post_padded) as the kernel, so fused_moe's Triton
# kernel sees identical inputs. Override: HELIX_MOE_ALIGN=torch | cuda | auto (default).
# --------------------------------------------------------------------------------------------- #
_MAX_SHARED_MEM_PER_BLOCK = {   # opt-in dynamic shared memory per block, bytes (CUDA docs)
    (7, 0): 98304, (7, 2): 98304, (7, 5): 65536,
    (8, 0): 166912, (8, 6): 101376, (8, 7): 166912, (8, 9): 101376, (9, 0): 232448,
}
_fused_moe_module = importlib.import_module("vllm.model_executor.layers.fused_moe.fused_moe")
_cuda_moe_align_block_size = _fused_moe_module.moe_align_block_size
_use_torch_align_cache: Dict[Any, bool] = {}


def moe_align_block_size_torch(topk_ids: torch.Tensor, block_size: int, num_experts: int):
    """PyTorch equivalent of vLLM 0.4.0's moe_align_block_size (same outputs, same layout):
    tokens of each expert, in ascending flattened order, padded to a multiple of block_size with
    the sentinel numel; expert_ids[b] = expert of block b; num_tokens_post_padded = total."""
    flat = topk_ids.flatten().long()
    numel, dev = flat.numel(), flat.device
    sorted_ids = torch.full((numel + num_experts * (block_size - 1),), numel, dtype=torch.int32,
                            device=dev)
    expert_ids = torch.zeros((numel + num_experts,), dtype=torch.int32, device=dev)
    counts = torch.bincount(flat, minlength=num_experts)
    padded = (counts + block_size - 1) // block_size * block_size
    pad_start = torch.cumsum(padded, 0) - padded          # where each expert's segment starts
    order = torch.sort(flat, stable=True).indices          # token slots grouped by expert
    sorted_exp = flat[order]
    rank = torch.arange(numel, device=dev) - (torch.cumsum(counts, 0) - counts)[sorted_exp]
    sorted_ids[pad_start[sorted_exp] + rank] = order.to(torch.int32)
    blocks = torch.repeat_interleave(torch.arange(num_experts, dtype=torch.int32, device=dev),
                                     padded // block_size)
    expert_ids[:blocks.numel()] = blocks
    num_tokens_post_pad = padded.sum().to(torch.int32).view(1)
    return sorted_ids, expert_ids, num_tokens_post_pad


def _use_torch_align(device: torch.device, num_experts: int) -> bool:
    mode = os.environ.get("HELIX_MOE_ALIGN", "auto").lower()
    if mode in ("torch", "cuda"):
        return mode == "torch"
    if device.type != "cuda":
        return True
    key = (device.index, num_experts)
    if key not in _use_torch_align_cache:
        cap = torch.cuda.get_device_capability(device)
        need = ((num_experts + 1) * num_experts + (num_experts + 1)) * 4
        _use_torch_align_cache[key] = need > _MAX_SHARED_MEM_PER_BLOCK.get(cap, 49152)
    return _use_torch_align_cache[key]


def _moe_align_block_size_dispatch(topk_ids: torch.Tensor, block_size: int, num_experts: int):
    if _use_torch_align(topk_ids.device, num_experts):
        return moe_align_block_size_torch(topk_ids, block_size, num_experts)
    return _cuda_moe_align_block_size(topk_ids, block_size, num_experts)


# fused_moe() looks the helper up in its own module at call time
_fused_moe_module.moe_align_block_size = _moe_align_block_size_dispatch


def _head_dim(config: PretrainedConfig) -> int:
    head_dim = getattr(config, "head_dim", None)
    if head_dim is None:
        head_dim = config.hidden_size // config.num_attention_heads
    return head_dim


class Qwen3MoeMLP(nn.Module):
    """Dense SwiGLU MLP (used only for layers listed in config.mlp_only_layers)."""

    def __init__(self, hidden_size: int, intermediate_size: int, hidden_act: str,
                 linear_method: Optional[LinearMethodBase] = None) -> None:
        super().__init__()
        self.gate_up_proj = MergedColumnParallelLinear(
            hidden_size, [intermediate_size] * 2, bias=False, linear_method=linear_method)
        self.down_proj = RowParallelLinear(
            intermediate_size, hidden_size, bias=False, linear_method=linear_method)
        if hidden_act != "silu":
            raise ValueError(f"Unsupported activation: {hidden_act}. Only silu is supported.")
        self.act_fn = SiluAndMul()

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        gate_up, _ = self.gate_up_proj(x)
        x = self.act_fn(gate_up)
        x, _ = self.down_proj(x)
        return x


class Qwen3MoeSparseMoeBlock(nn.Module):
    """
    Routed experts only (Qwen3-MoE has no shared expert).

    Packed layout expected by vLLM 0.4.0's fused_moe:
      w13: [num_experts, 2 * intermediate_per_tp, hidden]   (gate_proj ; up_proj)
      w2 : [num_experts, hidden, intermediate_per_tp]       (down_proj)
    Each expert is sharded along its intermediate dimension under tensor parallelism
    (same scheme as vLLM 0.4.0's Mixtral), followed by an all-reduce.
    """

    def __init__(self, config: PretrainedConfig,
                 linear_method: Optional[LinearMethodBase] = None) -> None:
        super().__init__()
        if linear_method is not None:
            raise NotImplementedError("Quantized experts are not supported in the Helix "
                                      "Qwen3-MoE stage.")
        self.tp_size = get_tensor_model_parallel_world_size()
        self.num_experts: int = config.num_experts
        self.top_k: int = config.num_experts_per_tok
        self.norm_topk_prob: bool = bool(getattr(config, "norm_topk_prob", True))
        self.hidden_size: int = config.hidden_size
        if config.moe_intermediate_size % self.tp_size != 0:
            raise ValueError(f"moe_intermediate_size={config.moe_intermediate_size} is not "
                             f"divisible by tensor parallel size {self.tp_size}.")
        self.intermediate_size: int = config.moe_intermediate_size // self.tp_size

        self.gate = ReplicatedLinear(self.hidden_size, self.num_experts, bias=False,
                                     linear_method=None)
        params_dtype = torch.get_default_dtype()
        self.w13 = nn.Parameter(torch.empty(self.num_experts, 2 * self.intermediate_size,
                                            self.hidden_size, dtype=params_dtype),
                                requires_grad=False)
        self.w2 = nn.Parameter(torch.empty(self.num_experts, self.hidden_size,
                                           self.intermediate_size, dtype=params_dtype),
                               requires_grad=False)

    def forward(self, hidden_states: torch.Tensor) -> torch.Tensor:
        num_tokens, hidden_size = hidden_states.shape
        hidden_states = hidden_states.view(-1, self.hidden_size)
        router_logits, _ = self.gate(hidden_states)  # [num_tokens, num_experts]
        # fused_moe: softmax over all experts -> top-k -> (optional) renormalize,
        # which is exactly Qwen3-MoE's routing.
        final_hidden_states = fused_moe(hidden_states, self.w13, self.w2, router_logits,
                                        self.top_k, renormalize=self.norm_topk_prob,
                                        inplace=True)
        if self.tp_size > 1:
            final_hidden_states = tensor_model_parallel_all_reduce(final_hidden_states)
        return final_hidden_states.view(num_tokens, hidden_size)


class Qwen3MoeAttention(nn.Module):

    def __init__(self, hidden_size: int, num_heads: int, num_kv_heads: int, head_dim: int,
                 rope_theta: float = 1000000.0, rope_scaling: Optional[Dict[str, Any]] = None,
                 max_position_embeddings: int = 4096, rms_norm_eps: float = 1e-6,
                 attention_bias: bool = False,
                 linear_method: Optional[LinearMethodBase] = None) -> None:
        super().__init__()
        self.hidden_size = hidden_size
        tp_size = get_tensor_model_parallel_world_size()
        self.total_num_heads = num_heads
        assert self.total_num_heads % tp_size == 0
        self.num_heads = self.total_num_heads // tp_size
        self.total_num_kv_heads = num_kv_heads
        if self.total_num_kv_heads >= tp_size:
            assert self.total_num_kv_heads % tp_size == 0
        else:
            assert tp_size % self.total_num_kv_heads == 0
        self.num_kv_heads = max(1, self.total_num_kv_heads // tp_size)
        self.head_dim = head_dim
        self.q_size = self.num_heads * self.head_dim
        self.kv_size = self.num_kv_heads * self.head_dim
        self.scaling = self.head_dim ** -0.5

        self.qkv_proj = QKVParallelLinear(hidden_size, self.head_dim, self.total_num_heads,
                                          self.total_num_kv_heads, bias=attention_bias,
                                          linear_method=linear_method)
        self.o_proj = RowParallelLinear(self.total_num_heads * self.head_dim, hidden_size,
                                        bias=attention_bias, linear_method=linear_method)
        self.rotary_emb = get_rope(self.head_dim, rotary_dim=self.head_dim,
                                   max_position=max_position_embeddings, base=rope_theta,
                                   is_neox_style=True, rope_scaling=rope_scaling)
        self.attn = Attention(self.num_heads, self.head_dim, self.scaling,
                              num_kv_heads=self.num_kv_heads)
        # QK-Norm (new in Qwen3): RMSNorm over each head's head_dim
        self.q_norm = RMSNorm(self.head_dim, eps=rms_norm_eps)
        self.k_norm = RMSNorm(self.head_dim, eps=rms_norm_eps)

    def forward(self, positions: torch.Tensor, hidden_states: torch.Tensor,
                kv_cache: torch.Tensor, attn_metadata: AttentionMetadata) -> torch.Tensor:
        qkv, _ = self.qkv_proj(hidden_states)
        q, k, v = qkv.split([self.q_size, self.kv_size, self.kv_size], dim=-1)
        # q / k are strided views of qkv; reshape() makes them contiguous per-head rows,
        # which the vLLM RMSNorm and rotary CUDA kernels expect.
        q = self.q_norm(q.reshape(-1, self.head_dim)).view(-1, self.q_size)
        k = self.k_norm(k.reshape(-1, self.head_dim)).view(-1, self.kv_size)
        q, k = self.rotary_emb(positions, q, k)
        attn_output = self.attn(q, k, v, kv_cache, attn_metadata)
        output, _ = self.o_proj(attn_output)
        return output


class Qwen3MoeDecoderLayer(nn.Module):

    def __init__(self, config: PretrainedConfig, layer_idx: int,
                 linear_method: Optional[LinearMethodBase] = None) -> None:
        super().__init__()
        self.hidden_size = config.hidden_size
        self.self_attn = Qwen3MoeAttention(
            hidden_size=config.hidden_size,
            num_heads=config.num_attention_heads,
            num_kv_heads=getattr(config, "num_key_value_heads", config.num_attention_heads),
            head_dim=_head_dim(config),
            rope_theta=getattr(config, "rope_theta", 1000000.0),
            rope_scaling=getattr(config, "rope_scaling", None),
            max_position_embeddings=getattr(config, "max_position_embeddings", 4096),
            rms_norm_eps=config.rms_norm_eps,
            attention_bias=getattr(config, "attention_bias", False),
            linear_method=linear_method,
        )
        mlp_only_layers = getattr(config, "mlp_only_layers", None) or []
        sparse_step = getattr(config, "decoder_sparse_step", 1)
        is_sparse = (layer_idx not in mlp_only_layers and config.num_experts > 0
                     and (layer_idx + 1) % sparse_step == 0)
        if is_sparse:
            self.mlp = Qwen3MoeSparseMoeBlock(config=config, linear_method=linear_method)
        else:
            self.mlp = Qwen3MoeMLP(config.hidden_size, config.intermediate_size,
                                   config.hidden_act, linear_method=linear_method)
        self.input_layernorm = RMSNorm(config.hidden_size, eps=config.rms_norm_eps)
        self.post_attention_layernorm = RMSNorm(config.hidden_size, eps=config.rms_norm_eps)

    def forward(self, positions: torch.Tensor, hidden_states: torch.Tensor,
                kv_cache: torch.Tensor, attn_metadata: AttentionMetadata,
                residual: Optional[torch.Tensor]):
        # Same contract as vLLM's decoder layers: returns (mlp_out, residual) where the
        # layer's true output is mlp_out + residual.
        if residual is None:
            residual = hidden_states
            hidden_states = self.input_layernorm(hidden_states)
        else:
            hidden_states, residual = self.input_layernorm(hidden_states, residual)
        hidden_states = self.self_attn(positions=positions, hidden_states=hidden_states,
                                       kv_cache=kv_cache, attn_metadata=attn_metadata)
        hidden_states, residual = self.post_attention_layernorm(hidden_states, residual)
        hidden_states = self.mlp(hidden_states)
        return hidden_states, residual


class Qwen3MoePipelineStage(nn.Module):
    """One Qwen3-MoE decoder layer as a Helix pipeline unit (see module docstring)."""

    packed_modules_mapping = {
        "qkv_proj": ["q_proj", "k_proj", "v_proj"],
        "gate_up_proj": ["gate_proj", "up_proj"],
    }
    embedding_modules = {
        "embed_tokens": "input_embeddings",
        "lm_head": "output_embeddings",
    }
    embedding_padding_modules = ["lm_head"]

    def __init__(self, config: PretrainedConfig,
                 linear_method: Optional[LinearMethodBase] = None,
                 lora_config=None) -> None:
        super().__init__()
        if lora_config is not None:
            raise NotImplementedError("LoRA is not supported in the Helix Qwen3-MoE stage.")
        self.config = config
        self.linear_method = linear_method
        self.vocab_size = config.vocab_size
        self.layer_id: int = config.layer_id  # set by LayerwiseModelRunner.load_model
        self.is_first_layer = self.layer_id == 0
        self.is_last_layer = self.layer_id == config.num_hidden_layers - 1

        self.decoder_layer = Qwen3MoeDecoderLayer(config, self.layer_id, linear_method)

        if self.is_first_layer:
            self.embed_tokens = VocabParallelEmbedding(self.vocab_size, config.hidden_size,
                                                       org_num_embeddings=config.vocab_size)
        if self.is_last_layer:
            self.norm = RMSNorm(config.hidden_size, eps=config.rms_norm_eps)
            # Note: Qwen3-30B-A3B has tie_word_embeddings=false. For tied checkpoints the
            # last stage still owns a separate (dummy) lm_head, which has the same cost.
            self.lm_head = ParallelLMHead(self.vocab_size, config.hidden_size,
                                          org_num_embeddings=config.vocab_size,
                                          padding_size=DEFAULT_VOCAB_PADDING_SIZE)
            self.logits_processor = LogitsProcessor(self.vocab_size, config.vocab_size,
                                                    getattr(config, "logit_scale", 1.0))
            self.sampler = Sampler()

    def get_input_embeddings(self, input_ids: torch.Tensor) -> torch.Tensor:
        return self.embed_tokens(input_ids)

    def forward(self, **kwargs) -> torch.Tensor:
        positions = kwargs["positions"]
        kv_cache = kwargs["kv_cache"]
        attn_metadata = kwargs["attn_metadata"]
        if self.is_first_layer:
            inputs_embeds = kwargs.get("input_embeds", None)
            hidden_states = (inputs_embeds if inputs_embeds is not None
                             else self.get_input_embeddings(kwargs["input_ids"]))
        else:
            hidden_states = kwargs["hidden_states"]

        mlp_out, residual = self.decoder_layer(positions, hidden_states, kv_cache,
                                               attn_metadata, None)
        if self.is_last_layer:
            # fused (mlp_out + residual) -> final RMSNorm
            hidden_states, _ = self.norm(mlp_out, residual)
        else:
            # full residual stream, sent to the next Helix node
            hidden_states = mlp_out + residual
        return hidden_states

    def compute_logits(self, hidden_states: torch.Tensor,
                       sampling_metadata: SamplingMetadata) -> torch.Tensor:
        return self.logits_processor(self.lm_head.weight, hidden_states, sampling_metadata)

    def sample(self, logits: torch.Tensor,
               sampling_metadata: SamplingMetadata) -> Optional[SamplerOutput]:
        return self.sampler(logits, sampling_metadata)

    def load_weights(self, model_name_or_path: str, cache_dir: Optional[str] = None,
                     load_format: str = "auto", revision: Optional[str] = None):
        # Same as llama.py: Helix's prototype only runs with load_format="dummy".
        raise NotImplementedError("Helix Qwen3-MoE stage only supports load_format='dummy'.")


# ----------------------------------------------------------------------------------------- #
# Register with vLLM 0.4.0's model registry. ModelRegistry.load_model_cls imports
# vllm.model_executor.models.<module> and does getattr(module, <class name>), so we attach
# the class to an existing module (same trick as llama.py).
from vllm.model_executor.models import _MODELS, qwen2_moe as _qwen2_moe_module  # noqa: E402

_MODELS["Qwen3MoeForCausalLM"] = ("qwen2_moe", "Qwen3MoePipelineStage")
_qwen2_moe_module.Qwen3MoePipelineStage = Qwen3MoePipelineStage
