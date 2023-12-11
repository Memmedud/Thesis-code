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
#

set -e

###################
# Cmdline parsing #
###################

# Process all options supplied on the command line
while getopts ':h-:' 'OPTKEY'; do
    case ${OPTKEY} in
        -)
        case "${OPTARG}" in
            'test')
                test=1
                ;;
            'default')
                default=1
                ;;
            'vext')
                vext=1
                ;;
            'pext')
                pext=1
                ;;
            'clean')
                clean=1
                ;;
            *)
                    if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                        echo "Unknown option --${OPTARG}" >&2
                    fi
                    ;;
            esac;;
        'h')
            echo "HELP"
            exit 0
            ;;
        '?')
            echo "INVALID OPTION -- ${OPTARG}" >&2
            exit 1
            ;;
        ':')
            echo "MISSING ARGUMENT for option -- ${OPTARG}" >&2
            exit 1
            ;;
        *)
            echo "UNIMPLEMENTED OPTION -- ${OPTKEY}" >&2
            exit 1
            ;;
    esac
done

if [[ $clean -eq 1 ]]
then
    rm test*
    rm -rf riscv*
    exit 1
fi

if [[ $test -eq 1 ]]; then
    wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=17ooB9AYZVGlgpnfDUcGmjN_JPxG3sWer' -O test.tar
    tar -xvf test.tar 
    rm test.tar
    rm -rf riscv-gnu-toolchain      # Delete the test-folder
    exit 1
fi

if [[ $default -eq 1 || $vext -eq 1 ]]
then
    if [[ ! -d riscv-gcc-main ]]
    then
        wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=109FKFoL8HSL8fNhGGj9eudY5xg3kDkdE' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=109FKFoL8HSL8fNhGGj9eudY5xg3kDkdE" -O riscv-gcc-main.tar && rm -rf /tmp/cookies.txt
        tar -xvf riscv-gcc-main.tar 
        rm riscv-gcc-main.tar
        exit 1
    fi
fi

if [[ $pext -eq 1 ]]
then
    if [[ ! -d riscv-gcc-pext ]]
    then
        wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1zgaJ5QXKrJPZ9992uAf0GrPccdM2WjsC' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1zgaJ5QXKrJPZ9992uAf0GrPccdM2WjsC" -O riscv-gcc-pext.tar && rm -rf /tmp/cookies.txt
        tar -xvf riscv-gcc-pext.tar 
        rm riscv-gcc-pext.tar
        exit 1
    fi
fi
