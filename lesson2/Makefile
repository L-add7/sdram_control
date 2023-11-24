all: create_lib compile simulate 

create_lib:
	vlib work

compile:
	vlog -l comp.log -sv uart_rx.v tb_uart_rx.v

simulate:
	vsim -l sim.log -voptargs=+acc work.tb_uart_rx -do "log -r *; run -all"
	
clean:
	rm -rf *work mti_lib transcript modelsim.ini *wlf seq.cr.mti seq.mpf *.log