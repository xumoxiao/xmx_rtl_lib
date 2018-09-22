onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /asyn_fifo_tb/u_asyn_fifo/gray_rd_addr
add wave -noupdate /asyn_fifo_tb/u_asyn_fifo/gray_wr_addr
add wave -noupdate -expand -group wr -color Yellow /asyn_fifo_tb/u_asyn_fifo/i_wr_clk
add wave -noupdate -expand -group wr -color Yellow /asyn_fifo_tb/u_asyn_fifo/i_wr_rst
add wave -noupdate -expand -group wr -color Yellow /asyn_fifo_tb/u_asyn_fifo/i_wr_en
add wave -noupdate -expand -group wr -color Yellow -radix unsigned /asyn_fifo_tb/u_asyn_fifo/i_wr_data
add wave -noupdate -expand -group wr -color Yellow /asyn_fifo_tb/u_asyn_fifo/o_wr_full
add wave -noupdate -expand -group wr -color Yellow /asyn_fifo_tb/u_asyn_fifo/o_wr_almost_full
add wave -noupdate -expand -group wr -color Yellow -radix unsigned /asyn_fifo_tb/u_asyn_fifo/o_wr_data_cnt
add wave -noupdate -expand -group rd -color Orange /asyn_fifo_tb/u_asyn_fifo/i_rd_clk
add wave -noupdate -expand -group rd -color Orange /asyn_fifo_tb/u_asyn_fifo/i_rd_rst
add wave -noupdate -expand -group rd -color Orange /asyn_fifo_tb/u_asyn_fifo/i_rd_en
add wave -noupdate -expand -group rd -color Orange -radix unsigned /asyn_fifo_tb/u_asyn_fifo/o_rd_data
add wave -noupdate -expand -group rd -color Orange /asyn_fifo_tb/u_asyn_fifo/o_rd_empty
add wave -noupdate -expand -group rd -color Orange /asyn_fifo_tb/u_asyn_fifo/o_rd_almost_empty
add wave -noupdate -expand -group rd -color Orange -radix unsigned /asyn_fifo_tb/u_asyn_fifo/o_rd_data_cnt
add wave -noupdate /asyn_fifo_tb/u_asyn_fifo/rd_empty_ft
add wave -noupdate /asyn_fifo_tb/u_asyn_fifo/rd_en_i
add wave -noupdate /asyn_fifo_tb/u_asyn_fifo/rr
add wave -noupdate /asyn_fifo_tb/u_asyn_fifo/rrn
add wave -noupdate /asyn_fifo_tb/u_asyn_fifo/rw
add wave -noupdate /asyn_fifo_tb/u_asyn_fifo/rwn
add wave -noupdate /asyn_fifo_tb/u_asyn_fifo/wr_en_i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12358399 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 193
configure wave -valuecolwidth 177
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
WaveRestoreZoom {4086487 ps} {24158234 ps}
