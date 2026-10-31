# Qwen3-30B-A3B in Helix 的模拟器和 MILP 布局（路线 1）

## 这一部分做了什么

- **模型条目**：在 `simulator/model_manager/model_manager.py` 里新增 `ModelName.Qwen3_30B_A3B`。整个代码库中只有这一处会按模型名称做分支，其余地方只是透传。
- **`model_card.py`**：模型的静态参数。
  - 48 层，每层 623,120,640 个参数（1.246 GB fp16）；
  - token 大小 2 B；activation 大小 4 KB（hidden 2048 × fp16）；
  - 每个 token 每层的 KV 为 2 KB。
- **`profiled_machine.py`**：一个通用的、按数据驱动的 GPU 类，从 `profiles/<GPU>/` 目录读取数据，取代 LLaMA 那样每种 GPU 手写一个类的做法。计算方法和 `llama2_70b/a100/llama2_70b_a100.py` 完全一致：
  - 单层延迟表的单位是 ms；
  - 每个节点的 typical throughput T_k 用同样的方法推导；
  - KV 容量以 token × 层计。
- **`qwen3_30b_a3b.py`**：对应 `LLaMa70BStatistics`，包括 typical layers 的两档规则和归一化性能的不动点迭代。不同的是，各 GPU 的 typical layers 由该 GPU 能放的最大层数推导出来，不再是手写的表。
- **`tools/profile_qwen3_moe.py`**：在单张 GPU 上用 Helix 自己的引擎做测量，测完直接写出 profile 目录。

## Profile 目录格式

默认位置是 `simulator/model_manager/qwen3_30b_a3b/profiles/<GPU>/`，可以用环境变量 `HELIX_QWEN3_PROFILE_DIR` 指向其他目录。

| 文件 | 内容 |
|---|---|
| `prompt_bs2time.csv` | 一个 batch 中 prompt token 的总数 → 单层耗时（ms），从 0 覆盖到 4096 |
| `decode_bs2time.csv` | 一个 batch 中 decode 的请求数 → 单层耗时（ms），从 0 覆盖到 256 |
| `meta.json` | 见下表 |

`meta.json` 的字段：

| 字段 | 含义 |
|---|---|
| `max_num_layers` | 这台机器最多放的层数，满足 Helix 的"一半显存放参数"规则。T4 和 V100 为 6，L4 为 9，A100-40G 为 16。 |
| `kv_cache_blocks` | 加载 k 层时 Helix 统一页池的 block 总数，k 从 1 到 max。KV 容量 = 16 × block 数。 |
| `prompt_max_requests` / `decode_max_tokens` | 默认 2 和 256，等于 Helix 引擎自身的上限（`max_num_batched_tokens=4096`、`max_num_seqs=256`），保证模拟器不会模拟出真实引擎跑不了的 batch。 |
| `placeholder` | `true` 表示这份 profile 不是实测数据，模拟器加载时会发出警告。 |

## 运行前检查

```bash
python tools/preflight_qwen3.py runtime                      # GPU 机器上，profiling 或部署之前
python tools/preflight_qwen3.py sim --machines A100 L4 T4    # 运行模拟器或 MILP 的机器上
```

检查项包括：torch、vLLM、transformers、numpy 的版本；GPU 型号和计算能力；Qwen3 是否已注册、config 和 tokenizer 能否加载；Gurobi 许可是否可用；所需 GPU 类型的 profile 是否齐全、是否为占位数据；以及 `MAX_HOP` 的值。任何一项 FAIL 时退出码为 1。

## 如何测量（在每种 GPU 上各跑一次）

环境要求与路线 2 相同：

```bash
pip install vllm==0.4.0.post1 "transformers==4.40.2" "numpy~=1.26"
```

在仓库根目录运行：

```bash
python tools/profile_qwen3_moe.py --machine L4      # 换成 A100 / T4 / V100 / ...
```

脚本分两步，每一步都在独立的子进程里运行：

1. **单层计时**：在单层引擎（第 23 层）上测量 prompt 的 15 个 token 数取值，以及 decode 的 15 个 batch 大小。decode 的上下文长度为 870，即平均输入 750 加上平均输出的一半。每个点测 5 次，取中位数。计时包含 Helix 每层 step 的 Python 和调度开销，这和真实系统一致。
2. **KV 页池**：分别加载 1 层、中间层数、最大层数，读取 block 数，用线性拟合补全其余层数，并用中间那个点检查拟合残差（超过 3% 会报错，此时请加 `--kv-all`，对每个层数都实测）。
   - 加载的是第 `[0, k)` 层，也就是把第 0 层的 embedding（0.62 GB，约半层大小）算了进去。持有第一层或最后一层的节点确实会少这么多 KV 空间，所以这个估计对所有节点都偏保守，中间层的节点会少算 5% 到 12%。这样宁可少算，也不会因为高估 KV 容量导致真实系统 swap 到 CPU。
   - 脚本还会核对显卡显存是否和 `--machine` 对应的型号相符，防止在 A100-80G 上测出 A100（40G）的 profile；确实需要时可以加 `--force` 跳过。

脚本会把结果写入 `profiles/<GPU>/`，把这个目录提交到仓库即可。多卡机型（`L4x2`、`T4x2` 等）目前没法测，因为 Helix 引擎只支持单卡（`PipelineStageGpuExecutor` 里有一个 TP 的 FIXME）。

## 运行模拟

在 `examples/simulation_qwen3/` 目录下：

```bash
export PYTHONPATH=../..
python run_qwen3.py gen-cluster                   # 生成 single24（4 A100 + 8 L4 + 12 T4）和 small9
python run_qwen3.py layout petals --cluster single24
python run_qwen3.py layout swarm  --cluster single24
python run_qwen3.py layout ilp    --cluster single24   # MILP 会从最大流最高的启发式解开始搜索
python run_qwen3.py simulate offline --cluster single24 --layout ilp
python run_qwen3.py simulate online  --cluster single24 --layout ilp   # 必须先跑 offline
```

- **布局完成后**和**模拟开始前**，脚本都会检查最长的单请求流水线跨了多少个节点。原因是 `llm_sys/comm/src/const.h` 里 `MAX_HOP=32`，每个请求最多经过 31 个计算节点，超过时真实系统会在 `Header::add_stage` 处崩溃。24 节点的集群不会超限；超过 31 个节点的集群可能超限，此时脚本会给出警告。
- **在线模式的到达率**默认取同一布局 offline 实测总吞吐（prompt + decode）的 75%，和论文 6.2 节的做法一致。之所以不用最大流估算值，是因为在线模式不能拒绝请求，过载时会直接触发断言。也可以用 `--rate` 手动指定。
- **在线模式会把总时长（预热 + 统计窗口）自动补齐到 3 的倍数**，这是 Helix 到达率采样器的要求。

## Gurobi 许可（重要）

Helix 的 `setup.py` 固定了 `gurobipy~=11.0.0`。这个版本自带的免费受限许可已在 **2025-11-24 过期**，求解时会报 `License expired`。可选的解决办法：

- 申请 Gurobi 的免费学术许可（推荐）；
- 或者改装新版 `pip install -U gurobipy`。13.0 自带的受限许可有效期到 2027-11-29，Helix 的 MILP 代码在 13.0 下可以直接运行，已经验证过。受限许可有规模上限：24 节点、不剪枝的 Qwen3 问题有 1848 个约束、1432 个变量，正好在上限以内；更大的集群需要学术许可，或者开启剪枝。

## 已在沙箱里验证过的内容（使用占位 profile）

GPU 实测数据还没有，下面的数字全部基于 `tests/qwen3_moe/make_placeholder_profiles.py` 生成的 roofline 估算，只能证明整条链路能跑通，**不能当作性能结论**。

- 用 `ModelManager(ModelName.Qwen3_30B_A3B, ...)` 能加载各类 GPU，并算出 T_k 和 KV 容量。
- Petals、Swarm、MILP 三种方法都能为 48 层模型生成布局：9 节点和 24 节点的 MILP 都在 Gurobi 13 下解出了结果；在占位数据下，24 节点的 MILP 结果不低于最好的启发式解（数字见交付说明）。
- 离散事件模拟（offline + MaxFlow 调度）在 9 节点和 24 节点集群上都能完整运行。
- 原有的 LLaMA-30B 和 LLaMA-70B 路径没有受到影响。
- 测试脚本：`tests/qwen3_moe/test_sim_profiles.py`。

## 需要注意的建模问题

- **T_k 的估算方法照搬自 LLaMA。** typical batch 由 `KV_CACHE_HWM=0.3` 推导，这是作者针对稠密 LLaMA 校准的。MoE 的 decode 主要受显存带宽限制，batch 越大越划算，这个估算可能偏保守，导致 MILP 目标里的吞吐和模拟出来的吞吐有偏差。拿到实测 profile 之后，建议对比一下模拟吞吐和最大流的比值，再判断要不要重新校准。
- **路由按均匀分布建模。** profile 是在 dummy 权重下测的，路由接近均匀。真实模型的专家负载可能更不均衡。
- **模拟器的内存开销随吞吐增长。** Qwen3-A3B 的 token 吞吐远高于 LLaMA-70B，模拟器会为每个 decode 迭代保留一个请求对象，长时间模拟需要足够的内存。README 建议 32 GB；沙箱的 8 GB 只够跑大约 20 到 40 秒的窗口。
