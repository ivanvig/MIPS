
module instruction_fetch
  #(
    parameter NB_REG             = 32,
    parameter NB_INSTR           = 32,
    parameter N_ADDR             = 2048,
    parameter LOG2_N_INSMEM_ADDR = clogb2(N_ADDR),
    parameter NB_INM_I           = 16,
    parameter NB_INM_J           = 26,
    parameter INSTR_FILE         = ""
    )
   (
    output wire [NB_INSTR-1:0] o_ir, //Output from IR or NOP depending on i_nop_reg
    output reg [NB_REG-1:0]    o_pc,

    input wire [NB_INM_I-1:0]  i_inm_i, //Branch addr in type i instructions, from instr[0-15]
    input wire [NB_INM_J-1:0]  i_inm_j, //Jump addr in type j instructions, from instr[0-25]
    input wire [NB_REG-1:0]    i_rs, //Jump addr in type R instructions, from RS
    input wire                 i_hazard,

    input wire                 i_jump_inm,
    input wire                 i_jump_rs,
    input wire                 i_branch,

    input wire                 i_clock,
    input wire                 i_reset,
    input wire                 i_valid
    ) ;
   reg [NB_REG-1:0]            pc ;
   wire [NB_INSTR-1:0]         mem_ir ; //IR register from Instr Mem

   //Program counter logic
   always @(posedge i_clock)
     begin
        if (i_reset) begin
           pc <= {NB_REG{1'b0}};
        o_pc <= {NB_REG{1'b0}};
     end else if (i_valid) begin
        case ({i_branch, i_jump_rs, i_jump_inm, i_hazard})
          4'b0000: pc <= pc+4 ;
          4'b0010: pc <= (pc & 32'hF0000000) | (i_inm_j << 2); //J/JAL
          4'b0100: pc <= i_rs; //JR/JALR
          4'b1000: pc <= $signed({1'b0, pc})+($signed(i_inm_i)-1)*4; //BEQ/BNE
          4'b0001: pc <= pc;
          default: pc <= pc;
        endcase // case
        o_pc <= pc+4; //pc to be
     end
     end // always @ (posedge i_clock)

   assign o_ir = mem_ir ;

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
      .i_enable            (~i_hazard),
      .i_reset             (i_reset)
      ) ;

   function integer clogb2;
      input integer                   depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
   endfunction

endmodule
