

#get path of the script
variable scriptPath [file dirname [file normalize [info script]]]

if {![file exists {work}]} {
	 echo str_width_conv_tb: create library
	 vlib {work}
}

vlog -work work  -sv "$scriptPath/../../../src/rtl/aurora/str_width_conv.sv"
#vlog -work work  -sv "$scriptPath/str_width_conv.sv"
vlog -work work  -sv "$scriptPath/str_width_conv_tb.sv"

vsim -novopt -c work.str_width_conv_tb -L unisims_ver -L secureip
log -r /*
source $scriptPath/wave.do

run -all