"""
Data-driven ModelOnMachine for Qwen3-30B-A3B.

The LLaMA model managers hard-code one Python class per GPU type (llama2_70b/<gpu>/*.py) that
differ only in a few numbers. Here a single class reads everything from a profile directory
produced by tools/profile_qwen3_moe.py on that GPU:

    <profile_dir>/<MACHINE>/prompt_bs2time.csv   # num prompt tokens in a batch -> ms, one layer
    <profile_dir>/<MACHINE>/decode_bs2time.csv   # num decode requests in a batch -> ms, one layer
    <profile_dir>/<MACHINE>/meta.json            # see REQUIRED_META_KEYS

Semantics are identical to llama2_70b/a100/llama2_70b_a100.py:
  * times are per layer, in milliseconds (load_profile_csv converts to seconds)
  * kv_cache_capacity[k] counts (token x layer) KV entries when k layers are loaded. Helix's
    engine keeps one page pool shared by all layers on the node (llm_sys/engine/worker.py
    patches num_layers to 1), so capacity = block_size * total_pool_blocks. (The LLaMA files
    store total_pool_blocks / k in vllm_num_blocks_dict and multiply by k again.)
  * typical throughput is derived exactly like the LLaMA classes do.
"""
import json
import os
from typing import Dict

from simulator.event_simulator.compute_node import InferenceSettings
from simulator.event_simulator.model import MachineProfile
from simulator.event_simulator.utils import (DECODE_PER_TOKEN_MAX_CONTEXT, MAX_INPUT_LEN,
                                             linear_interpolate, load_profile_csv)
from simulator.model_manager.base_classes import ModelOnMachine
from simulator.model_manager.qwen3_30b_a3b.helper import typical_statistics, workload_ratio

REQUIRED_META_KEYS = ["machine_name", "max_num_layers", "block_size", "kv_cache_blocks",
                      "prompt_max_requests", "decode_max_tokens"]


def load_meta(machine_dir: str) -> dict:
    with open(os.path.join(machine_dir, "meta.json")) as f:
        meta = json.load(f)
    missing = [k for k in REQUIRED_META_KEYS if k not in meta]
    assert not missing, f"{machine_dir}/meta.json is missing keys {missing}"
    return meta


class ProfiledQwen3OnMachine(ModelOnMachine):
    def __init__(self, machine_dir: str, total_layers: int, num_machines_dict: Dict[str, int],
                 typical_layers_dict: Dict[str, int], normalized_perf_dict: Dict[str, float]):
        meta = load_meta(machine_dir)
        self.meta = meta
        self.machine_name: str = meta["machine_name"]
        self.num_machines_dict = num_machines_dict
        self.is_placeholder: bool = bool(meta.get("placeholder", False))

        # per-layer profiling tables (seconds after load_profile_csv)
        self.prompt_bs2time: Dict[int, float] = load_profile_csv(
            os.path.join(machine_dir, "prompt_bs2time.csv"))
        self.decode_bs2time: Dict[int, float] = load_profile_csv(
            os.path.join(machine_dir, "decode_bs2time.csv"))
        # vLLM already accounts for activation memory when sizing the KV pool -> 0 (as LLaMA)
        self.prompt_bs2vram: Dict[int, float] = {bs: 0 for bs in self.prompt_bs2time}
        self.decode_bs2vram: Dict[int, float] = {bs: 0 for bs in self.decode_bs2time}
        for name, table in [("prompt", self.prompt_bs2time), ("decode", self.decode_bs2time)]:
            assert 0 in table, f"{machine_dir}: {name} table must contain batch size 0"

        # capacity
        self.max_num_layers: int = int(meta["max_num_layers"])
        block_size = int(meta["block_size"])
        blocks = {int(k): int(v) for k, v in meta["kv_cache_blocks"].items()}
        assert set(blocks) == set(range(1, self.max_num_layers + 1)), \
            f"{machine_dir}: kv_cache_blocks must cover 1..{self.max_num_layers}"
        self.kv_cache_capacity: Dict[int, int] = {k: block_size * b for k, b in blocks.items()}
        assert all(v > 0 for v in self.kv_cache_capacity.values()), \
            f"{machine_dir}: non-positive KV capacity (too many layers for this GPU?)"
        self.activation_backup_capacity: Dict[int, int] = {k: 0 for k in self.kv_cache_capacity}

        # batch limits (must stay inside the profiled tables)
        prompt_max_requests = int(meta["prompt_max_requests"])
        decode_max_tokens = int(meta["decode_max_tokens"])
        assert max(self.prompt_bs2time) >= prompt_max_requests * MAX_INPUT_LEN, \
            f"{machine_dir}: prompt table must reach {prompt_max_requests * MAX_INPUT_LEN} tokens"
        assert max(self.decode_bs2time) >= decode_max_tokens, \
            f"{machine_dir}: decode table must reach {decode_max_tokens}"

        self.num_layers_to_inference_settings: Dict[int, InferenceSettings] = {}
        for k in range(1, self.max_num_layers + 1):
            ratio = workload_ratio(target_machine_name=self.machine_name, target_num_layers=k,
                                   total_layers=total_layers,
                                   num_machines_dict=num_machines_dict,
                                   typical_layers_dict=typical_layers_dict,
                                   normalized_perf_dict=normalized_perf_dict)
            p_req, p_tok, d_tok = typical_statistics(
                workload_ratio=ratio, num_kv_cache_entries=self.kv_cache_capacity[k],
                num_layers_on_node=k)
            assert p_req <= 1, "Typical requests should be less than 1!"
            self.num_layers_to_inference_settings[k] = InferenceSettings(
                prompt_max_requests=prompt_max_requests,
                prompt_max_tokens=prompt_max_requests * MAX_INPUT_LEN,
                prompt_typical_requests=p_req,
                prompt_typical_tokens=p_tok,
                decode_max_context=decode_max_tokens * DECODE_PER_TOKEN_MAX_CONTEXT,
                decode_max_tokens=decode_max_tokens,
                decode_typical_tokens=d_tok,
            )

    # ------------------------------------------------------------------------------------- #
    def get_profiling_results(self) -> MachineProfile:
        return MachineProfile(prompt_bs2time=self.prompt_bs2time, prompt_bs2vram=self.prompt_bs2vram,
                              decode_bs2time=self.decode_bs2time, decode_bs2vram=self.decode_bs2vram)

    def get_max_num_layers(self) -> int:
        return self.max_num_layers

    def get_inference_settings(self, num_on_node_layers: int) -> InferenceSettings:
        assert 0 < num_on_node_layers <= self.max_num_layers, "Bad number of layers on node!"
        return self.num_layers_to_inference_settings[num_on_node_layers]

    @staticmethod
    def _interp(table: Dict[int, float], x: int) -> float:
        left, right = -1, 1000 * 1000
        for point in table:
            if left < point <= x:
                left = point
            if x <= point < right:
                right = point
        assert left in table and right in table, f"cannot interpolate at {x}"
        return linear_interpolate(x_0=left, y_0=table[left], x_1=right, y_1=table[right],
                                  x_target=x)

    def get_typical_token_throughput(self, num_on_node_layers: int) -> float:
        # identical to LLaMa70BonA100.get_typical_token_throughput
        s = self.get_inference_settings(num_on_node_layers)
        if s.prompt_typical_requests >= 1:
            total_tokens = s.prompt_typical_tokens + s.decode_typical_tokens
            layer_time = (self._interp(self.prompt_bs2time, s.prompt_typical_tokens)
                          + self._interp(self.decode_bs2time, s.decode_typical_tokens))
        else:
            rescaling = 1 / s.prompt_typical_requests
            total_tokens = rescaling * (s.prompt_typical_tokens + s.decode_typical_tokens)
            layer_time = (self._interp(self.prompt_bs2time, int(s.prompt_typical_tokens * rescaling))
                          + self._interp(self.decode_bs2time, s.decode_typical_tokens) * rescaling)
        return total_tokens / (num_on_node_layers * layer_time)

    def get_kv_cache_capacity(self, num_on_node_layers: int) -> int:
        return self.kv_cache_capacity[num_on_node_layers]

    def get_activation_backup_capacity(self, num_on_node_layers: int) -> int:
        return self.activation_backup_capacity[num_on_node_layers]
