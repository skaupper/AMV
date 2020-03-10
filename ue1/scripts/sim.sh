#!/usr/bin/env bash

SCRIPT_PATH=$(realpath $(dirname $BASH_SOURCE))
SIM_PATH=$SCRIPT_PATH/../sim
SRC_PATH=$SCRIPT_PATH/../src


mkdir -p $SIM_PATH
cd $SIM_PATH

vsim -batch -do ../scripts/comp.do
