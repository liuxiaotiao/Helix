#!/usr/bin/env bash
# What takes disk space on this node, and what could be cleaned. READ-ONLY: it deletes nothing,
# it only prints sizes and the command you would run. Usually run on every node with
#   examples/real_sys_qwen3/cluster_ctl.py disk
# or by hand:  bash tools/disk_report.sh [--quick]
#   --quick   skip the slow scans (largest directories / big files in home)
# Last line: SUMMARY home_free_gb=.. tmp_free_gb=.. safe_gb=.. review_gb=..
set -o pipefail
QUICK=false
[ "${1:-}" = "--quick" ] && QUICK=true

TMP_DIR="${TMPDIR:-/tmp}"
SAFE_BYTES=0
REVIEW_BYTES=0
bytes() { du -sb "$@" 2>/dev/null | awk '{s += $1} END {printf "%d", s}'; }
human() { numfmt --to=iec --suffix=B --format="%.1f" "${1:-0}" 2>/dev/null || echo "${1}B"; }
free_gb() { df -Pk "$1" 2>/dev/null | awk 'NR==2 {printf "%d", $4 / 1048576}'; }
row() {  # row <safe|review> <bytes> <label> <path> <command>
  [ "${2:-0}" -ge 10485760 ] || return 0            # hide anything below 10 MB
  if [ "$1" = safe ]; then SAFE_BYTES=$((SAFE_BYTES + $2)); else REVIEW_BYTES=$((REVIEW_BYTES + $2)); fi
  printf "  %9s  %-28s %s\n" "$(human "$2")" "$3" "$4"
  printf "  %9s  -> %s\n" "" "$5"
}
section() { echo; echo "== $* =="; }
# environments Helix currently uses (from ~/.helix_env.sh): marked so they are not deleted by mistake
in_use() { [ -f "$HOME/.helix_env.sh" ] && grep -qF "$1" "$HOME/.helix_env.sh" && echo "  <- Helix 正在使用"; }

echo "disk report for $(hostname) ($(whoami)), $(date '+%F %T')"
section "文件系统（home 和 \$TMPDIR 所在的盘）"
df -h "$HOME" "$TMP_DIR" 2>/dev/null | awk 'NR==1 || !seen[$0]++'

# ------------------------------------------------------------------------------------------- #
section "1. 可以放心删除：可再生的缓存（删了只是下次重新下载 / 编译）"
CONDA_BIN=""
for c in "${CONDA_EXE:-}" "$(command -v conda 2>/dev/null)" "$HOME/anaconda3/bin/conda" \
         "$HOME/miniconda3/bin/conda" "$HOME/miniforge3/bin/conda"; do
  [ -n "$c" ] && [ -x "$c" ] && { CONDA_BIN="$c"; break; }
done
if [ -n "$CONDA_BIN" ]; then
  # du over pkgs/ over-counts (files are hard-linked into envs); ask conda what it would remove
  CONDA_RECLAIM=$("$CONDA_BIN" clean -a --dry-run 2>/dev/null | grep -o '([0-9.]* [KMG]B)' \
    | tr -d '()' | awk '{v=$1; u=$2; m=(u=="GB")?1073741824:(u=="MB")?1048576:1024; s+=v*m} END {printf "%d", s}')
  row safe "${CONDA_RECLAIM:-0}" "conda 包缓存" "$("$CONDA_BIN" info --base 2>/dev/null)/pkgs" \
      "$CONDA_BIN clean -a -y        (不影响任何已安装的环境)"
fi
row safe "$(bytes "$HOME/.cache/pip")"              "pip 缓存"            "~/.cache/pip"              "rm -rf ~/.cache/pip"
row safe "$(bytes "$HOME/.cache/uv")"               "uv 缓存"             "~/.cache/uv"               "uv cache clean   (或 rm -rf ~/.cache/uv)"
row safe "$(bytes "$HOME/.triton/cache")"           "triton 编译缓存"      "~/.triton/cache"           "rm -rf ~/.triton/cache"
row safe "$(bytes "$HOME/.cache/torch_extensions")" "torch 扩展编译缓存"   "~/.cache/torch_extensions" "rm -rf ~/.cache/torch_extensions"
row safe "$(bytes "$HOME/.cache/vllm")"             "vLLM 编译缓存"        "~/.cache/vllm"             "rm -rf ~/.cache/vllm"
row safe "$(bytes "$HOME/.cache/flashinfer")"       "flashinfer 缓存"     "~/.cache/flashinfer"       "rm -rf ~/.cache/flashinfer"
row safe "$(bytes "$HOME/.nv/ComputeCache")"        "CUDA JIT 缓存"       "~/.nv/ComputeCache"        "rm -rf ~/.nv/ComputeCache"
row safe "$(bytes "$HOME/.npm/_cacache")"           "npm 缓存"            "~/.npm/_cacache"           "npm cache clean --force"
row safe "$(bytes "$HOME/.cache/yarn")"             "yarn 缓存"           "~/.cache/yarn"             "rm -rf ~/.cache/yarn"
# leftovers in $TMPDIR owned by this user (old pip builds, torch.compile, ray sessions, ...)
mapfile -t TMP_OLD < <(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -user "$(whoami)" -mmin +120 \
    \( -name 'pip-*' -o -name 'torchinductor_*' -o -name 'tmp*' -o -name 'ray' -o -name 'miniforge_*' \
       -o -name 'helix_qwen3_profiles' -o -name '*.whl' \) 2>/dev/null)
if [ "${#TMP_OLD[@]}" -gt 0 ]; then
  row safe "$(bytes "${TMP_OLD[@]}")" "\$TMPDIR 里的旧临时文件" "$TMP_DIR (${#TMP_OLD[@]} 项, 2 小时以上未改动)" \
      "find $TMP_DIR -mindepth 1 -maxdepth 1 -user \$(whoami) -mmin +120 \\( -name 'pip-*' -o -name 'torchinductor_*' -o -name 'tmp*' -o -name ray -o -name '*.whl' \\) -exec rm -rf {} +"
fi

# ------------------------------------------------------------------------------------------- #
section "2. 需要你确认：是数据，不是缓存（删前确认不再需要）"
HF="${HF_HOME:-$HOME/.cache/huggingface}"
if [ -d "$HF" ]; then
  row review "$(bytes "$HF")" "HuggingFace 缓存(模型/数据集)" "$HF" \
      "huggingface-cli delete-cache   (交互式按模型选择删除)"
  for m in $(du -sb "$HF"/hub/models--* "$HF"/hub/datasets--* 2>/dev/null | sort -rn | head -8 | cut -f2); do
    printf "  %9s     · %s\n" "$(human "$(bytes "$m")")" "$(basename "$m" | sed 's/^models--//; s/^datasets--/dataset: /; s/--/\//g')"
  done
fi
row review "$(bytes "$HOME/.cache/modelscope")" "ModelScope 缓存" "~/.cache/modelscope" "rm -rf ~/.cache/modelscope/<不需要的模型>"
row review "$(bytes "$HOME/.cache/torch/hub")"  "torch hub 下载的权重" "~/.cache/torch/hub" "rm -rf ~/.cache/torch/hub/<不需要的项>"
row review "$(bytes "$HOME/.local/share/Trash")" "回收站" "~/.local/share/Trash" "rm -rf ~/.local/share/Trash/*"
if [ -n "$CONDA_BIN" ]; then
  echo "  conda 环境（删除: $CONDA_BIN env remove -p <路径>；正在用的环境不要删）："
  "$CONDA_BIN" env list 2>/dev/null | awk '$1 !~ /^#/ && NF {print $NF}' | while read -r e; do
    [ -d "$e/conda-meta" ] && [ "$e" != "$("$CONDA_BIN" info --base 2>/dev/null)" ] || continue
    note=""
    [ -f "$HOME/.helix_env.sh" ] && grep -qxE "conda activate ($e|$(basename "$e"))" "$HOME/.helix_env.sh" \
      && note="  <- Helix 正在使用（虚拟环境建在它上面）"
    case "$e" in */helix-venv/toolchain) note="  <- Helix 编译用的 CUDA/GCC，装好后可删";; esac
    printf "  %9s     · %s%s\n" "$(human "$(bytes "$e")")" "$e" "$note"
  done
fi
echo "  Python 虚拟环境（含 Helix 的 ~/helix-venv；删除: rm -rf <目录>）："
find "$HOME" -xdev -maxdepth 4 -name pyvenv.cfg -not -path '*/anaconda3/*' -not -path '*/miniconda3/*' \
     -not -path '*/miniforge3/*' 2>/dev/null | while read -r cfg; do
  v="$(dirname "$cfg")"
  printf "  %9s     · %s%s\n" "$(human "$(bytes "$v")")" "$v" "$(in_use "$v/bin/activate")"
done
CORES=$(find "$HOME" -xdev -maxdepth 4 -type f \( -name core -o -name 'core.[0-9]*' \) -size +10M 2>/dev/null)
[ -n "$CORES" ] && row review "$(bytes $CORES)" "core dump 文件" "$(echo "$CORES" | head -3 | tr '\n' ' ')" "rm <文件>"
if ! $QUICK; then
  echo "  大于 1 GB 的文件（模型权重、checkpoint、数据……）："
  find "$HOME" -xdev -type f -size +1G -not -path '*/pkgs/*' -not -path '*/site-packages/*' \
       -printf '%s\t%p\n' 2>/dev/null | sort -rn | head -15 | while IFS=$'\t' read -r s p; do
    printf "  %9s     · %s\n" "$(human "$s")" "$p"
  done
  echo "  大于 200 MB 的日志："
  find "$HOME" "$TMP_DIR" -xdev -type f \( -name '*.log' -o -name 'nohup.out' -o -name '*.out' \) -size +200M \
       -printf '%s\t%p\n' 2>/dev/null | sort -rn | head -10 | while IFS=$'\t' read -r s p; do
    printf "  %9s     · %s\n" "$(human "$s")" "$p"
  done
fi

# ------------------------------------------------------------------------------------------- #
section "3. 需要 sudo（系统级，只列大小）"
for p in /var/cache/apt /var/log/journal /var/lib/docker /var/lib/snapd /var/crash; do
  [ -d "$p" ] || continue
  s=$(du -sb "$p" 2>/dev/null | cut -f1)
  [ -n "$s" ] && [ "$s" -ge 104857600 ] && printf "  %9s  %s\n" "$(human "$s")" "$p"
done
echo "  清理命令: sudo apt-get clean; sudo journalctl --vacuum-size=200M; docker system prune (如有 docker 且确认)"

# ------------------------------------------------------------------------------------------- #
if ! $QUICK; then
  section "home 下最大的目录（前 15）"
  du -xsb "$HOME"/* "$HOME"/.[!.]* 2>/dev/null | sort -rn | head -15 | while IFS=$'\t' read -r s p; do
    printf "  %9s  %s\n" "$(human "$s")" "$p"
  done
fi

section "汇总"
echo "  可以放心删除: $(human $SAFE_BYTES)    需要确认的(已列出大小的类别): $(human $REVIEW_BYTES)"
echo "  Helix 安装需要: 虚拟环境所在盘约 7 GB + \$TMPDIR 约 4 GB（同一块盘则共约 11 GB）"
echo "SUMMARY home_free_gb=$(free_gb "$HOME") tmp_free_gb=$(free_gb "$TMP_DIR") safe_gb=$((SAFE_BYTES / 1073741824)) review_gb=$((REVIEW_BYTES / 1073741824))"
