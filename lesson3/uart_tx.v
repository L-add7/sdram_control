`define     SIM 
module uart_tx#(
    parameter FREQUENCY = 50,   // 50 Mhz
    parameter BAUD_RATE = 9600       // bo te lv
)
(
    input               clk,
    input               rst,
    input               tx_trig,
    input    [7:0]      tx_data,
    
    output   reg        rs232_tx
);
`ifndef SIM
    parameter       BAND_CNT = (1/BAUD_RATE) * 1000000000000 / FREQUENCY ; 
`else
    parameter       BAND_CNT = 20 ;
`endif

    reg    [7:0]         tx_data_save;
    reg                  tx_flag;
    reg    [31:0]        band_cnt;
    
    reg                  bit_flag;
    reg    [3:0]         bit_cnt;   

    always @(posedge clk or posedge rst) begin
        if (rst)
            tx_data_save <= 7'd0 ;
        else if(tx_trig)
            tx_data_save <= tx_data;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            tx_flag <= 0 ; 
        else if(tx_trig)
            tx_flag <= 1;
        else if( (bit_cnt == 8) && (bit_flag) )
            tx_flag <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            band_cnt <= 0;
        else if(tx_flag) begin
            if( band_cnt == BAND_CNT - 1)
                band_cnt <= 0;
            else
                band_cnt <= band_cnt + 1;
        end
        else
            band_cnt <= 0; 
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            bit_flag <= 0;
        else if( band_cnt == BAND_CNT - 2)
            bit_flag <= 1;
        else
            bit_flag <= 0; 
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            bit_cnt <= 0;
        else if(bit_flag && (bit_cnt == 'd8))
            bit_cnt <= 0;
        else if(bit_flag ) 
            bit_cnt = bit_cnt + 1;
    end

    always @(*) begin
        case (bit_cnt)
            0 : rs232_tx = tx_flag ? 0 : 1 ;
            1 : rs232_tx = tx_data_save[0];
            2 : rs232_tx = tx_data_save[1];
            3 : rs232_tx = tx_data_save[2];
            4 : rs232_tx = tx_data_save[3];
            5 : rs232_tx = tx_data_save[4];
            6 : rs232_tx = tx_data_save[5];
            7 : rs232_tx = tx_data_save[6];
            8 : rs232_tx = tx_data_save[7];
        endcase
    end
endmodule