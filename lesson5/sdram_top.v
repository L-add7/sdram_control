module sdram_top(
    input                   clk,
    input                   rst,
    
    output                  sdram_clk,
    output                  sdram_cke,
    output                  sdram_cs_n,
    output                  sdram_cas_n,
    output                  sdram_ras_n,
    output                  sdram_we_n,
    output   [1:0]          sdram_bank,
    output  [11:0]          sdram_addr,
    output   [1:0]          sdram_dqm,
    inout   [15:0]          sdram_dq
);

    wire                flag_init_end;
    wire    [3:0]       init_cmd;
    wire   [11:0]       init_addr;
    wire    [3:0]       aref_cmd;
    wire   [11:0]       aref_addr;


    localparam          IDLE   = 5'b00001;
    localparam          ARBIT  = 5'b00010;
    localparam          AREF   = 5'b00100;
    localparam          WRITE  = 5'b01000;
    localparam          READ   = 5'b10000; 
    reg    [4:0]        cur_state,next_state;
    wire                ref_req;
    wire                flag_ref_end;


    assign sdram_cke = 1'b1;
    assign sdram_addr = (cur_state ==AREF ) ? aref_addr :init_addr;
    assign {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} = (cur_state ==AREF ) ? aref_cmd : init_cmd;
    assign sdram_dqm = 2'b00;
    assign sdram_clk = ~clk;
    

           
    always @(posedge clk or posedge rst) begin
        if (rst) 
            cur_state <= IDLE ;
        else
            cur_state <= next_state ;
    end

    always @(*) begin
        case (cur_state)
            IDLE  : next_state = flag_init_end ? ARBIT : IDLE ;
            ARBIT : next_state = ref_req ? AREF : IDLE;
            AREF  : next_state = flag_ref_end ? ARBIT : AREF;
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
endmodule