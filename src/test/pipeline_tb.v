module pipeline_tb ();
   localparam NB_REG             = 32;
   localparam NB_INSTR           = 32;
   localparam N_ADDR             = 512;
   localparam NB_INM_I           = 16;
   localparam NB_INM_J           = 26;
   localparam NB_OPCODE          = 6;
   localparam NB_FUNCCODE        = NB_OPCODE;
   localparam NB_INM             = 16;
   localparam NB_SHAMT           = 5;
   localparam NB_REG_ADDR        = 5;
   localparam NB_J_INM           = 26;
   localparam NB_ALUOP           = 4;
   localparam NB_EX              = NB_ALUOP+3;
   localparam NB_MEM             = 5;
   localparam NB_WB              = NB_REG_ADDR+3;
   localparam REGFILE_DEPTH      = 32;

   //microblaze-mips interface
   localparam NB_CONTROL_FRAME             = 32;
   localparam NB_ADDR_DATA                 = 16;
   localparam NB_INSTR_ADDR                = 9;

   //debug controllers
   localparam NB_LATCH                     = 32;

   localparam NB_FETCH_DATA_INPUT_SIZE     = 32; //IR
   localparam NB_FETCH_CONTROL_INPUT_SIZE  = 64; //PC+(PC+4)
   localparam NB_DECODE_DATA_INPUT_SIZE    = 85; //SHAMT+A+B+INM=5+32+32+16
   localparam NB_DECODE_CONTROL_INPUT_SIZE = 52; //EX+MEM+WB+(PC+4) = 7+5+8+32
   localparam NB_EXEC_DATA_INPUT_SIZE      = 64; //ALU_O+B_O = 32+32
   localparam NB_EXEC_CONTROL_INPUT_SIZE   = 45; //MEM+WB+(PC+4) = 5+8+32
   localparam NB_MEM_DATA_INPUT_SIZE       = 64; //REG_WE+EXT_MEM_O = 32+32
   localparam NB_MEM_CONTROL_INPUT_SIZE    = 40; //WB+(PC+4) = 8+32
   localparam NB_INSTR_MEMORY_INPUT_SIZE   = 32;
   localparam NB_DATA_MEMORY_INPUT_SIZE    = 32;
   localparam NB_REGFILE_INPUT_SIZE        = 32;
   localparam CONTROLLER_FETCH_DATA_ID     = 6'b1001_00;
   localparam CONTROLLER_FETCH_CONTROL_ID  = 6'b1001_01;
   localparam CONTROLLER_DECODE_DATA_ID    = 6'b1001_10;
   localparam CONTROLLER_DECODE_CONTROL_ID = 6'b1001_11;
   localparam CONTROLLER_EXEC_DATA_ID      = 6'b1010_00;
   localparam CONTROLLER_EXEC_CONTROL_ID   = 6'b1010_01;
   localparam CONTROLLER_MEM_DATA_ID       = 6'b1010_10;
   localparam CONTROLLER_MEM_CONTROL_ID    = 6'b1010_11;
   localparam CONTROLLER_INSTR_MEMORY_ID   = 6'b1000_01;
   localparam CONTROLLER_DATA_MEMORY_ID    = 6'b1000_00;
   localparam CONTROLLER_REGFILE_ID        = 6'b0000_00;

   localparam INSTR_FILE         = "output.mem";
   localparam DATA_FILE          = "";

   //INSTRUCTION CODES
   localparam START                = 6'b0000_01;
   localparam RESET                = 6'b0000_10;
   localparam LOAD_INSTR_LSB       = 6'b0001_00;
   localparam LOAD_INSTR_MSB       = 6'b0001_01;
   localparam REQ_DATA             = 6'b0000_11;
   localparam MODE_GET             = 6'b0010_00;
   localparam MODE_SET_CONT        = 6'b0010_01;
   localparam MODE_SET_STEP        = 6'b0010_10;
   localparam STEP                 = 6'b1000_00;
   localparam GOT_DATA             = 6'b1001_00;
   localparam GIB_DATA             = 6'b1001_01;

   //INSTRUCTION TYPE
   localparam REQ_MEM_DATA         = 9'b000_0000_01;
   localparam REQ_MEM_INSTR        = 9'b000_0000_10;
   localparam REQ_REG              = 9'b000_0001_00;
   localparam REQ_REG_PC           = 9'b000_0001_01;
   localparam REQ_LATCH_FETCH_DATA = 9'b000_0010_00;
   localparam REQ_LATCH_FETCH_CTRL = 9'b000_0010_01;
   localparam REQ_LATCH_DECO_DATA  = 9'b000_0100_00;
   localparam REQ_LATCH_DECO_CTRL  = 9'b000_0100_01;
   localparam REQ_LATCH_EXEC_DATA  = 9'b000_1000_00;
   localparam REQ_LATCH_EXEC_CTRL  = 9'b000_1000_01;
   localparam REQ_LATCH_MEM_DATA   = 9'b001_0000_00;
   localparam REQ_LATCH_MEM_CTRL   = 9'b001_0000_01;


   wire                                 tb_valid_i ;   // Throughput control.

   wire [NB_CONTROL_FRAME-1:0]          frame_to_blaze;
   wire [NB_CONTROL_FRAME-1:0]          frame_from_blaze;

   reg                                  tb_reset_i ;
   reg                                  tb_clock_i = 1'b0 ;
   integer                              tb_timer = 0 ;

   reg [6-1:0]                          instruction_code;
   reg                                  instruction_valid;
   reg [9-1:0]                          addr_type;
   reg [16-1:0]                         address;

   pipeline
     #(
       .NB_REG             (NB_REG ),
       .NB_INSTR           (NB_INSTR ),
       .N_ADDR             (N_ADDR ),
       .NB_INM_I           (NB_INM_I ),
       .NB_INM_J           (NB_INM_J ),
       .NB_OPCODE          (NB_OPCODE ),
       .NB_FUNCCODE        (NB_FUNCCODE ),
       .NB_INM             (NB_INM ),
       .NB_SHAMT           (NB_SHAMT ),
       .NB_REG_ADDR        (NB_REG_ADDR ),
       .NB_J_INM           (NB_J_INM ),
       .NB_ALUOP           (NB_ALUOP ),
       .NB_EX              (NB_EX ),
       .NB_MEM             (NB_MEM ),
       .NB_WB              (NB_WB ),
       .REGFILE_DEPTH      (REGFILE_DEPTH ),
       .INSTR_FILE         (INSTR_FILE),
       .DATA_FILE          (DATA_FILE)
       )
   u_pipeline
     (
      .o_frame_to_blaze   (frame_to_blaze),
      .i_frame_from_blaze (frame_from_blaze),
      .i_clock            (tb_clock_i),
      .i_valid            (tb_valid_i),
      .i_reset            (tb_reset_i)
      ) ;

   initial begin
      #(20) tb_reset_i = 1'b1;
      #(120) tb_reset_i = 1'b0;
   end

   always
     begin
        #(50) tb_clock_i = ~tb_clock_i ;
     end

   always @ ( posedge tb_clock_i )
     begin
        tb_timer   <= tb_timer + 1;
     end

   assign tb_valid_i = 1'b1 ;

   assign frame_from_blaze = {instruction_code,instruction_valid,addr_type,address};

   always @ (*)
     begin
        case(tb_timer)
          2: begin
             instruction_code = 6'b0000_10; //RESET
             instruction_valid = 1'b1;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
          3: begin
             instruction_code = 6'b0000_10;
             instruction_valid = 1'b1;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
          5: begin
             instruction_code = MODE_GET; //MODE_GET
             instruction_valid = 1'b1;
             addr_type = REQ_MEM_INSTR;
             address= 16'b0000_0000_0000;
          end
          6: begin
             instruction_code = MODE_GET;
             instruction_valid = 1'b1;
             addr_type = REQ_MEM_INSTR;
             address= 16'b0000_0000_0000;
          end
          // 8: begin
          //    instruction_code = MODE_SET_STEP;
          //    instruction_valid = 1'b1;
          //    addr_type = REQ_MEM_INSTR;
          //    address= 16'b0000_0000_0000;
          // end
          // 9: begin
          //    instruction_code = MODE_SET_STEP;
          //    instruction_valid = 1'b1;
          //    addr_type = REQ_MEM_INSTR;
          //    address= 16'b0000_0000_0000;
          // end
          11: begin
             instruction_code = MODE_GET; //MODE_GET
             instruction_valid = 1'b1;
             addr_type = REQ_MEM_INSTR;
             address= 16'b0000_0000_0000;
          end
          12: begin
             instruction_code = MODE_GET;
             instruction_valid = 1'b1;
             addr_type = REQ_MEM_INSTR;
             address= 16'b0000_0000_0000;
          end
          15: begin
             instruction_code = 6'b0000_01; //START
             instruction_valid = 1'b1;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
          16: begin
             instruction_code = 6'b0000_01;
             instruction_valid = 1'b1;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
          22: begin
             instruction_code = REQ_DATA; //REQ_MEM_INSTR
             instruction_valid = 1'b1;
             addr_type = REQ_MEM_INSTR;
             address= 16'b0000_0000_0000;
          end
          23: begin
             instruction_code = REQ_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_MEM_INSTR;
             address= 16'b0000_0000_0000;
          end
          24: begin
             instruction_code = REQ_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_MEM_INSTR;
             address= 16'b0000_0000_0000;
          end
          30: begin
             instruction_code = GOT_DATA; //GOT_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          31: begin
             instruction_code = GOT_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          32: begin
             instruction_code = GOT_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          34: begin
             instruction_code = GIB_DATA; //GIB_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          35: begin
             instruction_code = GIB_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          36: begin
             instruction_code = GIB_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          40: begin
             instruction_code = REQ_DATA; //REQ_MEM_INSTR
             instruction_valid = 1'b1;
             addr_type = REQ_MEM_INSTR;
             address= 16'b0000_0000_0001;
          end
          41: begin
             instruction_code = REQ_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_MEM_INSTR;
             address= 16'b0000_0000_0001;
          end
          42: begin
             instruction_code = REQ_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_MEM_INSTR;
             address= 16'b0000_0000_0001;
          end
          45: begin
             instruction_code = GOT_DATA; //GOT_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          46: begin
             instruction_code = GOT_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          47: begin
             instruction_code = GOT_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          50: begin
             instruction_code = GIB_DATA; //GIB_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          51: begin
             instruction_code = GIB_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          52: begin
             instruction_code = GIB_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          55: begin
             instruction_code = REQ_DATA; //REQ_LATCH_FETCH_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_FETCH_CTRL;
             address= 16'b0000_0000_0001;
          end
          56: begin
             instruction_code = REQ_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_FETCH_CTRL;
             address= 16'b0000_0000_0001;
          end
          58: begin
             instruction_code = GOT_DATA; //GOT_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          59: begin
             instruction_code = GOT_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          61: begin
             instruction_code = GIB_DATA; //GIB_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          62: begin
             instruction_code = GIB_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          64: begin
             instruction_code = GOT_DATA; //GOT_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          65: begin
             instruction_code = GOT_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          67: begin
             instruction_code = GIB_DATA; //GIB_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          68: begin
             instruction_code = GIB_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          70: begin
             instruction_code = REQ_DATA; //REQ_LATCH_FETCH_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_FETCH_CTRL;
             address= 16'b0000_0000_0001;
          end
          71: begin
             instruction_code = REQ_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_FETCH_CTRL;
             address= 16'b0000_0000_0001;
          end
          74: begin
             instruction_code = GOT_DATA; //GOT_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          75: begin
             instruction_code = GOT_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          77: begin
             instruction_code = GIB_DATA; //GIB_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          78: begin
             instruction_code = GIB_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          80: begin
             instruction_code = GOT_DATA; //GOT_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          81: begin
             instruction_code = GOT_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          83: begin
             instruction_code = GIB_DATA; //GIB_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          84: begin
             instruction_code = GIB_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          86: begin
             instruction_code = REQ_DATA; //REQ_DATA_MEM
             instruction_valid = 1'b1;
             addr_type = REQ_MEM_DATA;
             address= 16'b0000_0000_0000;
          end
          87: begin
             instruction_code = REQ_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_MEM_DATA;
             address= 16'b0000_0000_0000;
          end
          89: begin
             instruction_code = GOT_DATA; //GOT_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          90: begin
             instruction_code = GOT_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          92: begin
             instruction_code = GIB_DATA; //GIB_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          93: begin
             instruction_code = GIB_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          95: begin
             instruction_code = REQ_DATA; //REQ_DATA_MEM
             instruction_valid = 1'b1;
             addr_type = REQ_MEM_DATA;
             address= 16'b0000_0000_0010;
          end
          96: begin
             instruction_code = REQ_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_MEM_DATA;
             address= 16'b0000_0000_0010;
          end
          98: begin
             instruction_code = GOT_DATA; //GOT_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          99: begin
             instruction_code = GOT_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          101: begin
             instruction_code = GIB_DATA; //GIB_DATA
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          102: begin
             instruction_code = GIB_DATA;
             instruction_valid = 1'b1;
             addr_type = REQ_LATCH_DECO_DATA;
             address= 16'b0000_0000_0001;
          end
          default: begin
             instruction_code = 6'b0010_10; //NADA2
             instruction_valid = 1'b0;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
        endcase
     end

   function integer clogb2;
      input integer                   depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
   endfunction // clogb2

endmodule
