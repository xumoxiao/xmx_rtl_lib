onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /str_width_conv_tb/u_str_width_conv/I_UINT
add wave -noupdate /str_width_conv_tb/u_str_width_conv/I_WIDTH
add wave -noupdate /str_width_conv_tb/u_str_width_conv/I_CNT_WIDTH
add wave -noupdate /str_width_conv_tb/u_str_width_conv/I_DEPTH
add wave -noupdate /str_width_conv_tb/u_str_width_conv/I_UINT
add wave -noupdate /str_width_conv_tb/u_str_width_conv/I_WIDTH
add wave -noupdate -radix unsigned /str_width_conv_tb/u_str_width_conv/LCM
add wave -noupdate /str_width_conv_tb/u_str_width_conv/O_CNT_WIDTH
add wave -noupdate /str_width_conv_tb/u_str_width_conv/O_DEPTH
add wave -noupdate /str_width_conv_tb/u_str_width_conv/O_UINT
add wave -noupdate /str_width_conv_tb/u_str_width_conv/O_WIDTH
add wave -noupdate /str_width_conv_tb/u_str_width_conv/RAM_DEPTH
add wave -noupdate /str_width_conv_tb/u_str_width_conv/RD_WIDTH
add wave -noupdate /str_width_conv_tb/u_str_width_conv/WORD_WIDTH
add wave -noupdate /str_width_conv_tb/u_str_width_conv/i
add wave -noupdate /str_width_conv_tb/u_str_width_conv/i_clk
add wave -noupdate /str_width_conv_tb/u_str_width_conv/i_rst
add wave -noupdate /str_width_conv_tb/u_str_width_conv/k
add wave -noupdate /str_width_conv_tb/u_str_width_conv/oup_buff
add wave -noupdate -expand /str_width_conv_tb/u_str_width_conv/r
add wave -noupdate /str_width_conv_tb/u_str_width_conv/rn
add wave -noupdate /str_width_conv_tb/u_str_width_conv/tt_reg
add wave -noupdate /str_width_conv_tb/u_str_width_conv/r.oup_pre_cnt
add wave -noupdate /str_width_conv_tb/u_str_width_conv/r.inp_cnt
add wave -noupdate /str_width_conv_tb/u_str_width_conv/r.oup_cnt
add wave -noupdate -color Yellow /str_width_conv_tb/u_str_width_conv/r.inp_flag
add wave -noupdate -color Yellow -radix unsigned /str_width_conv_tb/u_str_width_conv/r.inp_ofs
add wave -noupdate -color Orange /str_width_conv_tb/u_str_width_conv/r.oup_flag
add wave -noupdate -color Orange -radix unsigned /str_width_conv_tb/u_str_width_conv/r.oup_ofs
add wave -noupdate -color {Orange Red} -radix unsigned /str_width_conv_tb/u_str_width_conv/r.buff_cnt
add wave -noupdate -expand -group s_axis -color Yellow /str_width_conv_tb/u_str_width_conv/s_axis_tdata
add wave -noupdate -expand -group s_axis -color Yellow /str_width_conv_tb/u_str_width_conv/s_axis_tkeep
add wave -noupdate -expand -group s_axis -color Yellow /str_width_conv_tb/u_str_width_conv/s_axis_tlast
add wave -noupdate -expand -group s_axis -color Yellow /str_width_conv_tb/u_str_width_conv/s_axis_trdy
add wave -noupdate -expand -group s_axis -color Yellow /str_width_conv_tb/u_str_width_conv/s_axis_tvld
add wave -noupdate /str_width_conv_tb/u_str_width_conv/pre_rdy
add wave -noupdate /str_width_conv_tb/u_str_width_conv/r.oup_pre_cnt
add wave -noupdate -expand -group buf -color Cyan /str_width_conv_tb/u_str_width_conv/buff_last
add wave -noupdate -expand -group buf -color Cyan /str_width_conv_tb/u_str_width_conv/buff_rdy
add wave -noupdate -expand -group buf -color Cyan /str_width_conv_tb/u_str_width_conv/buff_vld
add wave -noupdate -expand -group buf -color Cyan -subitemconfig {{/str_width_conv_tb/u_str_width_conv/r.buff[3]} {-color Cyan} {/str_width_conv_tb/u_str_width_conv/r.buff[2]} {-color Cyan} {/str_width_conv_tb/u_str_width_conv/r.buff[1]} {-color Cyan} {/str_width_conv_tb/u_str_width_conv/r.buff[0]} {-color Cyan}} /str_width_conv_tb/u_str_width_conv/r.buff
add wave -noupdate -expand -group m_axis -color Coral /str_width_conv_tb/u_str_width_conv/m_axis_tdata
add wave -noupdate -expand -group m_axis -color Coral /str_width_conv_tb/u_str_width_conv/m_axis_tkeep
add wave -noupdate -expand -group m_axis -color Coral /str_width_conv_tb/u_str_width_conv/m_axis_tlast
add wave -noupdate -expand -group m_axis -color Coral /str_width_conv_tb/u_str_width_conv/m_axis_trdy
add wave -noupdate -expand -group m_axis -color Coral /str_width_conv_tb/u_str_width_conv/m_axis_tvld
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1135646 ps} 0}
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
WaveRestoreZoom {1088138 ps} {1171806 ps}
