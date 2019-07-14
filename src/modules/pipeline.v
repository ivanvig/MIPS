module pipeline
  #(
    parameter NB_REG                       = 32,
    parameter NB_INSTR                     = 32,
    parameter N_ADDR                       = 2048,
    parameter NB_INM_I                     = 16,
    parameter NB_INM_J                     = 26,
    parameter NB_OPCODE                    = 6,
    parameter NB_FUNCCODE                  = NB_OPCODE,
    parameter NB_INM                       = 16,
    parameter NB_SHAMT                     = 5,
    parameter NB_REG_ADDR                  = 5,
    parameter NB_J_INM                     = 26,
    parameter NB_ALUOP                     = 4,
    parameter NB_EX                        = NB_ALUOP+3,
    parameter NB_MEM                       = 5,
    parameter NB_WB                        = NB_REG_ADDR+3,
    parameter REGFILE_DEPTH                = 32,

    //microblaze-mips interface
    parameter NB_CONTROL_FRAME             = 32,
    parameter NB_ADDR_DATA                 = 16,
    parameter NB_INSTR_ADDR                = 9,

    //debug controllers
    parameter NB_LATCH                     = 32,

    parameter NB_FETCH_DATA_INPUT_SIZE     = 32, //IR
    parameter NB_FETCH_CONTROL_INPUT_SIZE  = 64, //PC+(PC+4)
    parameter NB_DECODE_DATA_INPUT_SIZE    = 85, //SHAMT+A+B+INM=5+32+32+16
    parameter NB_DECODE_CONTROL_INPUT_SIZE = 52, //EX+MEM+WB+(PC+4) = 7+5+8+32
    parameter NB_EXEC_DATA_INPUT_SIZE      = 64, //ALU_O+B_O = 32+32
    parameter NB_EXEC_CONTROL_INPUT_SIZE   = 45, //MEM+WB+(PC+4) = 5+8+32
    parameter NB_MEM_DATA_INPUT_SIZE       = 64, //REG_WE+EXT_MEM_O = 32+32
    parameter NB_MEM_CONTROL_INPUT_SIZE    = 40, //WB+(PC+4) = 8+32
    parameter NB_INSTR_MEMORY_INPUT_SIZE   = 32,
    parameter NB_DATA_MEMORY_INPUT_SIZE    = 32,
    parameter NB_REGFILE_INPUT_SIZE        = 32,
    parameter CONTROLLER_FETCH_DATA_ID     = 6'b1001_00,
    parameter CONTROLLER_FETCH_CONTROL_ID  = 6'b1001_01,
    parameter CONTROLLER_DECODE_DATA_ID    = 6'b1001_10,
    parameter CONTROLLER_DECODE_CONTROL_ID = 6'b1001_11,
    parameter CONTROLLER_EXEC_DATA_ID      = 6'b1010_00,
    parameter CONTROLLER_EXEC_CONTROL_ID   = 6'b1010_01,
    parameter CONTROLLER_MEM_DATA_ID       = 6'b1010_10,
    parameter CONTROLLER_MEM_CONTROL_ID    = 6'b1010_11,
    parameter CONTROLLER_INSTR_MEMORY_ID   = 6'b1000_01,
    parameter CONTROLLER_DATA_MEMORY_ID    = 6'b1000_00,
    parameter CONTROLLER_REGFILE_ID        = 6'b0000_00,

    //Files
    parameter INSTR_FILE                   = "",
    parameter DATA_FILE                    = ""
    )

   (
    output wire [NB_CONTROL_FRAME-1:0] o_frame_to_blaze,
    input wire [NB_CONTROL_FRAME-1:0 ] i_frame_from_blaze,

    input wire                         i_clock,
    input wire                         i_valid,
    input wire                         i_reset
    );

   localparam MSB_RT            = 20;
   localparam MSB_RS            = 25;
   localparam MSB_OPCODE        = 31;
   //From fetch to decode
   wire [NB_INSTR-1:0]       if_ir_deco;
   wire [NB_REG-1:0]         if_system_pc;
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

   wire hazard;
   wire [NB_REG-1:0] sc_dataa_ex;
   wire [NB_REG-1:0] sc_datab_ex;

   wire [NB_REG-1:0] sc_datajmp_if;
   wire              sc_muxjmp_if;

   wire sc_muxa_ex;
   wire sc_muxb_ex;

   wire deco_store_sc;
   wire deco_rinst_sc;

   wire sc_muxa_deco;
   wire sc_muxb_deco;
   wire [NB_REG-1:0] sc_dataa_deco;
   wire [NB_REG-1:0] sc_datab_deco;

   wire [NB_INSTR-1:0] mux_ir_deco;

   wire                deco_isbrancho_sc;
   wire                deco_halt;
   //For debug blocks
   //Interface
   wire                        interface_valid;
   wire                        interface_reset;
   wire [NB_ADDR_DATA-1:0]     interface_instrmem_data;
   wire [NB_ADDR_DATA-1:0]     interface_instrmem_addr;
   wire [4-1:0]                interface_instrmem_we;
   wire [NB_ADDR_DATA-1:0]     interface_datamem_addr;
   wire [6-1:0]                interface_read_request_to_controllers;
   wire                        debug_endofdata_interface;
   wire                        debug_endofprogram_interface;
   reg [NB_CONTROL_FRAME-1:0]  debugmux_interface;

   wire                                    debug_instr_mem_re;
   wire                                    debug_data_mem_re;
   wire [5-1:0]                            debug_regfile_addr;

   wire [NB_FETCH_DATA_INPUT_SIZE-1:0    ] fetch_data_to_debug_unit;
   wire [NB_FETCH_CONTROL_INPUT_SIZE-1:0 ] fetch_control_to_debug_unit;
   wire [NB_DECODE_DATA_INPUT_SIZE-1:0   ] decode_data_to_debug_unit;
   wire [NB_DECODE_CONTROL_INPUT_SIZE-1:0] decode_control_to_debug_unit;
   wire [NB_EXEC_DATA_INPUT_SIZE-1:0     ] exec_data_to_debug_unit;
   wire [NB_EXEC_CONTROL_INPUT_SIZE-1:0  ] exec_control_to_debug_unit;
   wire [NB_MEM_DATA_INPUT_SIZE-1:0      ] mem_data_to_debug_unit;
   wire [NB_MEM_CONTROL_INPUT_SIZE-1:0   ] mem_control_to_debug_unit;
   wire [NB_INSTR_MEMORY_INPUT_SIZE-1:0  ] instr_mem_to_debug_unit;
   wire [NB_DATA_MEMORY_INPUT_SIZE-1:0   ] data_mem_to_debug_unit;
   wire [NB_REGFILE_INPUT_SIZE-1:0       ] regfile_to_debug_unit;

   wire [NB_CONTROL_FRAME-1:0]             fetch_data_to_mux;
   wire [NB_CONTROL_FRAME-1:0]             fetch_control_to_mux;
   wire [NB_CONTROL_FRAME-1:0]             decode_data_to_mux;
   wire [NB_CONTROL_FRAME-1:0]             decode_control_to_mux;
   wire [NB_CONTROL_FRAME-1:0]             exec_data_to_mux;
   wire [NB_CONTROL_FRAME-1:0]             exec_control_to_mux;
   wire [NB_CONTROL_FRAME-1:0]             mem_data_to_mux;
   wire [NB_CONTROL_FRAME-1:0]             mem_control_to_mux;
   wire [NB_CONTROL_FRAME-1:0]             instr_mem_to_mux;
   wire [NB_CONTROL_FRAME-1:0]             data_mem_to_mux;
   wire [NB_CONTROL_FRAME-1:0]             regfile_to_mux;

   wire                                    fetch_data_controller_writing;
   wire                                    fetch_control_controller_writing;
   wire                                    decode_data_controller_writing;
   wire                                    decode_control_controller_writing;
   wire                                    exec_data_controller_writing;
   wire                                    exec_control_controller_writing;
   wire                                    mem_data_controller_writing;
   wire                                    mem_control_controller_writing;
   wire                                    instr_mem_controller_writing;
   wire                                    data_mem_controller_writing;
   wire                                    regfile_controller_writing;

   wire                                    reset;

   assign reset = i_reset | interface_reset;

   assign deco_inm_i_if = deco_inm_exec ;
   assign mux_ir_deco = (hazard | deco_nop_reg_if) ? 32'h0000_0000 : if_ir_deco;

   assign fetch_data_to_debug_unit= if_ir_deco;
   assign fetch_control_to_debug_unit= {if_system_pc,if_pc_deco};
   assign decode_data_to_debug_unit= {deco_shamt_exec, deco_a_exec, deco_b_exec, deco_inm_exec};
   assign decode_control_to_debug_unit= {deco_ex_ctrl_exec, deco_mem_ctrl_exec, deco_wb_ctrl_exec, deco_pc_exec};
   assign exec_data_to_debug_unit= {exec_alu_mem, exec_b_mem};
   assign exec_control_to_debug_unit= {exec_mem_mem, exec_wb_mem, exec_pc_mem};
   assign mem_data_to_debug_unit= {mem_reg_wb_wb, mem_ext_mem_o_wb};
   assign mem_control_to_debug_unit= {mem_wb_wb, mem_pc_wb};

   instruction_fetch
     #(
       .NB_REG             (NB_REG),
       .NB_INSTR           (NB_INSTR),
       .N_ADDR             (N_ADDR),
       .NB_INM_I           (NB_INM_I),
       .NB_INM_J           (NB_INM_J),
       .INSTR_FILE         (INSTR_FILE)
       )
   u_instruction_fetch
      (
      .o_ir                (if_ir_deco),
      .o_pc                (if_pc_deco),
      .o_debug_instrmem_data (instr_mem_to_debug_unit),
      .o_debug_system_pc  (if_system_pc),

      .i_inm_i             (deco_inm_j_if[NB_INM_I-1:0]),
      .i_inm_j             (deco_inm_j_if),
      .i_rs                (sc_muxa_deco ? sc_dataa_deco : deco_rs_if),
      .i_hazard            (hazard),
      .i_jump_inm          (deco_jump_inm_if),
      .i_jump_rs           (deco_jump_rs_if),
      .i_branch            (deco_branch_if),

      .i_debug_instrmem_addr (interface_instrmem_addr),
      .i_debug_instrmem_data (interface_instrmem_data),
      .i_debug_instrmem_we   (interface_instrmem_we),
      .i_debug_instrmem_re   (debug_instr_mem_re),

      .i_clock             (i_clock),
      .i_reset             (reset),
      .i_valid             (deco_halt)
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
      .o_mem_ctrl      (deco_mem_ctrl_exec),
      .o_ex_ctrl       (deco_ex_ctrl_exec),
      .o_wb_ctrl       (deco_wb_ctrl_exec),
      .o_pc            (deco_pc_exec),
      .o_a             (deco_a_exec),
      .o_b             (deco_b_exec),

      .o_inm           (deco_inm_exec),
      .o_shamt         (deco_shamt_exec),
      .o_nop           (deco_nop_reg_if),
      .o_branch        (deco_isbrancho_sc),
      .o_branch_result (deco_branch_if),
      .o_jump_rs       (deco_jump_rs_if),
      .o_jump_rs_addr  (deco_rs_if),
      .o_jump_inm      (deco_jump_inm_if),
      .o_rinst         (deco_rinst_sc),
      .o_store         (deco_store_sc),

      .o_jump_inm_addr (deco_inm_j_if),

      .o_halt          (deco_halt),

      .o_debug_regfile_data (regfile_to_debug_unit),

      .i_instruction   (mux_ir_deco),
      .i_pc            (if_pc_deco),
      .i_regfile_addr  (wb_regfile_addr_deco),
      .i_regfile_data  (wb_regfile_data_deco),
      .i_regfile_we    (wb_regfile_we_deco),
      .i_sc_muxa       (sc_muxa_deco ),
      .i_sc_muxb       (sc_muxb_deco),
      .i_sc_dataa      (sc_dataa_deco),
      .i_sc_datab      (sc_datab_deco),

      .i_debug_regfile_addr (debug_regfile_addr),

      .i_valid         (interface_valid),
      .i_clk           (i_clock),
      .i_rst           (reset)
      );

   execution
     #(
       .NB_REG             (NB_REG),
       .NB_INM             (NB_INM),
       .NB_SHAMT           (NB_SHAMT),
       .NB_EX              (NB_EX),
       .NB_MEM             (NB_MEM),
       .NB_WB              (NB_WB)
       )
   u_execution
      (
       .o_alu               (exec_alu_mem),
       .o_b                 (exec_b_mem),
       .o_mem               (exec_mem_mem),
       .o_wb                (exec_wb_mem),
       .o_pc                (exec_pc_mem),

       .i_a                 (sc_muxa_ex ? sc_dataa_ex : deco_a_exec),
       .i_b                 (sc_muxb_ex ? sc_datab_ex : deco_b_exec),
       .i_inm               (deco_inm_exec),
       .i_shamt             (deco_shamt_exec),
       .i_ex                (deco_ex_ctrl_exec),
       .i_mem               (deco_mem_ctrl_exec),
       .i_wb                (deco_wb_ctrl_exec),
       .i_pc                (deco_pc_exec),

       .i_reset             (reset),
       .i_clock             (i_clock),
       .i_valid             (deco_halt)
      );

   memory_access
     #(
       .NB_REG             (NB_REG),
       .NB_MEM             (NB_MEM),
       .NB_WB              (NB_WB),
       .N_ADDR             (N_ADDR),
       .DATA_FILE          (DATA_FILE)
       )
   u_memory_access
      (
      .o_reg_wb            (mem_reg_wb_wb),
      .o_ext_mem_o         (mem_ext_mem_o_wb),
      .o_wb                (mem_wb_wb),
      .o_pc                (mem_pc_wb),

      .o_debug_datamem_data (data_mem_to_debug_unit),

      .i_alu_o             (exec_alu_mem),
      .i_b_o               (exec_b_mem),
      .i_mem               (exec_mem_mem),
      .i_wb                (exec_wb_mem),
      .i_pc                (exec_pc_mem),

      .i_debug_datamem_addr (interface_datamem_addr),
      .i_debug_datamem_re (debug_data_mem_re),

      .i_reset             (reset),
      .i_clock             (i_clock),
      .i_valid             (deco_halt)
      );

   write_back
     #(
       .NB_REG             (NB_REG),
       .NB_REG_ADDR        (NB_REG_ADDR),
       .NB_WB              (NB_WB)
       )
   u_write_back
      (
      .o_wb_data           (wb_regfile_data_deco),
      .o_reg_dest          (wb_regfile_addr_deco),
      .o_reg_we            (wb_regfile_we_deco),

      .i_reg_wb            (mem_reg_wb_wb),
      .i_ext_mem_o         (mem_ext_mem_o_wb),
      .i_wb                (mem_wb_wb),
      .i_pc                (mem_pc_wb)
      ) ;

   shortcircuit_unit
      #(
        .NB_REG_ADDR   (NB_REG_ADDR),
        .NB_REG        (NB_REG     ),
        .NB_OPCODE     (NB_OPCODE  )
        )
   u_shortcircuit_unit
     (
      .o_muxa_jump_rs  (sc_muxa_deco ),
      .o_muxb_jump_rs  (sc_muxb_deco),
      .o_dataa_jump_rs (sc_dataa_deco),
      .o_datab_jump_rs (sc_datab_deco),
      .o_data_a        (sc_dataa_ex),
      .o_data_b        (sc_datab_ex),
      .o_mux_a         (sc_muxa_ex),
      .o_mux_b         (sc_muxb_ex),
      .i_we_ex         (deco_wb_ctrl_exec[2]),
      .i_we_mem        (exec_wb_mem[2]),
      .i_rinst         (deco_rinst_sc),
      .i_store         (deco_store_sc),
      .i_jump_rs       (deco_jump_rs_if),
      .i_branch        (deco_isbrancho_sc),
      .i_jinst         (deco_jump_inm_if),
      .i_data_ex       (exec_alu_mem),
      .i_data_mem      (wb_regfile_data_deco),
      .i_rd_ex         (deco_wb_ctrl_exec[NB_WB-1-:NB_REG_ADDR]),
      .i_rd_mem        (exec_wb_mem[NB_WB-1-:NB_REG_ADDR]),
      .i_rs            (if_ir_deco[MSB_RS-:NB_REG_ADDR]),
      .i_rt            (if_ir_deco[MSB_RT-:NB_REG_ADDR]),

      .i_reset         (reset),
      .i_clock         (i_clock),
      .i_valid         (deco_halt)
      );

   hazard_unit
     #(
       .NB_REG_ADDR    (NB_REG_ADDR                             ),
       .NB_OPCODE      (NB_OPCODE                               )
       )
   u_hazard_unit
     (
      .o_hazard        (hazard                                  ),
      .i_jmp_branch    (deco_isbrancho_sc|deco_jump_rs_if       ),
      .i_rd            (deco_wb_ctrl_exec[NB_WB-1-:NB_REG_ADDR] ),
      .i_rs            (if_ir_deco[MSB_RS-:NB_REG_ADDR]         ),
      .i_rt            (if_ir_deco[MSB_RT-:NB_REG_ADDR]         ),
      .i_re            (deco_mem_ctrl_exec[NB_MEM-1]            ),
      .i_reset         (reset                                 ),
      .i_clock         (i_clock                                 ),
      .i_valid         (deco_halt                               )
      );

   /********************************************
    DEBUG BLOCKS
    *******************************************/
   wire [11-1:0]                           controllers_writing;
   reg                                     controllers_writing_d;

   assign controllers_writing = {fetch_data_controller_writing, fetch_control_controller_writing,
                                 decode_data_controller_writing, decode_control_controller_writing,
                                 exec_data_controller_writing, exec_control_controller_writing,
                                 mem_data_controller_writing, mem_control_controller_writing,
                                 instr_mem_controller_writing, data_mem_controller_writing,
                                 regfile_controller_writing};

   always @(posedge i_clock)
     if (reset)
       controllers_writing_d <= 1'b0;
     else
       controllers_writing_d <= |controllers_writing;

   assign debug_endofdata_interface = ~(|controllers_writing) & controllers_writing_d;

   //Debug mux
   always @(*)
     casez(controllers_writing)
       11'b100_0000_0000 : debugmux_interface = fetch_data_to_mux;
       11'b010_0000_0000 : debugmux_interface = fetch_control_to_mux;
       11'b001_0000_0000 : debugmux_interface = decode_data_to_mux;
       11'b000_1000_0000 : debugmux_interface = decode_control_to_mux;
       11'b000_0100_0000 : debugmux_interface = exec_data_to_mux;
       11'b000_0010_0000 : debugmux_interface = exec_control_to_mux;
       11'b000_0001_0000 : debugmux_interface = mem_data_to_mux;
       11'b000_0000_1000 : debugmux_interface = mem_control_to_mux;
       11'b000_0000_0100 : debugmux_interface = instr_mem_to_mux;
       11'b000_0000_0010 : debugmux_interface = data_mem_to_mux;
       11'b000_0000_0001 : debugmux_interface = regfile_to_mux;
       default : debugmux_interface = {NB_LATCH{1'b0}};
     endcase

   microblaze_mips_interface
     #(
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME),
       .NB_ADDR_DATA        (NB_ADDR_DATA    ),
       .NB_INSTR_ADDR       (NB_INSTR_ADDR   )
     )
   u_microblaze_mips_interface
     (
      .o_frame_to_blaze     (o_frame_to_blaze),
      .o_valid              (interface_valid),
      .o_reset              (interface_reset),
      .o_instr_data         (interface_instrmem_data),
      .o_instr_addr         (interface_instrmem_addr),
      .o_instr_mem_we       (interface_instrmem_we),
      .o_mem_addr           (interface_datamem_addr),
      .o_request_select     (interface_read_request_to_controllers),
      .i_frame_from_blaze   (i_frame_from_blaze),
      .i_frame_from_mips    (debugmux_interface),
      .i_eod                (debug_endofdata_interface),
      .i_eop                (debug_endofprogram_interface),

      .i_clock              (i_clock),
      .i_reset              (reset)
      );

   //Fetch
   debug_control_latches
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_FETCH_DATA_INPUT_SIZE        ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_FETCH_DATA_ID        )
       )
   u_debug_control_fetch_data
     (
      .o_frame_to_interface (fetch_data_to_mux ),
      .o_writing            (fetch_data_controller_writing            ),
      .i_request_select     (interface_read_request_to_controllers    ),
      .i_data_from_mips     (fetch_data_to_debug_unit     ),
      .i_clock              (i_clock              ),
      .i_reset              (reset              )
      ) ;
   debug_control_latches
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_FETCH_CONTROL_INPUT_SIZE       ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_FETCH_CONTROL_ID        )
       )
   u_debug_control_fetch_control
     (
      .o_frame_to_interface (fetch_control_to_mux ),
      .o_writing            (fetch_control_controller_writing            ),
      .i_request_select     (interface_read_request_to_controllers     ),
      .i_data_from_mips     (fetch_control_to_debug_unit     ),
      .i_clock              (i_clock              ),
      .i_reset              (reset              )
      ) ;

   //Decode
   debug_control_latches
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_DECODE_DATA_INPUT_SIZE        ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_DECODE_DATA_ID        )
       )
   u_debug_control_deco_data
     (
      .o_frame_to_interface (decode_data_to_mux ),
      .o_writing            (decode_data_controller_writing            ),
      .i_request_select     (interface_read_request_to_controllers     ),
      .i_data_from_mips     (decode_data_to_debug_unit     ),
      .i_clock              (i_clock              ),
      .i_reset              (reset              )
      ) ;
   debug_control_latches
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_DECODE_CONTROL_INPUT_SIZE        ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_DECODE_CONTROL_ID        )
       )
   u_debug_control_deco_control
     (
      .o_frame_to_interface (decode_control_to_mux ),
      .o_writing            (decode_control_controller_writing            ),
      .i_request_select     (interface_read_request_to_controllers     ),
      .i_data_from_mips     (decode_control_to_debug_unit     ),
      .i_clock              (i_clock              ),
      .i_reset              (reset              )
      ) ;

   //Exec
   debug_control_latches
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_EXEC_DATA_INPUT_SIZE        ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_EXEC_DATA_ID        )
       )
   u_debug_control_exec_data
     (
      .o_frame_to_interface (exec_data_to_mux ),
      .o_writing            (exec_data_controller_writing            ),
      .i_request_select     (interface_read_request_to_controllers     ),
      .i_data_from_mips     (exec_data_to_debug_unit     ),
      .i_clock              (i_clock              ),
      .i_reset              (reset              )
      ) ;
   debug_control_latches
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_EXEC_CONTROL_INPUT_SIZE        ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_EXEC_CONTROL_ID        )
       )
   u_debug_control_exec_control
     (
      .o_frame_to_interface (exec_control_to_mux ),
      .o_writing            (exec_control_controller_writing            ),
      .i_request_select     (interface_read_request_to_controllers     ),
      .i_data_from_mips     (exec_control_to_debug_unit     ),
      .i_clock              (i_clock              ),
      .i_reset              (reset              )
      ) ;

   //Mem
   debug_control_latches
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_MEM_DATA_INPUT_SIZE        ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_MEM_DATA_ID        )
       )
   u_debug_control_mem_data
     (
      .o_frame_to_interface (mem_data_to_mux ),
      .o_writing            (mem_data_controller_writing            ),
      .i_request_select     (interface_read_request_to_controllers     ),
      .i_data_from_mips     (mem_data_to_debug_unit     ),
      .i_clock              (i_clock              ),
      .i_reset              (reset              )
      ) ;
   debug_control_latches
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_MEM_CONTROL_INPUT_SIZE        ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_MEM_CONTROL_ID        )
       )
   u_debug_control_mem_control
     (
      .o_frame_to_interface (mem_control_to_mux ),
      .o_writing            (mem_control_controller_writing            ),
      .i_request_select     (interface_read_request_to_controllers     ),
      .i_data_from_mips     (mem_control_to_debug_unit     ),
      .i_clock              (i_clock              ),
      .i_reset              (reset              )
      ) ;

  //Instruction memory
   debug_control_memory
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_INSTR_MEMORY_INPUT_SIZE        ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_INSTR_MEMORY_ID        )
       )
   u_debug_control_instruction_memory
     (
      .o_frame_to_interface (instr_mem_to_mux),
      .o_mem_re             (debug_instr_mem_re             ),
      .o_writing            (instr_mem_controller_writing),
      .i_request_select     (interface_read_request_to_controllers     ),
      .i_data_from_mips     (instr_mem_to_debug_unit     ),
      .i_clock              (i_clock              ),
      .i_reset              (reset              )
      ) ;

   //Data memory
   debug_control_memory
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_DATA_MEMORY_INPUT_SIZE        ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_DATA_MEMORY_ID        )
       )
   u_debug_control_data_memory
     (
      .o_frame_to_interface (data_mem_to_mux ),
      .o_mem_re             (debug_data_mem_re             ),
      .o_writing            (data_mem_controller_writing            ),
      .i_request_select     (interface_read_request_to_controllers     ),
      .i_data_from_mips     (data_mem_to_debug_unit     ),
      .i_clock              (i_clock              ),
      .i_reset              (reset              )
      ) ;

   //Regfile
   debug_control_regfile
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_REGFILE_INPUT_SIZE        ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_REGFILE_ID        )
       )
   u_debug_control_regfile
     (
      .o_frame_to_interface (regfile_to_mux ),
      .o_writing            (regfile_controller_writing            ),
      .o_reg_addr           (debug_regfile_addr),
      .i_request_select     (interface_read_request_to_controllers     ),
      .i_data_from_mips     (regfile_to_debug_unit     ),
      .i_clock              (i_clock              ),
      .i_reset              (reset              )
      ) ;

   function integer clogb2;
      input integer          depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
   endfunction

endmodule
