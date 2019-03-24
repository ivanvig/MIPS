module pipeline
  #(
    //instruction_fetch
    parameter NB_REG = 32,
    parameter NB_INSTR = 32,
    parameter N_ADDR = 32,
    parameter LOG2_N_INSMEM_ADDR = clogb2(N_ADDR),
    parameter NB_INM_I = 16,
    parameter NB_INM_J = 26,

    //instruction_decode
    parameter NB_OPCODE = 6,
    parameter NB_FUNCCODE = NB_OPCODE,
    parameter NB_INM = 16,
    parameter NB_SHAMT = 5,
    parameter NB_REG_ADDR = 5,
    parameter NB_J_INM = 26,
    parameter NB_ALUOP = 4,
    parameter NB_EX = NB_ALUOP+3,
    parameter NB_MEM = 5,
    parameter NB_WB = NB_REG_ADDR+3,
    parameter REGFILE_DEPTH = 32
    )

   (
    //output wire [N_ADDR-1:0] o_register_file,
    //output wire []           o_latches,
    //output wire []           o_pc,
    //output wire []           o_data_mem,
    //output wire [NB_REG-1:0] o_n_clocks,

    input wire               i_clock,
    input wire               i_valid,
    input wire               i_reset
    );

   //From fetch to decode
   wire [NB_INSTR-1:0]       if_ir_deco;
   wire [NB_REG-1:0]         if_pc_deco;

   //From decode to fetch
   wire                      deco_nop_reg_if;
   wire [NB_INM_I-1:0]       deco_inm_i_if;
   wire [NB_INM_J-1:0]       deco_inm_j_if;
   wire [NB_REG-1:0]         deco_rs_if;
   wire                      deco_jump_inm_if;
   wire                      deco_jump_rs_if;
   wire                      deco_branch_if;

   //From decode to execution
   wire [NB_MEM-1:0]         deco_mem_ctrl_exec;
   wire [NB_EX-1:0]          deco_ex_ctrl_exec;
   wire [NB_WB-1:0]          deco_wb_ctrl_exec;
   wire [NB_REG-1:0]         deco_pc_exec;
   wire [NB_REG-1:0]         deco_a_exec;
   wire [NB_REG-1:0]         deco_b_exec;
   wire [NB_INM-1:0]         deco_inm_exec;
   wire [NB_SHAMT-1:0]       deco_shamt_exec;

   //From execution to memory access
   wire [NB_REG-1:0]         exec_alu_mem;
   wire [NB_REG-1:0]         exec_b_mem;
   wire [NB_MEM-1:0]         exec_mem_mem;
   wire [NB_WB-1:0]          exec_wb_mem;
   wire [NB_REG-1:0]         exec_pc_mem;

   //From memory access to writeback

   wire [NB_REG-1:0]         mem_reg_wb_wb;
   wire [NB_REG-1:0]         mem_ext_mem_o_wb;
   wire [NB_WB-1:0]          mem_wb_wb;
   wire [NB_REG-1:0]         mem_pc_wb;


   //From writeback to execution (regfile)
   wire [NB_REG_ADDR-1:0]    wb_regfile_addr_deco;
   wire [NB_REG-1:0]         wb_regfile_data_deco;
   wire                      wb_regfile_we_deco;

   assign deco_inm_i_if = deco_inm_exec ;

   instruction_fetch
     #(
       .NB_REG (NB_REG),
       .NB_INSTR (NB_INSTR),
       .N_ADDR (N_ADDR),
       .LOG2_N_INSMEM_ADDR (LOG2_N_INSMEM_ADDR),
       .NB_INM_I (NB_INM_I),
       .NB_INM_J (NB_INM_J)
       )
   u_instruction_fetch
     (
      .o_ir (if_ir_deco),
      .o_pc (if_pc_deco),

      .i_nop_reg (deco_nop_reg_if),
      .i_inm_i (deco_inm_i_if),
      .i_inm_j (deco_inm_j_if),
      .i_rs (deco_rs_if),
      .i_jump_inm (deco_jump_inm_if),
      .i_jump_rs (deco_jump_rs_if),
      .i_branch (deco_branch_if),

      .i_clock (i_clock),
      .i_reset (i_reset),
      .i_valid (i_valid)
      );

   instruction_decode
     #(
       .NB_OPCODE          (NB_OPCODE),
       .NB_FUNCCODE        (NB_FUNCCODE),
       .NB_REG             (NB_REG),
       .NB_REG_ADDR        (NB_REG_ADDR),
       .REGFILE_DEPTH      (REGFILE_DEPTH),
       .NB_INM             (NB_INM),
       .NB_SHAMT           (NB_SHAMT),
       .NB_J_INM           (NB_J_INM),
       .NB_ALUOP           (NB_ALUOP),
       .NB_EX              (NB_EX),
       .NB_MEM             (NB_MEM),
       .NB_WB              (NB_WB)
       )
   u_instruction_decode
     (
      .o_mem_ctrl (deco_mem_ctrl_exec),
      .o_ex_ctrl (deco_ex_ctrl_exec),
      .o_wb_ctrl (deco_wb_ctrl_exec),
      .o_pc (deco_pc_exec),
      .o_a (deco_a_exec),
      .o_b (deco_b_exec),
      
      .o_inm (deco_inm_exec),
      .o_shamt (deco_shamt_exec),
      .o_nop (deco_nop_reg_if),
      .o_branch (deco_branch_if),
      .o_jump_rs (deco_jump_rs_if),
      .o_jump_rs_addr (deco_rs_if),
      .o_jump_inm (deco_jump_inm_if),
      
      .o_jump_inm_addr (deco_inm_j_if),

      .i_instruction (if_ir_deco),
      .i_pc (if_pc_deco),
      .i_regfile_addr (wb_regfile_addr_deco),
      .i_regfile_data (wb_regfile_data_deco),
      .i_regfile_we (wb_regfile_we_deco),

      // .i_valid (i_valid),
      .i_clk (i_clock),
      .i_rst (i_reset)
      );

   execution
     #(
       .NB_REG    (NB_REG),
       .NB_INM    (NB_INM),
       .NB_SHAMT  (NB_SHAMT),
       .NB_EX     (NB_EX),
       .NB_MEM    (NB_MEM),
       .NB_WB     (NB_WB)
       )
   u_execution
     (
      .o_alu (exec_alu_mem),
      .o_b (exec_b_mem),
      .o_mem (exec_mem_mem),
      .o_wb (exec_wb_mem),
      .o_pc (exec_pc_mem),

      .i_a (deco_a_exec),
      .i_b (deco_b_exec),
      .i_inm (deco_inm_exec),
      .i_shamt (deco_shamt_exec),
      .i_ex (deco_ex_ctrl_exec),
      .i_mem (deco_mem_ctrl_exec),
      .i_wb (deco_wb_ctrl_exec),
      .i_pc (deco_pc_exec),

      .i_reset (i_reset),
      .i_clock (i_clock),
      .i_valid (i_valid)
      );

   memory_access
     #(
       .NB_REG (NB_REG),
       .NB_MEM (NB_MEM),
       .NB_WB  (NB_WB)
       )
   u_memory_access
     (
      .o_reg_wb (mem_reg_wb_wb),
      .o_ext_mem_o   (mem_ext_mem_o_wb),
      .o_wb (mem_wb_wb),
      .o_pc (mem_pc_wb),

      .i_alu_o (exec_alu_mem),
      .i_b_o (exec_b_mem),
      .i_mem (exec_mem_mem),
      .i_wb (exec_wb_mem),
      .i_pc (exec_pc_mem),

      .i_reset (i_reset),
      .i_clock (i_clock),
      .i_valid (i_valid)
      );

   write_back
     #(
       .NB_REG (NB_REG),
       .NB_REG_ADDR (NB_REG_ADDR),
       .NB_WB (NB_WB)
       )
   u_write_back
     (
      .o_wb_data (wb_regfile_data_deco),
      .o_reg_dest (wb_regfile_addr_deco),
      .o_reg_we (wb_regfile_we_deco),

      .i_reg_wb (mem_reg_wb_wb),
      .i_ext_mem_o (mem_ext_mem_o_wb),
      .i_wb (mem_wb_wb),
      .i_pc (mem_pc_wb)
      ) ;

   function integer clogb2;
      input integer          depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
   endfunction

endmodule
