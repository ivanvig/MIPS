/*
 OPERATIONS
 */

module alu
  #(
    // Parameters.
    parameter NB_DATA       = 32 ,   // Nr of bits in the registers
    parameter NB_OPERATION  = 4     // Nr of bits in the operation input
    )
   (
    // Outputs.
    output [NB_DATA-1:0]      o_result , // Result of the operation

    // Inputs.
    input wire [NB_DATA-1:0]      i_data_a,
    input wire [NB_DATA-1:0]      i_data_b,
    input wire [NB_OPERATION-1:0] i_op
    ) ;

   localparam NB_SHIFT = clogb2(NB_DATA);

   localparam ADD          = 4'b0000;
   localparam SUB          = 4'b0001;
   localparam AND          = 4'b0010;
   localparam OR           = 4'b0011;
   localparam XOR          = 4'b0100;
   localparam NOR          = 4'b0101;
   localparam SRL          = 4'b0110;
   localparam SLL          = 4'b0111;
   localparam SRA          = 4'b1000;
   localparam SLA          = 4'b1001;
   localparam SLT          = 4'b1010;
   localparam LUI          = 4'b1011;

   integer                        i;
   reg [NB_DATA-1:0]              result;

   assign o_result = result;

   always @(*)
     begin
        case(i_op)
          ADD: // ADD
            result = i_data_a + i_data_b ;
          SUB: // SUB
            result = i_data_a - i_data_b ;
          AND: // AND
            result = i_data_a & i_data_b ;
          OR: // OR
            result = i_data_a | i_data_b ;
          XOR: // XOR
            result = i_data_a ^ i_data_b ;
          NOR: // NOR
            result = ~ (i_data_a & i_data_b);
          SRL: begin// SRL (Logical: fills with zero)
             result = 'b0;
             // for(i = 0; i<2**NB_DATA; i=i+1) begin
             //    if(i_data_b == i)
             //      result = i_data_a[4:0] >> i;
             // end
             for(i = 0; i<2**NB_SHIFT; i=i+1) begin
                if(i_data_a[NB_SHIFT-1:0] == i)
                  result = i_data_b >> i;
             end
             // result = i_data_b >> i_data_a[4:0];
          end
          SLL: begin// SLL (Logical: fills with zero)
             result = 'b0;
             for(i = 0; i<2**NB_SHIFT; i=i+1) begin
                if(i_data_a[NB_SHIFT-1:0] == i)
                  result = i_data_b << i;
             end
             // result = i_data_b << i_data_a[4:0];
          end
          SRA: begin// SRA (Arithmetic: keep sign)
             result = 'b0;
             // for(i = 0; i<2**NB_DATA; i=i+1) begin
             //    if(i_data_b == i)
             //      result = $signed(i_data_a[4:0]) >>> i;
             // end
             for(i = 0; i<2**NB_SHIFT; i=i+1) begin
                if(i_data_a[NB_SHIFT-1:0] == i)
                  result = $signed(i_data_b) >>> i;
             end
             // result = $signed(i_data_b) >>> i_data_a[4:0];
          end
          SLA: begin// SLA (Arithmetic: keep sign)
             result = 'b0;
             // for(i = 0; i<2**NB_DATA; i=i+1) begin
             //    if(i_data_b == i)
             //      result = $signed(i_data_a[4:0]) <<< i;
             // end
             for(i = 0; i<2**NB_SHIFT; i=i+1) begin
                if(i_data_a[NB_SHIFT-1:0] == i)
                  result = $signed(i_data_b) <<< i;
             end
             // result = $signed(i_data_b) <<< i_data_a[4:0];
          end
          SLT:
            result = (i_data_a < i_data_b) ? {{NB_DATA-1{1'b0}}, 1'b1} : {NB_DATA{1'b0}};
          LUI:
            result = $signed(i_data_b) << 16 ;
          default: result = {NB_DATA{1'b1}};
        endcase
     end
     
     function integer clogb2;
        input integer                   depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
          depth = depth >> 1;
     endfunction // clogb2
endmodule
