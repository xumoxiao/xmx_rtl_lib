onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /str_ofs_conv_tb/u_str_ofs_conv/BYTE_CNT
add wave -noupdate /str_ofs_conv_tb/u_str_ofs_conv/BYTE_WIDTH
add wave -noupdate /str_ofs_conv_tb/u_str_ofs_conv/CONV_OFS_WIDTH
add wave -noupdate /str_ofs_conv_tb/u_str_ofs_conv/DATA_WIDTH
add wave -noupdate /str_ofs_conv_tb/u_str_ofs_conv/DEBUG
add wave -noupdate /str_ofs_conv_tb/u_str_ofs_conv/NEW_BYTE_POS_MAX
add wave -noupdate /str_ofs_conv_tb/u_str_ofs_conv/NEW_BYTE_POS_WIDTH
add wave -noupdate /str_ofs_conv_tb/u_str_ofs_conv/NEXT_BYTE_POS_MAX
add wave -noupdate /str_ofs_conv_tb/u_str_ofs_conv/NEXT_BYTE_POS_WIDTH
add wave -noupdate /str_ofs_conv_tb/u_str_ofs_conv/SHIFTER_BYTE_CNT
add wave -noupdate /str_ofs_conv_tb/u_str_ofs_conv/SIM
add wave -noupdate /str_ofs_conv_tb/u_str_ofs_conv/i_clk
add wave -noupdate /str_ofs_conv_tb/u_str_ofs_conv/i_rst
add wave -noupdate -expand -group conv -color Yellow /str_ofs_conv_tb/u_str_ofs_conv/i_conv_m_ofs
add wave -noupdate -expand -group conv -color Yellow /str_ofs_conv_tb/u_str_ofs_conv/i_conv_s_ofs
add wave -noupdate -expand -group conv -color Yellow /str_ofs_conv_tb/u_str_ofs_conv/i_conv_vld
add wave -noupdate -expand -group conv -color Yellow /str_ofs_conv_tb/u_str_ofs_conv/o_conv_rdy
add wave -noupdate -expand -group s_axis -color Cyan /str_ofs_conv_tb/u_str_ofs_conv/s_axis_tdata
add wave -noupdate -expand -group s_axis -color Cyan /str_ofs_conv_tb/u_str_ofs_conv/s_axis_tkeep
add wave -noupdate -expand -group s_axis -color Cyan /str_ofs_conv_tb/u_str_ofs_conv/s_axis_tlast
add wave -noupdate -expand -group s_axis -color Cyan /str_ofs_conv_tb/u_str_ofs_conv/s_axis_trdy
add wave -noupdate -expand -group s_axis -color Cyan /str_ofs_conv_tb/u_str_ofs_conv/s_axis_tvld
add wave -noupdate /str_ofs_conv_tb/u_str_ofs_conv/r.next_byte_pos
add wave -noupdate /str_ofs_conv_tb/u_str_ofs_conv/r.next_byte_flag
add wave -noupdate -expand -group m_axis -color Orange /str_ofs_conv_tb/u_str_ofs_conv/m_axis_tdata
add wave -noupdate -expand -group m_axis -color Orange /str_ofs_conv_tb/u_str_ofs_conv/m_axis_tkeep
add wave -noupdate -expand -group m_axis -color Orange /str_ofs_conv_tb/u_str_ofs_conv/m_axis_tlast
add wave -noupdate -expand -group m_axis -color Orange /str_ofs_conv_tb/u_str_ofs_conv/m_axis_tvld
add wave -noupdate -expand -group m_axis -color Orange /str_ofs_conv_tb/u_str_ofs_conv/m_axis_trdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2130375 ps} 0}
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
WaveRestoreZoom {2060977 ps} {2231528 ps}
