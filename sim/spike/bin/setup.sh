# Will clone and build Spike and pk for both rv32i /// and rv32e ///

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check that toolchain is up and running
if [[ -d $SCRIPT_DIR/../../../toolchain/riscv-gcc-main ]]; then

    if [[ ! -d $SCRIPT_DIR/riscv-isa-sim ]]; then
        git clone https://github.com/riscv-software-src/riscv-isa-sim
    fi

    if [[ ! -d $SCRIPT_DIR/riscv-pk ]]; then
        # Set up correct repo with rve patch
        git clone https://github.com/liweiwei90/riscv-pk
        cd $SCRIPT_DIR/riscv-pk
        git remote add upstream https://github.com/riscv-software-src/riscv-pk
        git fetch upstream
        git merge upstream/master
        git checkout plct-rve-dev
        git rebase master
    fi

    sudo apt-get install device-tree-compiler
        # Enter password

    # Build Spike
    if [[ ! -f $SCRIPT_DIR/spike ]]; then
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
    if [[ ! -f $SCRIPT_DIR/pk_ilp32 ]]; then
        cd $SCRIPT_DIR
        mkdir build
        cd build
        ../riscv-pk/configure --prefix=$RISCV --host=riscv32-unknown-elf --with-arch=rv32imcv_zicsr_zifencei --with-abi=ilp32
        make 
        make install
        mv pk $SCRIPT_DIR/pk_ilp32
        make clean
        cd $SCRIPT_DIR
        rm -rf build
    fi

    # Build pk with ilp32e   # Does not work for now, maybe not needed?
    # Can be fixed with https://github.com/riscv-software-src/riscv-pk/pull/280...
    if [[ ! -f $SCRIPT_DIR/pk_ilp32e ]]; then
        cd $SCRIPT_DIR
        mkdir build
        cd build
        ../riscv-pk/configure --prefix=$RISCV --host=riscv32-unknown-elf --with-arch=rv32emcv_zicsr_zifencei --with-abi=ilp32e
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