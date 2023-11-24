module tb_uart_tx;

reg               clk;
reg               rst;
reg               tx_trig;
reg    [7:0]      tx_data;

wire              rs232_tx;

initial begin
    clk = 1;
    rst = 1;
    #100
    rst = 0;
end

always #5 clk = ! clk ;
initial begin
    tx_data <= 8'd0;
    tx_trig <= 0;
    #200
    tx_trig <= 1;
    tx_data <= 8'h55;
    #10
    tx_trig <= 0;
end

uart_tx uart_tx_inst(
    .clk(clk),
    .rst(rst),
    .tx_trig(tx_trig),
    .tx_data(tx_data),
    
    .rs232_tx(rs232_tx)
);
endmodule