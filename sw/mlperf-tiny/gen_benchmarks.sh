# Build the MLPerf-Tiny benchmark

# Prevent silent failures
set -euo pipefail

# Path to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

USE_PEXT=OFF
USE_VEXT=OFF
USE_RV32E=OFF

SPIKE=ON
LONG_BENCHMARK=OFF

TOOLCHAIN=GCC
if [ "{$USE_PEXT}" == "ON" ]; then
    GCC_PREFIX=${SCRIPT_DIR}../../../toolchain/riscv-gcc-pext
else
    GCC_PREFIX=${SCRIPT_DIR}../../../toolchain/riscv-gcc-main
fi

CLEAN=0

#Parse Input Args
while getopts ':pvech' flag; do
  case "${flag}" in
    p) USE_PEXT=ON ;;
    v) USE_VEXT=ON ;;
    e) USE_RV32E=ON ;;
    c) CLEAN=1 ;;
    * | h) echo "Add -p to use packed extension"
           echo "Add -v to use vector extension"
           echo "Add -e to use RV32E instead of RV32I"
           echo "Add -c to clean build directory"
           exit 1 ;;
  esac
done

if [ "${USE_PEXT}" == "ON" ]; then
    GCC_PREFIX=${SCRIPT_DIR}../../../toolchain/riscv-gcc-pext       # Need to use a special version of GCC for PEXT
fi

if [ "${USE_VEXT}" == "ON" ] && [ "${USE_PEXT}" == "ON" ]; then
    echo "ERROR: ONLY CHOOSE EITHER P- or V-extension"
    exit 1
fi

# TODO: Add checks for gcc install and TF install
echo "*** Checking if toolchain has been setup ***"
if [ ! -d ../../toolchain/riscv-gcc-main ]; then
    ./setup.sh --default --pext --vext
fi

echo "*** Checking if TFLITE has been setup ***"
if [ ! -d ./Integration/tflm/tflite-micro ]; then
    cd Integration/tflm
    ./download_tflm.sh
    cd $SCRIPT_DIR
fi

if [ ${CLEAN} -eq 1 ]; then
    echo "*** Deleting Current Build Directory ***"
    cd $SCRIPT_DIR
    if [  -d ./_build ]; then
        rm -rf _build
    fi
fi

echo "*** Building benchmarks ***"
if [ ! -d ./_build ]; then
    mkdir _build
fi
cd _build
cmake -DRISCV_GCC_PREFIX=${GCC_PREFIX} -DAUTO_VECTORIZE=OFF -DSIM_VICUNA=OFF -DUSE_RV32E=${USE_RV32E} -DUSE_VEXT=${USE_VEXT} -DUSE_PEXT=${USE_PEXT} -DSPIKE=${SPIKE} -DLONG_BENCHMARK=${LONG_BENCHMARK} ..
make aww_tflm -j8 > aww.log
make ic_tflm  -j8 > ic.log
make toy_tflm -j8 > toy.log
make vww_tflm -j8 > vww.log

if [ ! -d ../bin ]; then
    mkdir ../bin
    mkdir ../bin/aww
    mkdir ../bin/vww
    mkdir ../bin/ic
    mkdir ../bin/toy
fi

echo "*** Moving banaries to common directory ***"
mv Integration/tflm/aww/aww_tflm.elf ../bin/aww/aww_tflm.elf
mv Integration/tflm/vww/vww_tflm.elf ../bin/vww/vww_tflm.elf
mv Integration/tflm/ic/ic_tflm.elf ../bin/ic/ic_tflm.elf
mv Integration/tflm/toy/toy_tflm.elf ../bin/toy/toy_tflm.elf

if [ "${SPIKE}" == "OFF" ]; then
    mv Integration/tflm/aww/aww_tflm.elf.vmem ../bin/aww/aww_tflm.vmem
    mv Integration/tflm/aww/aww_tflm.elf.lst ../bin/aww/aww_tflm.lst

    mv Integration/tflm/vww/vww_tflm.elf.vmem ../bin/vww/vww_tflm.vmem
    mv Integration/tflm/vww/vww_tflm.elf.lst ../bin/vww/vww_tflm.lst

    mv Integration/tflm/ic/ic_tflm.elf.vmem ../bin/ic/ic_tflm.vmem
    mv Integration/tflm/ic/ic_tflm.elf.lst ../bin/ic/ic_tflm.lst

    mv Integration/tflm/toy/toy_tflm.elf.vmem ../bin/toy/toy_tflm.vmem
    mv Integration/tflm/toy/toy_tflm.elf.lst ../bin/toy/toy_tflm.lst
fi

echo "*** DONE! ***"