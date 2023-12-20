# Start all the other scripts from this...

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

# TODO Make install configurable

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git submodule update --init --recursive  

cd $SCRIPT_DIR/hw/ibex
pip3 install -U -r python-requirements.txt
sudo apt-get install libelf-dev srecord
    # Password

cd $SCRIPT_DIR/toolchain
./setup.sh --default --vext --pext     # TODO: Any arguments?

cd $SCRIPT_DIR/sim/spike/bin
.setup.sh      # TODO: Any arguments?

cd $SCRIPT_DIR/sim/verilator
.setup.sh      # TODO: Any arguments?


