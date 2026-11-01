"""
Download the HuggingFace safetensors shards that ONE node needs for its layers (run on that node).

    python tools/fetch_weights.py --dir /home/ubuntu/p2p-framework/weights-q3-30b \
        --layers 12 18 [--layers 30 36] [--repo Qwen/Qwen3-30B-A3B] [--clean] [--dry-run]
    python tools/fetch_weights.py --dir ... --all          # every shard (the whole model)

Usually started on every node at once by `examples/real_sys_qwen3/cluster_ctl.py weights`.

* Small files (config.json, tokenizer, generation_config.json, model.safetensors.index.json) are
  always downloaded; then only the shards holding model.layers.{i}.* for the given layers, plus
  model.embed_tokens.* for the node with layer 0 and model.norm.* / lm_head.* for the node with
  the last layer. Shards are whole files: a shard shared with a neighbouring layer is kept whole.
* --clean deletes EVERYTHING inside --dir first (asked for explicitly; refuses / and $HOME).
* Files already present with the right size are skipped, so re-running resumes a broken download.
* Checks free disk space before downloading. HF_ENDPOINT / HF_TOKEN are honoured (mirror, token).
Prints HELIX_WEIGHTS_OK at the end on success.
"""
import argparse
import inspect
import json
import os
import shutil
import sys
import time

SMALL_FILES = ["config.json", "generation_config.json", "model.safetensors.index.json",
               "tokenizer.json", "tokenizer_config.json", "vocab.json", "merges.txt",
               "special_tokens_map.json", "LICENSE", "README.md"]
MANIFEST = ".helix_weights.json"


def needed_prefixes(ranges, total_layers):
    pre = set()
    for s, e in ranges:
        assert 0 <= s < e <= total_layers, f"bad layer range [{s}, {e})"
        pre.update(f"model.layers.{i}." for i in range(s, e))
        if s == 0:
            pre.add("model.embed_tokens.")
        if e == total_layers:
            pre.update(["model.norm.", "lm_head."])
    return pre


def shards_for(weight_map, prefixes):
    want = set()
    for name, shard in weight_map.items():
        if any(name.startswith(p) for p in prefixes):
            want.add(shard)
    return sorted(want)


def remote_sizes(repo, revision, files):
    """file -> bytes on the Hub (None if unknown)."""
    from huggingface_hub import HfApi
    api = HfApi()
    try:
        infos = api.get_paths_info(repo, files, revision=revision)
        got = {i.path: getattr(i, "size", None) for i in infos}
        return {f: got.get(f) for f in files}
    except Exception:  # noqa: BLE001  (older huggingface_hub)
        try:
            info = api.model_info(repo, revision=revision, files_metadata=True)
            got = {s.rfilename: s.size for s in info.siblings}
            return {f: got.get(f) for f in files}
        except Exception:  # noqa: BLE001
            return {f: None for f in files}


def download(repo, revision, filename, local_dir, retries=5):
    from huggingface_hub import hf_hub_download
    kw = dict(repo_id=repo, filename=filename, revision=revision, local_dir=local_dir)
    params = inspect.signature(hf_hub_download).parameters
    if "local_dir_use_symlinks" in params:
        import huggingface_hub
        major, minor = (int(x) for x in huggingface_hub.__version__.split(".")[:2])
        if (major, minor) < (0, 23):   # old versions symlink into ~/.cache by default
            kw["local_dir_use_symlinks"] = False
    for attempt in range(1, retries + 1):
        try:
            return hf_hub_download(**kw)
        except Exception as e:  # noqa: BLE001
            if attempt == retries:
                raise
            wait = min(60, 5 * attempt)
            print(f"  retry {attempt}/{retries - 1} for {filename} in {wait}s: {type(e).__name__}: "
                  f"{str(e)[:200]}", flush=True)
            time.sleep(wait)


def clean_dir(d):
    real = os.path.realpath(d)
    home = os.path.realpath(os.path.expanduser("~"))
    if real in ("/", home) or real.count(os.sep) < 2:
        raise SystemExit(f"refusing to clean {real}")
    if not os.path.isdir(real):
        return 0
    freed = 0
    for name in os.listdir(real):
        p = os.path.join(real, name)
        if os.path.isdir(p) and not os.path.islink(p):
            for root, _, files in os.walk(p):
                freed += sum(os.path.getsize(os.path.join(root, f)) for f in files
                             if not os.path.islink(os.path.join(root, f)))
            shutil.rmtree(p)
        else:
            freed += 0 if os.path.islink(p) else os.path.getsize(p)
            os.remove(p)
    return freed


def gb(x):
    return f"{x / 1e9:.1f} GB"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dir", required=True)
    ap.add_argument("--repo", default="Qwen/Qwen3-30B-A3B")
    ap.add_argument("--revision", default="main")
    ap.add_argument("--layers", nargs=2, type=int, action="append", metavar=("START", "END"),
                    help="layer range [START, END) this node serves; may repeat")
    ap.add_argument("--all", action="store_true", help="download every shard")
    ap.add_argument("--clean", action="store_true", help="delete everything inside --dir first")
    ap.add_argument("--dry-run", action="store_true", help="only print what would happen")
    ap.add_argument("--reserve-gb", type=float, default=2.0, help="keep this much disk free")
    a = ap.parse_args()
    assert a.all or a.layers, "give --layers START END (repeatable) or --all"

    d = os.path.abspath(os.path.expanduser(a.dir))
    print(f"[weights] {os.uname().nodename}: {a.repo}@{a.revision} -> {d}  "
          f"layers={a.layers if not a.all else 'ALL'}", flush=True)
    if a.clean:
        if a.dry_run:
            print(f"[weights] (dry run) would delete everything inside {d}")
        else:
            print(f"[weights] cleaned {d}: freed {gb(clean_dir(d))}", flush=True)
    # a dry run reads the index into a temporary directory and leaves --dir untouched
    import tempfile
    meta_dir = tempfile.mkdtemp(prefix="helix_weights_") if a.dry_run else d
    os.makedirs(d, exist_ok=True)

    # small files + index (skip ones the repo does not have)
    for f in SMALL_FILES:
        if a.dry_run and f not in ("config.json", "model.safetensors.index.json"):
            continue
        try:
            download(a.repo, a.revision, f, meta_dir, retries=3 if f in ("config.json", "model.safetensors.index.json") else 1)
        except Exception as e:  # noqa: BLE001
            if f in ("config.json", "model.safetensors.index.json"):
                raise SystemExit(f"cannot download {f} from {a.repo}: {e}\n"
                                 f"(no internet to huggingface.co? set HF_ENDPOINT to a mirror)")
    index = json.load(open(os.path.join(meta_dir, "model.safetensors.index.json")))
    cfg = json.load(open(os.path.join(meta_dir, "config.json")))
    total_layers = int(cfg.get("num_hidden_layers", 48))
    wm = index["weight_map"]
    shards = sorted(set(wm.values())) if a.all else shards_for(wm, needed_prefixes(a.layers, total_layers))

    sizes = remote_sizes(a.repo, a.revision, shards)
    todo, have = [], 0
    for s in shards:
        p = os.path.join(d, s)
        if os.path.exists(p) and sizes[s] is not None and os.path.getsize(p) == sizes[s]:
            have += sizes[s]
        else:
            todo.append(s)
    need = sum(sizes[s] or 4_100_000_000 for s in todo)   # unknown size: ~ a typical 4 GB shard
    free = shutil.disk_usage(d).free
    print(f"[weights] {len(shards)} shard(s) for these layers: {len(shards) - len(todo)} present "
          f"({gb(have)}), {len(todo)} to download ({gb(need)}); free disk {gb(free)}", flush=True)
    for s in shards:
        print(f"    {s}  {gb(sizes[s]) if sizes[s] else '?'}{'' if s in todo else '  (present)'}")
    if need + a.reserve_gb * 1e9 > free:
        raise SystemExit(f"not enough disk: need {gb(need)} (+{a.reserve_gb:g} GB reserve), free {gb(free)}")
    if a.dry_run:
        print("[weights] dry run: nothing downloaded")
        print("HELIX_WEIGHTS_OK")
        return

    t0 = time.time()
    for k, s in enumerate(todo, 1):
        t = time.time()
        download(a.repo, a.revision, s, d)
        sz = os.path.getsize(os.path.join(d, s))
        if sizes[s] is not None and sz != sizes[s]:
            raise SystemExit(f"{s}: got {sz} bytes, expected {sizes[s]}")
        print(f"[weights] {k}/{len(todo)} {s} {gb(sz)} in {time.time() - t:.0f}s "
              f"({sz / max(time.time() - t, 1e-3) / 1e6:.0f} MB/s)", flush=True)

    with open(os.path.join(d, MANIFEST), "w") as f:
        json.dump({"repo": a.repo, "revision": a.revision, "layers": a.layers, "all": a.all,
                   "shards": shards, "time": time.strftime("%F %T")}, f, indent=1)
    print(f"[weights] done in {time.time() - t0:.0f}s; {len(shards)} shard(s) in {d}")
    print("HELIX_WEIGHTS_OK")


if __name__ == "__main__":
    sys.exit(main())
