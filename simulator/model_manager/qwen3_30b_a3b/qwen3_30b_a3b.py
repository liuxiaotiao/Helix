"""
ModelStatistics for Qwen/Qwen3-30B-A3B (MoE, 48 layers) in Helix's simulator / MILP planner.

Mirrors llama2_70b/llama2_70b.py, but every GPU type is loaded from measured profiles:

    profile dir = $HELIX_QWEN3_PROFILE_DIR, or simulator/model_manager/qwen3_30b_a3b/profiles
    one sub-directory per machine type, named exactly as in the cluster / machine-profile
    files (e.g. "A100", "L4", "T4", "V100"), produced by tools/profile_qwen3_moe.py.
"""
import os
import warnings
from typing import Dict, List

from simulator.event_simulator.compute_node import InferenceSettings
from simulator.event_simulator.model import MachineProfile
from simulator.model_manager.base_classes import ModelStatistics
from simulator.model_manager.qwen3_30b_a3b import model_card as card
from simulator.model_manager.qwen3_30b_a3b.profiled_machine import (ProfiledQwen3OnMachine,
                                                                    load_meta)

DEFAULT_PROFILE_DIR = os.path.join(os.path.dirname(os.path.realpath(__file__)), "profiles")


def get_profile_dir() -> str:
    return os.environ.get("HELIX_QWEN3_PROFILE_DIR", DEFAULT_PROFILE_DIR)


class Qwen3_30B_A3B_Statistics(ModelStatistics):
    def __init__(self, num_machines_dict: Dict[str, int]):
        profile_dir = get_profile_dir()
        machine_dirs: Dict[str, str] = {}
        for name in num_machines_dict:
            d = os.path.join(profile_dir, name)
            if not os.path.isfile(os.path.join(d, "meta.json")):
                raise FileNotFoundError(
                    f"No Qwen3-30B-A3B profile for machine type '{name}' in {profile_dir}. "
                    f"Run tools/profile_qwen3_moe.py on a '{name}' GPU (see "
                    f"simulator/model_manager/qwen3_30b_a3b/README.md).")
            machine_dirs[name] = d
        max_layers = {name: int(load_meta(d)["max_num_layers"]) for name, d in machine_dirs.items()}

        # typical #layers per machine type: same two-regime rule as the LLaMA managers, but
        # derived from each GPU's capacity instead of hand-written tables
        typical_layers_dict = {n: max(1, round(0.6 * m)) for n, m in max_layers.items()}
        capacity = sum(num_machines_dict[n] * typical_layers_dict[n] for n in num_machines_dict)
        if capacity < card.TOTAL_LAYERS * 1.2:
            typical_layers_dict = dict(max_layers)

        # fixed-point iteration for the normalised per-machine performance (as in LLaMA code)
        normalized_perf_dict = {n: 10.0 for n in num_machines_dict}
        for _ in range(10):
            new_perf = {}
            for n, d in machine_dirs.items():
                m = ProfiledQwen3OnMachine(d, card.TOTAL_LAYERS, num_machines_dict,
                                           typical_layers_dict, normalized_perf_dict)
                new_perf[n] = (m.get_typical_token_throughput(typical_layers_dict[n])
                               * typical_layers_dict[n])
            normalized_perf_dict = new_perf

        self.num_machines_dict = num_machines_dict
        self.typical_layers_dict = typical_layers_dict
        self.normalized_perf_dict = normalized_perf_dict
        self.machines: Dict[str, ProfiledQwen3OnMachine] = {
            n: ProfiledQwen3OnMachine(d, card.TOTAL_LAYERS, num_machines_dict,
                                      typical_layers_dict, normalized_perf_dict)
            for n, d in machine_dirs.items()
        }
        placeholders = [n for n, m in self.machines.items() if m.is_placeholder]
        if placeholders:
            warnings.warn(f"Qwen3-30B-A3B profiles for {placeholders} are PLACEHOLDERS (not "
                          f"measured). Results are only good for testing the pipeline.")

        self.token_size: float = card.TOKEN_SIZE
        self.activation_size: float = card.ACTIVATION_SIZE
        self.model_param_sizes: List[float] = [card.LAYER_PARAM_BYTES] * card.TOTAL_LAYERS

    def _m(self, machine_type: str) -> ProfiledQwen3OnMachine:
        assert machine_type in self.machines, f"Machine type {machine_type} not found!"
        return self.machines[machine_type]

    # ---------------------------------------- Machine ---------------------------------------- #
    def get_profiling_results(self, machine_type: str) -> MachineProfile:
        return self._m(machine_type).get_profiling_results()

    def get_max_num_layers(self, machine_type: str) -> int:
        return self._m(machine_type).get_max_num_layers()

    def get_inference_settings(self, machine_type: str, num_on_node_layers: int) -> InferenceSettings:
        return self._m(machine_type).get_inference_settings(num_on_node_layers)

    def get_typical_token_throughput(self, machine_type: str, num_on_node_layers: int) -> float:
        return self._m(machine_type).get_typical_token_throughput(num_on_node_layers)

    def get_kv_cache_capacity(self, machine_type: str, num_on_node_layers: int) -> int:
        return self._m(machine_type).get_kv_cache_capacity(num_on_node_layers)

    def get_activation_backup_capacity(self, machine_type: str, num_on_node_layers: int) -> int:
        return self._m(machine_type).get_activation_backup_capacity(num_on_node_layers)

    # ----------------------------------------- Model ----------------------------------------- #
    def get_model_params(self) -> List[float]:
        return self.model_param_sizes

    def get_model_token_size(self) -> float:
        return self.token_size

    def get_model_activation_size(self) -> float:
        return self.activation_size
