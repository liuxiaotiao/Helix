#!/bin/bash

# Stop execution if any command fails
set -e

# Remove the existing build directory completely
echo "Removing existing build directory..."
rm -rf build

# Create a fresh build directory
echo "Creating a new build directory..."
mkdir -p build
cd build

# Run CMake to configure the build environment
echo "Configuring build with CMake..."
# Use the *active* Python / torch / conda env instead of the paths hard-coded in CMakeLists.txt
# (~/miniconda3/envs/runtime). Picks up cppzmq / zeromq / pybind11 installed with conda-forge too.
PYTHON_BIN=$(command -v python)
TORCH_CMAKE=$(python -c "import torch; print(torch.utils.cmake_prefix_path)")
PREFIX_PATH="${TORCH_CMAKE}"
# a Python venv first (tools/install_node.sh --venv puts the draft-API libzmq there), then conda
if [ -n "${VIRTUAL_ENV}" ]; then PREFIX_PATH="${PREFIX_PATH};${VIRTUAL_ENV}"; fi
if [ -n "${CONDA_PREFIX}" ]; then PREFIX_PATH="${PREFIX_PATH};${CONDA_PREFIX}"; fi
# extra prefixes, e.g. a conda-provided CUDA toolkit outside the env (install_node.sh --venv)
if [ -n "${HELIX_EXTRA_PREFIX}" ]; then PREFIX_PATH="${PREFIX_PATH};${HELIX_EXTRA_PREFIX}"; fi
EXTRA_ARGS=()
PYBIND11_CMAKE=$(python -m pybind11 --cmakedir 2>/dev/null || true)
if [ -n "${PYBIND11_CMAKE}" ]; then EXTRA_ARGS+=("-Dpybind11_DIR=${PYBIND11_CMAKE}"); fi
echo "Python: ${PYTHON_BIN}"
echo "CMAKE_PREFIX_PATH: ${PREFIX_PATH}"
cmake -DCMAKE_BUILD_TYPE=Release -DPython3_EXECUTABLE="${PYTHON_BIN}" -DPYTHON_EXECUTABLE="${PYTHON_BIN}" \
      -DCMAKE_PREFIX_PATH="${PREFIX_PATH}" "${EXTRA_ARGS[@]}" .. || { echo "CMake configuration failed"; exit 1; }

# Run Make to build the project with 8 threads
echo "Building with Make..."
make -j8 || { echo "Make failed"; exit 1; }

# Return to the original directory
cd ..

# Install the Python module
echo "Installing the Python module..."
python setup.py install || { echo "Python module installation failed"; exit 1; }

echo "Build and installation completed successfully."
