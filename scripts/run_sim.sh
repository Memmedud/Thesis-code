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

if [ "${USE_VEXT}" == "ON" ] && [ "${USE_PEXT}" == "ON" ]; then
    echo "ERROR: ONLY CHOOSE EITHER P- or V-extension"
    exit 1
fi

if [ ${CLEAN} -eq 1 ]; then
    echo "*** Building CPU ***"
    if [ "${USE_RV32E}" == "ON" ]; then
        if [ "${USE_PEXT}" == "ON" ]; then

            cd $SCRIPT_DIR/../hw/ibex_pext
            fusesoc --cores-root=. run --target=sim --setup --build lowrisc:ibex:ibex_simple_system $(util/ibex_config.py experimental-pext-small-rv32e fusesoc_opts)
            mv build $SCRIPT_DIR/../sim/verilated/ibex_rv32emcp

        elif [ "${USE_VEXT}" == "ON" ]; then

            #cd $SCRIPT_DIR/../hw/vicuna
            echo "We dont support vicuna yet!"

        else

            cd $SCRIPT_DIR/../hw/ibex
            fusesoc --cores-root=. run --target=sim --setup --build lowrisc:ibex:ibex_simple_system $(util/ibex_config.py small-rv32e fusesoc_opts)
            mv build $SCRIPT_DIR/../sim/verilated/ibex_rv32emc

        fi
    else
        if [ "${USE_PEXT}" == "ON" ]; then

            cd $SCRIPT_DIR/../hw/ibex_pext
            fusesoc --cores-root=. run --target=sim --setup --build lowrisc:ibex:ibex_simple_system $(util/ibex_config.py experimental-pext-small fusesoc_opts)
            mv build $SCRIPT_DIR/../sim/verilated/ibex_rv32imcp

        elif [ "${USE_VEXT}" == "ON" ]; then

            #cd $SCRIPT_DIR/../hw/vicuna
            echo "We dont support vicuna yet!"

        else

            cd $SCRIPT_DIR/../hw/ibex_pext
            fusesoc --cores-root=. run --target=sim --setup --build lowrisc:ibex:ibex_simple_system $(util/ibex_config.py small fusesoc_opts)
            if [ -d $SCRIPT_DIR/../sim/verilated/ibex_rv32imc ]; then
                rm -rf $SCRIPT_DIR/../sim/verilated/ibex_rv32imc
            fi
            mv build $SCRIPT_DIR/../sim/verilated/ibex_rv32imc

        fi
    fi
fi

echo "*** Running SW ***"
cd $SCRIPT_DIR
if [ "${USE_RV32E}" == "ON" ]; then
    if [ "${USE_PEXT}" == "ON" ]; then

        ./../sim/verilated/ibex_rv32emcp/lowrisc_ibex_ibex_simple_system_0/sim-verilator/Vibex_simple_system [-t] --meminit=ram,../../sw/$2

    elif [ "${USE_VEXT}" == "ON" ]; then

        #cd $SCRIPT_DIR/../hw/vicuna
        echo "We dont support vicuna yet!"

    else

        ./../sim/verilated/ibex_rv32emc/lowrisc_ibex_ibex_simple_system_0/sim-verilator/Vibex_simple_system [-t] --meminit=ram,../../sw/$2

    fi
else
    if [ "${USE_PEXT}" == "ON" ]; then

        ./../sim/verilated/ibex_rv32imcp/lowrisc_ibex_ibex_simple_system_0/sim-verilator/Vibex_simple_system [-t] --meminit=ram,../../sw/$2

    elif [ "${USE_VEXT}" == "ON" ]; then

        #cd $SCRIPT_DIR/../hw/vicuna
        echo "We dont support vicuna yet!"

    else

        ./../sim/verilated/ibex_rv32imc/lowrisc_ibex_ibex_simple_system_0/sim-verilator/Vibex_simple_system [-t] --meminit=ram,../../sw/$2

    fi
fi


