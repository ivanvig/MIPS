`timescale 1ns / 1ps

module execution_tb ();

    //==========================================================================
    // LOCAL PARAMETERS.
    //==========================================================================
   localparam NB_REG = 32;
   localparam NB_INM = 16;
   localparam NB_EX = 6;
   localparam NB_MEM = 5;
   localparam NB_WB = 8;
    //==========================================================================
    // INTERNAL SIGNALS.
    //==========================================================================
   reg [NB_REG-1:0]                     tb_alu_o;
   reg [NB_REG-1:0]                     tb_b_o;
   reg [NB_MEM-1:0]                     tb_mem_o;
   reg [NB_WB-1:0]                      tb_wb_o;
   reg [NB_REG-1:0]                     tb_pc_o;

   wire [NB_REG-1:0]                    tb_a_i;
   wire [NB_REG-1:0]                    tb_b_i;
   wire [NB_INM-1:0]                    tb_inm_i;
   wire [NB_EX-1:0]                     tb_ex_i;
   wire [NB_MEM-1:0]                    tb_mem_i;
   wire [NB_WB-1:0]                     tb_wb_i;
   wire [NB_REG-1:0]                    tb_pc_i;

   wire                                 tb_valid_i ;   // Throughput control.

   wire                                 tb_reset_i ;
   reg                                  tb_clock_i = 1'b0 ;
   integer                              tb_timer = 0 ;

    //==========================================================================
    // CONNECTION TO DUT
    //==========================================================================

    //==========================================================================
    // ALGORITHM.
    //==========================================================================

   execution
     #(
       .NB_REG (NB_REG),
       .NB_INM (NB_INM),
       .NB_EX (NB_EX),
       .NB_MEM (NB_MEM),
       .NB_WB (NB_WB)
       )
   u_execution
     (
      .o_alu (tb_alu_o),
      .o_b (tb_b_o),
      .o_mem (tb_mem_o),
      .o_wb (tb_wb_o),
      .o_pc(tb_pc_o),

      .i_a (tb_a_i),
      .i_b (tb_b_i),
      .i_inm (tb_inm_i),
      .i_ex (tb_ex_i),
      .i_mem (tb_mem_i),
      .i_wb (tb_wb_i),
      .i_pc (tb_pc_i),

      .i_reset (tb_reset_i),
      .i_clock (tb_clock_i),
      .i_valid (tb_valid_i)
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

   //ADD          = 4'b0000
   //SUB          = 4'b0001
   //AND          = 4'b0010
   //OR           = 4'b0011
   //XOR          = 4'b0100
   //NOR          = 4'b0101
   //SRL          = 4'b0110
   //SLL          = 4'b0111
   //SRA          = 4'b1000
   //SLA          = 4'b1001
   //SLT          = 4'b1010
   //LUI          = 4'b1011

   //EX: - !6 alu_control 2! b_i ! s_u !
   
   always @ (*)
     begin
        case(tb_timer)
          4: begin
             tb_a_i = 32'h0000_0000;
             tb_b_i = 32'h0000_0000;
             tb_inm_i = 16'h0000;
             tb_ex_i = 6'b0000_0_0;
             tb_mem_i = 5'b00001;
             tb_wb_i = 8'b0000_0001;
             tb_pc_i = 32'h0000_0005;
          end
          5: begin
             tb_a_i = 32'h0000_0000;
             tb_b_i = 32'h0000_0000;
             tb_inm_i = 16'h0000;
             tb_ex_i = 6'b0000_0_0;
             tb_mem_i = 5'b00001;
             tb_wb_i = 8'b0000_0001;
             tb_pc_i = 32'h0000_0005;
          end
          6: begin
             tb_a_i = 32'h0000_0000;
             tb_b_i = 32'h0000_0000;
             tb_inm_i = 16'h0000;
             tb_ex_i = 6'b0000_0_0;
             tb_mem_i = 5'b00001;
             tb_wb_i = 8'b0000_0001;
             tb_pc_i = 32'h0000_0005;
          end
          7: begin
             tb_a_i = 32'h0000_0000;
             tb_b_i = 32'h0000_0000;
             tb_inm_i = 16'h0000;
             tb_ex_i = 6'b0000_0_0;
             tb_mem_i = 5'b00001;
             tb_wb_i = 8'b0000_0001;
             tb_pc_i = 32'h0000_0005;
          end
          8: begin
             tb_a_i = 32'h0000_0000;
             tb_b_i = 32'h0000_0000;
             tb_inm_i = 16'h0000;
             tb_ex_i = 6'b0000_0_0;
             tb_mem_i = 5'b00001;
             tb_wb_i = 8'b0000_0001;
             tb_pc_i = 32'h0000_0005;
          end
          9: begin
             tb_a_i = 32'h0000_0000;
             tb_b_i = 32'h0000_0000;
             tb_inm_i = 16'h0000;
             tb_ex_i = 6'b0000_0_0;
             tb_mem_i = 5'b00001;
             tb_wb_i = 8'b0000_0001;
             tb_pc_i = 32'h0000_0005;
          end

          default: begin
             tb_a_i = 32'h0000_0000;
             tb_b_i = 32'h0000_0000;
             tb_inm_i = 16'h0000;
             tb_ex_i = 6'b0000_0_0;
             tb_mem_i = 5'b00001;
             tb_wb_i = 8'b0000_0001;
             tb_pc_i = 32'h0000_0005;
          end
        endcase
     end

   function integer clogb2;
      input integer                   depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
   endfunction
   
endmodule
