`timescale 1ns / 1ps

module instruction_fetch_tb ();

    //==========================================================================
    // LOCAL PARAMETERS.
    //==========================================================================
    localparam NB_REG = 32 ;                        
    localparam NB_INSTR = 32 ;                      
    localparam N_ADDR = 2048 ;                      
    localparam LOG2_N_INSMEM_ADDR = clogb2(N_ADDR);                         
    localparam NB_INM_I = 16;                      
    localparam NB_INM_J = 26;                       
    //==========================================================================
    // INTERNAL SIGNALS.
    //==========================================================================
    wire [NB_INSTR-1:0] tb_instruction_o;
                            
    reg                 tb_inop_reg_i;
    reg [NB_INM_I-1:0]  tb_i_inm_i;
    reg [NB_INM_J-1:0]  tb_inm_j_i;
    reg [NB_REG-1:0]    tb_rs_i;
            
    reg                 tb_jump_inm_i;
    reg                 tb_jump_rs_i; 
    reg                 tb_branch_i;  
    
    
    
    wire                 tb_valid_i ;   // Throughput control.

    wire                 tb_reset_i ;
    reg                  tb_clock_i = 1'b0 ;
    integer              tb_timer = 0 ;

    //==========================================================================
    // CONNECTION TO DUT
    //==========================================================================

    //==========================================================================
    // ALGORITHM.
    //==========================================================================

    instruction_fetch
    #(
        .NB_REG                  (NB_REG            ),
        .NB_INSTR                (NB_INSTR          ),
        .N_ADDR                  (N_ADDR            ),
        .LOG2_N_INSMEM_ADDR      (LOG2_N_INSMEM_ADDR),
        .NB_INM_I                (NB_INM_I          ),
        .NB_INM_J                (NB_INM_J          )
    )
    u_instruction_fetch
    (
      .o_instruction            (tb_instruction_o),
      .i_inm_i                  (tb_i_inm_i),
      .i_inm_j                  (tb_inm_j_i),
      .i_rs                     (tb_rs_i),
      .i_jump_inm               (tb_jump_inm_i),
      .i_jump_rs                (tb_jump_rs_i),
      .i_branch                 (tb_branch_i),
                                 
      .i_clock                  (tb_clock_i),
      .i_reset                  (tb_reset_i),
      .i_valid                  (tb_valid_i)
    ) ;
    
    always
    begin
        #(50) tb_clock_i = ~tb_clock_i ;
    end

    always @ ( posedge tb_clock_i )
    begin
        tb_timer   <= tb_timer + 1;
    end

    assign tb_reset_i = (tb_timer == 2) ; // Reset at time 2
    assign tb_valid_i = 1'b1 ;
    
    always @ (*)
    begin
        case(tb_timer)
        4: begin
            tb_i_inm_i = 16'h0001;
            tb_inm_j_i = 26'b0000_1111_0000_1100_1111_0011_11;
            tb_rs_i    = 32'haaa0_bbbb;
            tb_jump_inm_i = 1'b1 ;
            tb_jump_rs_i = 1'b0 ;
            tb_branch_i = 1'b0 ;
        end
        5: begin            
            tb_i_inm_i =  16'h0002;                       
            tb_inm_j_i =  26'b0001_1111_0000_1100_1111_0011_11;
            tb_rs_i =     32'haaa1_bbbb;                       
            tb_jump_inm_i = 1'b0 ;
            tb_jump_rs_i = 1'b1 ;
            tb_branch_i = 1'b0 ;
        end
        6: begin
            tb_i_inm_i = 16'h0003;                       
            tb_inm_j_i = 26'b0010_1111_0000_1100_1111_0011_11;
            tb_rs_i =    32'haaa2_bbbb;                       
            tb_jump_inm_i = 1'b0 ;
            tb_jump_rs_i = 1'b0 ;
            tb_branch_i = 1'b1 ;
        end
        7: begin
            tb_i_inm_i =  16'h0004;                       
            tb_inm_j_i =  26'b0011_1111_0000_1100_1111_0011_11;
            tb_rs_i =     32'haaa3_bbbb;                       
            tb_jump_inm_i = 1'b0 ;
            tb_jump_rs_i = 1'b0 ;
            tb_branch_i = 1'b0 ;
        end
        8: begin
            tb_i_inm_i = 16'h0005;                       
            tb_inm_j_i = 26'b0100_1111_0000_1100_1111_0011_11;
            tb_rs_i =    32'haaa4_bbbb;                       
            tb_jump_inm_i = 1'b1 ;
            tb_jump_rs_i = 1'b1 ;
            tb_branch_i = 1'b0 ;
        end
        9: begin
            tb_i_inm_i = 16'h0006;                       
            tb_inm_j_i = 26'b0101_1111_0000_1100_1111_0011_11;
            tb_rs_i =    32'haaa5_bbbb;                       
            tb_jump_inm_i = 1'b0 ;
            tb_jump_rs_i = 1'b1 ;
            tb_branch_i = 1'b1 ;
        end
        10: begin
            tb_i_inm_i = 16'h0007;                       
            tb_inm_j_i = 26'b0000_1111_0000_1100_1111_0011_11;
            tb_rs_i =    32'haaa6_bbbb;                       
            tb_jump_inm_i = 1'b1 ;
            tb_jump_rs_i = 1'b1 ;
            tb_branch_i = 1'b1 ;
        end
        default: begin
            tb_i_inm_i = 16'h0000;                       
            tb_inm_j_i = 26'b0000_0000_0000_0000_0000_0000_00;
            tb_rs_i =    32'h0000_0000;                       
            tb_jump_inm_i = 1'b0 ;
            tb_jump_rs_i =  1'b0 ;
            tb_branch_i =  1'b0 ; 
            end
        endcase
    end
 

    

   function integer clogb2;
      input integer                   depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
   endfunction
   
endmodule
