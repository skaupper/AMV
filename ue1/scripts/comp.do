#
# This script is intended to run from the sim/ directory!
#


#
# Define constants
#


# the library name which all sources get compiled into
set LIB_NAME                work

# source path and filenames to compile (relative to the sim/ directory!)
set SOURCE_PATH             ../src
set SOURCES                 [list   ram.sv                  \
                                    WishboneBFM_pack.vhd    \
                                    WishboneBFM_tb.vhd]

set STOP_SIGNAL             /WishboneBFM_tb/finished

# the patterns to identify VHDL and Verilog files
set VHDL_REGEX              {\.vhd$}
set VERILOG_REGEX           {\.s?v$}

# set the compilers used to compile different languages
set VHDL_COMPILER           vcom
set VERILOG_COMPILER        vlog

# compile flags to used split into general and language specific flags
set GENERAL_COMPILE_FLAGS   [list -work $LIB_NAME             \
                                  -quiet]
set VHDL_COMPILE_FLAGS      [list {*}$GENERAL_COMPILE_FLAGS     \
                                  +acc=$STOP_SIGNAL]
set VERILOG_COMPILE_FLAGS   [list {*}$GENERAL_COMPILE_FLAGS]



#
# Create library (work)
#

vlib $LIB_NAME
vmap $LIB_NAME $LIB_NAME



#
# Compile sources
#

foreach f $SOURCES {
    # check if `f` contains a VHDL or Verilog source file
    # and set compiler and compile flags accordingly
    if {[regexp $VHDL_REGEX $f]} {
        set compiler $VHDL_COMPILER
        set compile_flags $VHDL_COMPILE_FLAGS
    } elseif {[regexp $VERILOG_REGEX $f]} {
        set compiler $VERILOG_COMPILER
        set compile_flags $VERILOG_COMPILE_FLAGS
    } else {
        return -code error "Unknown file format: $f"
    }

    # build compile command and execute it
    set command [list $compiler {*}$compile_flags $SOURCE_PATH/$f]
    # puts $command
    eval $command
}


exit
