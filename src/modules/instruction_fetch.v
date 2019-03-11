module instruction_fetch
#(
  parameter NB_REG = 32,
  parameter NB_INSTR = 32,
  parameter NB_RT = 5,
  parameter NB_INM_I = 16,
  parameter NB_INM_J = 26
)
(
 output wire [NB_INSTR-1:0] o_instruction, //Output from IR or NOP depending on i_nop_reg

 input wire                 i_nop_reg, //Input from NOP_REG which indicates that there was a jump/branch
 input wire [NB_INM_I-1:0]  i_inm_i, //Branch addr in type i instructions, from instr[0-15]
 input wire [NB_INM_J-1:0]  i_inm_j, //Jump addr in type j instructions, from instr[0-25]
 input wire [NB_REG-1:0]    i_rs, //Jump addr in type R instructions, from RS
 
 input wire                 i_jump_inm,
 input wire                 i_jump_rs,
 input wire                 i_branch,

 input wire                 i_clock,
 input wire                 i_reset,
 input wire                 i_valid
 ) ;
   reg [NB_REG-1:0]         pc ;
   wire [NB_INSTR-1:0]      mem_ir ; //IR register from Instr Mem

   //Program counter logic
   always @(posedge i_clock)
   begin
     if (i_reset)
       pc <= {NB_REG{1'b0}};
     else if (i_valid) begin
        case ({i_branch, i_jump_rs, i_jump_inm})
          3'b000: pc <= pc ;
          3'b001: pc <= (pc & 32'hF0000000) | (i_inm_j << 2); //J/JAL
          3'b010: pc <= i_rs; //JR/JALR
          3'b100: pc <= pc*4+i_inm_i*4; //BEQ/BNE
          default: pc <= pc+4;
        endcase // case
     end
   end // always @ (posedge i_clock)

   assign o_instruction = (i_nop_reg==1'b0) ? mem_ir : 32'h0000_0000 ;
endmodule
