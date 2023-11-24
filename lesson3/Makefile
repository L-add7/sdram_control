all: create_lib compile simulate 

create_lib:
	vlib work

compile:
	vlog -l comp.log -sv uart_tx.v tb_uart_tx.v

simulate:
	vsim -l sim.log -voptargs=+acc work.tb_uart_tx -do "log -r *; run -all"
	
clean:
	rm -rf *work mti_lib transcript modelsim.ini *wlf seq.cr.mti seq.mpf *.log