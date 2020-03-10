#
# This script is intended to run from the sim/ directory!
#



#
# Define constants
#

set TB_NAME         WishboneBFM_tb

set SCRIPTS_PATH    ../scripts
set WAVE_FILE       $SCRIPTS_PATH/wave.do

set STOP_SIGNAL     WishboneBFM_tb.finished



#
# Start simulation
#

vsim $TB_NAME
if {![batch_mode]} {
    source $WAVE_FILE
}

quietly when -fast "$STOP_SIGNAL == '1'" stop
run -all


# only exit in batch mode
if {[batch_mode]} {
    exit
}
