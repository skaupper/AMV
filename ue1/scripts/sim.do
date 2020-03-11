#
# This script is intended to run from the sim/ directory!
#

if [batch_mode] {
  eval echo "Detected batch mode"
  eval onerror {quit -f}
  eval onbreak {quit -f}
}

transcript quietly

#
# Define constants
#

set TB_NAME         WishboneBFM_tb

set SCRIPTS_PATH    ../scripts
set WAVE_FILE       $SCRIPTS_PATH/wave.do
set WLF_FILE        wave.wlf

set STOP_SIGNAL     /$TB_NAME/finished



#
# Start simulation
#

vsim $TB_NAME -novopt -wlf $WLF_FILE
source $WAVE_FILE

quietly when -fast "$STOP_SIGNAL == '1'" stop
run -all


# only exit in batch mode
if {[batch_mode]} {
    quit -f
}
