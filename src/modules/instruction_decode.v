module instruction_decode
  #(
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

    //Instruction code
    localparam R_INST = 6'b0000_00,
    localparam LB   	= 6'b1000_00,
    localparam LH   	= 6'b1000_01,
    localparam LW   	= 6'b1000_11,
    localparam LBU  	= 6'b1001_00,
    localparam LHU  	= 6'b1001_01,
    localparam LWU  	= 6'b1001_11,
    localparam SB   	= 6'b1010_00,
    localparam SH   	= 6'b1010_01,
    localparam SW   	= 6'b1010_11,
    localparam ADDI 	= 6'b0010_01,
    localparam ANDI 	= 6'b0011_00,
    localparam ORI  	= 6'b0011_01,
    localparam XORI 	= 6'b0011_10,
    localparam LUI  	= 6'b0011_11,
    localparam SLTI 	= 6'b0010_10,
    localparam BEQ  	= 6'b0001_00,
    localparam BNE  	= 6'b0001_01,
    localparam J	  	= 6'b0000_10,
    localparam JAL  	= 6'b0000_11,

    //Func code
    localparam FUNC_SLL  = 6'b00_0000,
    localparam FUNC_SRL  = 6'b00_0010,
    localparam FUNC_SRA  = 6'b00_0011,
    localparam FUNC_SLLV = 6'b00_0100,
    localparam FUNC_SRLV = 6'b00_0110,
    localparam FUNC_SRAV = 6'b00_0111,
    localparam FUNC_ADDU = 6'b10_0001,
    localparam FUNC_SUBU = 6'b10_0011,
    localparam FUNC_AND  = 6'b10_0100,
    localparam FUNC_OR   = 6'b10_0101,
    localparam FUNC_XOR  = 6'b10_0110,
    localparam FUNC_NOR  = 6'b10_0111,
    localparam FUNC_SLT  = 6'b10_1010,
    localparam FUNC_JR   = 6'b00_1000,
    localparam FUNC_JALR = 6'b00_1001,


    //ALU code
    localparam ADD = 4'b0000,
    localparam SUB = 4'b0001,
    localparam AND = 4'b0010,
    localparam OR  = 4'b0011,
    localparam XOR = 4'b0100,
    localparam NOR = 4'b0101,
    localparam SRL = 4'b0110,
    localparam SLL = 4'b0111,
    localparam SRA = 4'b1000,
    localparam SLA = 4'b1001,
    localparam SLT = 4'b1010,
    localparam LUI_OP = 4'b1011
    )
   (
    output [NB_MEM-1:0]   o_mem_ctrl,
    output [NB_EX-1:0]    o_ex_ctrl,
    output [NB_WB-1:0]    o_wb_ctrl,
    output [NB_REG-1:0]   o_pc,
    output [NB_REG-1:0]   o_a,
    output [NB_REG-1:0]   o_b,
    output [NB_INM-1:0]   o_inm,
    output [NB_SHAMT-1:0] o_shamt,
    output                o_use_shamt,
    output                o_nop,
    output                o_branch,
    output                o_jump_rs,
    output                o_jump_inm,
    output [NB_J_INM-1:0] o_jump_inm_addr,
   
    input [NB_REG-1:0]    i_instruction,
    input [NB_REG-1:0]    i_pc,
   
    // input               i_valid,
    input                 i_clk,
    input                 i_rst
   
    );
   //
   //////////////////////////////////////////////////////////////////////////////////////////
  // Control Frame Structure:																															//
  //																																											//
  // EX (7 bits):																																					//
  // |6    	   |2  	 |1 	 |0 		 |																											//
  // | ALUCTRL | B/I | S/U | SHAMT |																											//
  //																																											//
  // MEM (5 bits):																																				//
  // |4	  |3	 |2    |1			 |																														//
  // | RE | WE | S/U | DSIZE |																														//
  //																																											//
  // WB (8 bits):																																					//
  // |7		  |2			 |1				 |0				 |																								//
  // | DEST | REG_WE | MEM/ALU | DATA/PC |																								//
  //																																											//
  //////////////////////////////////////////////////////////////////////////////////////////


   // TODO: AGREGAR REGISTER FILE Y LOGICA PARA A Y B




   
   localparam RA_REG_ADDR = {NB_REG_ADDR{1'b0}};

   localparam MSB_INM    = 15;
   localparam MSB_OPCODE = 31;
   localparam MSB_FUNC   = 5;
   localparam MSB_RD     = 15;
   localparam MSB_RT     = 20;
   localparam MSB_RS     = 25;
   localparam MSB_SHAMT  = 10;
   localparam MSB_J_INM  = 25;
   
   reg [NB_REG-1:0]     pc;

   // DEC signals
   wire                 to_ra_reg, use_shamt, use_2nd_lut;
   wire                 is_branch, beq_bne, jrs, jinm;
   // EX signals
   reg [NB_EX-1:0] ex_reg;

   wire [NB_ALUOP-1:0]  aluop;
   wire [NB_ALUOP-1:0]  aluop1, aluop2;
   wire                 s_u_ex, b_i;
   // MEM signals
   reg [NB_MEM-1:0]            mem_reg;
   
   wire                 renb, wenb, s_u_mem;
   wire [1:0]           dsize;
   // WB signals
   reg [NB_WB-1:0] wb_reg;

   wire [NB_REG_ADDR-1:0]  dest;
   wire                    reg_we, mem_alu, data_pc;
   wire                    data_pc1, data_pc2;

   // from instruction
   wire [NB_REG_ADDR-1:0] rt, rd, rs;
   wire [NB_OPCODE-1:0]   opcode;
   wire [NB_FUNCCODE-1:0] func;
   wire [NB_INM-1:0]      inm;
   wire [NB_SHAMT-1:0]    shamt;
   wire [NB_J_INM-1:0]    j_inm_addr;

   // branch
   wire                   comp, branch_result;
   reg                    nop_reg;

   //OUTPUT assign
   assign o_pc            = pc;
   assign o_ex_ctrl       = ex_reg;
   assign o_mem_ctrl      = mem_reg;
   assign o_wb_ctrl       = wb_reg;
   assign o_inm           = inm;
   assign o_nop           = nop_reg;
   assign o_branch        = is_branch;
   assign o_jump_rs       = jrs;
   assign o_jump_inm      = jinm;
   assign o_jump_inm_addr = j_inm_addr;
   assign o_shamt         = shamt;
   assign o_use_shamt     = use_shamt;

   //Instruction values
   assign opcode     = i_instruction[MSB_OPCODE-:NB_OPCODE];
   assign func       = i_instruction[MSB_FUNC-:NB_FUNCCODE];
   assign inm        = i_instruction[MSB_INM-:NB_INM];

   assign rt         = i_instruction[MSB_RT-:NB_REG_ADDR];
   assign rs         = i_instruction[MSB_RS-:NB_REG_ADDR];
   assign rd         = i_instruction[MSB_RD-:NB_REG_ADDR];

   assign shamt      = i_instruction[MSB_SHAMT-:NB_SHAMT];
   assign j_inm_addr = i_instruction[MSB_J_INM-:NB_J_INM];


   //PC
   always @ (posedge i_clk) begin
      if (i_rst)
        pc <= {NB_REG{1'b0}};
      else
        pc <= i_pc;
   end
   // Jump logic
   // TODO [!!!!!!!!!] : no comparar rs y rt, sino el valor de los registros a donde apuntan rs y rt
   assign comp = rs == rt; // <----- MAL
   assign branch_result = beq_bne ? ~comp : comp;

   always @ (posedge i_clk) begin
      if (i_rst)
        nop_reg <= 1'b0;
      else
        nop_reg <= (jrs | jinm | (branch_result & is_branch));
   end

   // EX logic
   assign aluop = use_2nd_lut ? aluop2 : aluop1;

   always @ (posedge i_clk) begin
      if(i_rst)
        ex_reg <= {NB_EX{1'b0}};
      else
        ex_reg <= {aluop, b_i, s_u_ex, shamt};
   end

   // MEM logic
   always @ (posedge i_clk) begin
      if(i_rst)
        mem_reg <= {NB_MEM{1'b0}};
      else
        mem_reg <= {renb, wenb, s_u_mem, dsize};
   end
   // WB logic
   assign dest    = to_ra_reg ? RA_REG_ADDR : (b_i ? rt : rd);
   assign data_pc = use_2nd_lut ? data_pc2 : data_pc1;

   always @ (posedge i_clk) begin
      if(i_rst)
        wb_reg <= {NB_WB{1'b0}};
      else
        wb_reg <= {dest, reg_we, mem_alu, data_pc};
   end
   

   // Main LUT
   always @ (*) begin
      case(opcode)
        R_INST: begin
           assign use_2nd_lut = 1'b1;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne			= 1'b0;
           assign jinm				= 1'b0;

           assign aluop1			= 4'b0000; //use aluop2
           assign b_i 				= 1'b0;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b0;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b00;

           assign reg_we 			= 1'b1;
           assign mem_alu 		= 1'b1;
           assign data_pc1		= 1'b0; // use data_pc2
        end

        LB: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne     = 1'b0;
           assign jinm        = 1'b0;

           assign aluop1			= 4'b0000;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b1;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b00;

           assign reg_we 			= 1'b1;
           assign mem_alu 		= 1'b0;
           assign data_pc1		= 1'b0;
        end

        LH: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne     = 1'b0;
           assign jinm        = 1'b0;

           assign aluop1			= 4'b0000;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b1;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b01;

           assign reg_we 			= 1'b1;
           assign mem_alu 		= 1'b0;
           assign data_pc1		= 1'b0;
        end

        LW: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne     = 1'b0;
           assign jinm        = 1'b0;

           assign aluop1			= 4'b0000;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b1;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b10;

           assign reg_we 			= 1'b1;
           assign mem_alu 		= 1'b0;
           assign data_pc1		= 1'b0;
        end

        LBU: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne     = 1'b0;
           assign jinm        = 1'b0;

           assign aluop1			= 4'b0000;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b1;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b1;
           assign dsize 			= 2'b00;

           assign reg_we 			= 1'b1;
           assign mem_alu 		= 1'b0;
           assign data_pc1		= 1'b0;
        end

        LHU: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne     = 1'b0;
           assign jinm        = 1'b0;

           assign aluop1			= 4'b0000;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b1;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b1;
           assign dsize 			= 2'b01;

           assign reg_we 			= 1'b1;
           assign mem_alu 		= 1'b0;
           assign data_pc1		= 1'b0;
        end

        LWU: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne     = 1'b0;
           assign jinm        = 1'b0;

           assign aluop1			= 4'b0000;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b1;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b1;
           assign dsize 			= 2'b10;

           assign reg_we 			= 1'b1;
           assign mem_alu 		= 1'b0;
           assign data_pc1		= 1'b0;
        end

        SB: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne     = 1'b0;
           assign jinm        = 1'b0;

           assign aluop1			= 4'b0000;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b0;
           assign wenb 				= 1'b1;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b00;

           assign reg_we 			= 1'b0;
           assign mem_alu 		= 1'b0;
           assign data_pc1		= 1'b0;
        end

        SH: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne     = 1'b0;
           assign jinm        = 1'b0;

           assign aluop1			= 4'b0000;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b0;
           assign wenb 				= 1'b1;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b01;

           assign reg_we 			= 1'b0;
           assign mem_alu 		= 1'b0;
           assign data_pc1		= 1'b0;
        end

        SW: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne     = 1'b0;
           assign jinm        = 1'b0;

           assign aluop1			= 4'b0000;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b0;
           assign wenb 				= 1'b1;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b10;

           assign reg_we 			= 1'b0;
           assign mem_alu 		= 1'b0;
           assign data_pc1		= 1'b0;
        end

        ADDI: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne     = 1'b0;
           assign jinm        = 1'b0;

           assign aluop1			= ADD;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b0;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b00;

           assign reg_we 			= 1'b1;
           assign mem_alu 		= 1'b1;
           assign data_pc1		= 1'b0;
        end

        ANDI: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne     = 1'b0;
           assign jinm        = 1'b0;

           assign aluop1			= AND;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b1;

           assign renb 				= 1'b0;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b00;

           assign reg_we 			= 1'b1;
           assign mem_alu 		= 1'b1;
           assign data_pc1		= 1'b0;
        end

        ORI: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne     = 1'b0;
           assign jinm        = 1'b0;

           assign aluop1			= OR;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b1;

           assign renb 				= 1'b0;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b00;

           assign reg_we 			= 1'b1;
           assign mem_alu 		= 1'b1;
           assign data_pc1		= 1'b0;
        end

        XORI: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne     = 1'b0;
           assign jinm        = 1'b0;

           assign aluop1			= XOR;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b1;

           assign renb 				= 1'b0;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b00;

           assign reg_we 			= 1'b1;
           assign mem_alu 		= 1'b1;
           assign data_pc1		= 1'b0;
        end

        LUI: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne     = 1'b0;
           assign jinm        = 1'b0;

           assign aluop1			= LUI_OP;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b1;

           assign renb 				= 1'b0;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b00;

           assign reg_we 			= 1'b1;
           assign mem_alu 		= 1'b1;
           assign data_pc1		= 1'b0;
        end

        SLTI: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne     = 1'b0;
           assign jinm        = 1'b0;

           assign aluop1			= SLT;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b0;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b00;

           assign reg_we 			= 1'b1;
           assign mem_alu 		= 1'b1;
           assign data_pc1		= 1'b0;
        end

        BEQ: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b1;
           assign beq_bne			= 1'b0;
           assign jinm				= 1'b0;

           assign aluop1			= 4'b0000;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b0;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b00;

           assign reg_we 			= 1'b0;
           assign mem_alu 		= 1'b0;
           assign data_pc1		= 1'b0;
        end

        BNE: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b1;
           assign beq_bne			= 1'b1;
           assign jinm				= 1'b0;

           assign aluop1			= 4'b0000;
           assign b_i 				= 1'b1;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b0;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b00;

           assign reg_we 			= 1'b0;
           assign mem_alu 		= 1'b0;
           assign data_pc1		= 1'b0;
        end

        J: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne			= 1'b0;
           assign jinm				= 1'b1;

           assign aluop1			= 4'b0000;
           assign b_i 				= 1'b0;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b0;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b00;

           assign reg_we 			= 1'b0;
           assign mem_alu 		= 1'b0;
           assign data_pc1		= 1'b0;
        end

        JAL: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b1;
           assign is_branch		= 1'b0;
           assign beq_bne			= 1'b0;
           assign jinm				= 1'b1;

           assign aluop1			= 4'b0000;
           assign b_i 				= 1'b0;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b0;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b00;

           assign reg_we 			= 1'b1;
           assign mem_alu 		= 1'b0;
           assign data_pc1		= 1'b1;
        end
        default: begin
           assign use_2nd_lut = 1'b0;

           assign to_ra_reg 	= 1'b0;
           assign is_branch		= 1'b0;
           assign beq_bne			= 1'b0;
           assign jinm				= 1'b0;

           assign aluop1			= 4'b0000;
           assign b_i 				= 1'b0;
           assign s_u_ex 			= 1'b0;

           assign renb 				= 1'b0;
           assign wenb 				= 1'b0;
           assign s_u_mem 		= 1'b0;
           assign dsize 			= 2'b00;

           assign reg_we 			= 1'b0;
           assign mem_alu 		= 1'b0;
           assign data_pc1		= 1'b0;
        end
      endcase
   end

   // 2nd LUT
   always @ (*) begin
      case(func)
        FUNC_SLL: begin
           assign use_shamt = 1'b1;
           assign aluop2    = SLL;
           assign data_pc2  = 1'b0;
           assign jrs       = 1'b0;
        end

        FUNC_SRL: begin
           assign use_shamt = 1'b1;
           assign aluop2    = SRL;
           assign data_pc2  = 1'b0;
           assign jrs       = 1'b0;
        end

        FUNC_SRA: begin
           assign use_shamt = 1'b1;
           assign aluop2    = SRA;
           assign data_pc2  = 1'b0;
           assign jrs       = 1'b0;
        end

        FUNC_SLLV: begin
           assign use_shamt = 1'b0;
           assign aluop2    = SLL;
           assign data_pc2  = 1'b0;
           assign jrs       = 1'b0;
        end

        FUNC_SRLV: begin
           assign use_shamt = 1'b0;
           assign aluop2    = SRL;
           assign data_pc2  = 1'b0;
           assign jrs       = 1'b0;
        end

        FUNC_SRAV: begin
           assign use_shamt = 1'b0;
           assign aluop2    = SRA;
           assign data_pc2  = 1'b0;
           assign jrs       = 1'b0;
        end

        FUNC_ADDU: begin
           assign use_shamt = 1'b0;
           assign aluop2    = ADD;
           assign data_pc2  = 1'b0;
           assign jrs       = 1'b0;
        end

        FUNC_SUBU: begin
           assign use_shamt = 1'b0;
           assign aluop2    = SUB;
           assign data_pc2  = 1'b0;
           assign jrs       = 1'b0;
        end

        FUNC_AND: begin
           assign use_shamt = 1'b0;
           assign aluop2    = AND;
           assign data_pc2  = 1'b0;
           assign jrs       = 1'b0;
        end

        FUNC_OR: begin
           assign use_shamt = 1'b0;
           assign aluop2    = OR;
           assign data_pc2  = 1'b0;
           assign jrs       = 1'b0;
        end

        FUNC_XOR: begin
           assign use_shamt = 1'b0;
           assign aluop2    = XOR;
           assign data_pc2  = 1'b0;
           assign jrs       = 1'b0;
        end

        FUNC_NOR: begin
           assign use_shamt = 1'b0;
           assign aluop2    = NOR;
           assign data_pc2  = 1'b0;
           assign jrs       = 1'b0;
        end

        FUNC_SLT: begin
           assign use_shamt = 1'b0;
           assign aluop2    = SLT;
           assign data_pc2  = 1'b0;
           assign jrs       = 1'b0;
        end

        FUNC_JR: begin
           assign use_shamt = 1'b0;
           assign aluop2    = 4'b000;
           assign data_pc2  = 1'b0;
           assign jrs       = 1'b1;
        end

        FUNC_JALR: begin
           assign use_shamt = 1'b0;
           assign aluop2    = 4'b000;
           assign data_pc2  = 1'b1;
           assign jrs       = 1'b1;
        end

        default: begin
           assign use_shamt = 1'b0;
           assign aluop2    = 4'b000;
           assign data_pc2  = 1'b0;
           assign jrs       = 1'b0;
        end
      endcase
   end
endmodule

