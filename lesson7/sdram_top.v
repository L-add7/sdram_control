module sdram_top(
    input                             clk,
    input                             rst,

    output                            sdram_clk,
    output                            sdram_cke,
    output   reg                      sdram_cs_n,
    output   reg                      sdram_cas_n,
    output   reg                      sdram_ras_n,
    output   reg                      sdram_we_n,
    output   reg       [1:0]          sdram_bank,
    output   reg      [11:0]          sdram_addr,
    output             [1:0]          sdram_dqm,
    inout             [15:0]          sdram_dq,

    input                             wr_trig,
    input                             rd_trig
);

    wire                flag_init_end;
    wire    [3:0]       init_cmd;
    wire   [11:0]       init_addr;
    wire    [3:0]       aref_cmd;
    wire   [11:0]       aref_addr;
    wire    [3:0]       wr_cmd;
    wire   [11:0]       wr_addr;
    wire    [1:0]       wr_bank_addr;
    wire   [15:0]       wr_data;
    wire    [3:0]       rd_cmd;
    wire   [11:0]       rd_addr;
    wire    [1:0]       rd_bank_addr;

    localparam          IDLE   = 5'b00001;  //1
    localparam          ARBIT  = 5'b00010;  //2
    localparam          AREF   = 5'b00100;  //4
    localparam          WRITE  = 5'b01000;  //8
    localparam          READ   = 5'b10000;  //16
    reg    [4:0]        cur_state,next_state;
    wire                ref_req,wr_req,rd_req;
    wire                flag_ref_end;
    wire                flag_wr_end;
    wire                flag_rd_end;

    assign sdram_cke = 1'b1;
    // assign sdram_addr = (cur_state ==AREF ) ? aref_addr :init_addr;
    // assign {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} = (cur_state ==AREF ) ? aref_cmd : init_cmd;
    assign sdram_dqm = 2'b00;
    assign sdram_clk = ~clk;
    always @(*) begin
        if(cur_state == AREF) begin
            sdram_addr = aref_addr ;
            {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} = aref_cmd;
            sdram_bank = 2'b00;
        end
        else if(cur_state == WRITE) begin
            sdram_addr = wr_addr ;
            {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} = wr_cmd ;
            sdram_bank = wr_bank_addr;
        end
        else if(cur_state == READ) begin
            sdram_addr = rd_addr;
            {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} = rd_cmd ;
            sdram_bank = rd_bank_addr;
        end
        else if(cur_state == ARBIT || cur_state == IDLE) begin
            sdram_addr = init_addr ;
            {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} = init_cmd ;
            sdram_bank = 2'b00;
        end
        else begin
            sdram_addr = init_addr ;
            {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} = init_cmd ;
            sdram_bank = 2'b00;
        end
    end

    assign sdram_dq = (cur_state == WRITE) ? wr_data : {16{1'bz}};
    // assign sdram
           
    always @(posedge clk or posedge rst) begin
        if (rst) 
            cur_state <= IDLE ;
        else
            cur_state <= next_state ;
    end

    always @(*) begin
        case (cur_state)
            IDLE  : next_state = flag_init_end ? ARBIT : IDLE ;
            ARBIT : begin
                if(ref_req)
                    next_state = AREF ;
                else if (wr_req)
                    next_state =  WRITE;
                else if(rd_req)
                    next_state = READ;
                else
                    next_state = ARBIT;
            end
            AREF  : next_state = flag_ref_end ? ARBIT : AREF;
            WRITE : next_state = flag_wr_end  ? ARBIT : WRITE;
            READ  : next_state = flag_rd_end  ? ARBIT : READ ;
            default:next_state = IDLE ; 
        endcase
    end


    reg     ref_en;   
    always @(posedge clk or posedge rst) begin
        if ( rst )
            ref_en <= 0 ;
        else if(ref_req && (cur_state == ARBIT))
            ref_en <= 1;
        else
            ref_en <= 0; 
    end
    
    reg     wr_en;
    always @(posedge clk or posedge rst) begin
        if( rst )
            wr_en <= 0;
        else if(wr_req && (cur_state == ARBIT))
            wr_en <= 1;
        else 
            wr_en <= 0; 
    end

    reg     rd_en;
    always @(posedge clk or posedge rst) begin
        if( rst )
            rd_en <= 0;
        else if(rd_req && (cur_state == ARBIT))
            rd_en <= 1;
        else 
            rd_en <= 0; 
    end

    sdram_init  sdram_init_inst(
            .clk                (clk),
            .rst                (rst),
            .cmd_reg            (init_cmd),
            .sdram_addr         (init_addr),
            .flag_init_end      (flag_init_end)
    );

    sdram_aref sdram_aref_inst(
            .clk                (clk),
            .rst                (rst),
            .ref_en             (ref_en),
            .flag_init_end      (flag_init_end),

            .ref_req            (ref_req),
            .flag_ref_end       (flag_ref_end),
            .aref_cmd           (aref_cmd),
            .sdram_addr         (aref_addr)
    );

    sdram_write sdram_write_inst(
            .clk                (clk),
            .rst                (rst),
            .wr_en              (wr_en),
            .wr_req             (wr_req),
            .flag_wr_end        (flag_wr_end),
            .ref_req            (ref_req),
            .wr_trig            (wr_trig),
            .wr_cmd             (wr_cmd),
            .wr_addr            (wr_addr) ,
            .bank_addr          (wr_bank_addr),
            .wr_data            (wr_data)
    );
    
    sdram_read  sdram_read_inst(
            .clk                      (clk),
            .rst                      (rst),

            .rd_en                    (rd_en),
            .rd_req                   (rd_req),
            .flag_rd_end              (flag_rd_end),

            .ref_req                  (ref_req),
            .rd_trig                  (rd_trig),   

            .rd_cmd                   (rd_cmd),
            .rd_addr                  (rd_addr),
            .bank_addr                (rd_bank_addr)
);
endmodule