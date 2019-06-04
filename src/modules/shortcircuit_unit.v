module shortcircuit_unit
  #(
    parameter NB_REG_ADDR = 5,
    parameter NB_REG      = 32,
    parameter NB_OPCODE   = 6

    )
   (
    output [NB_REG-1:0]     o_data_a,
    output [NB_REG-1:0]     o_data_b,
    output reg              o_mux_a,
    output reg              o_mux_b,
    output                  o_muxa_jump_rs,
    output                  o_muxb_jump_rs,
    output                  o_dataa_jump_rs,
    output                  o_datab_jump_rs,

    input                   i_store,
    input                   i_jump_rs,
    input                   i_we_ex,
    input                   i_we_mem,
    input                   i_rinst,
    input                   i_branch,
    input                   i_jinst,
    input [NB_REG-1:0]      i_data_ex,
    input [NB_REG-1:0]      i_data_mem,
    input [NB_REG_ADDR-1:0] i_rd_ex,
    input [NB_REG_ADDR-1:0] i_rd_mem,
    input [NB_REG_ADDR-1:0] i_rs,
    input [NB_REG_ADDR-1:0] i_rt,

    input wire              i_clock,
    input wire              i_reset,
    input wire              i_valid
    ) ;

   localparam JBITS      = 5'b0000_1;

   wire [2-1:0]             data_source_a;
   wire [2-1:0]             data_source_b;
   reg [2-1:0]              data_source_a_reg;
   reg [2-1:0]              data_source_b_reg;

   wire [NB_REG-1:0]        data_a;
   wire [NB_REG-1:0]        data_b;
   wire                     mux_a;
   wire                     mux_b;

   // juan dice que el croto circuoito de jump rs
   assign o_muxa_jump_rs  = |data_source_a & i_jump_rs & i_rinst;
   assign o_muxb_jump_rs  = |data_source_b & i_jump_rs & i_rinst;
   assign o_dataa_jump_rs = data_a;
   assign o_datab_jump_rs = data_b;


   always @(posedge i_clock)
   begin
      if (i_reset) begin
         o_mux_a <= 1'b0;
         o_mux_b <= 1'b0;
      end else if (i_valid) begin
         o_mux_a <= mux_a;
         o_mux_b <= mux_b;
         data_source_a_reg <= data_source_a;
         data_source_b_reg <= data_source_b;
      end
   end

   assign o_data_a = data_a;
   assign o_data_b = data_b;

   assign mux_a = |data_source_a & ~i_jinst;
   assign mux_b = |data_source_b & (i_rinst | i_store | i_branch) & ~i_jinst;

   assign data_a = data_source_a_reg[0] ? i_data_ex : i_data_mem;
   assign data_b = data_source_b_reg[0] ? i_data_ex : i_data_mem;

   assign data_source_a[0] = ((i_rs == i_rd_ex) & i_we_ex);
   assign data_source_a[1] = ((i_rs == i_rd_mem) & i_we_mem) & ~data_source_a[0];

   assign data_source_b[0] = ((i_rt == i_rd_ex) & i_we_ex);
   assign data_source_b[1] = ((i_rt == i_rd_mem) & i_we_mem) & ~data_source_b[0];


endmodule
