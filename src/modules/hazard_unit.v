module hazard_unit
  #(
    parameter NB_REG_ADDR   = 5,
    parameter NB_OPCODE     = 6

    )
   (
    output                  o_hazard,

    input                   i_re, // es un LOAD
    input                   i_jmp_branch, // es un jmp RS o branch
    input [NB_REG_ADDR-1:0] i_rd,
    input [NB_REG_ADDR-1:0] i_rs,
    input [NB_REG_ADDR-1:0] i_rt,

    input                   i_clock,
    input                   i_reset,
    input                   i_valid
    ) ;

   reg                      jump_branch_reg;
   reg [NB_REG_ADDR-1:0]    rs_reg;
   reg [NB_REG_ADDR-1:0]    rt_reg;

   always @ (negedge i_clock)
     begin
        if (i_valid) begin
           jump_branch_reg <= i_jmp_branch;
           rs_reg <= i_rs;
           rt_reg <= i_rt;
        end
     end

   assign o_hazard = ((i_rd == rs_reg) | (i_rd == rt_reg)) & (i_re | jump_branch_reg);

endmodule
