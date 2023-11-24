`define SIM
module  uart_rx#(
    parameter FREQUENCY = 50,   // 50 Mhz
    parameter BAUD_RATE = 9600       // bo te lv
)
(
    input                   clk,
    input                   rst,
    input                   rs232_rx,

    output  reg    [7:0]    rx_data,
    output  reg             po_flag
);
`ifndef SIM
    parameter       BAND_CNT = (1/BAUD_RATE) * 1000000000000 / FREQUENCY ; 
`else
    parameter       BAND_CNT = 20 ;
`endif
 
    parameter       sample_cnt = BAND_CNT / 2 - 1;
    reg                     rs232_rx_d1;
    reg                     rs232_rx_d2;
    reg                     rs232_rx_d3;
    reg                     rx_flag;
    reg        [31:0]       band_cnt;
    reg                     bit_flag;
    reg        [3:0]        bit_cnt;

    wire                    rx_neg;
    assign                  rx_neg = rs232_rx_d2 && (!rs232_rx_d3);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rs232_rx_d1 <= 1;
            rs232_rx_d2 <= 1;
            rs232_rx_d3 <= 1;
        end
        else begin
            rs232_rx_d1 <= rs232_rx;
            rs232_rx_d2 <= rs232_rx_d1;
            rs232_rx_d3 <= rs232_rx_d2;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) 
            rx_flag <= 0;
        else if( bit_cnt == 9)
            rx_flag <= 0;
        else if(rx_neg)
            rx_flag <= 1;
        
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            band_cnt <= 0;
        else if( (!rs232_rx_d2) || rx_flag ) begin
            if ( band_cnt == BAND_CNT - 1)
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
        else if( band_cnt == sample_cnt)
            bit_flag <= 1;
        else 
            bit_flag <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            bit_cnt <= 0;
        else if(band_cnt==0 && (bit_cnt == 9))
            bit_cnt <= 0;
        else if(bit_flag)
            bit_cnt <= bit_cnt + 1;
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            rx_data <= 8'b0;
        else if( (bit_cnt != 0) && bit_flag )
            rx_data <= {rs232_rx_d2,rx_data[7:1]};
        else
            rx_data <= rx_data;
    end

    always @(posedge  clk or posedge rst) begin
        if(rst)
            po_flag <= 0;
        else if(bit_flag && (bit_cnt == 8))
            po_flag <= 1;
        else
            po_flag <= 0;
    end
endmodule