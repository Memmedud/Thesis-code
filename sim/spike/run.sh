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

# Positional arguments:
# $1 - path to binary file
# $2 - arch string, i.e. rv32imc, rv32emcp etc..
# $3 - VLEN, from 32 to 1024 (only applicable if vector extension is enabled)

# Example call to invoke Spike:
# ./run.sh my_binary.elf rv32gcv 64

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $3 -eq " " ]]; then
  VLEN="1024"
else
  VLEN=$3
fi

if [[ $2 == "rv32imc" || $2 == "rv32imcv" || $2 == "rv32imcp" ]]; then
  $SCRIPT_DIR/bin/spike --isa=$2_zicsr_zicntr_zihpm --varch=vlen:$VLEN,elen:32 $SCRIPT_DIR/$1
elif [[ $2 == "rv32emc" || $2 == "rv32emcv" || $2 == "rv32emcp" ]]; then
  $SCRIPT_DIR/bin/spike --isa=$2_zicsr_zicntr_zihpm --varch=vlen:$VLEN,elen:32 $SCRIPT_DIR/bin/pk_ilp32e $SCRIPT_DIR/$1
else
  echo "Unsupported arch string $2"
fi