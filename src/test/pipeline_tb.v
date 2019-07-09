module pipeline_tb ();

   localparam NB_REG             = 32;
   localparam NB_INSTR           = 32;
   localparam N_ADDR             = 512;
   localparam LOG2_N_INSMEM_ADDR = clogb2(N_ADDR);
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

   wire                                 tb_valid_i ;   // Throughput control.

   wire [NB_CONTROL_FRAME-1:0]          frame_to_blaze;
   wire [NB_CONTROL_FRAME-1:0]          frame_from_blaze;

   reg                                  tb_reset_i ;
   reg                                  tb_clock_i = 1'b0 ;
   integer                              tb_timer = 0 ;

   pipeline
     #(
      .NB_REG             (NB_REG ),
      .NB_INSTR           (NB_INSTR ),
      .N_ADDR             (N_ADDR ),
      .LOG2_N_INSMEM_ADDR (LOG2_N_INSMEM_ADDR ),
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
   function integer clogb2;
      input integer                   depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
   endfunction // clogb2

endmodule
