module hazard_unit
  #(
    parameter NB_REG_ADDR   = 5,
    parameter NB_OPCODE     = 6,

    localparam JBITS = 5'b0000_1
    )
   (
    output                  o_hazard,

    input                   i_re,
    input [NB_OPCDE-1:0]    i_op,
    input [NB_REG_ADDR-1:0] i_rd,
    input [NB_REG_ADDR-1:0] i_rs,
    input [NB_REG_ADDR-1:0] i_rt
    ) ;

   assign o_hazard = (JBITS != {i_op[NB_OPCODE-1:1]}) & ((i_rd == i_rs) | (i_rd == i_rt)) & i_re;

endmodule
