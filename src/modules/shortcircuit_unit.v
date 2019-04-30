module shortcircuit_unit
  #(
    parameter NB_REG_ADDR = 5,
    parameter NB_REG      = 32,
    parameter NB_OPCODE   = 6

    )
   (
    output [NB_REG-1:0]     o_data_a,
    output [NB_REG-1:0]     o_data_b,
    output                  o_mux_a,
    output                  o_mux_b,

    input                   i_we_ex,
    input                   i_we_mem,
    input [NB_REG-1:0]      i_data_ex,
    input [NB_REG-1:0]      i_data_mem,
    input [NB_REG_ADDR-1:0] i_rd_ex,
    input [NB_REG_ADDR-1:0] i_rd_mem,
    input [NB_REG_ADDR-1:0] i_rs,
    input [NB_REG_ADDR-1:0] i_rt
    ) ;

   localparam JBITS      = 5'b0000_1;

   wire [2-1:0]             data_source_a;
   wire [2-1:0]             data_source_b;

   assign o_mux_a = |data_source_a;
   assign o_mux_b = |data_source_b;

   assign o_data_a = data_source_a[0] ? i_data_ex : i_data_mem;
   assign o_data_b = data_source_b[0] ? i_data_ex : i_data_mem;

   assign data_source_a[0] = ((i_rs == i_rd_ex) & i_we_ex);
   assign data_source_a[1] = ((i_rs == i_rd_mem) & i_we_mem) & ~data_source_a[0];

   assign data_source_b[0] = ((i_rt == i_rd_ex) & i_we_ex);
   assign data_source_b[1] = ((i_rt == i_rd_mem) & i_we_mem) & ~data_source_b[0];


endmodule
