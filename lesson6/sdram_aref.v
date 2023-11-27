//    64ms refresh 4096 times    so 15.625us fresh one time
//    the cycle is 20ns (50MHZ)  so 750 cycle is enough
module sdram_aref(
    input                   clk,
    input                   rst,
    input                   ref_en,
    input                   flag_init_end,


    output  reg             ref_req,
    output                  flag_ref_end,
    output  reg   [3:0]     aref_cmd,
    output       [11:0]     sdram_addr
);
    reg           [3:0]     cmd_cnt;        
    reg           [9:0]     delay_cnt;
    parameter               DELAY_CYCLE = 750 ;

    // cs ras cas we
    localparam  Precharge = 4'b0010;   
    localparam  AutoFresh = 4'b0001;
    localparam  NOP       = 4'b0111;
    always @(posedge clk or posedge rst) begin
        if (rst) 
            delay_cnt <= 0;
        else if ( delay_cnt == DELAY_CYCLE)
            delay_cnt <= 0;
        else if ( flag_init_end )
            delay_cnt <= delay_cnt + 1;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) 
            ref_req <= 0;
        else if( delay_cnt == DELAY_CYCLE)
            ref_req <= 1;
        else if( ref_en )
            ref_req <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            cmd_cnt <= 0;
        else if (ref_en)
            cmd_cnt <= 1;
        else if ( cmd_cnt == 'd9 )
            cmd_cnt <= 0;
        else if ( cmd_cnt != 0)
            cmd_cnt <= cmd_cnt + 1;
        else
            cmd_cnt <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if ( rst )
            aref_cmd <= NOP;
        else if(cmd_cnt == 'd1)
            aref_cmd <= Precharge;
        else if(cmd_cnt == 'd2)
            aref_cmd <= AutoFresh;
        else
            aref_cmd <= NOP;
    end

    assign sdram_addr = 12'b0100_0000_0000;

    assign flag_ref_end = (cmd_cnt == 'd9) ;
endmodule