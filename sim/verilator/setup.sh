# Installs verilator from source, can also be installed via apt

# Prevent silent failures
set -euo pipefail

# Path to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Prerequisites:
sudo apt-get install git help2man perl python3 make autoconf g++ flex bison ccache
sudo apt-get install libgoogle-perftools-dev numactl perl-doc
sudo apt-get install libfl2  # Ubuntu only (ignore if gives error)
sudo apt-get install libfl-dev  # Ubuntu only (ignore if gives error)
#sudo apt-get install zlibc zlib1g zlib1g-dev  # Ubuntu only (ignore if gives error)

if [ ! -d "verilator" ]; then
  git clone https://github.com/verilator/verilator
  unset VERILATOR_ROOT
  cd verilator
  git checkout v5.006
  autoconf
  ./configure --prefix ${SCRIPT_DIR}/verilator/install    # Final install directory is "sim/verilator/verilator/install/bin/verilator"
  make -j 4
  make install
  # TODO: Find an elegant way to add to path...
fi
