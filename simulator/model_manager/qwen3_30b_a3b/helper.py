"""
Same model as llama2_70b/helper.py, with the total layer count passed in instead of hard-coded.
"""
from typing import Dict, Tuple

from simulator.event_simulator.utils import AVG_INPUT_LEN, AVG_OUTPUT_LEN, KV_CACHE_HWM


def workload_ratio(target_machine_name: str, target_num_layers: int, total_layers: int,
                   num_machines_dict: Dict[str, int], typical_layers_dict: Dict[str, int],
                   normalized_perf_dict: Dict[str, float]) -> float:
    """workload_ratio = num_layers * t_machine / T, T = round-trip time of a request."""
    assert num_machines_dict.keys() == typical_layers_dict.keys() == normalized_perf_dict.keys()
    layer_times = {name: 1 / perf for name, perf in normalized_perf_dict.items()}
    sum_time, sum_layers = 0.0, 0
    for name, count in num_machines_dict.items():
        sum_time += count * typical_layers_dict[name] * layer_times[name]
        sum_layers += count * typical_layers_dict[name]
    round_trip = (total_layers - target_num_layers) * (sum_time / sum_layers)
    batch_time = target_num_layers * layer_times[target_machine_name]
    round_trip += batch_time
    assert round_trip > batch_time, "Round trip time is smaller than batch time!"
    return batch_time / round_trip


def typical_statistics(workload_ratio: float, num_kv_cache_entries: int,
                       num_layers_on_node: int) -> Tuple[float, int, int]:
    """prompt_typical_requests, prompt_typical_tokens, decode_typical_tokens (as llama2_70b)."""
    seq_length = AVG_INPUT_LEN + AVG_OUTPUT_LEN
    available_layer_entries = int(KV_CACHE_HWM * num_kv_cache_entries / num_layers_on_node)
    prompt_typical_requests = available_layer_entries / seq_length * workload_ratio / AVG_OUTPUT_LEN
    prompt_typical_tokens = round(prompt_typical_requests * AVG_INPUT_LEN)
    decode_typical_tokens = round(available_layer_entries / seq_length * workload_ratio)
    if prompt_typical_requests > 1:
        prompt_typical_requests = 1
        prompt_typical_tokens = AVG_INPUT_LEN
        decode_typical_tokens = AVG_OUTPUT_LEN
    return prompt_typical_requests, prompt_typical_tokens, decode_typical_tokens
