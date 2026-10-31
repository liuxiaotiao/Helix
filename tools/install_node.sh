#!/usr/bin/env bash
# Install everything Helix (Qwen3-30B-A3B real system) needs on ONE node. Idempotent: steps that
# are already done are skipped, so it is safe to re-run. Usually launched by
#   examples/real_sys_qwen3/cluster_ctl.py install
# but works by hand too:  bash tools/install_node.sh [options]
#
# Two modes:
#   conda mode (default)  packages go into the conda env --env (created if missing, Python 3.10)
#   venv mode (--venv)    --env must be an EXISTING conda env; only its Python is used: a venv is
#                         created from it and every pip package and the compiled libzmq go into the
#                         venv. Nothing is installed into the conda env. If conda-provided build
#                         tools are needed (nvcc, a GCC 12), they go into <venv>/toolchain.
#
#   --env NAME|PATH     conda env name or path, e.g. moe or /home/ubuntu/anaconda3/envs/moe (default: runtime)
#   --venv DIR          venv mode: create / use a Python venv at DIR
#   --install-conda     install Miniforge into --conda-dir if no conda is found (conda mode)
#   --conda-dir DIR     default: ~/miniforge3
#   --cuda-from-conda   if nvcc is missing, install a CUDA 12.1 compiler (conda mode: into the env;
#                       venv mode: into <venv>/toolchain). Otherwise load one first (module load ...)
#   --rebuild           rebuild llm_sys/comm even if llm_worker / llm_host import fine
#   --clean             start over: delete the venv (venv mode) or the Helix-created conda env
#                       (conda mode), llm_sys/comm/build, ~/.helix_env.sh and the pip cache first.
#                       Never deletes a conda env that this script did not create.
#   --dry-run           only print what would be done
#
# Writes ~/.helix_env.sh (activates conda env [+ venv]); cluster_ctl.py uses it.
# Last line on success: HELIX_INSTALL_OK
set -eo pipefail

ENV_NAME=runtime
VENV=""
CONDA_DIR="$HOME/miniforge3"
INSTALL_CONDA=false
CUDA_FROM_CONDA=false
REBUILD=false
CLEAN=false
DRY=false
while [ $# -gt 0 ]; do
  case "$1" in
    --env) ENV_NAME="$2"; shift 2;;
    --venv) VENV="$2"; shift 2;;
    --conda-dir) CONDA_DIR="$2"; shift 2;;
    --install-conda) INSTALL_CONDA=true; shift;;
    --cuda-from-conda) CUDA_FROM_CONDA=true; shift;;
    --rebuild) REBUILD=true; shift;;
    --clean) CLEAN=true; shift;;
    --dry-run) DRY=true; shift;;
    *) echo "unknown option $1"; exit 2;;
  esac
done

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NODE_NAME="$(hostname)"
log()  { echo "[install@$NODE_NAME] $*"; }
step() { echo; echo "[install@$NODE_NAME] ===== $* ====="; }
run()  { if $DRY; then echo "  DRY: $*"; else "$@"; fi; }
die()  { echo "[install@$NODE_NAME] ERROR: $*" >&2; exit 1; }

CONDA_CHANNELS=(-c conda-forge --override-channels)
CUDA_CHANNEL=(-c "nvidia/label/cuda-12.1.1" --override-channels)
CUDA_PKGS=(cuda-nvcc cuda-cudart-dev cuda-cudart-static cuda-nvrtc-dev cuda-nvtx cuda-driver-dev
           libcublas-dev libcufft-dev libcurand-dev libcusolver-dev libcusparse-dev)
if [ -n "$VENV" ]; then MODE=venv; else MODE=conda; fi
case "$VENV" in "~") VENV="$HOME";; "~/"*) VENV="$HOME/${VENV#\~/}";; esac   # quoted ~ from cluster.json
case "$VENV" in ""|/*) ;; *) VENV="$(pwd)/$VENV";; esac

# ------------------------------------------------------------------------------------------- #
step "1/7 conda ($MODE mode)"
CONDA_BIN=""
for c in "${CONDA_EXE:-}" "$(command -v conda 2>/dev/null || true)" "$CONDA_DIR/bin/conda" \
         "$HOME/miniforge3/bin/conda" "$HOME/miniconda3/bin/conda" "$HOME/anaconda3/bin/conda"; do
  if [ -n "$c" ] && [ -x "$c" ]; then CONDA_BIN="$c"; break; fi
done
if [ -z "$CONDA_BIN" ]; then
  [ "$MODE" = conda ] || die "no conda found, but --venv needs your existing conda env '$ENV_NAME'"
  $INSTALL_CONDA || die "no conda found; re-run with --install-conda (installs Miniforge to $CONDA_DIR)"
  ARCH="$(uname -m)"
  URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-${ARCH}.sh"
  log "installing Miniforge from $URL"
  run bash -c "curl -fsSL -o /tmp/miniforge_$$.sh '$URL' || wget -q -O /tmp/miniforge_$$.sh '$URL'"
  run bash "/tmp/miniforge_$$.sh" -b -p "$CONDA_DIR"
  CONDA_BIN="$CONDA_DIR/bin/conda"
fi
CONDA_BASE="$("$CONDA_BIN" info --base 2>/dev/null || dirname "$(dirname "$CONDA_BIN")")"
log "conda: $CONDA_BIN (base $CONDA_BASE)"
if ! $DRY; then
  # shellcheck disable=SC1091
  source "$CONDA_BASE/etc/profile.d/conda.sh"
fi
# --env takes a name ("moe") or a path ("/home/ubuntu/anaconda3/envs/moe")
env_exists() {
  case "$ENV_NAME" in
    */*) [ -d "$ENV_NAME/conda-meta" ];;
    *) conda env list | awk '{print $1}' | grep -qx "$ENV_NAME";;
  esac
}

# ------------------------------------------------------------------------------------------- #
if $CLEAN; then
  step "clean: remove the previous Helix installation"
  if [ "$MODE" = venv ]; then
    if [ -e "$VENV" ]; then
      # refuse anything that does not look like a venv (never $HOME, /, a conda env, ...)
      [ "$VENV" != "/" ] && [ "$VENV" != "$HOME" ] && [ -f "$VENV/pyvenv.cfg" ] \
        || die "--clean: $VENV does not look like a Python venv (no pyvenv.cfg); not deleting it"
      run rm -rf "$VENV"
      log "removed venv $VENV"
    fi
  else
    CLEAN_PREFIX=""
    if env_exists; then
      case "$ENV_NAME" in */*) CLEAN_PREFIX="$ENV_NAME";;
        *) CLEAN_PREFIX="$(conda env list | awk -v n="$ENV_NAME" '$1 == n {print $NF}')";; esac
    fi
    if [ -n "$CLEAN_PREFIX" ]; then
      [ -f "$CLEAN_PREFIX/conda-meta/.helix_created" ] \
        || die "--clean: conda env '$ENV_NAME' was not created by this script; remove it yourself if you mean it"
      run conda env remove -y -p "$CLEAN_PREFIX"
      log "removed conda env $CLEAN_PREFIX"
    fi
  fi
  run rm -rf "$REPO/llm_sys/comm/build" "$HOME/.helix_env.sh" "$HOME/.cache/pip"
  log "removed llm_sys/comm/build, ~/.helix_env.sh and the pip cache"
fi

if [ "$MODE" = conda ]; then
  step "2/7 conda env '$ENV_NAME' (Python 3.10)"
  if ! $DRY && env_exists; then
    log "env exists"
  else
    case "$ENV_NAME" in */*) ENV_FLAG=(-p "$ENV_NAME");; *) ENV_FLAG=(-n "$ENV_NAME");; esac
    run conda create -y "${ENV_FLAG[@]}" "${CONDA_CHANNELS[@]}" python=3.10
    # mark it as ours, so that --clean may delete it later
    $DRY || touch "$(conda run "${ENV_FLAG[@]}" python -c 'import sys; print(sys.prefix)')/conda-meta/.helix_created"
  fi
else
  step "2/7 venv $VENV on top of the existing conda env '$ENV_NAME'"
  $DRY || env_exists || die "conda env '$ENV_NAME' not found (venv mode does not create it)"
fi
if ! $DRY; then
  conda activate "$ENV_NAME"
  python -c 'import sys; assert (3, 8) <= sys.version_info[:2] <= (3, 11)' \
    || die "conda env $ENV_NAME has Python $(python -V 2>&1 | cut -d' ' -f2); vLLM 0.4.0.post1 / torch 2.1.2 need 3.8-3.11 (3.10 recommended)"
  python -c 'import sys; sys.exit(sys.version_info[:2] != (3, 10))' \
    || log "WARNING: Python $(python -V 2>&1 | cut -d' ' -f2); Helix was developed and tested with 3.10"
  if [ "$MODE" = venv ]; then
    if [ -x "$VENV/bin/python" ]; then
      log "venv exists"
    else
      python -m venv "$VENV" || die "could not create a venv (python -m venv) from conda env $ENV_NAME"
      log "created venv $VENV from $(python -V 2>&1) in conda env $ENV_NAME"
    fi
    # shellcheck disable=SC1091
    source "$VENV/bin/activate"
    [ "$(command -v python)" = "$VENV/bin/python" ] || die "venv activation failed"
    pip install -q --upgrade pip
  fi
  {
    echo "# written by Helix tools/install_node.sh ($MODE mode)"
    echo "source \"$CONDA_BASE/etc/profile.d/conda.sh\""
    echo "conda activate $ENV_NAME"
    [ "$MODE" = venv ] && echo "source \"$VENV/bin/activate\""
  } > "$HOME/.helix_env.sh"
  log "wrote ~/.helix_env.sh"
fi
# where natively built libraries (libzmq) and conda-provided build tools go
if [ "$MODE" = venv ]; then PREFIX="$VENV"; TOOLCHAIN="$VENV/toolchain"; else PREFIX="${CONDA_PREFIX:-}"; TOOLCHAIN="${CONDA_PREFIX:-}"; fi
toolchain_install() {   # conda packages for building only; never into the user's env in venv mode
  if [ "$MODE" = venv ]; then
    if [ -d "$TOOLCHAIN/conda-meta" ]; then run conda install -y -p "$TOOLCHAIN" "$@"
    else run conda create -y -p "$TOOLCHAIN" "$@"; fi
    # conda re-activates the current env after installing: put the venv back in front
    # shellcheck disable=SC1091
    $DRY || source "$VENV/bin/activate"
  else
    run conda install -y "$@"
  fi
}

# ------------------------------------------------------------------------------------------- #
step "3/7 vLLM 0.4.0.post1 + pinned transformers / numpy"
if ! $DRY && python - <<'EOF' 2>/dev/null
import numpy, transformers, vllm
assert vllm.__version__ == "0.4.0.post1" and transformers.__version__ == "4.40.2"
assert numpy.__version__.startswith("1.26")
EOF
then
  log "already installed"
else
  # torch 2.1.2 + CUDA libs + vLLM need ~7 GB in the env and ~4 GB of downloads in $TMPDIR while
  # pip installs. Check first instead of failing half-way with "No space left on device".
  free_gb() { df -Pk "$1" 2>/dev/null | awk 'NR==2 {printf "%d", $4 / 1048576}'; }
  fs_of() { df -P "$1" 2>/dev/null | awk 'NR==2 {print $1}'; }
  SITE_DIR="$(python -c 'import site; print(site.getsitepackages()[0])')"
  TMP_DIR="${TMPDIR:-/tmp}"
  if [ -z "${HELIX_SKIP_SPACE_CHECK:-}" ] && ! $DRY; then
    if [ "$(fs_of "$SITE_DIR")" = "$(fs_of "$TMP_DIR")" ]; then
      [ "$(free_gb "$SITE_DIR")" -ge 11 ] || die "only $(free_gb "$SITE_DIR") GB free on the disk of $SITE_DIR and $TMP_DIR; ~11 GB needed.
       Free space (e.g. pip cache purge; conda clean -a), put the venv on a bigger disk (cluster.json
       remote.venv), or set TMPDIR to another disk (remote.pre: export TMPDIR=/bigdisk/tmp)."
    else
      [ "$(free_gb "$SITE_DIR")" -ge 7 ] || die "only $(free_gb "$SITE_DIR") GB free for $SITE_DIR; ~7 GB needed.
       Free space (pip cache purge; conda clean -a) or put the venv on a bigger disk (cluster.json remote.venv)."
      [ "$(free_gb "$TMP_DIR")" -ge 4 ] || die "only $(free_gb "$TMP_DIR") GB free in $TMP_DIR; ~4 GB needed for pip's downloads.
       Set TMPDIR to a bigger disk (cluster.json remote.pre: export TMPDIR=/bigdisk/tmp)."
    fi
    log "disk: $(free_gb "$SITE_DIR") GB free for $SITE_DIR, $(free_gb "$TMP_DIR") GB free in $TMP_DIR"
  fi
  # no pip cache (saves ~3 GB); retry / resume interrupted downloads
  PIP_NET=(--no-cache-dir --retries 10 --timeout 60)
  pip install --help 2>/dev/null | grep -q -- "--resume-retries" && PIP_NET+=(--resume-retries 10)
  run pip install "${PIP_NET[@]}" "vllm==0.4.0.post1" "transformers==4.40.2" "numpy~=1.26"
fi

# ------------------------------------------------------------------------------------------- #
step "4/7 Helix (editable) + planner dependencies"
run pip install -q -e "$REPO" --no-deps
run pip install -q "networkx~=3.2.1" "matplotlib~=3.8.2" "gurobipy==13.0.3"

# ------------------------------------------------------------------------------------------- #
step "5/7 build tools: C++ compiler, cmake, pybind11 2.11.1, libzmq with DRAFT API"
# C++ compiler + make: the system's, else conda-forge GCC 12 (into the env / <venv>/toolchain)
if command -v g++ >/dev/null 2>&1 && command -v make >/dev/null 2>&1; then
  log "C++ compiler: ${CXX:-$(command -v g++)}"
elif [ -n "${CXX:-}" ] && [ -x "$(command -v "$CXX" 2>/dev/null)" ] && command -v make >/dev/null 2>&1; then
  log "C++ compiler: $CXX"
else
  if [ ! -x "$TOOLCHAIN/bin/$(uname -m)-conda-linux-gnu-g++" ]; then
    toolchain_install "${CONDA_CHANNELS[@]}" make "gxx_linux-64=12"
  fi
  if ! $DRY; then
    export CC="$TOOLCHAIN/bin/$(uname -m)-conda-linux-gnu-gcc" CXX="$TOOLCHAIN/bin/$(uname -m)-conda-linux-gnu-g++"
    export PATH="$PATH:$TOOLCHAIN/bin"   # make; appended so the env's python stays first
  fi
  log "no system g++/make: using $CXX"
fi
# cmake (>= 3.22, < 4) and pybind11 2.11.1 from PyPI unless suitable ones are already there
if command -v cmake >/dev/null 2>&1 && cmake --version | head -1 | grep -Eq " 3\.(2[2-9]|3[0-9])"; then
  log "cmake: $(command -v cmake) ($(cmake --version | head -1))"
else
  run pip install -q "cmake>=3.22,<4"
fi
if [ "$(python -m pybind11 --version 2>/dev/null)" = "2.11.1" ]; then
  log "pybind11 2.11.1 present"
else
  run pip install -q "pybind11==2.11.1"
fi
if [ "$MODE" = conda ]; then
  # our own env: give it a libstdc++ at least as new as the compiler's (avoids GLIBCXX_* errors)
  if ! $DRY && [ -n "$(find "$PREFIX/lib" -maxdepth 1 -name 'libstdc++.so.6.0.3[3-9]' -print -quit 2>/dev/null)" ]; then
    log "libstdc++ in the env is recent"
  else
    run conda install -y "${CONDA_CHANNELS[@]}" libstdcxx-ng
  fi
fi
# llm_sys/comm uses zmq::poller_t, a ZeroMQ *draft* API; packaged libzmq (conda-forge, apt) is built
# without drafts, so libzmq is compiled from the release tarball with ENABLE_DRAFTS=ON into $PREFIX.
# cppzmq is header-only and vendored in llm_sys/comm/third_party/cppzmq.
LIBZMQ_VER=4.3.5
LIBZMQ_URL="https://github.com/zeromq/libzmq/releases/download/v${LIBZMQ_VER}/zeromq-${LIBZMQ_VER}.tar.gz"
have_draft_zmq() {
  [ -f "$PREFIX/lib/libzmq.so" ] && python - "$PREFIX/lib/libzmq.so" <<'EOF' 2>/dev/null
import ctypes, sys
ctypes.CDLL(sys.argv[1]).zmq_poller_new
EOF
}
if ! $DRY && have_draft_zmq; then
  log "libzmq with draft API already in $PREFIX"
else
  if [ "$MODE" = conda ] && ! $DRY && conda list 2>/dev/null | awk '{print $1}' | grep -qx zeromq; then
    run conda remove -y --force zeromq     # conda's non-draft libzmq would clash with ours
  fi
  SRC="$(mktemp -d)"
  run bash -c "cd '$SRC' && (curl -fsSL -o zmq.tgz '$LIBZMQ_URL' || wget -q -O zmq.tgz '$LIBZMQ_URL') && tar xzf zmq.tgz"
  run cmake -S "$SRC/zeromq-${LIBZMQ_VER}" -B "$SRC/build" -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_INSTALL_LIBDIR=lib -DENABLE_DRAFTS=ON \
      -DBUILD_TESTS=OFF -DWITH_DOCS=OFF -DWITH_LIBSODIUM=OFF -DENABLE_CURVE=OFF -DWITH_TLS=OFF \
      -DBUILD_STATIC=OFF
  run cmake --build "$SRC/build" -j "$(nproc)"
  run cmake --install "$SRC/build"
  $DRY || have_draft_zmq || die "libzmq with draft API did not install correctly"
  rm -rf "$SRC"
fi

# ------------------------------------------------------------------------------------------- #
step "6/7 CUDA compiler (needed by torch's CMake package)"
NVCC=""
# a CUDA install under /usr/local is often not on PATH in non-interactive (ssh) shells:
# prefer 12.1-12.6 (torch 2.1's CMake needs libnvToolsExt, which newer toolkits may lack)
find_local_cuda() {
  local best="" d v
  for d in /usr/local/cuda-12.* /usr/local/cuda; do
    [ -x "$d/bin/nvcc" ] || continue
    v="$("$d/bin/nvcc" --version | sed -n 's/.*release \([0-9]*\.[0-9]*\).*/\1/p')"
    case "$v" in 12.[1-6]) echo "$d/bin/nvcc"; return;; 12.*) [ -z "$best" ] && best="$d/bin/nvcc";; esac
  done
  [ -n "$best" ] && echo "$best"
}
if command -v nvcc >/dev/null 2>&1; then
  NVCC="$(command -v nvcc)"
elif [ -n "$(find_local_cuda)" ]; then
  NVCC="$(find_local_cuda)"
  log "found $NVCC (not on PATH)"
elif [ -x "$TOOLCHAIN/bin/nvcc" ]; then
  NVCC="$TOOLCHAIN/bin/nvcc"
elif $CUDA_FROM_CONDA; then
  toolchain_install "${CUDA_CHANNEL[@]}" "${CUDA_PKGS[@]}"
  NVCC="$TOOLCHAIN/bin/nvcc"
else
  die "nvcc not found. Load a CUDA 12.1-12.6 toolkit first (e.g. put 'module load cuda/12.4' in
       cluster.json remote.pre) or re-run with --cuda-from-conda"
fi
$DRY || log "nvcc: $NVCC ($("$NVCC" --version | tail -1))"

# ------------------------------------------------------------------------------------------- #
step "7/7 llm_sys/comm (ZeroMQ communication layer)"
comm_err() { (cd /tmp && python -c "import llm_worker, llm_host" 2>&1 >/dev/null) || true; }
comm_ok() { (cd /tmp && python -c "import llm_worker, llm_host") >/dev/null 2>&1; }
if ! $DRY && ! $REBUILD && comm_ok; then
  log "llm_worker / llm_host already importable (use --rebuild to force)"
else
  NVCC_ON_PATH=false
  [ "$(command -v nvcc 2>/dev/null)" = "$NVCC" ] && NVCC_ON_PATH=true
  if [ "$NVCC" = "$TOOLCHAIN/bin/nvcc" ] || ! $NVCC_ON_PATH; then   # tell CMake where CUDA is
    CUDA_ROOT="$(dirname "$(dirname "$NVCC")")"
    export CUDA_HOME="$CUDA_ROOT" CUDA_PATH="$CUDA_ROOT" CUDACXX="$NVCC" CUDA_TOOLKIT_ROOT_DIR="$CUDA_ROOT"
    if [ "$CUDA_ROOT" != "${CONDA_PREFIX:-}" ]; then
      export CUDA_BIN_PATH="$CUDA_ROOT/bin" HELIX_EXTRA_PREFIX="$CUDA_ROOT"
    fi
  fi
  # torch's CMake package enables CUDA, and nvcc refuses host GCCs newer than it supports
  # (CUDA 12.0-12.3: GCC <= 12, 12.4-12.6: <= 13, 12.8+: <= 14). Use conda's GCC 12 for CUDA if needed.
  if ! $DRY; then
    NVCC_VER="$("$NVCC" --version | sed -n 's/.*release \([0-9]*\.[0-9]*\).*/\1/p')"
    gcc_major() { ("$1" -dumpversion 2>/dev/null || echo 99) | cut -d. -f1; }
    MAX_GCC=$(python -c "v=tuple(map(int,'$NVCC_VER'.split('.'))); print(12 if v<(12,4) else 13 if v<(12,8) else 14)")
    # nvcc's host compiler: $CUDAHOSTCXX if set, otherwise g++ on PATH (NOT $CXX)
    NVCC_HOST="${CUDAHOSTCXX:-$(command -v g++ || echo g++)}"
    log "nvcc $NVCC_VER supports host GCC <= $MAX_GCC; its host compiler $NVCC_HOST is GCC $(gcc_major "$NVCC_HOST")"
    if [ "$(gcc_major "$NVCC_HOST")" -gt "$MAX_GCC" ]; then
      if [ -n "${CXX:-}" ] && [ "$(gcc_major "$CXX")" -le "$MAX_GCC" ]; then
        HOSTCXX="$(command -v "$CXX")"
      else
        HOSTCXX="$TOOLCHAIN/bin/$(uname -m)-conda-linux-gnu-g++"
        [ -x "$HOSTCXX" ] || toolchain_install "${CONDA_CHANNELS[@]}" "gxx_linux-64=12"
      fi
      export CUDAHOSTCXX="$HOSTCXX"
      log "using $CUDAHOSTCXX as the CUDA host compiler"
    fi
  fi
  if ! $NVCC_ON_PATH && [ "$(dirname "$NVCC")" != "${CONDA_PREFIX:-}/bin" ]; then
    run bash -c "export PATH=\"\$PATH:$(dirname "$NVCC")\"; cd '$REPO/llm_sys/comm' && bash build.sh"
  else
    run bash -c "cd '$REPO/llm_sys/comm' && bash build.sh"
  fi
fi

# ------------------------------------------------------------------------------------------- #
step "verify"
$DRY && { log "dry run finished"; exit 0; }
TEST_OUT="$("$REPO/llm_sys/comm/build/test_msg" 2>&1 || true)"
case "$TEST_OUT" in *"Test Passed"*) log "test_msg: Test Passed";; *) die "llm_sys/comm/build/test_msg failed";; esac
if comm_ok; then
  log "import llm_worker, llm_host: ok"
else
  ERR="$(comm_err | tail -1)"
  case "$ERR" in
    *GLIBCXX*|*CXXABI*)
      die "llm_worker / llm_host need a newer libstdc++ than conda env '$ENV_NAME' provides:
       $ERR
       Fix: conda install -n $ENV_NAME -c conda-forge libstdcxx-ng   (or build with an older GCC)";;
    *) die "llm_worker / llm_host not importable: $ERR";;
  esac
fi
python -c "import vllm, transformers, torch; print('[install] vllm', vllm.__version__, '| transformers', transformers.__version__, '| torch', torch.__version__, '| CUDA', torch.version.cuda)"
log "python: $(command -v python) ($MODE mode)"
if command -v nvidia-smi >/dev/null 2>&1; then
  DRV="$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1)"
  GPU="$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader | head -1)"
  log "GPU: $GPU, driver $DRV"
  [ "${DRV%%.*}" -ge 525 ] 2>/dev/null || log "WARNING: driver $DRV may be too old for CUDA 12.1 wheels (need >= 525.60)"
else
  log "no nvidia-smi: fine for the host / a planning node, required on workers"
fi
echo "HELIX_INSTALL_OK"
