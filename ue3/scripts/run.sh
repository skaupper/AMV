#!/usr/bin/env bash
set -euo pipefail
ARG=${1:-"all"}

SCRIPT_PATH=$(readlink -f $(dirname $BASH_SOURCE))
SIM_PATH=$SCRIPT_PATH/../sim
SRC_PATH=$SCRIPT_PATH/../src

mkdir -p $SIM_PATH
cd $SIM_PATH



echo "Run comp.do ..."
vsim -c -do ../scripts/comp.do

if [ "$ARG" == "sim" ]; then
    echo "Run sim.do without GUI ..."
    vsim -c -do ../scripts/sim.do
elif [ "$ARG" == "gui" ]; then
    echo "Run sim.do with GUI ..."
    vsim -do ../scripts/sim.do
fi
