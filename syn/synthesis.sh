#Plug into ibex and vicuna scripts...

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IBEX_DIR=$SCRIPT_DIR/../hw/ibex

# Expand with Vicuna and ibex_pext as well

export sv2v=$SCRIPT_DIR/sv2v
export sta=$SCRIPT_DIR/OpenSTA
export PATH=$sv2v/bin:$PATH
export PATH=$sta/app:$PATH

# Remember to set up syn_setup.sh in ibex syn folder
$IBEX_DIR/syn/syn_yosys.sh

# Do something with results...