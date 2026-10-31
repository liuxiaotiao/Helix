"""
Static description of Qwen/Qwen3-30B-A3B as used by Helix's simulator and placement planner.
All numbers follow the official config.json (see examples/real_sys_qwen3/model/config.json).
"""
from simulator.event_simulator.utils import Byte

TOTAL_LAYERS = 48
HIDDEN_SIZE = 2048
NUM_HEADS, NUM_KV_HEADS, HEAD_DIM = 32, 4, 128
NUM_EXPERTS, TOP_K, MOE_INTERMEDIATE = 128, 8, 768
VOCAB_SIZE = 151936
DTYPE_BYTES = 2  # fp16 (Helix runtime runs fp16 so that T4 / V100 work)

# parameters of one decoder layer (checked against the real stage in
# tests/qwen3_moe/test_cpu_structure.py: 623,120,640)
LAYER_PARAMS = (
    (NUM_HEADS * HEAD_DIM + 2 * NUM_KV_HEADS * HEAD_DIM) * HIDDEN_SIZE   # qkv_proj
    + HIDDEN_SIZE * NUM_HEADS * HEAD_DIM                                   # o_proj
    + 2 * HEAD_DIM + 2 * HIDDEN_SIZE                                       # q/k norm, 2 layer norms
    + NUM_EXPERTS * HIDDEN_SIZE                                            # router
    + NUM_EXPERTS * 3 * HIDDEN_SIZE * MOE_INTERMEDIATE                     # experts (gate, up, down)
)
LAYER_PARAM_BYTES = LAYER_PARAMS * DTYPE_BYTES * Byte   # 1.246 GB per layer

# what flows over the network (same conventions as llama2_70b.py)
TOKEN_SIZE = 2 * Byte                                   # a token id
ACTIVATION_SIZE = HIDDEN_SIZE * DTYPE_BYTES * Byte      # hidden state of one token: 4 KB

# KV cache of one token in one layer: K and V, 4 kv heads x 128 dims, fp16 -> 2 KB
KV_BYTES_PER_TOKEN_LAYER = 2 * NUM_KV_HEADS * HEAD_DIM * DTYPE_BYTES

assert LAYER_PARAMS == 623_120_640
