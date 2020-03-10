#
# This script is intended to run from the sim/ directory!
#



#
# Define constants
#


# the library name which all sources get compiled into
set LIB_NAME work

# source path and filenames to compile (relative to the sim/ directory!)
set SOURCE_PATH ../src
set SOURCES [list           \
    ram.sv                  \
    WishboneBFM_pack.vhd    \
    WishboneBFM_tb.vhd
]

# the patterns to identify VHDL and Verilog files
set VHDL_REGEX {\.vhd$}
set VERILOG_REGEX {\.s?v$}

# set the compilers used to compile different languages
set VHDL_COMPILER vcom
set VERILOG_COMPILER vlog

# compile flags to used split into general and language specific flags
set GENERAL_COMPILE_FLAGS [list \
    -work $LIB_NAME             \
    -quiet
]
set VHDL_COMPILE_FLAGS      [list {*}$GENERAL_COMPILE_FLAGS]
set VERILOG_COMPILE_FLAGS   [list {*}$GENERAL_COMPILE_FLAGS]



#
# Create library (work)
#

catch {vdel -all -lib $LIB_NAME}
vlib $LIB_NAME
vmap $LIB_NAME $LIB_NAME



#
# Compile sources
#

foreach f $SOURCES {
    if {[regexp $VHDL_REGEX $f]} {
        set compiler $VHDL_COMPILER
        set compile_flags $VHDL_COMPILE_FLAGS
    } elseif {[regexp $VERILOG_REGEX $f]} {
        set compiler $VERILOG_COMPILER
        set compile_flags $VERILOG_COMPILE_FLAGS
    } else {
        return -code error "Unknown file format: $f"
    }

    set command [list $compiler {*}$compile_flags $SOURCE_PATH/$f]
    puts $command
    eval $command
}


exit 0
