module write_back
  #(
    parameter NB_REG = 32,
    parameter NB_REG_ADDR = 5,
    parameter NB_WB = 8
    )
   (
    output reg [NB_REG-1:0]       o_wb_data,
    output wire [NB_REG_ADDR-1:0] o_reg_dest,
    output wire                   o_reg_we,

    input wire [NB_REG-1:0]       i_reg_wb,
    input wire [NB_REG-1:0]       i_ext_mem_o,
    input wire [NB_WB-1:0]        i_wb,
    input wire [NB_REG-1:0]       i_pc
    ) ;
   wire [2-1:0]                   data_selector;

   assign {o_reg_dest, o_reg_we, data_selector} = i_wb ;

   always @ (*)
     begin
        casez (data_selector)
          2'b00: o_wb_data = i_ext_mem_o ;
          2'b10: o_wb_data = i_reg_wb ;
          2'b?1: o_wb_data = i_pc;
        endcase
     end
endmodule
