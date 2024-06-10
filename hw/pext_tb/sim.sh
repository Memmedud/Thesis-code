# Run ALU testbench

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

verilator --binary --top-module ibex_pext_tb -j 0 -Wall -Wno-UNUSEDPARAM  -Wno-UNUSEDSIGNAL $ibex_pkg_pext $ibex_pkg $ibex_alu_pext $ibex_alu_pext_helper $ibex_mult_pext $ibex_mult_pext_helper $tb

if [ -d $VERILATOR_OUT_DIR/tb ]; then
    rm -rf $VERILATOR_OUT_DIR/tb
fi
mv obj_dir $VERILATOR_OUT_DIR/tb

$VERILATOR_OUT_DIR/tb/Vibex_pext_tb 
