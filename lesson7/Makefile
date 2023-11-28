all: create_lib compile simulate 

create_lib:
	vlib work

compile:
	vlog -l comp.log -sv sdram_top.v sdram_write.v sdram_read.v sdram_aref.v sdram_init.v sdram_model_plus.v tb_sdram_top.v

simulate:
	vsim -l sim.log -voptargs=+acc work.tb_sdram_top -do "log -r *; run -all"
	
clean:
	rm -rf *work mti_lib transcript modelsim.ini *wlf seq.cr.mti seq.mpf *.log