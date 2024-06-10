#Plugs into ibex scripts to run synthesis

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

IBEX_DIR=$SCRIPT_DIR/../hw/ibex
IBEX_PEXT_DIR=$SCRIPT_DIR/../hw/ibex_pext
#VICUNA_DIR=$SCRIPT_DIR/../hw/vicuna  #Vicuna is not supported with this flow

# Expand with Vicuna and ibex_pext as well
export sv2v=$SCRIPT_DIR/sv2v
export sta=$SCRIPT_DIR/OpenSTA
export PATH=$sv2v/bin:$PATH
export PATH=$sta/app:$PATH
# TODO: Export yosys binary as well if we ever build from source

# Remember to set up syn_setup.sh in ibex syn folder
cd $IBEX_DIR/syn
./syn_yosys.sh

# Results reported in the Ibex syn folder