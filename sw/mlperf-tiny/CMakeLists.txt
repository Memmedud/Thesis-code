#
# Copyright (C) 2021-2022 Chair of Electronic Design Automation, TUM.
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the License); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an AS IS BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

cmake_minimum_required(VERSION 3.10)
message(STATUS "CMake Version ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}.${CMAKE_PATCH_VERSION}")

set(SIMULATOR "Spike" CACHE STRING "Specify the simulator.")
set_property(CACHE SIMULATOR PROPERTY STRINGS OVPsim Spike ETISS Vicuna)

# Choose which toolchain you want to use, either GCC or LLVM (or x86 for native build)
set(TOOLCHAIN "GCC" CACHE STRING "Specify which toolchain to use.")
set_property(CACHE TOOLCHAIN PROPERTY STRINGS GCC)

# RISC-V extensions for HW acceleration
option(USE_RV32E "Use RV32E with reduced register count" OFF)
option(USE_VEXT "Use the RISC-V V Vector Extension" ON)
option(AUTO_VECTORIZE "Use RISC-V Auto-Vectorization" OFF)
option(USE_PEXT "Use the RISC-V P Packed Extension" OFF)
option(SPIKE "Compile for Spike ISA simulator" OFF)
option(LONG_BENCHMARK "Compile long benchmarks" OFF)
option(SIM_VICUNA "Compiler with Vicuna workarounds" OFF)

if(USE_RV32E)
  if(USE_VEXT)
    set(RISCV_ARCH "rv32emc_zve32x_zicsr" CACHE STRING "march argument to the compiler, using the vector extension")
  elseif(USE_PEXT)
  set(RISCV_ARCH "rv32emc_zpn_zbpbo_zicsr" CACHE STRING "march argument to the compiler, using the vector extension")
  else()
    set(RISCV_ARCH "rv32emc_zicsr" CACHE STRING "march argument to the compiler, using only scalar instructions")
  endif()
  set(RISCV_ABI "ilp32e" CACHE STRING "mabi argument to the compiler")
  set(RISCV_CMODEL "medlow" CACHE STRING "mcmodel argument to the compiler")
else() 
  if(USE_VEXT)
    set(RISCV_ARCH "rv32imc_zve32x_zvl64b_zicsr" CACHE STRING "march argument to the compiler, using the vector extension")
  elseif(USE_PEXT)
    set(RISCV_ARCH "rv32imc_zpn_zbpbo_zicsr" CACHE STRING "march argument to the compiler, using the packed extension")
  else()
    set(RISCV_ARCH "rv32imc_zicsr" CACHE STRING "march argument to the compiler, using only scalar instructions")
  endif()
  set(RISCV_ABI "ilp32" CACHE STRING "mabi argument to the compiler")
  set(RISCV_CMODEL "medlow" CACHE STRING "mcmodel argument to the compiler")
endif()

set(AUTO_VECTORIZE_VLEN "128" CACHE STRING "Specify the vector length if using auto vectorization.")

# Tell CMake about our processor
set(CMAKE_SYSTEM_PROCESSOR ${RISCV_ARCH})
# The Generic system name is used for bare-metal targets (without OS) in CMake
set(CMAKE_SYSTEM_NAME Generic)

# Enable tests by default
option(ENABLE_INTG_TESTS "Enable integration tests" ON)

# Configure CMake
if(NOT ${TOOLCHAIN} STREQUAL "NONE")
  set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/CMake/toolchain_${TOOLCHAIN}.cmake")
endif()
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/CMake")

project(muriscvnn LANGUAGES C CXX ASM DESCRIPTION "muRISCV-NN, a CMSIS-NN port for RISC-V.")

# This is the main library we are building, resolves to project name
set(MURISCVNN_LIB ${CMAKE_PROJECT_NAME})

# See whats going in CMake while getting the build process up and running
set(CMAKE_VERBOSE_MAKEFILE ON)

# Using C and C++ 11
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

if(USE_VEXT AND USE_PEXT)
  message(FATAL_ERROR "V/P-Extension can not be enabled simultaneously.")
elseif(USE_VEXT)
  add_definitions(-DUSE_VEXT)
elseif(USE_PEXT)
  add_definitions(-DUSE_PEXT)
endif()

if(SPIKE)
  add_definitions(-DSPIKE)
endif()

if (SIM_VICUNA)
  add_definitions(-DSIM_VICUNA)
endif()

# Set build mode
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Set some compiler options for easier debug or faster builds
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -O0 -g -ggdb")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0 -g -ggdb")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O3")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wshadow -Wno-format -std=c11")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11 -fno-use-cxa-atexit")

# Lets stick to standard .elf file ending for now
set(CMAKE_EXECUTABLE_SUFFIX_C .elf)
set(CMAKE_EXECUTABLE_SUFFIX_CXX .elf)

include(add_intg_test)

add_subdirectory(Source)

enable_testing()

add_subdirectory(Integration)
