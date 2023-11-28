`timescale 1ns/1ns

module tb_cmd_decode;

reg                     clk;
reg                     rst;

reg                     uart_flag;
reg         [7:0]       uart_data;

wire                    wr_trig;
wire                    rd_trig;
wire                    wfifo_wr_en;
wire      [7:0]         wfifo_data;

initial begin
    clk = 0 ;
    rst = 1 ;
    #100 
    rst = 0 ;
end

always #5 clk = ~clk ; 

initial begin
    uart_flag    <=  0 ;
    uart_data    <=  0 ;
    #200
    uart_flag    <=  1 ;
    uart_data    <=  8'h55;
    #10
    uart_flag    <=  0 ;
    #200
    uart_flag    <=  1 ;
    uart_data    <=  8'h12;
    #10
    uart_flag    <=  0 ;
    #200
    uart_flag    <=  1 ;
    uart_data    <=  8'h34;
    #10
    uart_flag    <=  0 ;

    #200
    uart_flag    <=  1 ;
    uart_data    <=  8'h56;
    #10
    uart_flag    <=  0 ;

    #200
    uart_flag    <=  1 ;
    uart_data    <=  8'h78;
    #10
    uart_flag    <=  0 ;

    #200
    uart_flag    <=  1 ;
    uart_data    <=  8'haa;
    #10
    uart_flag    <=  0 ;
end     

cmd_decode cmd_decode_inst(
    .clk                (clk),
    .rst                (rst),

    .uart_flag          (uart_flag),
    .uart_data          (uart_data),

    .wr_trig            (wr_trig),
    .rd_trig            (rd_trig),
    .wfifo_wr_en        (wfifo_wr_en),
    .wfifo_data         (wfifo_data)
);



endmodule