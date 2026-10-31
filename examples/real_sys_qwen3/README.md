# 在 Helix 原型系统（vLLM 0.4.0.post1）上运行 Qwen3-30B-A3B

本目录是"路线 2"的实现：在 Helix 现有的逐层执行引擎上增加 Qwen3-MoE 支持，执行引擎、调度器和 C++ 通信层都不需要改动。

## 新增和修改的文件

| 文件 | 说明 |
|---|---|
| `llm_sys/engine/qwen3_moe.py` | **新增**。`Qwen3MoePipelineStage`，结构仿照 `llama.py`，一个对象只含一层。注册为 `Qwen3MoeForCausalLM` 架构。 |
| `llm_sys/worker.py` | **改了两处**：在原有的 `import llm_sys.engine.llama` 后面加了 `import llm_sys.engine.qwen3_moe`。另外把写死的"IP 必须以 10 开头"检查换成 `utils.assert_usable_local_ip`。 |
| `examples/real_sys_qwen3/model/config.json` | 适配 Helix 的模型配置（说明见下文）。 |
| `examples/real_sys_qwen3/model/tokenizer*.json`、`special_tokens_map.json` | 合成 tokenizer，由 `make_dummy_tokenizer.py` 生成。 |
| `tests/qwen3_moe/` | 参考实现和 4 个测试。 |
| `examples/real_sys_qwen3/cluster.example.json`、`helix_cluster.py`、`cluster_ctl.py`、`tools/net_bench.py`、`tools/install_node.sh`、`tools/fake_worker.py`、`step2_start_host.py`、`step3_start_worker.py`、`step4_parse_results.py` | **新增**。在自己的集群上部署的工具（见"在集群上部署"一节）。 |
| `llm_sys/utils.py`、`maxflow_host.py`、`heuristic_host.py` | host 地址和本机 IP 可以用环境变量 `HELIX_CONFIG_BROADCAST_ADDR` / `HELIX_LOCAL_IP` 覆盖；不设时行为和原来一样。`torch` 改为延迟导入，规划工具不需要装 torch。 |
| `llm_sys/comm/build.sh`、`llm_sys/comm/setup.py`、`CMakeLists.txt` | 构建时使用当前环境的 Python / torch / conda / venv 路径，不再写死；CMakeLists 显式定义 `ZMQ_BUILD_DRAFT_API`（`poller.h` 需要），找不到已安装的 cppzmq 时用仓库里附带的头文件。 |
| `llm_sys/comm/third_party/cppzmq/` | **新增**。cppzmq 4.11.0 的两个头文件和 MIT 许可证。 |
| `llm_sys/comm/src/compute_worker.h` | 环境变量 `HELIX_COMM_CPU_TENSORS=1` 时把收到的张量留在 CPU（只给 `tools/fake_worker.py` 的网络测试用）；不设时行为不变。 |
| `setup.py`、`requirements.txt` | gurobipy 约束从 `~=11.0.0` 放宽为 `>=11.0`（11.x 自带许可证已过期，用 13）。 |

## stage 的实现要点

在 vLLM 0.4.0 自带的 Qwen2-MoE 基础上，按 Qwen3-MoE 的结构做了这些改动：

- **head_dim**：从 config 读取，值为 128，不等于 hidden/heads = 64。
- **QKV**：去掉 bias。
- **QK-Norm**：q 和 k 先按 head 各做一次 RMSNorm，再做 RoPE。
- **专家**：去掉共享专家；128 个专家打包成 `w13 [E, 2I, H]` 和 `w2 [E, H, I]` 两个张量，用 vLLM 0.4.0 的 Triton `fused_moe` 执行。
- **路由**：softmax，取 top-8，再重新归一化（`norm_topk_prob`）。
- **残差**：每一层把完整的残差流（`mlp_out + residual`）发给下一个节点；最后一层做 final norm、lm_head 和采样。

注意：Helix 原来的 `llama.py` 只返回了 `mlp_out`，把残差丢掉了。这不影响性能测量，因为计算量一样，但输出在数学上是错的。`llama.py` 我没有改动。

## config.json 和官方配置的差异

模型结构的数字（48 层、hidden 2048、32/4 个头、head_dim 128、128 个专家选 8、moe_intermediate 768、vocab 151936）都和官方 `Qwen/Qwen3-30B-A3B` 一致。改动的地方只有：

- **`model_type: "qwen2_moe"`**：让 vLLM 0.4.0 搭配的旧版 transformers 能解析这个 config。`head_dim` 这类额外字段会原样保留为属性。架构名仍然是 `Qwen3MoeForCausalLM`，由 Helix 自己注册。
- **`torch_dtype: float16`**：T4 和 V100 不支持 bf16。
- **`max_position_embeddings: 4096`**：Helix 的 `init_engine` 设了 `max_num_batched_tokens=4096`，vLLM 0.4.0 要求 max_model_len 不超过这个值。Helix 的 trace 本来就过滤掉了输入超过 2048 或输出超过 1024 的请求，而且 4096 以内各位置的 RoPE 数值和官方配置完全相同。
- **`shared_expert_intermediate_size: 0`、`sliding_window: null`**。

## 环境注意事项（重要）

现在直接执行 `pip install vllm==0.4.0.post1`，pip 会装上最新版的 transformers（5.x），vLLM 0.4.0 用不了。需要固定版本：

```bash
pip install vllm==0.4.0.post1 "transformers==4.40.2" "numpy~=1.26"
```

## 运行前检查

在 GPU 机器上先运行 `python tools/preflight_qwen3.py runtime`，确认版本、GPU、模型注册、config 和 tokenizer 都没有问题。

## Tokenizer

Helix 的 host 发送的是合成的 token id，原型系统也只用 dummy 权重，所以 tokenizer 只用来读取 eos，以及对采样出来的 id 做解码。`model/` 里已经放好了一个词表大小为 151936 的合成 tokenizer，不需要联网下载。如果要重新生成：

```bash
cd examples/real_sys_qwen3 && python make_dummy_tokenizer.py ./model
```

如果想用真实的 Qwen3 tokenizer，把官方仓库里的 tokenizer 文件拷进 `model/` 即可。做性能测试不需要。

## 测试

从仓库根目录运行。

| 测试 | 需要什么 | 检查什么 |
|---|---|---|
| `python tests/qwen3_moe/test_cpu_structure.py` | 只要 CPU | 注册是否成功；config 能否被 vLLM 正确解析；各参数形状；每层 623,120,640 个参数；全模型 30.53B |
| `python tests/qwen3_moe/test_cpu_wiring.py` | 只要 CPU | 真实的 stage 前向（只把 CUDA kernel 换成等价的 torch 实现）和参考实现比对，覆盖第一层、中间层、最后一层 |
| `python tests/qwen3_moe/test_ref_vs_hf.py` | transformers ≥ 4.51（可以装在另一个环境） | 参考实现和 HF 官方 `Qwen3MoeDecoderLayer` 的数值一致 |
| `python tests/qwen3_moe/test_gpu_stage.py` | **GPU** 和 vLLM 0.4.0.post1 | 通过 Helix 引擎跑 prompt 和 4 轮 batched decode，覆盖 paged KV cache、跨 block、fused_moe、attention kernel、embedding 输入和贪心采样 |

GPU 测试会在每个用例后打印 `ok` 或 `BAD`，全部通过时最后一行是 `SUMMARY: {'middle': True, 'first': True, 'last': True}`。容差是 fp16 相对 fp32 的最大相对误差小于 2e-2，并且每个 token 的余弦相似度大于 0.9995。

## 在集群上部署（完整流程）

下面所有命令都在**同一份仓库副本 + 同一个 conda 环境**里执行。集群有共享文件系统时最省事；没有的话，每台机器都要有一份相同的仓库（包括 `profiles/`、`config/`、`layouts/`、`deploy/` 和 `cluster.json`）。

### 角色与约束

- **host（协调者）**：一台机器，不需要 GPU，但需要装 torch 和通信库。它的 IP **不能**同时跑 worker（worker 按 IP 认领配置，host 是 0 号机）。
- **worker**：每台机器（每个 IP）只跑一个 worker、只用一张 GPU（多卡机器用 `CUDA_VISIBLE_DEVICES` 选一张）。
- 每种 GPU 最多能放的层数 = VRAM/2 ÷ 1.246 GB：T4/V100 6 层，L4 9 层，A100-40G 16 层，A100-80G/H100 32 层。全部 worker 加起来至少要能放下 48 层，最好留余量。
- 端口：host 的 5000（可在 `cluster.json` 改），以及所有机器的 6000 ~ 6000+节点数，节点之间必须互通。
- 权重是 dummy 的：测的是吞吐和延迟，不产生有意义的文本。

### 1. 从控制节点分发代码并安装

前提：控制节点能免密 ssh 到 host 和所有 worker；各节点能访问 PyPI 和 conda-forge；worker 已装好 NVIDIA 驱动（≥ 525，驱动需要 root，脚本不负责装）。

```bash
# 在控制节点上（Linux）拿到仓库，然后：
cd examples/real_sys_qwen3
cp cluster.example.json cluster.json     # 填 host_ip、每个 worker 的 IP 和 GPU 类型；按需改 remote 一节
python cluster_ctl.py sync               # 把整个仓库打包推到每个节点的同一路径（共享文件系统时跳过）
python cluster_ctl.py install --install-conda --cuda-from-conda
python cluster_ctl.py check
```

`install` 在每个节点上并行运行 `tools/install_node.sh`，日志在控制节点的 `logs/install_<ip>.log`。这个脚本可以重复运行，已完成的步骤会跳过，所以某台失败了修好原因再跑一次即可（也可以 `--nodes <ip>` 只重装那一台）。它依次做：

1. 找 conda；没有且加了 `--install-conda` 时装 Miniforge 到 `~/miniforge3`（只用 conda-forge 源）。
2. 建 Python 3.10 的 `runtime` 环境（venv 模式下改为在你现有的环境上建虚拟环境，见下文），并写 `~/.helix_env.sh`（之后所有远程命令用它激活环境）。
3. `pip install vllm==0.4.0.post1 transformers==4.40.2 numpy~=1.26`。
4. `pip install -e .` 和规划器依赖（gurobipy 13）。
5. 编译工具：cmake 和 pybind11 2.11.1 从 PyPI 装（已有合适版本就跳过）；节点没有 g++ 时从 conda-forge 装 GCC 12；cppzmq 只有头文件，已放在仓库 `llm_sys/comm/third_party/cppzmq/`；libzmq 从官方源码包编译并打开 draft API（通信层用到的 `zmq::poller_t` 是 draft API，apt 和 conda-forge 的预编译 libzmq 都没打开它）。
6. 找 nvcc：优先用节点已有的——PATH 上的，或 `/usr/local/cuda-12.x` 下的（优先 12.1–12.6，不在 PATH 上也能找到；也可在 `remote.pre` 里写 `module load cuda/12.4`）；没有且加了 `--cuda-from-conda` 时从 NVIDIA 的 conda 源装 CUDA 12.1 编译工具链。torch 的 CMake 配置会启用 CUDA，而 nvcc 不接受比它新的 GCC（CUDA 12.1 最高支持 GCC 12），系统 GCC 太新时脚本会自动用 conda 的 GCC 12 作为 CUDA 的宿主编译器。
7. 编译通信层（`llm_sys/comm/build.sh`），最后跑 `test_msg`、导入检查，并报告 GPU 和驱动版本。

**已经有自己的 conda 环境、不想新建环境时**：在 `cluster.json` 的 `remote` 里写上 `"env": "<你的环境名或完整路径>"`（例如 `"/home/ubuntu/anaconda3/envs/moe"`）和 `"venv": "~/helix-venv"`，再运行同样的 `install`（不需要 `--install-conda`）。脚本只激活你的环境，用它的 Python（要求 3.8–3.11，推荐 3.10）在 `~/helix-venv` 建一个虚拟环境，所有 pip 包和编译出来的 libzmq 都装进虚拟环境，不往你的 conda 环境里装或删任何东西。如果节点上没有 nvcc 或合适的 GCC，加了 `--cuda-from-conda` 时这些编译工具会放进 `~/helix-venv/toolchain` 这个独立目录，同样不碰你的环境。之后激活顺序由 `~/.helix_env.sh` 负责（先激活 conda 环境，再激活虚拟环境）。手动执行的写法：

```bash
bash tools/install_node.sh --env <你的环境名> --venv ~/helix-venv [--cuda-from-conda]
```

唯一可能需要动你环境的情况：你的环境里自带的 libstdc++ 比编译器旧，导入通信模块时会报 `GLIBCXX_...not found`。脚本会检测到并提示你选择：给环境更新 libstdc++，或者换用旧一点的 GCC 编译。

共享文件系统（`"shared_fs": true`）时，`sync` 不需要，`install` 默认只在一台节点上装一次（conda 环境和编译产物都在共享目录里）；如果每个节点的 conda 是各自独立的，加 `--all`。

想手动装也可以，在每台机器上执行 `bash tools/install_node.sh --install-conda --cuda-from-conda`。

验证单台机器的 GPU 推理是否正确：在任意 worker 上运行 `python tests/qwen3_moe/test_gpu_stage.py`，最后一行 SUMMARY 应全为 True。两台机器之间的连通性可以用 `packed_server` / `packed_client` 测（见仓库根目录 readme 3.2 节）。

### 2. 从控制节点自动采集 profile 和带宽

在控制节点上（建议放在 tmux 里，采集要跑一段时间）：

```bash
python cluster_ctl.py check              # 逐台检查：能否连上、环境、GPU 型号/显存是否和 type 一致、通信库
python cluster_ctl.py profile            # 每种 GPU 挑一台，并行跑 profiler；结果只保存在被测节点上
                                         # （加 --fetch 同时拷一份回本机；之后也可以用 collect 收集）
python cluster_ctl.py bandwidth          # 测几对节点间的单流 TCP 带宽（--write 把中位数写回 cluster.json）
```

- 远程命令先执行 `remote.pre`，再用 `~/.helix_env.sh` 激活环境。
- 结果写在被测节点自己的仓库里（`simulator/model_manager/qwen3_30b_a3b/profiles/<类型>/`），会一直保留在那里；`sync` 不会覆盖它们。`python cluster_ctl.py collect` 随时可以从各节点重新收集。
- 不在内置显存表里的卡型（比如 A6000）会自动用实测显存。也可以在 `machine_types` 里写明 `vram_gb`。
- 多卡机器可以给 worker 加 `"gpu": <编号>`，采集和运行都只用这张卡。
- 只想补测某种卡：`python cluster_ctl.py profile --types L4`。

手动采集的方式也保留着：在某种卡上直接运行 `python tools/profile_qwen3_moe.py --machine L4`。

### 3. 规划（控制节点上，或者你自己有 Gurobi 的电脑上）

**在控制节点上规划：**

```bash
python helix_cluster.py init             # -> config/cluster.ini、config/machine_profile.ini
python helix_cluster.py layout petals
python helix_cluster.py layout swarm     # worker 少于 8 台时跳过
python helix_cluster.py layout ilp       # Gurobi MILP，默认最多 1800 s（--max-run-time）
python helix_cluster.py simulate offline --layout ilp     # 可选：模拟吞吐
python helix_cluster.py gen-config --layout ilp           # -> deploy/ilp/real_sys_config.txt
```

`gen-config` 会打印每台机器分到的层和上下游，并检查 MAX_HOP、层覆盖、IP 唯一性。pip 版 gurobipy 自带的受限许可证只支持 2000 个变量/约束，24 个节点的模型就已接近这个上限，再大的集群需要 Gurobi 学术许可证（学校网络内可以免费申请）。

**在你自己的电脑上规划（用本地 Gurobi 许可证），代码通过 GitHub 到控制节点：**

两个方向的数据量都很小。集群 → 本地只有 profile 和 `cluster.json`（几十 KB），用一个包拷回来；本地 → 集群的规划结果走 git。

```bash
# A) 集群控制节点：采集，打包带回本地（不改动仓库里受版本管理的文件）
git pull && python cluster_ctl.py sync          # 代码更新后先分发到各节点
python cluster_ctl.py profile                  # 结果只留在被测节点上
python cluster_ctl.py bandwidth                # 只打印带宽；把数值写进本地的 cluster.json
python cluster_ctl.py collect --bundle plan_inputs.tgz
# 用 scp 等把 plan_inputs.tgz 拷到本地

# B) 本地电脑：规划并提交
tar -xzf plan_inputs.tgz -C <本地仓库>
cd <本地仓库>/examples/real_sys_qwen3
python helix_cluster.py init
python helix_cluster.py layout petals && python helix_cluster.py layout swarm   # 少于 8 台跳过 swarm
python helix_cluster.py layout ilp
python helix_cluster.py gen-config --layout ilp
git add cluster.json config layouts/cluster/ilp deploy/ilp ../../simulator/model_manager/qwen3_30b_a3b/profiles
git commit -m "Helix plan for the cluster" && git push

# C) 集群控制节点：拉取并推给所有节点
git pull && python cluster_ctl.py push-plan
python cluster_ctl.py net-test --layout ilp
```

要点：
- **控制节点上不要改受版本管理的文件**，这样 `git pull` 永远不会冲突：`cluster.json` 只在本地改；不要用 `bandwidth --write`（它会改 `cluster.json`），也不要用 `profile --fetch`；打包文件 `*.tgz` 已被 `.gitignore` 忽略。
- **节点不需要访问 GitHub**：控制节点 `git pull` 之后，用 `sync` 分发代码，用 `push-plan` 分发规划结果。
- 本地只需要一个规划用的 Python 环境（3.10–3.12），不需要 torch、vLLM 或 GPU：`pip install "numpy~=1.26" "networkx~=3.2.1" "matplotlib~=3.8.2" "gurobipy==<和本地 Gurobi 许可证一致的版本>"`。
- 不想经过 git 时，也可以用 `python helix_cluster.py export-plan --layout ilp --out plan.tgz` 打包，拷回控制节点后 `python cluster_ctl.py push-plan --bundle plan.tgz`（注意这样会改动控制节点仓库里的文件，下次 `git pull` 前要先清理）。
- `hosts.txt`、`cluster.json` 里是集群内网 IP；如果 GitHub 仓库是公开的，留意这一点。

### 4. 启动

没有共享文件系统时，先把规划结果（`cluster.json`、profiles、`config/`、`layouts/`、`deploy/`）推到各节点，host 启动时要读它们（在本地规划的话，上一步的 `push-plan --bundle` 已经做了）：

```bash
python cluster_ctl.py push-plan
```

`sync` 只分发代码，不会碰这些规划文件和节点上的 profile。

正式跑之前，建议先做一次不占 GPU 的网络测试：

```bash
python cluster_ctl.py net-test --layout ilp
```

它在 host 上运行真正的 host 程序（maxflow 调度），在每台 worker 上运行 `tools/fake_worker.py`。fake worker 用同一套通信协议，但不做计算，只回传形状正确的假结果。这样能验证配置分发、按 IP 认领层、节点间端口和连接、请求逐跳路由是否都正常。输出会列出每个 worker 有没有加入集群、分到哪些层，以及 host 收回了多少次结果、用到了几条不同路径；全部正常时最后一行是 `network test PASSED`。有 worker 没加入，通常是防火墙、IP 写错或环境没装好。


```bash
# host（host_ip 那台机器）
python step2_start_host.py offline maxflow --layout ilp --duration 300

# 每台 worker（自动在 cluster.json 里找到本机 IP）
python step3_start_worker.py maxflow
```

启动顺序无所谓。host 和 worker 的调度方法必须一致（maxflow / swarm / random）。地址不再需要改 `llm_sys/utils.py`：脚本会根据 `cluster.json` 设置 `HELIX_CONFIG_BROADCAST_ADDR`；机器有多个网卡、或没有到公网的默认路由时，可以手动设置 `HELIX_LOCAL_IP=<本机集群 IP>`。

也可以从控制节点一次性启停所有 worker（日志在各节点的 `examples/real_sys_qwen3/logs/worker_<ip>.log`）：

```bash
python cluster_ctl.py start-workers maxflow
python cluster_ctl.py stop-workers       # worker 不会自己退出，测完要停掉
```

### 5. 看结果

```bash
python step4_parse_results.py ./result/maxflow_offline_ilp/
```

输出平均 prompt / decode 延迟和 decode 吞吐。offline 结果还会给出下一步 online 实验该用的 `--rate`（论文的设定：峰值的 75%，按 prompt+输出总 token 计）：

```bash
python step2_start_host.py online maxflow --layout ilp --rate <上一步给出的值>
```

`result/<方法>_<模式>_<布局>/query_route.txt` 里记录了每个请求实际走的路径。

## 已知限制

- **只支持 dummy 权重**（和 `llama.py` 一样）。dummy 初始化下 router 的输出接近均匀，所以各专家的负载接近均匀分布，真实模型的路由可能更不均衡。
- **`fused_moe` 没有针对这个形状调优。** vLLM 0.4.0 没有 `E=128,N=768` 的调优配置，会使用默认的 kernel 参数，吞吐会偏保守。
- **不支持专家并行。** 每个节点必须放下所持层的全部 128 个专家。张量并行按专家的 intermediate 维切分，参照 vLLM 0.4.0 的 Mixtral 写法，这部分没有测试过。
- **第 0 层在 decode 阶段的输入始终是占位 token**（id 2）。Helix 原本就是这样设计的，不影响计算量。
