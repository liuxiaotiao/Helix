"""
Pre-flight checks before running Helix with Qwen3-30B-A3B. Prints OK / WARN / FAIL per item.

  python tools/preflight_qwen3.py runtime   # on a GPU worker (vLLM env): before profiling / serving
  python tools/preflight_qwen3.py sim       # where you run the simulator / MILP planner
  python tools/preflight_qwen3.py sim --machines A100 L4 T4   # also require these profiles

Exit code is 1 if any FAIL.
"""
import argparse
import importlib
import os
import re
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, REPO)
RESULTS = []


def report(level, item, detail=""):
    RESULTS.append(level)
    print(f"[{level:4s}] {item}" + (f" -- {detail}" if detail else ""))


def version_of(mod):
    try:
        return importlib.import_module(mod).__version__
    except Exception as e:  # noqa: BLE001
        return None if isinstance(e, ImportError) else f"error: {e}"


def check_python():
    v = sys.version_info
    lvl = "OK" if (v.major, v.minor) >= (3, 8) else "FAIL"
    report(lvl, f"python {v.major}.{v.minor}", "Helix recommends 3.10")


def check_runtime():
    expect = {"torch": "2.1.2", "vllm": "0.4.0.post1"}
    for mod, want in expect.items():
        got = version_of(mod)
        if got is None:
            report("FAIL", f"{mod} not installed", f"pip install vllm=={expect['vllm']}")
        elif not str(got).startswith(want):
            report("FAIL", f"{mod}=={got}", f"expected {want}")
        else:
            report("OK", f"{mod}=={got}")
    tf = version_of("transformers")
    if tf is None:
        report("FAIL", "transformers not installed")
    else:
        major_minor = tuple(int(x) for x in re.findall(r"\d+", str(tf))[:2])
        lvl = "OK" if (4, 40) <= major_minor < (4, 41) else "FAIL"
        report(lvl, f"transformers=={tf}", "pin transformers==4.40.2 (pip pulls 5.x for vllm "
                                            "0.4.0, which breaks it)" if lvl == "FAIL" else "")
    np_v = version_of("numpy")
    report("OK" if np_v and str(np_v).startswith("1.") else "FAIL", f"numpy=={np_v}",
           "" if np_v and str(np_v).startswith("1.") else "need numpy~=1.26 (torch 2.1 / vllm 0.4)")

    try:
        import torch
        if not torch.cuda.is_available():
            report("FAIL", "CUDA not available")
        else:
            cap = torch.cuda.get_device_capability()
            name = torch.cuda.get_device_name()
            mem = torch.cuda.get_device_properties(0).total_memory / 1e9
            report("OK" if cap >= (7, 0) else "FAIL", f"GPU {name}, sm_{cap[0]}{cap[1]}, "
                                                       f"{mem:.1f} GB", "fp16 is used (no bf16 needed)")
            if torch.cuda.device_count() > 1:
                report("WARN", f"{torch.cuda.device_count()} GPUs visible",
                       "Helix's engine uses only cuda:0 (no tensor parallelism)")
    except Exception as e:  # noqa: BLE001
        report("FAIL", "torch/CUDA check failed", repr(e))

    model_dir = os.path.join(REPO, "examples", "real_sys_qwen3", "model")
    try:
        import llm_sys.engine.qwen3_moe  # noqa: F401
        from vllm.model_executor.models import ModelRegistry
        from llm_sys.engine.qwen3_moe import Qwen3MoePipelineStage
        assert ModelRegistry.load_model_cls("Qwen3MoeForCausalLM") is Qwen3MoePipelineStage
        report("OK", "Qwen3MoeForCausalLM registered with vLLM")
    except Exception as e:  # noqa: BLE001
        report("FAIL", "cannot import/register llm_sys.engine.qwen3_moe", repr(e))
    try:
        from vllm.config import ModelConfig
        mc = ModelConfig(model=model_dir, tokenizer=model_dir, tokenizer_mode="auto",
                         trust_remote_code=False, download_dir=None, load_format="dummy",
                         dtype="auto", seed=0)
        ok = (mc.get_head_size() == 128 and mc.max_model_len == 4096
              and str(mc.dtype) == "torch.float16")
        report("OK" if ok else "FAIL", "model config", f"head_dim={mc.get_head_size()} "
               f"max_model_len={mc.max_model_len} dtype={mc.dtype}")
        from vllm.transformers_utils.tokenizer import get_tokenizer
        tok = get_tokenizer(model_dir)
        report("OK" if len(tok) == 151936 else "FAIL", f"tokenizer vocab={len(tok)}")
    except Exception as e:  # noqa: BLE001
        report("FAIL", "model config / tokenizer", repr(e))

    # in a fresh interpreter: llm_sys/worker.py imports llm_worker *before* torch
    import subprocess
    for mod in ["llm_worker", "llm_host"]:
        r = subprocess.run([sys.executable, "-c", f"import {mod}"], capture_output=True, text=True)
        if r.returncode == 0:
            report("OK", f"{mod} (ZeroMQ comm) importable")
        else:
            err = (r.stderr.strip().splitlines() or ["?"])[-1]
            report("WARN", f"{mod} not importable", "only needed for the multi-node real system "
                   f"(build llm_sys/comm); profiling and tests do not need it ({err})")


def check_sim(machines):
    for mod in ["networkx", "matplotlib", "numpy"]:
        v = version_of(mod)
        report("OK" if v else "FAIL", f"{mod}=={v}")
    try:
        import gurobipy as gp
        ver = ".".join(map(str, gp.gurobi.version()))
        try:
            m = gp.Model()
            m.Params.OutputFlag = 0
            m.addVar()
            m.optimize()
            report("OK", f"gurobipy {ver}: licence works")
        except gp.GurobiError as e:
            report("FAIL", f"gurobipy {ver}: {e}", "gurobipy 11.0's bundled licence expired on "
                   "2025-11-24: get an academic licence or `pip install -U gurobipy`")
    except ImportError:
        report("FAIL", "gurobipy not installed")

    from simulator.model_manager.qwen3_30b_a3b.qwen3_30b_a3b import get_profile_dir
    from simulator.model_manager.qwen3_30b_a3b.profiled_machine import load_meta
    d = get_profile_dir()
    found = sorted(x for x in os.listdir(d) if os.path.isfile(os.path.join(d, x, "meta.json"))) \
        if os.path.isdir(d) else []
    report("OK" if found else "WARN", f"profiles in {d}: {found or 'none'}",
           "" if found else "run tools/profile_qwen3_moe.py on each GPU type")
    for name in found:
        meta = load_meta(os.path.join(d, name))
        if meta.get("placeholder"):
            report("WARN", f"profile {name} is a PLACEHOLDER", "not measured")
    for name in machines or []:
        if name not in found:
            report("FAIL", f"no profile for machine type {name}")

    const_h = os.path.join(REPO, "llm_sys", "comm", "src", "const.h")
    if os.path.exists(const_h):
        m = re.search(r"#define\s+MAX_HOP\s+(\d+)", open(const_h).read())
        if m:
            report("OK", f"MAX_HOP={m.group(1)} -> <= {int(m.group(1)) - 1} compute nodes per "
                         f"pipeline", "run_qwen3.py checks each layout against this")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("what", choices=["runtime", "sim"])
    ap.add_argument("--machines", nargs="*")
    a = ap.parse_args()
    check_python()
    check_runtime() if a.what == "runtime" else check_sim(a.machines)
    n_fail = RESULTS.count("FAIL")
    print(f"\n{n_fail} FAIL, {RESULTS.count('WARN')} WARN")
    sys.exit(1 if n_fail else 0)


if __name__ == "__main__":
    main()
