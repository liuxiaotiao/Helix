# 2024.04.24 Yixuan Mei
import ipaddress
import os
import socket

# in simulator, the first compute node has idx 2
# in real sys, the first compute node has idx 1
# simulator idx - SIMULATOR_NODE_OFFSET = real node idx
SIMULATOR_NODE_OFFSET = 1


def to_real(node_id: int) -> int:
    if node_id == 0 or node_id == 1:
        return 0
    else:
        return node_id - SIMULATOR_NODE_OFFSET


# Address of the host's config-broadcast socket (the host machine's IP). Can be overridden with
# the environment variable HELIX_CONFIG_BROADCAST_ADDR, e.g. "tcp://10.0.0.1:5000", so that the
# same checkout works on any cluster without editing this file.
CONFIG_BROADCAST_ADDR = os.environ.get("HELIX_CONFIG_BROADCAST_ADDR", "tcp://10.128.0.31:5000")


def warm_up():
    import torch  # lazy: config generation / layout tools do not need torch
    # create a tensor and move it to GPU (Warm up GPU)
    x = torch.tensor([1, 2, 3])
    for i in range(100):
        x.cuda()


def get_local_ip():
    # Explicit override (clusters with several NICs, or without a default route to the internet)
    if os.environ.get("HELIX_LOCAL_IP"):
        return os.environ["HELIX_LOCAL_IP"]
    # Attempt to connect to an internet host in order to determine the local interface
    try:
        # Create a dummy socket to connect to an Internet IP or DNS
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            # Use Google's public DNS server to find out our IP
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
        return ip
    except Exception as e:
        return f"Error obtaining local IP: {str(e)}"


def assert_usable_local_ip(ip: str) -> None:
    """
    Original Helix check: the local IP must be a 10.x.x.x cluster address. Workers identify
    themselves to the host by this IP, so it must equal the ip_address in real_sys_config.txt.
    Setting HELIX_LOCAL_IP explicitly lifts the 10.x restriction.
    """
    try:
        ipaddress.IPv4Address(ip)
    except ValueError:
        raise AssertionError(f"Could not determine the local IP ({ip}). "
                             f"Set HELIX_LOCAL_IP=<this machine's cluster IP>.")
    assert ip.startswith("10") or os.environ.get("HELIX_LOCAL_IP"), \
        f"Local IP {ip} is not of form 10.xxx.xxx.xxx. If it is the right cluster interface, " \
        f"set HELIX_LOCAL_IP={ip} explicitly."


class FlyingQuery:
    def __init__(self, query_uid, input_length, output_length, compute_node_uids, start_layers, end_layers, pipeline):
        self.query_uid = query_uid
        self.input_length = input_length
        self.output_length = output_length
        self.processed_tokens = 0

        # scheduling
        self.compute_node_uids = compute_node_uids
        self.start_layers = start_layers
        self.end_layers = end_layers
        # List[PipelineStage]
        self.pipeline = pipeline


def write_run_info(result_dir: str, ground_zero: float) -> None:
    """Wall-clock time (time.time()) of t=0 in events.txt, so per-node samples taken during the
    run (examples/real_sys_qwen3: GPU utilization / memory / power) can be lined up with it."""
    import json
    import socket
    with open(os.path.join(result_dir, "run_info.json"), "w") as f:
        json.dump({"ground_zero": ground_zero, "host": socket.gethostname()}, f)
