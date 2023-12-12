#!/bin/bash
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

# Will clone and build Spike and pk for both rv32i and rv32e

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check that toolchain is up and running
if [[ -d $SCRIPT_DIR/../../../toolchain/riscv-gcc-main ]]; then

    if [[ ! -d riscv-isa-sim ]]; then
        git clone https://github.com/riscv-software-src/riscv-isa-sim
    fi

    if [[ ! -d riscv-pk ]]; then
        git clone https://github.com/riscv-software-src/riscv-pk
    fi

    sudo apt-get install device-tree-compiler
        # Enter password

    # Build Spike
    if [[ ! -f spike ]]; then
        cd $SCRIPT_DIR/riscv-isa-sim
        mkdir build
        cd build
        ../configure --prefix=$RISCV
        make
        sudo make install
            # Enter password
        mv spike $SCRIPT_DIR/spike
        cd ..
        rm -rf build
    fi

    export RISCV=$SCRIPT_DIR/../../../toolchain/riscv-gcc-main/
    export PATH=$RISCV/bin:$PATH    

    # Build pk with ilp32
    if [[ ! -f pk_ilp32 ]]; then
        cd $SCRIPT_DIR
        mkdir build
        cd build
        ../riscv-pk/configure --prefix=$RISCV --host=riscv32-unknown-elf --with-arch=rv32imc_zicsr_zifencei --with-abi=ilp32
        make 
        make install
        mv pk $SCRIPT_DIR/pk_ilp32
        make clean
        cd $SCRIPT_DIR
        rm -rf build
    fi

    # Build pk with ilp32e   # Does not work for now, maybe not needed?

    if [[ ! -f pk_ilp32e && 1 -eq 0 ]]; then
        cd $SCRIPT_DIR
        mkdir build
        cd build
        ../riscv-pk/configure --prefix=$RISCV --host=riscv32-unknown-elf --with-arch=rv32emc_zicsr_zifencei --with-abi=ilp32e
        make 
        make install
        mv pk $SCRIPT_DIR/pk_ilp32e
        make clean
        cd $SCRIPT_DIR
        rm -rf build
    fi

else

    echo "Install toolchain first!"
    
fi