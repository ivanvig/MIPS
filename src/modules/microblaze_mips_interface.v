module microblaze_mips_interface
  #(
    parameter NB_CONTROL_FRAME = 32,

    )
   (
    input wire [NB_CONTROL_FRAME-1:0] i_frame_from_blaze,
    input wire [NB_CONTROL_FRAME-1:0] i_frame_from_mips,

    output wire [NB_CONTROL_FRAME-1:0] o_frame_to_blaze,

    )
    // 32 INSTR CODE 26 | 25 ADDR_TYPE 16 | 15 DATA 0 |
    localparam NB_INSTR_CODE = 6;
   localparam NB_INSTR_ADDRESS = 10;
   localparam NB_INSTR_DATA = 16;

   //INSTRUCTION CODES
   localparam START                = 6'b0000_01;
   localparam RESET                = 6'b0000_10;
   localparam LOAD_INSTR_LSB       = 6'b0001_00;
   localparam LOAD_INSTR_MSB       = 6'b0001_01;
   localparam REQ_DATA             = 6'b0000_11;
   localparam MODE_GET             = 6'b0010_00;
   localparam MODE_SET             = 6'b0010_01;
   localparam STEP                 = 6'b1000_00;

   //INSTRUCTION TYPE
   localparam REQ_MEM_DATA         = 10'b0000_0000_01;
   localparam REQ_MEM_INSTR        = 10'b0000_0000_10;
   localparam REQ_REG              = 10'b0000_0001_00;
   localparam REQ_REG_PC           = 10'b0000_0001_01;
   localparam REQ_LATCH_FETCH_DATA = 10'b0000_0010_00;
   localparam REQ_LATCH_FETCH_CTRL = 10'b0000_0010_01;
   localparam REQ_LATCH_DECO_DATA  = 10'b0000_0100_00;
   localparam REQ_LATCH_DECO_CTRL  = 10'b0000_0100_01;
   localparam REQ_LATCH_EXEC_DATA  = 10'b0000_1000_00;
   localparam REQ_LATCH_EXEC_CTRL  = 10'b0000_1000_01;
   localparam REQ_LATCH_MEM_DATA   = 10'b0001_0000_00;
   localparam REQ_LATCH_MEM_CTRL   = 10'b0001_0000_01;



   wire [NB_INSTR_CODE-1:0]           instruction_code;
   wire [NB_ADDRESS-1:0]              address_type;
   wire [NB_DATA-1:0]                 instruction_data;

   assign o_frame_to_blaze = i_frame_from_mips;

   assign {instruction_code, address_type, instruction_data} = i_frame_from_blaze;

    always @(*)
      begin
         casez (instruction_code)
         endcase // casez (instruction_code)
      end
