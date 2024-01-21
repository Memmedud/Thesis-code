#!/bin/bash
#
# Copyright (C) 2023 Chair of Electronic Design Automation, TUM.
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

# Prevent silent failures
set -euo pipefail

# Path to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

USE_PEXT=OFF
USE_VEXT=OFF
USE_RV32E=OFF

SPIKE=ON
LONG_BENCHMARK=OFF

TOOLCHAIN=GCC
GCC_PREFIX=${SCRIPT_DIR}../../../toolchain/riscv-gcc-main

CLEAN=0

#Parse Input Args
while getopts ':pvech' flag; do
  case "${flag}" in
    p) USE_PEXT=ON ;;
    v) USE_VEXT=ON ;;
    e) USE_RV32E=ON ;;
    c) CLEAN=1 ;;
    * | h) echo "Add -p to use packed extension"
           echo "Add -v to use vector extension"
           echo "Add -e to use RV32E instead of RV32I"
           echo "Add -c to clean build directory"
           exit 1 ;;
  esac
done

if [ "${USE_PEXT}" == "ON" ]; then
    GCC_PREFIX=${SCRIPT_DIR}../../../toolchain/riscv-gcc-pext       # Need to use a special version of GCC for PEXT
fi

if [ "${USE_VEXT}" == "ON" ] && [ "${USE_PEXT}" == "ON" ]; then
    echo "ERROR: ONLY CHOOSE EITHER P- or V-extension"
    exit 1
fi

# TODO: Add checks for gcc install and TF install
echo "*** Checking if toolchain has been setup ***"
if [ ! -d ../../toolchain/riscv-gcc-main ]; then
    ./setup.sh --default --pext --vext
fi

echo "*** Checking if TFLITE has been setup ***"
if [ ! -d ./Integration/tflm/tflite-micro ]; then
    cd Integration/tflm
    ./download_tflm.sh
    cd $SCRIPT_DIR
fi

if [ ${CLEAN} -eq 1 ]; then
    echo "*** Deleting Current Build Directory ***"
    cd $SCRIPT_DIR
    if [  -d ./_build ]; then
        rm -rf _build
    fi
fi

echo "*** Building benchmarks ***"
if [ ! -d ./_build ]; then
    mkdir _build
fi
cd _build
cmake -DRISCV_GCC_PREFIX=${GCC_PREFIX} -DUSE_RV32E=${USE_RV32E} -DUSE_VEXT=${USE_VEXT} -DUSE_PEXT=${USE_PEXT} -DSPIKE=${SPIKE} -DLONG_BENCHMARK=${LONG_BENCHMARK} ..
make all -j8

if [ ! -d ../bin ]; then
    mkdir ../bin
fi

echo "*** Moving banaries to common directory ***"
mv Integration/tflm/aww/aww_tflm.elf ../bin/aww_tflm.elf
mv Integration/tflm/vww/vww_tflm.elf ../bin/vww_tflm.elf
mv Integration/tflm/ic/ic_tflm.elf ../bin/ic_tflm.elf
mv Integration/tflm/toy/toy_tflm.elf ../bin/toy_tflm.elf

echo "*** DONE! ***"