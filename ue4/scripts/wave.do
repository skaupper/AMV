onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/clk
add wave -noupdate /top/rst
add wave -noupdate /top/duv_if/clk
add wave -noupdate /top/duv_if/mem_addr_o
add wave -noupdate /top/duv_if/mem_data_i
add wave -noupdate /top/duv_if/mem_data_o
add wave -noupdate /top/duv_if/mem_ce_no
add wave -noupdate /top/duv_if/mem_oe_no
add wave -noupdate /top/duv_if/mem_we_no
add wave -noupdate /top/duv_if/illegal_inst_o
add wave -noupdate /top/duv_if/cpu_halt_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {388 ns} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ns} {5775 ns}
