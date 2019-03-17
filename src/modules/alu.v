/*
OPERATIONS
*/

module alu
  #(
    // Parameters.
    parameter                                       NB_DATA                     = 8 ,   // Nr of bits in the registers
    parameter                                       NB_OPERATION                = 6 ,    // Nr of bits in the operation input
    localparam ADD =        6'b100000,
    localparam SUB =        6'b100010,
    localparam AND =        6'b100100,
    localparam OR  =        6'b100101,
    localparam XOR =        6'b100110,
    localparam SRA =        6'b000011,
    localparam SRL =        6'b000010,
    localparam NOR =        6'b100111
    )
   (
    // Outputs.
    output reg [NB_DATA-1:0] o_result , // Result of the operation
    
    // Inputs.
    input wire [NB_DATA-1:0] i_data_a,
    input wire [NB_DATA-1:0] i_data_b,
    input wire [NB_OPERATION-1:0] i_op
    ) ;
   
   integer                   i;

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
          SRA: begin// SRA (Arithmetic: keep sign)
             o_result = 'b0;
             for(i = 0; i<2**NB_DATA; i=i+1) begin
                if(i_data_b == i)
                  o_result = $signed(i_data_a) >>> i;
             end
          end
          SRL: begin// SRL (Logical: fills with zero)
             o_result = 'b0;
             for(i = 0; i<2**NB_DATA; i=i+1) begin
                if(i_data_b == i)
                  o_result = i_data_a >> i;
             end
          end
          NOR: // NOR
            o_result = ~ (i_data_a & i_data_b);
          default: o_result = {NB_DATA{1'b1}};
        endcase
     end
endmodule
