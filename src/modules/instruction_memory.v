module instruction_memory
  #(
    // Parameters.
    parameter 									NB_DATA = 16,
    parameter 									N_ADDR = 2048,
    parameter 									LOG2_N_INSMEM_ADDR = clogb2(N_ADDR)
    )
   (
    // Outputs.
    output wire [NB_DATA-1:0]           o_data,
    // Inputs.
    input wire [LOG2_N_INSMEM_ADDR-1:0] i_addr, // Signal from control unit
    input wire                          i_clock,
    input wire                          i_enable,
    input wire                          i_reset 							
    ) ;	

   //==========================================================================
   // LOCAL PARAMETERS.
   //==========================================================================


   //==========================================================================
   // INTERNAL SIGNALS.
   //==========================================================================
   reg [NB_DATA-1:0]                    mem_bank [N_ADDR-1:0] ;
   reg [NB_DATA-1:0]                    data ;   
   
   integer                              i;                         

   //==========================================================================
   // ALGORITHM.
   //==========================================================================
   //  | 15 Opcode 11 | 10 Operand 0 | Instruction format
   initial begin
      for (i=0; i<N_ADDR; i=i+1)
        mem_bank[i] = 32'h0000_0001;
   end

   assign o_data = data ;

   always @ (negedge i_clock)
     begin
        if (i_reset)
          data <= mem_bank[0];
        else if (i_enable)
          data <= mem_bank[i_addr];
     end
   
   function integer clogb2;
      input integer                   depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
   endfunction

endmodule
