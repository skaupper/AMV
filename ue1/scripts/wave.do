onerror {resume}
add wave -noupdate /wishbonebfm_tb/clk
add wave -noupdate /wishbonebfm_tb/rst
add wave -noupdate /wishbonebfm_tb/toBus
add wave -noupdate /wishbonebfm_tb/fromBus
TreeUpdate [SetDefaultTree]
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
