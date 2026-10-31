"""
GPU correctness test for the Helix Qwen3-MoE stage, run through Helix's own layer-wise engine
(llm_sys/engine: PipelineStageEngine + LayerwiseScheduler + paged KV cache + vLLM kernels).

Each case builds a one-layer Helix engine exactly like llm_sys/worker.py does, replaces the
dummy weights with well-conditioned random weights, then drives prompt + decode steps the same
way worker.py does (add_request / update_req_data / step) and compares every output with
tests/qwen3_moe/reference.py, which is itself checked against HF transformers
(test_ref_vs_hf.py).

Cases (each in its own subprocess, since vLLM 0.4.0 initialises torch.distributed once):
  middle : layer 23, hidden-state input, 3 requests (5 / 32 / 126 tokens) batched together,
           then 4 batched decode steps (crossing KV block boundaries at 32 and 128)  -> checks attention, QK-Norm, RoPE positions,
           paged KV cache reads/writes across block boundaries, fused MoE, residual stream
  first  : layer 0, token-id input      -> checks embedding path
  last   : layer 47, greedy sampling    -> checks final norm + lm_head + sampler

Run on a GPU node (any of A100 / L4 / T4 / V100), from the repo root, inside the Helix
runtime env (vllm==0.4.0.post1):
    python tests/qwen3_moe/test_gpu_stage.py
Does not need ZeroMQ / llm_host / llm_worker.
"""
import json
import os
import subprocess
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
MODEL_DIR = os.path.join(REPO, "examples", "real_sys_qwen3", "model")
REL_TOL = 2e-2      # fp16 kernels vs fp32 reference: max|diff| / max|ref|
COS_TOL = 0.9995    # per-token cosine similarity


def build_engine(layer_ids):
    import llm_sys.engine.llama  # noqa: F401  (same imports as llm_sys/worker.py)
    import llm_sys.engine.qwen3_moe  # noqa: F401
    from vllm.engine.arg_utils import EngineArgs
    from llm_sys.engine.exec_engine import PipelineStageEngine
    # Same as llm_sys/worker.py:init_engine, except a smaller CPU swap space and a lower
    # gpu_memory_utilization (leaves room for the fp32 reference weights on 16 GB GPUs; the
    # KV-cache size does not matter for this test).
    engine_args = EngineArgs(model=MODEL_DIR, block_size=16, load_format="dummy",
                             enforce_eager=True, swap_space=4, max_num_batched_tokens=4096,
                             gpu_memory_utilization=0.5)
    return PipelineStageEngine.from_engine_args(engine_args, layer_ids)


def reinit_weights(stage, seed):
    import torch
    g = torch.Generator(device="cuda").manual_seed(seed)

    def fill_(p, std, mean=0.0):
        # fill slice by slice along dim 0 to keep the fp32 temporaries small
        # (w13 alone would need ~3 GiB of fp32 scratch if filled at once)
        flat = p.data.view(p.shape[0], -1)
        step = max(1, (1 << 24) // max(1, flat.shape[1]))
        for i in range(0, flat.shape[0], step):
            chunk = flat[i:i + step]
            chunk.copy_(torch.randn(chunk.shape, generator=g, device=p.device,
                                    dtype=torch.float32).mul_(std).add_(mean))

    for name, p in stage.named_parameters():
        if name.endswith("norm.weight"):
            fill_(p, 0.1, 1.0)
        elif name.endswith("mlp.gate.weight"):
            fill_(p, 0.2)          # router: clear top-k margins
        elif "embed_tokens" in name:
            fill_(p, 1.0)
        elif "lm_head" in name:
            fill_(p, 0.02)
        else:
            fill_(p, 0.05)


def compare(name, got, ref):
    import torch
    got, ref = got.float(), ref.float()
    rel = ((got - ref).abs().max() / ref.abs().max()).item()
    cos = torch.nn.functional.cosine_similarity(got, ref, dim=-1).min().item()
    ok = rel < REL_TOL and cos > COS_TOL
    print(f"  {'ok ' if ok else 'BAD'} {name:<28} rel_max_err={rel:.2e} min_cos={cos:.6f}")
    return ok


def ref_kwargs(cfg):
    return dict(num_heads=cfg.num_attention_heads, num_kv_heads=cfg.num_key_value_heads,
                head_dim=cfg.head_dim, top_k=cfg.num_experts_per_tok,
                norm_topk_prob=cfg.norm_topk_prob, rope_theta=cfg.rope_theta,
                eps=cfg.rms_norm_eps)


def run_case(case):
    import torch
    from vllm import SamplingParams
    sys.path.insert(0, os.path.dirname(__file__))
    from reference import extract_stage_weights, layer_output, rms_norm

    torch.manual_seed(0)
    num_layers = 48
    layer = {"middle": 23, "first": 0, "last": num_layers - 1}[case]
    engine = build_engine([layer])
    runner = engine.model_executor.driver_worker.model_runner
    stage = runner.models[layer]
    cfg = stage.config
    H = cfg.hidden_size
    backend = stage.decoder_layer.self_attn.attn.backend
    print(f"[{case}] layer {layer} on {torch.cuda.get_device_name()}  "
          f"({type(stage).__name__}, attention backend {getattr(backend, '__name__', backend)})")
    reinit_weights(stage, seed=1234 + layer)
    W = {k: v.cuda() for k, v in extract_stage_weights(stage).items()}
    kw = ref_kwargs(cfg)
    all_ok = True

    # decode positions 32 and 128 open a new 16-token KV block; 126 tokens span 8 blocks
    lengths = [5, 32, 126] if case != "last" else [9, 32]
    n_decode = 4 if case != "last" else 2
    req_ids = list(range(100, 100 + len(lengths)))
    # per-request full input sequence (prompt + decode inputs), in the layer's input space
    seqs = {}
    for rid, n in zip(req_ids, lengths):
        if case == "first":
            seqs[rid] = torch.randint(0, cfg.vocab_size, (n + n_decode,), device="cuda")
            # Helix never feeds sampled tokens back into layer 0: during decode the layer-0
            # node embeds the placeholder token that exec_engine appends after every step
            # (_dummy_token_id = 2). Fine for benchmarking; mirrored here.
            seqs[rid][n:] = 2
        else:
            seqs[rid] = torch.randn(n + n_decode, H, device="cuda").half()

    def layer_in(rid, upto):
        x = seqs[rid][:upto]
        return stage.embed_tokens.weight[x].float() if case == "first" else x.float()

    lm_head_t = (stage.lm_head.weight[: cfg.vocab_size].float().t().contiguous()
                 if case == "last" else None)   # fp32 copy made once (~1.2 GiB)

    def reference(rid, upto):
        out = layer_output(W, layer_in(rid, upto), torch.arange(upto, device="cuda"), **kw)
        if case == "last":
            final = rms_norm(out, stage.norm.weight, cfg.rms_norm_eps)
            return final @ lm_head_t   # logits
        return out

    greedy = case == "last"
    sp = SamplingParams(temperature=0.0 if greedy else 1.0, ignore_eos=True,
                        max_tokens=n_decode + 8)

    # ---------------- prompt phase (all requests in one batch) ----------------
    for rid, n in zip(req_ids, lengths):
        if case == "first":
            engine.add_request(f"{rid}", "", sp, local_layers=(layer, layer), seq_id=rid,
                               input_tensor=None, prompt_token_ids=seqs[rid][:n].tolist())
        else:
            engine.add_request(f"{rid}", "", sp, local_layers=(layer, layer), seq_id=rid,
                               input_tensor=seqs[rid][:n].clone(), prompt_token_ids=[1] * n)
    out = engine.step(layer_id=layer, finished_seq_infos=[], force_decode=False)
    all_ok &= check_step(case, "prompt", out, req_ids, lengths, reference, step=0)
    # worker.py runs one forced-decode step right after a prompt step and asserts it parsed
    # no prompt; with nothing runnable it must return (None, None, None)
    forced = engine.step(layer_id=layer, finished_seq_infos=[], force_decode=True)
    assert forced == (None, None, None), forced

    # ---------------- decode phase (batched) ----------------
    for d in range(n_decode):
        for rid, n in zip(req_ids, lengths):
            pos = n + d
            if case == "first":
                engine.scheduler.update_req_data(layer, (f"{rid}", layer), {(rid, layer): None})
            else:
                engine.scheduler.update_req_data(layer, (f"{rid}", layer),
                                                 {(rid, layer): seqs[rid][pos:pos + 1].clone()})
        out = engine.step(layer_id=layer, finished_seq_infos=[], force_decode=False)
        all_ok &= check_step(case, f"decode {d + 1}", out, req_ids, lengths, reference, step=d + 1)
    return all_ok


def check_step(case, label, out, req_ids, lengths, reference, step):
    import torch
    ok = True
    if case == "last":
        request_outputs, _ = out
        by_id = {int(ro.request_id[0]): ro for ro in request_outputs}
        for rid, n in zip(req_ids, lengths):
            upto = n + step  # prompt step sees n tokens; decode step k sees n + k tokens
            logits = reference(rid, upto)[-1]
            tok = by_id[rid].outputs[0].token_ids[-1]
            gap = (logits.max() - logits[tok]).item()
            good = gap < 1e-2 * max(1.0, logits.abs().max().item())
            print(f"  {'ok ' if good else 'BAD'} {label} req {rid}: greedy token {tok}, "
                  f"ref argmax {logits.argmax().item()}, logit gap {gap:.2e}")
            ok &= good
        return ok

    send_infos, output_tensor, is_prompt = out
    assert is_prompt == (step == 0), (label, is_prompt)
    rows = {int(req_id[0]): (b, e) for req_id, b, e in send_infos}
    for rid, n in zip(req_ids, lengths):
        b, e = rows[rid]
        got = output_tensor[b:e]
        if step == 0:
            ref = reference(rid, n)
        else:
            ref = reference(rid, n + step)[-1:]
        ok &= compare(f"{label} req {rid} ({e - b} rows)", got, ref)
    return ok


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--case":
        sys.path.insert(0, REPO)
        import torch
        with torch.no_grad():   # no autograd graphs / extra fp32 copies kept alive
            ok = run_case(sys.argv[2])
        print(json.dumps({"case": sys.argv[2], "ok": bool(ok)}))
        sys.exit(0 if ok else 1)

    results = {}
    for case in ["middle", "first", "last"]:
        print(f"===== case: {case} =====", flush=True)
        r = subprocess.run([sys.executable, __file__, "--case", case], cwd=REPO)
        results[case] = r.returncode == 0
    print("\nSUMMARY:", results)
    sys.exit(0 if all(results.values()) else 1)


if __name__ == "__main__":
    main()
