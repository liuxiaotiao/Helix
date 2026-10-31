"""
Simulator-side tests for Qwen3-30B-A3B (no GPU, no vLLM; needs the simulator deps only).

  * tools/profile_qwen3_moe.py helpers: max-layer rule, KV linear fit, profile writing
  * round trip: written profile -> ProfiledQwen3OnMachine reads back identical tables (ms -> s)
  * ModelManager(ModelName.Qwen3_30B_A3B) on placeholder profiles: model card numbers,
    typical throughput / KV capacity sanity, half-VRAM rule that ilp_layout.py asserts
  * bad profiles are rejected with clear errors

Run from the repo root:  python tests/qwen3_moe/test_sim_profiles.py
"""
import importlib.util
import json
import os
import subprocess
import sys
import tempfile

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, REPO)

_spec = importlib.util.spec_from_file_location(
    "profile_qwen3_moe", os.path.join(REPO, "tools", "profile_qwen3_moe.py"))
prof = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(prof)


def expect_error(fn, words):
    try:
        fn()
    except Exception as e:  # noqa: BLE001
        assert any(w in str(e) for w in words), f"unexpected error: {e}"
        return
    raise AssertionError(f"expected an error mentioning {words}")


def main():
    from simulator.model_manager.qwen3_30b_a3b import model_card as card
    from simulator.model_manager.qwen3_30b_a3b.profiled_machine import ProfiledQwen3OnMachine

    # --- helpers of the profiler ---
    assert card.LAYER_PARAM_BYTES == 1_246_241_280
    assert {m: prof.max_layers_for(m, card.LAYER_PARAM_BYTES) for m in ["T4", "L4", "A100"]} \
        == {"T4": 6, "L4": 9, "A100": 16}
    fit = prof.fit_kv_blocks({1: 1000, 5: 600, 9: 200}, 9)
    assert fit == {k: 1000 - 100 * (k - 1) for k in range(1, 10)}, fit
    expect_error(lambda: prof.fit_kv_blocks({1: 1000, 5: 900, 9: 200}, 9), ["not linear"])
    print("[ok] profiler helpers (max layers, KV fit + linearity check)")

    with tempfile.TemporaryDirectory() as tmp:
        # --- write / read round trip ---
        prompt = {16: 1.5, 4096: 9.25}
        decode = {1: 1.25, 256: 3.5}
        kv = {k: 1000 * (7 - k) for k in range(1, 7)}
        d = prof.write_profile(tmp, "T4", prompt, decode, kv, 6, {"note": "unit test"})
        m = ProfiledQwen3OnMachine(d, card.TOTAL_LAYERS, {"T4": 10}, {"T4": 5}, {"T4": 10.0})
        assert m.prompt_bs2time == {0: 0.0, 16: 0.0015, 4096: 0.00925}
        assert m.decode_bs2time == {0: 0.0, 1: 0.00125, 256: 0.0035}
        assert m.get_kv_cache_capacity(2) == 16 * 5000 and m.get_max_num_layers() == 6
        s = m.get_inference_settings(3)
        assert s.prompt_max_tokens == 4096 and s.decode_max_tokens == 256
        print("[ok] write_profile -> ProfiledQwen3OnMachine round trip")

        # --- bad profiles are rejected ---
        meta_p = os.path.join(d, "meta.json")
        meta = json.load(open(meta_p))
        bad = dict(meta, kv_cache_blocks={k: v for k, v in meta["kv_cache_blocks"].items() if k != "3"})
        json.dump(bad, open(meta_p, "w"))
        expect_error(lambda: ProfiledQwen3OnMachine(d, 48, {"T4": 1}, {"T4": 1}, {"T4": 1.0}),
                     ["must cover"])
        json.dump(meta, open(meta_p, "w"))
        with open(os.path.join(d, "decode_bs2time.csv"), "w") as f:
            f.write("0,0\n1,1.0\n128,2.0\n")
        expect_error(lambda: ProfiledQwen3OnMachine(d, 48, {"T4": 1}, {"T4": 1}, {"T4": 1.0}),
                     ["must reach 256"])
        print("[ok] incomplete profiles are rejected")

        # --- ModelManager on placeholder profiles ---
        ph = os.path.join(tmp, "ph")
        subprocess.run([sys.executable, os.path.join(REPO, "tests", "qwen3_moe",
                                                     "make_placeholder_profiles.py"), ph],
                       check=True, stdout=subprocess.DEVNULL)
        os.environ["HELIX_QWEN3_PROFILE_DIR"] = ph
        import warnings
        from simulator.model_manager.model_manager import ModelManager, ModelName
        with warnings.catch_warnings(record=True) as w:
            warnings.simplefilter("always")
            mm = ModelManager(ModelName.Qwen3_30B_A3B, {"A100": 4, "L4": 8, "T4": 12})
            assert any("PLACEHOLDER" in str(x.message) for x in w), "placeholder warning missing"
        assert mm.get_num_layers() == 48 and mm.get_model_activation_size() == 4096
        assert mm.get_model_token_size() == 2
        vram = {"A100": 40e9, "L4": 24e9, "T4": 16e9}
        for mt in ["A100", "L4", "T4"]:
            L = mm.get_max_num_layers(mt)
            assert 2 * L * max(mm.get_model_params()) <= vram[mt] + 1   # ilp_layout.py's assert
            tp = [mm.get_typical_token_throughput(mt, k) for k in range(1, L + 1)]
            assert all(t > 0 for t in tp)
            assert all(a >= b for a, b in zip(tp, tp[1:])), f"{mt}: T_k should not grow with k"
            kvc = [mm.get_kv_cache_capacity(mt, k) for k in range(1, L + 1)]
            assert all(a > b > 0 for a, b in zip(kvc, kvc[1:]))
        print("[ok] ModelManager(Qwen3_30B_A3B) on placeholder profiles")

        # --- missing GPU type gives an actionable error ---
        expect_error(lambda: ModelManager(ModelName.Qwen3_30B_A3B, {"A100": 1, "L4x2": 1}),
                     ["profile_qwen3_moe.py"])
        print("[ok] missing machine profile -> actionable error")
    print("ALL SIMULATOR PROFILE TESTS PASSED")


if __name__ == "__main__":
    main()
