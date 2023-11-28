all: create_lib compile simulate 

create_lib:
	vlib work

compile:
	vlog -l comp.log -sv cmd_decode.v tb_cmd_decode.v

simulate:
	vsim -l sim.log -voptargs=+acc work.tb_cmd_decode -do "log -r *; run -all"
	
clean:
	rm -rf *work mti_lib transcript modelsim.ini *wlf seq.cr.mti seq.mpf *.log