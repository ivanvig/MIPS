module top_level
#(
  //instruction_fetch
  parameter NB_REG = 32,
  parameter NB_INSTR = 32,
  parameter NB_ADDR = 32,
  parameter LOG2_N_INSMEM_ADDR = clogb2(N_ADDR),
  parameter NB_INM_I = 16,
  parameter NB_INM_J = 26,

  //instruction_decode
  parameter NB_OPCODE = 6,
  parameter NB_FUNCCODE = NB_OPCODE,
  parameter NB_REG = 32,
  parameter NB_INM = 16,
  parameter NB_SHAMT = 5,
  parameter NB_REG_ADDR = 5,
  parameter NB_J_INM = 26,
  parameter NB_ALUOP = 4,
  parameter NB_EX = NB_ALUOP+3,
  parameter NB_MEM = 5,
  parameter NB_WB = NB_REG_ADDR+3,

  //execution
  parameter NB_REG = 32,
  parameter NB_INM = 16,
  parameter NB_EX = 6,
  parameter NB_MEM = 5,
  parameter NB_WB = 8

  //
)
   (
    );

   
