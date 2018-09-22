

#get path of the script
variable scriptPath [file dirname [file normalize [info script]]]

if {![file exists {work}]} {
	 echo asyn_fifo_tb: create library
	 vlib {work}
}

vlog -work work  -sv "$scriptPath/../../../src/rtl/asyn_fifo.sv"
vlog -work work  -sv "$scriptPath/asyn_fifo_tb.sv"

vsim -novopt -c work.asyn_fifo_tb -L unisims_ver -L secureip
log -r /*
source $scriptPath/wave.do

run -all