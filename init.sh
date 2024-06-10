# Installs dependencies needed for simulating Ibex, other dependencies 
# are installed through the install scripts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git submodule update --init --recursive  

cd $SCRIPT_DIR/hw/ibex
pip3 install -U -r python-requirements.txt
sudo apt-get install libelf-dev srecord
    # Password
