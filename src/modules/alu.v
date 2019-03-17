/*
OPERATIONS
*/

module alu
  #(
    // Parameters.
    parameter NB_DATA       = 32 ,   // Nr of bits in the registers
    parameter NB_OPERATION  = 4 ,    // Nr of bits in the operation input
    localparam ADD          = 4'b0000,
    localparam SUB          = 4'b0001,
    localparam AND          = 4'b0010,
    localparam OR           = 4'b0011,
    localparam XOR          = 4'b0100,
    localparam NOR          = 4'b0101,
    localparam SRL          = 4'b0110,
    localparam SLL          = 4'b0111,
    localparam SRA          = 4'b1000,
    localparam SLA          = 4'b1001,
    localparam SLT          = 4'b1010,
    localparam LUI          = 4'b1011
    )
   (
    // Outputs.
    output reg [NB_DATA-1:0] o_result , // Result of the operation

    // Inputs.
    input wire [NB_DATA-1:0] i_data_a,
    input wire [NB_DATA-1:0] i_data_b,
    input wire [NB_OPERATION-1:0] i_op
    ) ;

   integer i;

   always @(*)
     begin
        case(i_op)
          ADD: // ADD
            o_result = i_data_a + i_data_b ;
          SUB: // SUB
            o_result = i_data_a - i_data_b ;
          AND: // AND
            o_result = i_data_a & i_data_b ;
          OR: // OR
            o_result = i_data_a | i_data_b ;
          XOR: // XOR
            o_result = i_data_a ^ i_data_b ;
          NOR: // NOR
            o_result = ~ (i_data_a & i_data_b);
          SRL: begin// SRL (Logical: fills with zero)
             o_result = 'b0;
             for(i = 0; i<2**NB_DATA; i=i+1) begin
                if(i_data_b == i)
                  o_result = i_data_a >> i;
             end
          end
          SLL: begin// SLL (Logical: fills with zero)
             o_result = 'b0;
             for(i = 0; i<2**NB_DATA; i=i+1) begin
                if(i_data_b == i)
                  o_result = i_data_a << i;
             end
          end
          SRA: begin// SRA (Arithmetic: keep sign)
             o_result = 'b0;
             for(i = 0; i<2**NB_DATA; i=i+1) begin
                if(i_data_b == i)
                  o_result = $signed(i_data_a) >>> i;
             end
          end
          SLA: begin// SLA (Arithmetic: keep sign)
             o_result = 'b0;
             for(i = 0; i<2**NB_DATA; i=i+1) begin
                if(i_data_b == i)
                  o_result = $signed(i_data_a) <<< i;
             end
          end
          SLT:
            o_result = (i_data_a < i_data_b) ? {{NB_DATA-1{1'b0}}, 1'b1} : {NB_DATA{1'b0}};
          LUI:
            o_result = $signed(i_data_b) << 16 ;
          default: o_result = {NB_DATA{1'b1}};
        endcase
     end
endmodule
