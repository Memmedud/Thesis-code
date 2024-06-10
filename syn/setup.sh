# Installs dependencies for synthesis

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# Remebmer to install Haskell Stack first: curl -sSL https://get.haskellstack.org/ | sh
cd $SCRIPT_DIR
if [ ! -d sv2v ]; then
    git clone https://github.com/zachjs/sv2v.git
    cd sv2v
    make
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
fi

cd $SCRIPT_DIR
if [ ! -d nangate45 ]; then
    git clone https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts
    mv OpenROAD-flow-scripts/flow/platforms/nangate45 nangate45
    rm -rf OpenROAD-flow-scripts
    # Lib is in /home/mats/prosjektoppgave/Thesis-code/syn/nangate45/lib/NangateOpenCellLibrary_typical.lib
fi