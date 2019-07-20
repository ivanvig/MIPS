module instruction_fetch
  #(
    parameter NB_REG             = 32,
    parameter NB_INSTR           = 32,
    parameter N_ADDR             = 2048,
    parameter NB_INM_I           = 16,
    parameter NB_INM_J           = 26,
    parameter INSTR_FILE         = ""
    )
   (
    output wire [NB_INSTR-1:0] o_ir, //Output from IR or NOP depending on i_nop_reg
    output reg [NB_REG-1:0]    o_pc,

    //System PC and DATA for debugging
    output wire [NB_REG-1:0]   o_debug_instrmem_data,
    output wire [NB_REG-1:0]   o_debug_system_pc,

    input wire [NB_INM_I-1:0]  i_inm_i, //Branch addr in type i instructions, from instr[0-15]
    input wire [NB_INM_J-1:0]  i_inm_j, //Jump addr in type j instructions, from instr[0-25]
    input wire [NB_REG-1:0]    i_rs, //Jump addr in type R instructions, from RS
    input wire                 i_hazard,

    input wire                 i_jump_inm,
    input wire                 i_jump_rs,
    input wire                 i_branch,

    //Loading instructions and debugging
    input wire [16-1:0]        i_debug_instrmem_addr,
    input wire [NB_INSTR-1:0]  i_debug_instrmem_data,
    input wire [4-1:0]         i_debug_instrmem_we,
    input wire                 i_debug_instrmem_re,

    input wire                 i_clock,
    input wire                 i_reset,
    input wire                 i_valid
    ) ;
   localparam LOG2_N_INSMEM_ADDR = clogb2(N_ADDR-1);

   reg [NB_REG-1:0]            pc ;
   wire [NB_INSTR-1:0]         mem_ir ; //IR register from Instr Mem

   assign o_debug_system_pc = pc;
   //Program counter logic
   always @(posedge i_clock)
     begin
        if (i_reset) begin
           pc <= {NB_REG{1'b0}};
           o_pc <= {NB_REG{1'b0}};
        end else if (i_valid) begin
           case ({i_branch, i_jump_rs, i_jump_inm, i_hazard})
             4'b1000: pc <= $signed({1'b0, pc})+($signed(i_inm_i)-1)*4; //BEQ/BNE
             4'b0100: pc <= i_rs; //JR/JALR
             4'b0010: pc <= (pc & 32'hF0000000) | (i_inm_j << 2); //J/JAL
             4'b0001: pc <= pc;
             4'b0000: pc <= pc+4 ;
             default: pc <= pc;
           endcase // case
           o_pc <= pc+4; //pc to be
        end
     end // always @ (posedge i_clock)

   assign o_ir = mem_ir ;

   byte_enabled_dual_port
     #(
       .NB_COL          (4                                              ),
       .COL_WIDTH       (8                                              ),
       .RAM_DEPTH       (N_ADDR                                         ),
       .RAM_PERFORMANCE ("LOW_LATENCY"                                  ),
       .INIT_FILE       (INSTR_FILE                                     )
       )
   u_instruction_memory
     (
      .o_data_a         (mem_ir                                         ),
      .o_data_b         (o_debug_instrmem_data                          ), //For debugging
      .i_addr_a         (pc[LOG2_N_INSMEM_ADDR+2-1-:LOG2_N_INSMEM_ADDR] ),
      .i_addr_b         (i_debug_instrmem_addr                          ),
      .i_data_a         ({32{1'b0}}                                     ),
      .i_data_b         (i_debug_instrmem_data                          ),
      .i_clock          (i_clock                                        ),
      .wea              (1'b0                                           ),
      .web              (i_debug_instrmem_we                            ),
      .ena              (~i_hazard & i_valid                            ),
      .enb              (i_debug_instrmem_re | |i_debug_instrmem_we     ),
      .i_reset_a        (i_reset                                        ),
      .i_reset_b        (i_reset                                        ),
      .i_rea            (1'b1                                           ),
      .i_reb            (1'b1                                           )
      );

   /*
   instruction_memory
     #(
       .NB_DATA            (NB_REG),
       .N_ADDR             (N_ADDR),
       .LOG2_N_INSMEM_ADDR (LOG2_N_INSMEM_ADDR),
       .INIT_FILE          (INSTR_FILE)
        )
   u_instruction_memory
      (
      .o_data              (mem_ir),
      .i_addr              (pc),
      .i_clock             (i_clock),
      .i_enable            (~i_hazard & i_valid),
      .i_reset             (i_reset)
      ) ;*/

   function integer clogb2;
      input integer                   depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
   endfunction

endmodule
