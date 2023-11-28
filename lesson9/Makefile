all: create_lib compile simulate 

create_lib:
	vlib work

compile:
	vlog -l comp.log -sv top.v sdram_top.v sdram_write.v sdram_read.v sdram_aref.v sdram_init.v sdram_model_plus.v fifo_16x8.v cmd_decode.v uart_rx.v uart_tx.v tb_top.v

simulate:
	vsim -l sim.log -voptargs=+acc work.tb_top -do "log -r *; run -all"
	
clean:
	rm -rf *work mti_lib transcript modelsim.ini *wlf seq.cr.mti seq.mpf *.log