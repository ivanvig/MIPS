module hazard_unit
  #(
    parameter NB_REG_ADDR   = 5,
    parameter NB_OPCODE     = 6

    )
   (
    output                  o_hazard,

    input                   i_re_exec, //LOAD en exec
    input                   i_re_mem, //LOAD en mem
    input                   i_jmp_branch, // es un jmp RS o branch
    input [NB_REG_ADDR-1:0] i_rd_exec, //dato del LOAD en exec
    input [NB_REG_ADDR-1:0] i_rd_mem, //dato del LOAD en mem
    input [NB_REG_ADDR-1:0] i_rs,
    input [NB_REG_ADDR-1:0] i_rt,

    input                   i_clock,
    input                   i_reset,
    input                   i_valid
    ) ;

   reg                      jump_branch_reg;
   reg [NB_REG_ADDR-1:0]    rs_reg;
   reg [NB_REG_ADDR-1:0]    rt_reg;

   wire                     instr_after_load; //ADD -> LOAD
   wire                     branch_after_instr; //BRANCH -> ADD
   wire                     branch_after_load; //BRANCH -> X -> LOAD

   always @ (negedge i_clock)
     begin
        if (i_reset) begin
           jump_branch_reg <= 1'b0;
           rs_reg <= {NB_REG_ADDR{1'b0}};
           rt_reg <= {NB_REG_ADDR{1'b0}};
        end else
          if (i_valid) begin
             jump_branch_reg <= i_jmp_branch;
             rs_reg <= i_rs;
             rt_reg <= i_rt;
          end
     end

   assign instr_after_load = ((i_rd_exec == rs_reg) | (i_rd_exec == rt_reg)) & i_re_exec;
   assign branch_after_instr = ((i_rd_exec == rs_reg) | (i_rd_exec == rt_reg)) & jump_branch_reg;
   assign branch_after_load = ((i_rd_mem == rs_reg) | (i_rd_mem == rt_reg)) & (i_re_mem & jump_branch_reg);

   assign o_hazard = instr_after_load | branch_after_instr | branch_after_load;

endmodule
