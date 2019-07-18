`timescale 1 ps / 1 ps

module top_level
  (
   output       uart_rxd_out,
   output [3:0] led,
   input        ck_rst,
   input        CLK100MHZ,
   input        uart_txd_in
   );

   localparam INSTR_FILE         = "output.mem";
   localparam DATA_FILE          = "";

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

   wire [31:0]   gpio_rtl_0_tri_o;
   wire [31:0]   gpio_rtl_tri_i;

   ublaze ublaze_i
     (
      .gpio_rtl_0_tri_o(gpio_rtl_0_tri_o),
      .gpio_rtl_tri_i(gpio_rtl_tri_i),
      .reset(ck_rst),
      .sys_clock(CLK100MHZ),
      .usb_uart_rxd(uart_txd_in),
      .usb_uart_txd(uart_rxd_out)
      );

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
      .o_frame_to_blaze   (gpio_rtl_tri_i),
      .o_iface_valid      (led[0]),
      .o_deco_valid       (led[1]),
      .i_frame_from_blaze (gpio_rtl_0_tri_o),
      .i_clock            (CLK100MHZ),
      .i_valid            (1'b1),
      .i_reset            (~ck_rst)
      ) ;
endmodule
