
add wave -noupdate /wishbonebfm_tb/clk
add wave -noupdate /wishbonebfm_tb/rst
add wave -noupdate -radix hexadecimal -childformat {{/wishbonebfm_tb/bfmIn.dat -radix hexadecimal}} -expand -subitemconfig {/wishbonebfm_tb/bfmIn.dat {-radix hexadecimal}} /wishbonebfm_tb/bfmIn
add wave -noupdate -radix hexadecimal -childformat {{/wishbonebfm_tb/bfmOut.dat -radix hexadecimal} {/wishbonebfm_tb/bfmOut.adr -radix hexadecimal} {/wishbonebfm_tb/bfmOut.sel -radix hexadecimal}} -expand -subitemconfig {/wishbonebfm_tb/bfmOut.dat {-radix hexadecimal} /wishbonebfm_tb/bfmOut.adr {-radix hexadecimal} /wishbonebfm_tb/bfmOut.sel {-radix hexadecimal}} /wishbonebfm_tb/bfmOut
