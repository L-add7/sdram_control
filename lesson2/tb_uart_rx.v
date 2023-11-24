module tb_uart_rx;

reg             clk;
reg             rst;
reg             rs232_tx;

wire     [7:0]  rx_data;
wire            po_flag;

reg      [7:0]  mem_a[3:0];

initial begin

clk = 1;
rst = 1;
rs232_tx = 1;

#100

rst = 0;

#100
tx_byte();
#10
$finish();
end

always #5 clk = !clk;

initial $readmemh("./rx_data.txt",mem_a);

task  tx_bit (
    input   [7:0] data
);
    integer i ;
    for(i = 0 ; i < 10 ; i = i + 1 ) begin
        case (i)
            0: rs232_tx <= 1'b0;
            1: rs232_tx <= data[i-1];
            2: rs232_tx <= data[i-1];
            3: rs232_tx <= data[i-1];
            4: rs232_tx <= data[i-1];
            5: rs232_tx <= data[i-1];
            6: rs232_tx <= data[i-1];
            7: rs232_tx <= data[i-1];
            8: rs232_tx <= data[i-1];
            9: rs232_tx <= 1'b1;
        endcase
        #200;
    end
endtask

task tx_byte();
    integer i;
    for( i = 0 ; i < 4 ; i = i + 1) begin
        tx_bit(mem_a[i]);
    end
endtask

uart_rx uart_rx(
    .clk(clk),
    .rst(rst),
    .rs232_rx(rs232_tx),

    .rx_data(rx_data),
    .po_flag(po_flag)
);

endmodule