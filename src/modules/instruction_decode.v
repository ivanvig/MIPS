module instruction_decode
  #(
    parameter NB_OPCODE = 6,
    parameter NB_REG = 32,
    parameter NB_INM = 16,
    parameter NB_ALUOP = 5,
    parameter NB_EX = NB_ALUOP+2,
    parameter NB_MEM = 0,
    parameter NB_WB = 0,

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
    localparam JAL  	= 6'b0000_11

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
    localparam LUI = 4'b1011
    )
   (
    output [NB_MEM-1:0] o_mem_ctrl,
    output [NB_EX-1:0]  o_ex_ctrl,
    output [NB_WB-1:0]  o_wb_ctrl,
    output [NB_REG-1:0] o_pc,
    output [NB_REG-1:0] o_a,
    output [NB_REG-1:0] o_b,
    output [NB_INM-1:0] o_inm,
    output              o_nop,
    
    input [NB_REG-1:0]  i_instruction,
    input [NB_REG-1:0]  i_pc,

    // input               i_valid,
    input               i_clk,
    input               i_rst
    
    );

  //////////////////////////////////////////////////////////////////////////////////////////
  // Control Frame Structure:																															//
  //																																											//
  // EX (7 bits):																																					//
  // |6      |1  |0  |																																		//
  // |ALUCTRL|B/I|S/U|																																		//
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
   

   // DEC signals
   wire                 to_ra_reg, use_shamt, use_2nd_lut;
   wire                 is_branch, beq_bne, jrs, jinm;
   // EX signals
   wire [NB_ALUOP-1:0]  aluop;
   wire [NB_ALUOP-1:0]  aluop1, aluop2;
   wire                 s_u_ex, b_i;
   // MEM signals
   wire                 renb, wenb, s_u_mem;
   wire [1:0]           dsize;
   // WB signals
   wire                 reg_we, mem_alu, data_pc;
   wire                 data_pc1, data_pc2;

   
   wire [NB_OPCODE-1:0] opcode;


   
   assign opcode = i_instruction[NB_REG-1-:NB_OPCODE];
   
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
           assign beq_bne	= 1'b0;
           assign jinm		= 1'b0;

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
           assign beq_bne	= 1'b0;
           assign jinm		= 1'b0;

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
           assign beq_bne	= 1'b0;
           assign jinm		= 1'b0;

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
           assign beq_bne	= 1'b0;
           assign jinm		= 1'b0;

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
           assign beq_bne	= 1'b0;
           assign jinm		= 1'b0;

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
           assign beq_bne	= 1'b0;
           assign jinm		= 1'b0;

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
           assign beq_bne	= 1'b0;
           assign jinm		= 1'b0;

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
           assign beq_bne	= 1'b0;
           assign jinm		= 1'b0;

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
           assign beq_bne	= 1'b0;
           assign jinm		= 1'b0;

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
           assign beq_bne	= 1'b0;
           assign jinm		= 1'b0;

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
           assign beq_bne	= 1'b0;
           assign jinm		= 1'b0;

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
           assign beq_bne	= 1'b0;
           assign jinm		= 1'b0;

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
           assign beq_bne	= 1'b0;
           assign jinm		= 1'b0;

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
           assign beq_bne	= 1'b0;
           assign jinm		= 1'b0;

           assign aluop1			= LUI;
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
           assign beq_bne	= 1'b0;
           assign jinm		= 1'b0;

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
      endcase
      
   end

   @(*)
   always @(posedge i_clk) begin
   end
   
endmodule

