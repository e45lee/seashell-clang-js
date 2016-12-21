#!/bin/bash
LLVM_VERSION=3.9
ARCH=X86

cd /usr/src
mkdir build
cd build

echo "Starting build in docker container..."
/emsdk_portable/emscripten/tag-${EMSCRIPTEN_VERSION}/emcmake cmake \
	-DCMAKE_CROSSCOMPILING=True -DCMAKE_INSTALL_PREFIX=install \
	-DLLVM_ENABLE_THREADS=0 -DLLVM_TARGETS_TO_BUILD=${ARCH} -DLLVM_TARGET_ARCH=${ARCH} \
	-DEMSCRIPTEN_PRELOAD=/emsdk_portable/emscripten/tag-${EMSCRIPTEN_VERSION}/tools/file_packager.py \
	-DCMAKE_BUILD_TYPE=RelWithDebInfo \
	-DLLVM_TABLEGEN=/usr/src/patch/llvm-${LLVM_VERSION}-tblgen -DCLANG_TABLEGEN=/usr/src/patch/clang-${LLVM_VERSION}-tblgen \
	/usr/src

make -j2 install VERBOSE=1
