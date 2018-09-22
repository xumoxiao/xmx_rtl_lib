
# -------------------------------------------------------------------------------------------------
# Get path of the script
# -------------------------------------------------------------------------------------------------
variable scriptPath [file dirname [file normalize [info script]]]
if {![file exists {work}]} {
	 echo str_ofs_conv_tb: create library
	 vlib {work}
}
# -------------------------------------------------------------------------------------------------
# Source File
# -------------------------------------------------------------------------------------------------
vlog -work work -sv "$scriptPath/../../../src/rtl/str_ofs_conv.sv"
vlog -work work -sv "$scriptPath/str_ofs_conv_tb.sv"

# -------------------------------------------------------------------------------------------------
# Execution Cmd
# -------------------------------------------------------------------------------------------------
vsim -novopt -c work.str_ofs_conv_tb

log -r /*
source $scriptPath/wave.do

run -all

