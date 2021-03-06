# Seashell
# Copyright (C) 2012-2015 The Seashell Maintainers
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# See also 'ADDITIONAL TERMS' at the end of the included LICENSE file.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
cmake_minimum_required(VERSION 2.6)
project(seashell-js)

include(CTest)
enable_testing()

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Debug' as none was specified.")
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build." FORCE)
endif(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)

# Find node.js 
find_program(node NAMES nodejs node iojs)

# Set global build flags
set(CMAKE_EXE_LINKER_FLAGS "-s FORCE_FILESYSTEM=1 -lnodefs.js -s SINGLE_FILE=1 -s BINARYEN_ASYNC_COMPILATION=0 -s DISABLE_EXCEPTION_CATCHING=0 -s ERROR_ON_UNDEFINED_SYMBOLS=0 ${CMAKE_EXE_LINKER_FLAGS}")
set(CMAKE_C_FLAGS "-s DISABLE_EXCEPTION_CATCHING=0 ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "-s DISABLE_EXCEPTION_CATCHING=0 ${CMAKE_CXX_FLAGS}")
# Do not compile with MinSizeRel as the emscripten JS optimizer is really slow.
set(CMAKE_CXX_FLAGS_MINSIZEREL "-Oz -DNDEBUG ")
set(CMAKE_C_FLAGS_MINSIZEREL "-Oz -DNDEBUG ")
set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "-Oz ")
# Standard release build flags -- DO NOT TURN on -O>2 as the JS optimizer is really slow.
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG ")
set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG ")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-O3 -DNDEBUG ")
# Standard, O2 for release.
set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O3 -DNDEBUG --profiling")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O3 -DNDEBUG --profiling")
set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "-O3 -DNDEBUG --profiling")
# Full debugging information for Debug
set(CMAKE_C_FLAGS_DEBUG "-O0 -g3")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g3")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "-O0 -g3")

# Build our libraries.
add_subdirectory(lib)
add_subdirectory(interpreter)

project(seashell-clang-js)
set(LLVM_ROOT "${CMAKE_BINARY_DIR}/lib/llvm")

# A bit of a sanity check:
if( NOT EXISTS ${LLVM_ROOT}/include/llvm )
  message(FATAL_ERROR "LLVM_ROOT (${LLVM_ROOT}) is not a valid LLVM install.  Something's gone horribly wrong.")
endif()

# We incorporate the CMake features provided by LLVM:
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${LLVM_ROOT}/cmake/modules/CMakeFiles")
include(LLVMConfig)


# Configure I/O stub.
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/io.js.in" "${CMAKE_CURRENT_BINARY_DIR}/io.js")

# Components
add_subdirectory(compiler)
add_subdirectory(tests)

install(FILES package.json DESTINATION .)
