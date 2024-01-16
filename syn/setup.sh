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
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# Remebmer to install Haskell Stack first: curl -sSL https://get.haskellstack.org/ | sh
cd $SCRIPT_DIR
if [ ! -d sv2v ]; then
    git clone https://github.com/zachjs/sv2v.git
    cd sv2v
    make
    # TODO: Figure out what to with the binary
    # Located sv2v/bin/sv2v.exe ...
fi

cd $SCRIPT_DIR
if [ ! -d yosys ]; then
    sudo apt-get install build-essential clang bison flex \
	libreadline-dev gawk tcl-dev libffi-dev git \
	graphviz xdot pkg-config python3 libboost-system-dev \
	libboost-python-dev libboost-filesystem-dev

    git clone https://github.com/YosysHQ/yosys -b yosys-0.9
    cd yosys
    #make config-clang
    #make 
    #sudo make install
    sudo apt-get install yosys=0.9-2  # We dont actually build from source, just install with apt...
fi

cd $SCRIPT_DIR
if [ ! -d OpenSTA ]; then
    sudo apt-get install tcl swig bison flex

    git clone https://github.com/The-OpenROAD-Project/OpenSTA.git -b v2.2.0
    cd OpenSTA
    mkdir build
    cd build
    # Comment out line 294 in CMakeLists.txt
    cmake ..
    make
    # TODO: Figure out what to do with binary in app/sta.exe ...
fi

cd $SCRIPT_DIR
if [ ! -d nangate45 ]; then
    git clone https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts
    mv OpenROAD-flow-scripts/flow/platforms/nangate45 nangate45
    rm -rf OpenROAD-flow-scripts
    # Lib is in /home/mats/prosjektoppgave/Thesis-code/syn/nangate45/lib/NangateOpenCellLibrary_typical.lib
fi