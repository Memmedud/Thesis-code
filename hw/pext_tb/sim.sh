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

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IBEX_RTL_DIR=$SCRIPT_DIR/../ibex_pext/rtl
VERILATOR_OUT_DIR=$SCRIPT_DIR/verilated

ibex_pkg_pext=$IBEX_RTL_DIR/ibex_pkg_pext.sv
ibex_pkg=$IBEX_RTL_DIR/ibex_pkg.sv
ibex_alu_pext=$IBEX_RTL_DIR/ibex_alu_pext.sv
ibex_alu_pext_helper=$IBEX_RTL_DIR/ibex_alu_pext_helper.sv
ibex_mult_pext=$IBEX_RTL_DIR/ibex_mult_pext.sv
ibex_mult_pext_helper=$IBEX_RTL_DIR/ibex_mult_pext_helper.sv
ibex_decoder_pext=$IBEX_RTL_DIR/ibex_decoder_pext.sv

tb=$SCRIPT_DIR/tb/ibex_pext_tb.sv

mult_tb=$SCRIPT_DIR/tb/ibex_pext_mult_tb.sv
data_packet=$SCRIPT_DIR/tb/data_packet.sv

verilator --binary --top-module ibex_pext_tb -j 0 -Wall -Wno-UNUSEDPARAM -Wno-UNUSEDSIGNAL $ibex_pkg_pext $ibex_pkg $ibex_alu_pext $ibex_alu_pext_helper $ibex_mult_pext $ibex_mult_pext_helper $tb
#verilator --binary --top-module ibex_pext_mult_tb -j 0 -Wall $ibex_pkg_pext $ibex_alu_pext $ibex_decoder_pext $ibex_mult_pext $mult_tb
#verilator --binary --top-module ibex_pext_tb -j 0 -Wall $ibex_pkg_pext $ibex_alu_pext $ibex_decoder_pext $tb

if [ -d $VERILATOR_OUT_DIR/tb ]; then
    rm -rf $VERILATOR_OUT_DIR/tb
fi
mv obj_dir $VERILATOR_OUT_DIR/tb

$VERILATOR_OUT_DIR/tb/Vibex_pext_tb
#$VERILATOR_OUT_DIR/tb/Vibex_pext_mult_tb +verilator+seed+859473