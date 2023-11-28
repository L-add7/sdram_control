module sdram_read(
    input                       clk,
    input                       rst,

    input                       rd_en,
    output                      rd_req,
    output   reg                flag_rd_end,

    input                       ref_req,
    input                       rd_trig,

    output   reg      [3:0]     rd_cmd,
    output   reg     [11:0]     rd_addr,
    output   reg      [1:0]     bank_addr
);

//usual
    reg                         flag_rd;

//active
    reg         [3:0]           act_cnt;
    reg        [11:0]           row_addr;             // use for active row  
    reg                         flag_act_end;
//read
    reg         [1:0]           burst_cnt,burst_cnt_d1;
    reg         [6:0]           col_cnt; 
    wire        [8:0]           col_addr;
    reg                         sd_row_end ;  
//Precharge
    reg         [2:0]           charge_cnt;
    reg                         flag_pre_end;
//end
    reg                         data_end;

    localparam                  CMD_ACTIVE    =  4'b0011; //3
    localparam                  CMD_SD_RD     =  4'b0101; //5
    localparam                  CMD_Precharge =  4'b0010; //2
    localparam                  CMD_NOP       =  4'b0111; //7

    localparam                  ST_IDLE     =  5'b00001;
    localparam                  ST_REQ      =  5'b00010;
    localparam                  ST_ACT      =  5'b00100;
    localparam                  ST_READ     =  5'b01000;
    localparam                  ST_PRE      =  5'b10000;
    reg   [4:0]         cur_state,next_state;       


    always @(posedge clk or posedge rst) begin
        if (rst)
            cur_state <= ST_IDLE;
        else
            cur_state <= next_state;
    end

    always @(*)begin
        case (cur_state)
            ST_IDLE : next_state = rd_trig ? ST_REQ : ST_IDLE ;
            ST_REQ  : next_state = rd_en   ? ST_ACT : ST_REQ  ;
            ST_ACT  : next_state = flag_act_end ? ST_READ : ST_ACT ;
            ST_READ: begin
                if(data_end == 1'b1)
                    next_state   =      ST_PRE;
                else if(ref_req == 1'b1 && burst_cnt_d1 == 'd2 && flag_rd == 1'b1)
                    next_state   =      ST_PRE;
                else if(sd_row_end == 1'b1 && flag_rd == 1'b1)
                    next_state   =      ST_PRE;
            end
            ST_PRE  : begin
                if(data_end && flag_pre_end)
                    next_state = ST_IDLE;
                else if(ref_req && flag_rd && flag_pre_end )
                    next_state = ST_REQ ;
                else if(sd_row_end && flag_rd && flag_pre_end)
                    next_state = ST_REQ ;
                else
                    next_state = ST_PRE ;
            end
            default: next_state =  ST_IDLE;
        endcase
    end


    always @(posedge clk or posedge rst ) begin
        if (rst)
            flag_rd <= 0;
        else if(rd_trig)
            flag_rd <= 1;
        else if(data_end)
            flag_rd <= 0;
    end

    assign rd_req = (cur_state == ST_REQ); 

    always @(posedge clk or posedge rst) begin
        if( rst )
            row_addr <= 0;
        else if(col_addr == 'd511)
            row_addr <= row_addr + 1;
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            col_cnt <= 0;
        else if( burst_cnt_d1 == 2'b11)
            col_cnt <= col_cnt + 1; 
    end

    assign col_addr = {col_cnt,burst_cnt_d1};

    always @(posedge clk or posedge rst) begin
        if(rst)
            bank_addr <= 2'b0;
        else if( (row_addr == 12'b1111_1111_1111) && (col_addr == 9'b1_1111_1111) )
            bank_addr <= bank_addr + 1;
    end


    always @(posedge clk or posedge rst) begin
        if(rst)
            act_cnt <= 0;
        else if ( cur_state == ST_ACT) 
            act_cnt <= act_cnt + 1;
        else
            act_cnt <= 0;
    end


    always @(posedge clk or posedge rst) begin
        if(rst)
            flag_act_end <= 0;
        else if (act_cnt == 'd2)
            flag_act_end <= 1;
        else
            flag_act_end <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if ( rst )
            charge_cnt <= 0;
        else if(cur_state == ST_PRE)
            charge_cnt <= charge_cnt + 1;
        else
            charge_cnt <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            flag_pre_end <= 0;
        else if(charge_cnt == 'd2)
            flag_pre_end <= 1;
        else
            flag_pre_end <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) 
            burst_cnt <= 0;
        else if( cur_state == ST_READ )
            burst_cnt <= burst_cnt + 1;
        else
            burst_cnt <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            burst_cnt_d1 <= 0;
        else
            burst_cnt_d1 <= burst_cnt ; 
    end


    always @(posedge clk or posedge rst) begin
        if(rst)
            sd_row_end <= 0;
        else if( col_addr == 9'b1_1111_1101)
            sd_row_end <= 1;
        else if(flag_pre_end)
            sd_row_end <= 0; 
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_cmd      <= CMD_NOP;
        end
        else if( (cur_state == ST_ACT) && (act_cnt == 'd0)) begin
            rd_cmd      <= CMD_ACTIVE ;
        end
        else if( cur_state == ST_READ && (burst_cnt == 'd0) && (sd_row_end == 1'b0)) begin
            rd_cmd      <= CMD_SD_RD ;
        end
        else if( cur_state == ST_PRE && (charge_cnt == 'd0)) begin
            rd_cmd      <= CMD_Precharge;
        end
        else begin
            rd_cmd      <= CMD_NOP;
        end
    end

    always @(*) begin
        if (rst) begin
            rd_addr     <= 0;
        end
        else if( (cur_state == ST_ACT) && (act_cnt == 'd1)) begin
            rd_addr     <= row_addr;
        end
        else if( cur_state == ST_READ && (burst_cnt == 'd1)) begin
            rd_addr     <= {3'b000,col_addr};    //?
        end
        else if( cur_state == ST_PRE && (charge_cnt == 'd0)) begin
            rd_addr     <= 12'b0100_0000_0000;
        end
        else begin
            rd_addr     <= 0;
        end
    end


    always @(posedge clk or posedge rst) begin
        if( rst ) 
            flag_rd_end <= 0;
        else if( ( cur_state == ST_PRE && ref_req ) || (cur_state == ST_PRE && flag_rd) )
            flag_rd_end <= 1;
        else if( data_end && flag_pre_end)
            flag_rd_end <= 1;
        else 
            flag_rd_end <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            data_end <= 0;
        else if( (row_addr == 'd2) && (col_addr =='d6))
            data_end <= 1;
        else if( cur_state == ST_IDLE )
            data_end <= 0;  
    end
endmodule