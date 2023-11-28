module cmd_decode(
    input                       clk,
    input                       rst,

    input                       uart_flag,
    input       [7:0]           uart_data,

    output                      wr_trig,
    output                      rd_trig,
    output                      wfifo_wr_en,
    output      [7:0]           wfifo_data
);
    
    localparam                  RECEIVE_END = 3'd4 ; 
    reg     [2:0]               receive_num,receive_num_d1;
    reg     [7:0]               cmd_reg;


    always @(posedge clk or posedge rst) begin
        if(rst)
            receive_num <= 0;
        else if( (receive_num == 'd4) && uart_flag)
            receive_num <= 0;
        else if( (receive_num == 'd0) && uart_flag && (uart_data == 8'haa))
            receive_num  <= 0;
        else if(uart_flag)
            receive_num <= receive_num + 1;
        else 
            receive_num <= receive_num;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            receive_num_d1 <= 0;
        else
            receive_num_d1 <= receive_num;
    end
    always @(posedge clk or posedge rst) begin
        if(rst)
            cmd_reg <= 8'h00;
        else if(uart_flag && (receive_num == 'd0))
            cmd_reg <= uart_data ;
    end

    assign wr_trig = (receive_num == RECEIVE_END && receive_num_d1 == RECEIVE_END && cmd_reg == 8'h55) ? uart_flag : 1'b0;
    assign rd_trig = (receive_num == 'd0 && uart_data == 8'haa) ? uart_flag : 0;
    assign wfifo_wr_en = (receive_num != 0) ? uart_flag : 0;
    assign wfifo_data = uart_data ; 
    
endmodule