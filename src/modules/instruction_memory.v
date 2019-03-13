module instruction_memory
#(
    // Parameters.
    parameter 									NB_DATA = 16,
    parameter 									N_ADDR = 2048,
    parameter 									LOG2_N_INSMEM_ADDR = clogb2(N_ADDR)
)
(
    // Outputs.
    output wire     [NB_DATA-1:0]               o_data,
    // Inputs.
    input  wire 	[LOG2_N_INSMEM_ADDR-1:0]    i_addr, // Signal from control unit
    input  wire 								i_clock,
    input  wire 								i_enable,
    input  wire 								i_reset 							
) ;	

    //==========================================================================
    // LOCAL PARAMETERS.
    //==========================================================================


    //==========================================================================
    // INTERNAL SIGNALS.
    //==========================================================================
    reg             [NB_DATA-1:0]               mem_bank [N_ADDR-1:0] ;
    reg             [NB_DATA-1:0]               data ;                            

    //==========================================================================
    // ALGORITHM.
    //==========================================================================
    //  | 15 Opcode 11 | 10 Operand 0 | Instruction format
    initial begin
    mem_bank[0] = 32'b00010_000_0000_0001_00010_000_0000_0001 ; 
    mem_bank[1] = 32'b00101_000_0000_0010_00101_000_0000_0010 ; 
    mem_bank[2] = 32'b00001_000_0000_0111_00001_000_0000_0111 ; 
    mem_bank[3] = 32'b00011_000_0000_1000_00011_000_0000_1000 ; 
    mem_bank[4] = 32'b00110_000_0000_0010_00110_000_0000_0010 ; 
    mem_bank[5] = 32'b00100_000_0000_0010_00100_000_0000_0010 ; 
    mem_bank[6] = 32'b00001_000_0000_1011_00001_000_0000_1011 ; 
    mem_bank[7] = 32'b00011_000_0000_0011_00011_000_0000_0011 ; 
    mem_bank[8] = 32'b00111_000_0000_0011_00111_000_0000_0011 ; 
    mem_bank[9] = 32'b00000_000_0000_0000_00000_000_0000_0000 ; 
    end

    assign o_data = data ;

    always @ (posedge i_clock)
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
