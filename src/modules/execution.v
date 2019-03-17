module execution
  #(
    parameter NB_REG = 32,
    parameter NB_INM = 16,
    parameter NB_EX = 6,
    parameter NB_MEM = 5,
    parameter NB_WB = 8
    )
   (
    output reg [NB_REG-1:0] o_alu,
    output reg [NB_REG-1:0] o_b,
    output reg [NB_MEM-1:0] o_mem,
    output reg [NB_WB-1:0]  o_wb,
    output reg [NB_REG-1:0] o_pc,

    input wire [NB_REG-1:0] i_a,
    input wire [NB_REG-1:0] i_b,
    input wire [NB_INM-1:0] i_inm,
    input wire [NB_EX-1:0]  i_ex,
    input wire [NB_MEM-1:0] i_mem,
    input wire [NB_WB-1:0]  i_wb,
    input wire [NB_REG-1:0] i_pc,

    input wire              i_reset,
    input wire              i_clock,
    input wire              i_valid
    ) ;
   localparam NB_ALUCONTROL = 4;

   wire [NB_REG-1:0]        alu_b ;
   wire [NB_REG-1:0]        alu_out ;
   wire [NB_ALUCONTROL-1:0] alu_control ;
   wire [NB_REG-1:0]        ext_inm ;
   wire                     b_i ;
   wire                     s_u ;

   assign {alu_control, b_i , s_u} = i_ex ;

   assign ext_inm = (s_u) ? { {NB_REG-NB_INM{1'b0}}, i_inm} : {{NB_REG-NB_INM{i_inm[NB_INM-1]}}, i_inm}; //s_u == 1'b1 : unsigned, else signed

   assign alu_b = (b_i) ? ext_inm : i_b ; //b_i == 1'b1 : inmediate, else b

   // Control signals and registers to next pipeline stage
   always @ (posedge i_clock)
     begin
     if (i_reset) begin
        o_mem <= {NB_MEM{1'b0}};
        o_wb <= {NB_WB{1'b0}};
        o_pc <= {NB_REG{1'b0}};
        o_b <= {NB_REG{1'b0}};
     end else if (i_valid) begin
        o_mem <= i_mem;
        o_wb <= i_wb;
        o_pc <= i_pc;
        o_b <= i_b;
     end
     end // always @ (posedge i_clock)

   // Alu out logic
   always @ (posedge i_clock)
     begin
        if (i_reset)
          o_alu <= {NB_REG{1'b0}};
        else if (i_valid)
          o_alu <= alu_out ;
     end // always @ (posedge i_clock)

   alu#(
        .NB_DATA(NB_REG),
        .NB_OPERATION(NB_ALUCONTROL)
        )
   u_alu(
         .o_result(alu_out),
         .i_data_a(i_a),
         .i_data_b(alu_b),
         .i_op(alu_control)
         );
endmodule // execution



