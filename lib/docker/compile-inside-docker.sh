#!/bin/bash -e
LLVM_VERSION=3.9
ARCH=X86

cd /usr/src
if ! [ -d build ]; then
  mkdir build
fi
cd build

echo "Starting build in docker container..."
emcmake cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=/usr/lib/ccache/emcc -DCMAKE_CXX_COMPILER=/usr/lib/ccache/em++ \
	-DCMAKE_CROSSCOMPILING=True -DCMAKE_INSTALL_PREFIX=install \
  -DLLVM_ENABLE_THREADS=0 -DLLVM_TARGETS_TO_BUILD=${ARCH} -DLLVM_TARGET_ARCH=${ARCH} \
  -DLLVM_ENABLE_LIBCXX=1 \
  -DEMSCRIPTEN_PRELOAD=/emsdk_portable/emscripten/sdk/tools/file_packager.py \
  -DLLVM_TABLEGEN=/usr/src/patch/llvm-${LLVM_VERSION}-tblgen -DCLANG_TABLEGEN=/usr/src/patch/clang-${LLVM_VERSION}-tblgen \
  -GNinja \
	/usr/src

ninja
CTEST_OUTPUT_ON_FAILURE=1 ninja test
ninja install
