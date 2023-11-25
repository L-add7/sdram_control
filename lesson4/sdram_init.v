//describe : we need to wait at least 100us ,we wait 200us there
//the clk we use is 50Mhz,(0.02us)  so 200us we neew to wait 10000
module sdram_init#(
    parameter   FREQUENCY = 50,         //MHZ
    parameter   INI_TIME = 200          //us
)
(
    input                      clk,
    input                      rst,

    output   reg     [3:0]     cmd_reg,
    output          [11:0]     sdram_addr,
    output   reg               flag_init_end
);      

parameter WAIT_CNT = INI_TIME * FREQUENCY;

// cs ras cas we
localparam  Precharge = 4'b0010;   
localparam  AutoFresh = 4'b0001;
localparam  NOP       = 4'b0111;
localparam  ModeSet   = 4'b0000;

localparam  ModeSdramAddr = 12'b000000110010;

reg         [15:0]          wait_cnt;
reg                         flag_200us;
reg          [3:0]          cnt_cmd;

//wait 200us
always @(posedge clk or posedge rst) begin
    if (rst) 
        wait_cnt <= 0;
    else if ( !flag_200us )
        wait_cnt <= wait_cnt + 1;
end

always @(posedge clk or posedge rst) begin
    if(rst)
        flag_200us <= 0;
    else if ( wait_cnt == WAIT_CNT - 1)
        flag_200us <= 1;
end      

// commond cnt
// Based on SDRAM timing diagram
always @(posedge clk or posedge rst) begin
    if(rst)
        cnt_cmd <= 0;
    else if ( flag_init_end)
        cnt_cmt <= cnt_cmd;
    else if (flag_200us)
        cnt_cmd <= cnt_cmd + 1;
end
//create commond
always @(posedge clk or posedge rst) begin
    if (rst)
        cmd_reg <= 0;
    else if(flag_200us) begin
        case ( cnt_cmd )
        0 :  cmd_reg = Precharge;
        1 :  cmd_reg = AutoFresh;
        5 :  cmd_reg = AutoFresh;
        9 :  cmd_reg = ModeSet;
        default : cmd_reg = NOP;
        endcase 
    end
end

//create end signal
always @(posedge clk or posedge rst) begin
    if(rst) 
        flag_init_end <= 0;
    else if(cmd_reg == ModeSet)
        flag_init_end <= 1;
end

assign sdram_addr = ( cnt_cmd == 9) ? ModeSdramAddr : 12'b010000000000;
endmodule