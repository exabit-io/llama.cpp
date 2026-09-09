#!/usr/bin/env bash
# Build recipe for the gfx906 branch (Ubuntu 24.04, ROCm 7.14 TheRock ML-gfx906 apt). Same flags as every measured binary.
#   scripts/gfx906/build.sh [prefix]     (default /opt/llama.cpp-gfx906)
set -euo pipefail
PREFIX=${1:-/opt/llama.cpp-gfx906}
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DGGML_HIP=ON -DGPU_TARGETS=gfx906 -DAMDGPU_TARGETS=gfx906 \
  -DGGML_HIP_GRAPHS=ON -DGGML_HIP_RCCL=ON "-DGGML_CUDA_FA_QUANTS=f16-f16;q8_0-q8_0;q8_0-q4_0" -DGGML_HIP_NO_VMM=ON -DGGML_HIP_MMQ_MFMA=ON -DGGML_CCACHE=ON -DGGML_NATIVE=ON \
  -DBUILD_SHARED_LIBS=ON -DCMAKE_C_FLAGS=-march=native -DCMAKE_CXX_FLAGS=-march=native \
  '-DCMAKE_HIP_FLAGS=-mllvm -amdgpu-sched-strategy=max-ilp' -DCMAKE_INSTALL_PREFIX="$PREFIX" -DLLAMA_CURL=OFF
cmake --build build -j"$(nproc)"
cmake --install build --prefix "$PREFIX"
echo "installed $PREFIX; run binaries with LD_LIBRARY_PATH=$PREFIX/lib (no rpath) and the variables in scripts/gfx906/env.sh"
