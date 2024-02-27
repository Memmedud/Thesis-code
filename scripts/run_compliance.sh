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
#set -euo pipefail

# Path to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

USE_PEXT=ibex_pkg::RV32PNone
USE_RV32E=0

#Parse Input Args
while getopts ':pvechtw' flag; do
  case "${flag}" in
    p) USE_PEXT=ibex_pkg::RV32PZpn ;;
    e) USE_RV32E=1 ;;
    * | h) echo "Add -p to use packed extension"
           echo "Add -e to use RV32E instead of RV32I"
           exit 1 ;;
  esac
done

echo "*** Building CPU ***"
if [ "${USE_PEXT}" == "ibex_pkg::RV32PNone" ]; then

    export RISCV_PREFIX=$SCRIPT_DIR/../toolchain/riscv-gcc-main/bin/riscv32-unknown-elf-
    cd $SCRIPT_DIR/../hw/ibex
    export TARGET_SIM=$SCRIPT_DIR/../hw/ibex/build/lowrisc_ibex_ibex_riscv_compliance_0.1/sim-verilator/Vibex_riscv_compliance
    #Build ibex
    fusesoc --cores-root=. run --target=sim --setup --build lowrisc:ibex:ibex_riscv_compliance --RV32E=$USE_RV32E --RV32M=ibex_pkg::RV32MFast

else

    export RISCV_PREFIX=$SCRIPT_DIR/../toolchain/riscv-gcc-pext/bin/riscv32-unknown-elf-
    cd $SCRIPT_DIR/../hw/ibex_pext
    export TARGET_SIM=$SCRIPT_DIR/../hw/ibex_pext/build/lowrisc_ibex_ibex_riscv_compliance_0.1/sim-verilator/Vibex_riscv_compliance
    #Build ibex
    fusesoc --cores-root=. run --target=sim --setup --build lowrisc:ibex:ibex_riscv_compliance --RV32E=$USE_RV32E --RV32M=ibex_pkg::RV32MFast --RV32P=ibex_pkg::$USE_PEXT

fi

cd $SCRIPT_DIR/../sw/riscv-arch-test

if [ -d work ]; then
    rm -rf work
fi

#export RISCV_DEVICE=rv32imc
export RISCV_TARGET=ibex

if [ "${USE_RV32E}" == "1" ]; then
    if [ "${USE_PEXT}" == "ibex_pkg::RV32PZpn" ]; then

        echo "*** Running compliance tests ***"
        make RISCV_DEVICE=I
        make RISCV_DEVICE=C
        make RISCV_DEVICE=M
        make RISCV_DEVICE=P

    else

        echo "*** Running compliance tests ***"
        make RISCV_DEVICE=I
        make RISCV_DEVICE=C
        make RISCV_DEVICE=M

    fi
else
    if [ "${USE_PEXT}" == "ibex_pkg::RV32PZpn" ]; then

        echo "*** Running compliance tests ***"
        make RISCV_DEVICE=I
        make RISCV_DEVICE=C
        make RISCV_DEVICE=M
        #make RISCV_DEVICE=P

    else

        echo "*** Running compliance tests ***"
        make RISCV_DEVICE=I
        make RISCV_DEVICE=C
        make RISCV_DEVICE=M
    fi
fi

echo "*** Finished ***"