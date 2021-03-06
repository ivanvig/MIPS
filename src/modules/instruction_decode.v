module instruction_decode
  #(
    parameter NB_OPCODE     = 6,
    parameter NB_FUNCCODE   = NB_OPCODE,
    parameter NB_REG        = 32,
    parameter NB_REG_ADDR   = 5,
    parameter REGFILE_DEPTH = 1 << NB_REG_ADDR,
    parameter NB_INM        = 16,
    parameter NB_SHAMT      = 5,
    parameter NB_J_INM      = 26,
    parameter NB_ALUOP      = 4,
    parameter NB_EX         = NB_ALUOP+3,
    parameter NB_MEM        = 5,
    parameter NB_WB         = NB_REG_ADDR+3,

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
    localparam HLT    = 6'b1111_11,

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
    localparam ADD    = 4'b0000,
    localparam SUB    = 4'b0001,
    localparam AND    = 4'b0010,
    localparam OR     = 4'b0011,
    localparam XOR    = 4'b0100,
    localparam NOR    = 4'b0101,
    localparam SRL    = 4'b0110,
    localparam SLL    = 4'b0111,
    localparam SRA    = 4'b1000,
    localparam SLA    = 4'b1001,
    localparam SLT    = 4'b1010,
    localparam LUI_OP = 4'b1011
    )
   (
    output [NB_MEM-1:0]     o_mem_ctrl,
    output [NB_EX-1:0]      o_ex_ctrl,
    output [NB_WB-1:0]      o_wb_ctrl,
    output [NB_REG-1:0]     o_pc,
    output [NB_REG-1:0]     o_a,
    output [NB_REG-1:0]     o_b,
    output [NB_INM-1:0]     o_inm,
    output [NB_SHAMT-1:0]   o_shamt,
    output                  o_nop,
    output                  o_branch,
    output                  o_branch_result,
    output                  o_jump_rs,
    output [NB_REG-1:0]     o_jump_rs_addr,
    output                  o_jump_inm,
    output [NB_J_INM-1:0]   o_jump_inm_addr,
    output                  o_rinst,
    output                  o_store,
    output                  o_halt,

    //For debug
    output reg [NB_REG-1:0] o_debug_regfile_data,

    input [NB_REG-1:0]      i_instruction,
    input [NB_REG-1:0]      i_pc,
    input [NB_REG_ADDR-1:0] i_regfile_addr,
    input [NB_REG-1:0]      i_regfile_data,
    input                   i_regfile_we,

    input                   i_sc_muxa,
    input                   i_sc_muxb,
    input [NB_REG-1:0]      i_sc_dataa,
    input [NB_REG-1:0]      i_sc_datab,
    input                   i_hazard,

    //For debug
    input [NB_REG_ADDR-1:0] i_debug_regfile_addr,

    input                   i_clk,
    input                   i_rst,
    input                   i_valid
    );
   //
   ///////////////////////////////////////////
   // Control Frame Structure:              //
   //                                       //
   // EX (7 bits):                          //
   // |6        |2    |1    |0      |       //
   // | ALUCTRL | B/I | S/U | SHAMT |       //
   //                                       //
   // MEM (5 bits):                         //
   // |4   |3   |2    |1      |             //
   // | RE | WE | S/U | DSIZE |             //
   //                                       //
   // WB (8 bits):                          //
   // |7     |2       |1        |0        | //
   // | DEST | REG_WE | MEM/ALU | DATA/PC | //
   //                                       //
   ///////////////////////////////////////////

   localparam RA_REG_ADDR = {NB_REG_ADDR{1'b1}};

   localparam MSB_INM     = 15;
   localparam MSB_OPCODE  = 31;
   localparam MSB_FUNC    = 5;
   localparam MSB_RD      = 15;
   localparam MSB_RT      = 20;
   localparam MSB_RS      = 25;
   localparam MSB_SHAMT   = 10;
   localparam MSB_J_INM   = 25;

   reg [NB_REG-1:0]         pc;

   // REG File
   reg [NB_REG-1:0]         regfile [REGFILE_DEPTH-1:0];
   wire [NB_REG-1:0]        regfile_o1;
   wire [NB_REG-1:0]        regfile_o2;

   // DEC signals
   reg                      to_ra_reg, use_shamt, use_2nd_lut;
   reg                      is_branch, beq_bne, jrs, jinm;
   // EX signals
   reg [NB_EX-1:0]          ex_reg;
   reg [NB_INM-1:0]         inm_reg;
   reg [NB_SHAMT-1:0]       shamt_reg;

   wire [NB_ALUOP-1:0]      aluop;
   reg [NB_ALUOP-1:0]       aluop1, aluop2;
   reg                      s_u_ex, b_i;
   // MEM signals
   reg [NB_MEM-1:0]         mem_reg;

   reg                      renb, wenb, s_u_mem;
   reg [1:0]                dsize;
   // WB signals
   reg [NB_WB-1:0]          wb_reg;

   wire                     data_pc;
   wire [NB_REG_ADDR-1:0]   dest;
   reg                      reg_we, mem_alu;
   reg                      data_pc1, data_pc2;

   // from instruction
   wire [NB_REG_ADDR-1:0]   rt, rd, rs;
   wire [NB_OPCODE-1:0]     opcode;
   wire [NB_FUNCCODE-1:0]   func;
   wire [NB_INM-1:0]        inm;
   wire [NB_SHAMT-1:0]      shamt;
   wire [NB_J_INM-1:0]      j_inm_addr;

   // branch
   wire                     comp, branch_result;
   wire [NB_REG-1:0]        compvara, compvarb;
   reg                      nop_reg;
   reg [NB_REG-1:0]         a_reg,b_reg;

   wire                     valid;

   //DEBUG
   always@(posedge i_clk) o_debug_regfile_data <= regfile[i_debug_regfile_addr];

   //OUTPUT assign
   assign o_rinst         = use_2nd_lut;
   assign o_store         = wenb;
   assign o_pc            = pc;
   assign o_ex_ctrl       = ex_reg;
   assign o_mem_ctrl      = mem_reg;
   assign o_wb_ctrl       = wb_reg;
   assign o_inm           = inm_reg;
   assign o_nop           = nop_reg;
   assign o_branch        = is_branch;
   assign o_branch_result = is_branch & branch_result;
   assign o_jump_rs       = jrs&use_2nd_lut;
   assign o_jump_rs_addr  = regfile_o1;
   assign o_jump_inm      = jinm;
   assign o_jump_inm_addr = j_inm_addr;
   assign o_shamt         = shamt_reg;
   assign o_a             = a_reg;
   assign o_b             = b_reg;
   assign o_halt          = valid;

   //Instruction values
   assign opcode     = i_instruction[MSB_OPCODE-:NB_OPCODE];
   assign func       = i_instruction[MSB_FUNC-:NB_FUNCCODE];
   assign inm        = i_instruction[MSB_INM-:NB_INM];

   assign rt         = i_instruction[MSB_RT-:NB_REG_ADDR];
   assign rs         = i_instruction[MSB_RS-:NB_REG_ADDR];
   assign rd         = i_instruction[MSB_RD-:NB_REG_ADDR];

   assign shamt      = i_instruction[MSB_SHAMT-:NB_SHAMT];
   assign j_inm_addr = i_instruction[MSB_J_INM-:NB_J_INM];

   //Halt and debug unit logic
   assign valid = i_valid & ~(opcode==HLT);

   //PC
   always @ (posedge i_clk) begin
      if (i_rst)
        pc <= {NB_REG{1'b0}};
      else if (valid)
        pc <= i_pc;
   end

   // REGFILE
   assign regfile_o1 = regfile[rs];
   assign regfile_o2 = regfile[rt];

   always @ (negedge i_clk) begin

      if (i_rst) begin: reset

         integer index;
         for (index = 0; index < REGFILE_DEPTH; index = index + 1)
           regfile[index] <= {(NB_REG){1'b0}};

      end else begin: no_reset_jeje
         if (valid)
           if (i_regfile_we )//& &i_regfile_addr)
             regfile[i_regfile_addr] <= i_regfile_data;
      end
   end // always @ (negedge i_clk)

   always @ (posedge i_clk)
     begin
        if (i_rst) begin
           a_reg <= {NB_REG{1'b0}};
           b_reg <= {NB_REG{1'b0}};
        end else if (valid) begin
           a_reg <= regfile_o1;
           b_reg <= regfile_o2;
        end
     end


   // Jump logic
   assign compvara = i_sc_muxa ? i_sc_dataa : regfile_o1;
   assign compvarb = i_sc_muxb ? i_sc_datab : regfile_o2;

   assign comp = (compvara == compvarb);
   assign branch_result = beq_bne ? ~comp : comp;

   always @ (posedge i_clk) begin
      if (i_rst) begin
         nop_reg <= 1'b1;
      end else if (valid)begin
         nop_reg <= ((jrs&use_2nd_lut) | jinm | (branch_result & is_branch)) & ~i_hazard;
      end
   end

   // EX logic
   assign aluop = use_2nd_lut ? aluop2 : aluop1;

   always @ (posedge i_clk) begin
      if(i_rst)
        ex_reg <= {NB_EX{1'b0}};
      else if (valid) begin
         ex_reg <= {aluop, b_i, s_u_ex, use_shamt&use_2nd_lut};
         inm_reg <= inm;
         shamt_reg <= shamt;
      end
   end

   // MEM logic
   always @ (posedge i_clk) begin
      if(i_rst)
        mem_reg <= {NB_MEM{1'b0}};
      else if (valid)
        mem_reg <= {renb, wenb, s_u_mem, dsize};
   end

   // WB logic
   assign dest    = to_ra_reg ? RA_REG_ADDR : (b_i ? rt : rd);
   assign data_pc = use_2nd_lut ? data_pc2 : data_pc1;

   always @ (posedge i_clk) begin
      if(i_rst)
        wb_reg <= {NB_WB{1'b0}};
      else if (valid)
        wb_reg <= {dest, reg_we & |dest, mem_alu, data_pc};
   end

   // Main LUT
   always @ (*) begin
      case(opcode)
        R_INST: begin
           use_2nd_lut = 1'b1;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = 4'b0000; //use aluop2
           b_i         = 1'b0;
           s_u_ex      = 1'b0;

           renb        = 1'b0;
           wenb        = 1'b0;
           s_u_mem     = 1'b0;
           dsize       = 2'b00;

           reg_we      = 1'b1;
           mem_alu     = 1'b1;
           data_pc1    = 1'b0; // use data_pc2
        end

        LB: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = 4'b0000;
           b_i         = 1'b1;
           s_u_ex      = 1'b0;

           renb        = 1'b1;
           wenb        = 1'b0;
           s_u_mem     = 1'b0;
           dsize       = 2'b00;

           reg_we      = 1'b1;
           mem_alu     = 1'b0;
           data_pc1    = 1'b0;
        end

        LH: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = 4'b0000;
           b_i         = 1'b1;
           s_u_ex      = 1'b0;

           renb        = 1'b1;
           wenb        = 1'b0;
           s_u_mem     = 1'b0;
           dsize       = 2'b01;

           reg_we      = 1'b1;
           mem_alu     = 1'b0;
           data_pc1    = 1'b0;
        end

        LW: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = 4'b0000;
           b_i         = 1'b1;
           s_u_ex      = 1'b0;

           renb        = 1'b1;
           wenb        = 1'b0;
           s_u_mem     = 1'b0;
           dsize       = 2'b10;

           reg_we      = 1'b1;
           mem_alu     = 1'b0;
           data_pc1    = 1'b0;
        end

        LBU: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = 4'b0000;
           b_i         = 1'b1;
           s_u_ex      = 1'b0;

           renb        = 1'b1;
           wenb        = 1'b0;
           s_u_mem     = 1'b1;
           dsize       = 2'b00;

           reg_we      = 1'b1;
           mem_alu     = 1'b0;
           data_pc1    = 1'b0;
        end

        LHU: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = 4'b0000;
           b_i         = 1'b1;
           s_u_ex      = 1'b0;

           renb        = 1'b1;
           wenb        = 1'b0;
           s_u_mem     = 1'b1;
           dsize       = 2'b01;

           reg_we      = 1'b1;
           mem_alu     = 1'b0;
           data_pc1    = 1'b0;
        end

        LWU: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = 4'b0000;
           b_i         = 1'b1;
           s_u_ex      = 1'b0;

           renb        = 1'b1;
           wenb        = 1'b0;
           s_u_mem     = 1'b1;
           dsize       = 2'b10;

           reg_we      = 1'b1;
           mem_alu     = 1'b0;
           data_pc1    = 1'b0;
        end

        SB: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = 4'b0000;
           b_i         = 1'b1;
           s_u_ex      = 1'b0;

           renb        = 1'b0;
           wenb        = 1'b1;
           s_u_mem     = 1'b0;
           dsize       = 2'b00;

           reg_we      = 1'b0;
           mem_alu     = 1'b0;
           data_pc1    = 1'b0;
        end

        SH: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = 4'b0000;
           b_i         = 1'b1;
           s_u_ex      = 1'b0;

           renb        = 1'b0;
           wenb        = 1'b1;
           s_u_mem     = 1'b0;
           dsize       = 2'b01;

           reg_we      = 1'b0;
           mem_alu     = 1'b0;
           data_pc1    = 1'b0;
        end

        SW: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = 4'b0000;
           b_i         = 1'b1;
           s_u_ex      = 1'b0;

           renb        = 1'b0;
           wenb        = 1'b1;
           s_u_mem     = 1'b0;
           dsize       = 2'b10;

           reg_we      = 1'b0;
           mem_alu     = 1'b0;
           data_pc1    = 1'b0;
        end

        ADDI: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = ADD;
           b_i         = 1'b1;
           s_u_ex      = 1'b0;

           renb        = 1'b0;
           wenb        = 1'b0;
           s_u_mem     = 1'b0;
           dsize       = 2'b00;

           reg_we      = 1'b1;
           mem_alu     = 1'b1;
           data_pc1    = 1'b0;
        end

        ANDI: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = AND;
           b_i         = 1'b1;
           s_u_ex      = 1'b1;

           renb        = 1'b0;
           wenb        = 1'b0;
           s_u_mem     = 1'b0;
           dsize       = 2'b00;

           reg_we      = 1'b1;
           mem_alu     = 1'b1;
           data_pc1    = 1'b0;
        end

        ORI: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = OR;
           b_i         = 1'b1;
           s_u_ex      = 1'b1;

           renb        = 1'b0;
           wenb        = 1'b0;
           s_u_mem     = 1'b0;
           dsize       = 2'b00;

           reg_we      = 1'b1;
           mem_alu     = 1'b1;
           data_pc1    = 1'b0;
        end

        XORI: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = XOR;
           b_i         = 1'b1;
           s_u_ex      = 1'b1;

           renb        = 1'b0;
           wenb        = 1'b0;
           s_u_mem     = 1'b0;
           dsize       = 2'b00;

           reg_we      = 1'b1;
           mem_alu     = 1'b1;
           data_pc1    = 1'b0;
        end

        LUI: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = LUI_OP;
           b_i         = 1'b1;
           s_u_ex      = 1'b1;

           renb        = 1'b0;
           wenb        = 1'b0;
           s_u_mem     = 1'b0;
           dsize       = 2'b00;

           reg_we      = 1'b1;
           mem_alu     = 1'b1;
           data_pc1    = 1'b0;
        end

        SLTI: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = SLT;
           b_i         = 1'b1;
           s_u_ex      = 1'b0;

           renb        = 1'b0;
           wenb        = 1'b0;
           s_u_mem     = 1'b0;
           dsize       = 2'b00;

           reg_we      = 1'b1;
           mem_alu     = 1'b1;
           data_pc1    = 1'b0;
        end

        BEQ: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b1;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = 4'b0000;
           b_i         = 1'b1;
           s_u_ex      = 1'b0;

           renb        = 1'b0;
           wenb        = 1'b0;
           s_u_mem     = 1'b0;
           dsize       = 2'b00;

           reg_we      = 1'b0;
           mem_alu     = 1'b0;
           data_pc1    = 1'b0;
        end

        BNE: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b1;
           beq_bne     = 1'b1;
           jinm        = 1'b0;

           aluop1      = 4'b0000;
           b_i         = 1'b1;
           s_u_ex      = 1'b0;

           renb        = 1'b0;
           wenb        = 1'b0;
           s_u_mem     = 1'b0;
           dsize       = 2'b00;

           reg_we      = 1'b0;
           mem_alu     = 1'b0;
           data_pc1    = 1'b0;
        end

        J: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b1;

           aluop1      = 4'b0000;
           b_i         = 1'b0;
           s_u_ex      = 1'b0;

           renb        = 1'b0;
           wenb        = 1'b0;
           s_u_mem     = 1'b0;
           dsize       = 2'b00;

           reg_we      = 1'b0;
           mem_alu     = 1'b0;
           data_pc1    = 1'b0;
        end

        JAL: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b1;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b1;

           aluop1      = 4'b0000;
           b_i         = 1'b0;
           s_u_ex      = 1'b0;

           renb        = 1'b0;
           wenb        = 1'b0;
           s_u_mem     = 1'b0;
           dsize       = 2'b00;

           reg_we      = 1'b1;
           mem_alu     = 1'b0;
           data_pc1    = 1'b1;
        end
        default: begin
           use_2nd_lut = 1'b0;

           to_ra_reg   = 1'b0;
           is_branch   = 1'b0;
           beq_bne     = 1'b0;
           jinm        = 1'b0;

           aluop1      = 4'b0000;
           b_i         = 1'b0;
           s_u_ex      = 1'b0;

           renb        = 1'b0;
           wenb        = 1'b0;
           s_u_mem     = 1'b0;
           dsize       = 2'b00;

           reg_we      = 1'b0;
           mem_alu     = 1'b0;
           data_pc1    = 1'b0;
        end
      endcase
   end

   // 2nd LUT
   always @ (*) begin
      case(func)
        FUNC_SLL: begin
           use_shamt = 1'b1;
           aluop2    = SLL;
           data_pc2  = 1'b0;
           jrs       = 1'b0;
        end

        FUNC_SRL: begin
           use_shamt = 1'b1;
           aluop2    = SRL;
           data_pc2  = 1'b0;
           jrs       = 1'b0;
        end

        FUNC_SRA: begin
           use_shamt = 1'b1;
           aluop2    = SRA;
           data_pc2  = 1'b0;
           jrs       = 1'b0;
        end

        FUNC_SLLV: begin
           use_shamt = 1'b0;
           aluop2    = SLL;
           data_pc2  = 1'b0;
           jrs       = 1'b0;
        end

        FUNC_SRLV: begin
           use_shamt = 1'b0;
           aluop2    = SRL;
           data_pc2  = 1'b0;
           jrs       = 1'b0;
        end

        FUNC_SRAV: begin
           use_shamt = 1'b0;
           aluop2    = SRA;
           data_pc2  = 1'b0;
           jrs       = 1'b0;
        end

        FUNC_ADDU: begin
           use_shamt = 1'b0;
           aluop2    = ADD;
           data_pc2  = 1'b0;
           jrs       = 1'b0;
        end

        FUNC_SUBU: begin
           use_shamt = 1'b0;
           aluop2    = SUB;
           data_pc2  = 1'b0;
           jrs       = 1'b0;
        end

        FUNC_AND: begin
           use_shamt = 1'b0;
           aluop2    = AND;
           data_pc2  = 1'b0;
           jrs       = 1'b0;
        end

        FUNC_OR: begin
           use_shamt = 1'b0;
           aluop2    = OR;
           data_pc2  = 1'b0;
           jrs       = 1'b0;
        end

        FUNC_XOR: begin
           use_shamt = 1'b0;
           aluop2    = XOR;
           data_pc2  = 1'b0;
           jrs       = 1'b0;
        end

        FUNC_NOR: begin
           use_shamt = 1'b0;
           aluop2    = NOR;
           data_pc2  = 1'b0;
           jrs       = 1'b0;
        end

        FUNC_SLT: begin
           use_shamt = 1'b0;
           aluop2    = SLT;
           data_pc2  = 1'b0;
           jrs       = 1'b0;
        end

        FUNC_JR: begin
           use_shamt = 1'b0;
           aluop2    = 4'b000;
           data_pc2  = 1'b0;
           jrs       = 1'b1;
        end

        FUNC_JALR: begin
           use_shamt = 1'b0;
           aluop2    = 4'b000;
           data_pc2  = 1'b1;
           jrs       = 1'b1;
        end

        default: begin
           use_shamt = 1'b0;
           aluop2    = 4'b000;
           data_pc2  = 1'b0;
           jrs       = 1'b0;
        end
      endcase
   end
endmodule
