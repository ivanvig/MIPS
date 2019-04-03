module pipeline_tb #();

   localparam NB_REG             = 32;
   localparam NB_INSTR           = 32;
   localparam N_ADDR             = 32;
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
   localparam INSTR_FILE         = "/home/jsoriano/ArqDeComputadoras/TP_FINAL/src/output";
   localparam DATA_FILE          = "";

   wire                                 tb_valid_i ;   // Throughput control.

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
      .i_clock            (tb_clock_i),
      .i_valid            (tb_valid_i),
      .i_reset            (tb_reset_i)
      ) ;
      
    initial begin
    #(20) tb_reset_i = 1'b1;
    #(60) tb_reset_i = 1'b0;
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
