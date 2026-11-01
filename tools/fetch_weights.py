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
PROGRESS = ".helix_weights_progress.json"   # read by cluster_ctl.py weights / weights-status


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


def _lfs_sha(info):
    lfs = getattr(info, "lfs", None)
    if lfs is None:
        return None
    return lfs.get("sha256") if isinstance(lfs, dict) else getattr(lfs, "sha256", None)


def remote_sha256(repo, revision, files):
    """file -> sha256 of the LFS object on the Hub (None if unknown)."""
    from huggingface_hub import HfApi
    try:
        got = {i.path: _lfs_sha(i) for i in HfApi().get_paths_info(repo, files, revision=revision)}
    except Exception:  # noqa: BLE001
        got = {}
    return {f: got.get(f) for f in files}


def sha256_of(path):
    import hashlib
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(16 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


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


def download(repo, revision, filename, local_dir, retries=8):
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
            wait = min(120, 15 * attempt)
            print(f"  retry {attempt}/{retries - 1} for {filename} in {wait}s: {type(e).__name__}: "
                  f"{str(e)[:200]}", flush=True)
            time.sleep(wait)


def dir_size(d):
    total = 0
    for root, _, files in os.walk(d):
        for f in files:
            p = os.path.join(root, f)
            if not os.path.islink(p):
                total += os.path.getsize(p)
    return total


def curl_download(repo, revision, filename, local_dir, expected_size=None, attempts=30):
    """Plain curl into <file>.part (resumable with -C -, aborted and resumed when the transfer
    stalls below 1 MB/s for 60 s), then renamed. Used with --curl: it only needs the CDN to be
    reachable with curl, nothing from the huggingface_hub download stack."""
    import subprocess
    endpoint = os.environ.get("HF_ENDPOINT", "https://huggingface.co").rstrip("/")
    url = f"{endpoint}/{repo}/resolve/{revision}/{filename}"
    dst = os.path.join(local_dir, filename)
    part = dst + ".part"
    cmd = ["curl", "-fsSL", "--connect-timeout", "30", "--speed-limit", "1000000", "--speed-time", "60",
           "-C", "-", "-o", part, url]
    if os.environ.get("HF_TOKEN"):
        cmd[1:1] = ["-H", f"Authorization: Bearer {os.environ['HF_TOKEN']}"]
    for attempt in range(1, attempts + 1):
        if expected_size is not None and os.path.exists(part) and os.path.getsize(part) >= expected_size:
            break
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode == 0:
            break
        have = os.path.getsize(part) if os.path.exists(part) else 0
        if attempt == attempts:
            raise RuntimeError(f"curl failed for {filename} (exit {r.returncode}): {r.stderr.strip()[-300:]}")
        wait = min(60, 5 * attempt)
        print(f"  curl exit {r.returncode} for {filename} at {have / 1e9:.2f} GB "
              f"({r.stderr.strip()[-150:]}); resuming in {wait}s ({attempt}/{attempts - 1})", flush=True)
        time.sleep(wait)
    os.replace(part, dst)
    return dst


def clean_dir(d, dry_run=False):
    """delete everything inside d; returns the bytes freed (or that would be freed)."""
    real = os.path.realpath(d)
    home = os.path.realpath(os.path.expanduser("~"))
    if real in ("/", home) or real.count(os.sep) < 2:
        raise SystemExit(f"refusing to clean {real}")
    if not os.path.isdir(real):
        return 0
    freed = dir_size(real)
    if not dry_run:
        for name in os.listdir(real):
            p = os.path.join(real, name)
            if os.path.isdir(p) and not os.path.islink(p):
                shutil.rmtree(p)
            else:
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
    ap.add_argument("--no-xet", action="store_true",
                    help="plain HTTPS download instead of HF's Xet storage (use when Xet transfers fail)")
    ap.add_argument("--no-verify", action="store_true", help="skip the sha256 check of downloaded shards")
    ap.add_argument("--curl", action="store_true",
                    help="download the shards with curl (resumable) instead of huggingface_hub")
    a = ap.parse_args()
    if a.no_xet:   # must be set before huggingface_hub is imported (it reads it at import time)
        os.environ["HF_HUB_DISABLE_XET"] = "1"
    assert a.all or a.layers, "give --layers START END (repeatable) or --all"

    d = os.path.abspath(os.path.expanduser(a.dir))
    print(f"[weights] {os.uname().nodename}: {a.repo}@{a.revision} -> {d}  "
          f"layers={a.layers if not a.all else 'ALL'}", flush=True)
    freed_by_clean = 0
    if a.clean:
        freed_by_clean = clean_dir(d, dry_run=a.dry_run)
        if a.dry_run:
            print(f"[weights] (dry run) would delete everything inside {d} ({gb(freed_by_clean)})")
            # a real run cleans first, so that space counts as free
        else:
            print(f"[weights] cleaned {d}: freed {gb(freed_by_clean)}", flush=True)
            freed_by_clean = 0
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
    free = shutil.disk_usage(d).free + freed_by_clean
    print(f"[weights] {len(shards)} shard(s) for these layers: {len(shards) - len(todo)} present "
          f"({gb(have)}), {len(todo)} to download ({gb(need)}); free disk {gb(free)}"
          f"{' after cleaning' if freed_by_clean else ''}", flush=True)
    for s in shards:
        print(f"    {s}  {gb(sizes[s]) if sizes[s] else '?'}{'' if s in todo else '  (present)'}")
    if need + a.reserve_gb * 1e9 > free:
        raise SystemExit(f"not enough disk: need {gb(need)} (+{a.reserve_gb:g} GB reserve), free {gb(free)}")
    if a.dry_run:
        print("[weights] dry run: nothing downloaded")
        print("HELIX_WEIGHTS_OK")
        return

    # partial downloads (<dir>/.cache/huggingface/download/*.incomplete) are resumed by the next
    # run, but a partial file written by the Xet client must not be continued by a plain HTTP
    # download (or vice versa): drop them when the download mode changed
    mode = "curl" if a.curl else "http" if os.environ.get("HF_HUB_DISABLE_XET") else "xet"
    mode_file = os.path.join(d, ".helix_download_mode")
    old_mode = open(mode_file).read().strip() if os.path.exists(mode_file) else None
    if old_mode and old_mode != mode:
        import glob
        stale = glob.glob(os.path.join(d, ".cache", "huggingface", "download", "**", "*.incomplete"),
                          recursive=True)
        for f in stale:
            os.remove(f)
        if stale:
            print(f"[weights] download mode {old_mode} -> {mode}: removed {len(stale)} partial file(s)")
    with open(mode_file, "w") as f:
        f.write(mode)
    print(f"[weights] download mode: {mode}", flush=True)
    shas = {} if a.no_verify else remote_sha256(a.repo, a.revision, todo)

    # progress file for `cluster_ctl.py weights` / `weights-status`: bytes downloaded so far =
    # size of the directory (partial files included) minus `base`
    prog = {"state": "downloading", "need": need, "base": dir_size(d), "shards_total": len(todo),
            "shards_done": 0, "current": None, "started": time.time(), "updated": time.time()}

    def save_progress(**kw):
        prog.update(kw, updated=time.time())
        tmp = os.path.join(d, PROGRESS + ".tmp")
        with open(tmp, "w") as f:
            json.dump(prog, f)
        os.replace(tmp, os.path.join(d, PROGRESS))

    t0 = time.time()
    try:
        for k, s in enumerate(todo, 1):
            save_progress(current=s)
            t = time.time()
            if a.curl:
                curl_download(a.repo, a.revision, s, d, expected_size=sizes[s])
            else:
                download(a.repo, a.revision, s, d)
            sz = os.path.getsize(os.path.join(d, s))
            if sizes[s] is not None and sz != sizes[s]:
                os.remove(os.path.join(d, s))
                raise SystemExit(f"{s}: got {sz} bytes, expected {sizes[s]} (deleted; rerun to retry)")
            if shas.get(s):
                save_progress(current=s + " (sha256 check)")
                got = sha256_of(os.path.join(d, s))
                if got != shas[s]:
                    os.remove(os.path.join(d, s))
                    raise SystemExit(f"{s}: sha256 mismatch (deleted; rerun to retry)")
            save_progress(shards_done=k)
            print(f"[weights] {k}/{len(todo)} {s} {gb(sz)} in {time.time() - t:.0f}s "
                  f"({sz / max(time.time() - t, 1e-3) / 1e6:.0f} MB/s)", flush=True)
    except BaseException as e:
        save_progress(state="failed", error=f"{type(e).__name__}: {str(e)[:300]}")
        raise
    save_progress(state="done", current=None)

    with open(os.path.join(d, MANIFEST), "w") as f:
        json.dump({"repo": a.repo, "revision": a.revision, "layers": a.layers, "all": a.all,
                   "shards": shards, "time": time.strftime("%F %T")}, f, indent=1)
    print(f"[weights] done in {time.time() - t0:.0f}s; {len(shards)} shard(s) in {d}")
    print("HELIX_WEIGHTS_OK")


if __name__ == "__main__":
    sys.exit(main())
