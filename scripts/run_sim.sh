# Starts simulations of selected design with a selected executable

# Prevent silent failures
set -euo pipefail

# Path to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

EXE_DIR="/home/mats/masteroppgave/Thesis-code/sw/hello-world/hello_test/hello_test.vmem"
#EXE_DIR=$SCRIPT_DIR/../sw/hello-world/hello_test/hello_test.vmem
#EXE_DIR=$SCRIPT_DIR/../sw/pext-test/pext_test/pext_test.vmem
#EXE_DIR=$SCRIPT_DIR/../hw/ibex_pext/examples/sw/benchmarks/coremark/coremark.elf
#EXE_DIR=$SCRIPT_DIR/../sw/mlperf-tiny/bin/aww_tflm.elf

USE_PEXT=OFF
USE_VEXT=OFF
USE_RV32E=OFF

VIEW=OFF

CLEAN=0

#Parse Input Args
while getopts ':pvechtw' flag; do
  case "${flag}" in
    p) USE_PEXT=ON ;;
    v) USE_VEXT=ON ;;
    e) USE_RV32E=ON ;;
    w) VIEW=ON ;;
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
            if [ -d build/ibex_rv32emcp ]; then
                rm -rf build/ibex_rv32emcp
            fi
            mv build/lowrisc_ibex_ibex_simple_system_0 build/ibex_rv32emcp

        elif [ "${USE_VEXT}" == "ON" ]; then

            echo "Vicuna is automatically build when running sims on it"


        else

            cd $SCRIPT_DIR/../hw/ibex_pext
            fusesoc --cores-root=. run --target=sim --setup --build lowrisc:ibex:ibex_simple_system $(util/ibex_config.py small-rv32e fusesoc_opts)
            if [ -d build/ibex_rv32emc ]; then
                rm -rf build/ibex_rv32emc
            fi
            mv build/lowrisc_ibex_ibex_simple_system_0 build/ibex_rv32emc

        fi
    else
        if [ "${USE_PEXT}" == "ON" ]; then

            cd $SCRIPT_DIR/../hw/ibex_pext
            fusesoc --cores-root=. run --target=sim --setup --build lowrisc:ibex:ibex_simple_system $(util/ibex_config.py experimental-pext-small fusesoc_opts)
            if [ -d build/ibex_rv32imcp ]; then
                rm -rf build/ibex_rv32imcp
            fi
            mv build/lowrisc_ibex_ibex_simple_system_0 build/ibex_rv32imcp

        elif [ "${USE_VEXT}" == "ON" ]; then

            #cd $SCRIPT_DIR/../hw/vicuna
            echo "We dont support vicuna yet!"

        else

            cd $SCRIPT_DIR/../hw/ibex_pext
            fusesoc --cores-root=. run --target=sim --setup --build lowrisc:ibex:ibex_simple_system $(util/ibex_config.py small fusesoc_opts)
            if [ -d build/ibex_rv32imc ]; then
                rm -rf build/ibex_rv32imc
            fi
            mv build/lowrisc_ibex_ibex_simple_system_0 build/ibex_rv32imc

        fi
    fi
fi

if [ "$EXE_DIR" != "" ]; then
    echo "*** Running SW ***"
    cd $SCRIPT_DIR/../hw/ibex_pext
    if [ "${USE_RV32E}" == "ON" ]; then
        if [ "${USE_PEXT}" == "ON" ]; then

            cd build/ibex_rv32emcp
            ./sim-verilator/Vibex_simple_system [-t] --meminit=ram,$EXE_DIR

        elif [ "${USE_VEXT}" == "ON" ]; then

            #cd $SCRIPT_DIR/../hw/vicuna
            echo "We dont support RV32E on vicuna yet!"

        else

            cd build/ibex_rv32emc
            ./sim-verilator/Vibex_simple_system [-t] --meminit=ram,$EXE_DIR

        fi
    else
        if [ "${USE_PEXT}" == "ON" ]; then

            cd build/ibex_rv32imcp
            ./sim-verilator/Vibex_simple_system [-t] --meminit=ram,$EXE_DIR

        elif [ "${USE_VEXT}" == "ON" ]; then

            cd $SCRIPT_DIR/../hw/vicuna/sim
            echo $EXE_DIR > /home/mats/masteroppgave/Thesis-code/hw/vicuna/sim/progs.txt
            make

        else

            cd build/ibex_rv32imc
            ./sim-verilator/Vibex_simple_system [-t] --meminit=ram,$EXE_DIR

        fi
    fi

    if [ "${VIEW}" == "ON" ]; then
        gtkwave sim.vcd
    fi
fi


