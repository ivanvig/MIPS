
//  Xilinx Simple Dual Port Single Clock RAM with Byte-write
//  This code implements a parameterizable SDP single clock memory.
//  If a reset or enable is not necessary, it may be tied off or removed from the code.

module byte_enable_bram
  #(
    parameter NB_COL    = 4,                        // Specify number of columns (number of bytes)
    parameter COL_WIDTH = 8,                        // Specify column width (byte width, typically 8 or 9)
    parameter RAM_DEPTH = 512,                      // Specify RAM depth (number of entries)
    parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) (
       output [(NB_COL*COL_WIDTH)-1:0] o_dout, // RAM output data
       input [clogb2(RAM_DEPTH-1)-1:0] i_waddr, // Write address bus, width determined from RAM_DEPTH
       input [clogb2(RAM_DEPTH-1)-1:0] i_raddr, // Read address bus, width determined from RAM_DEPTH
       input [(NB_COL*COL_WIDTH)-1:0]  i_din, // RAM input data
       input                           i_clk, // Clock
       input [NB_COL-1:0]              i_wen, // Byte-write enable
       input                           i_ren, // Read Enable, for additional power savings, disable when not in use
       input                           i_rst // Output reset (does not affect memory contents)
       );
   
   reg [(NB_COL*COL_WIDTH)-1:0]        BRAM [RAM_DEPTH-1:0];
   reg [(NB_COL*COL_WIDTH)-1:0]        ram_data = {(NB_COL*COL_WIDTH){1'b0}};

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
   generate
      if (INIT_FILE != "") begin: use_init_file
         initial
           $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
      end else begin: init_bram_to_zero
         integer ram_index;
         initial
           for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
             BRAM[ram_index] = {(NB_COL*COL_WIDTH){1'b0}};
      end
   endgenerate
   
   
   always @(posedge i_clk)
     if (i_ren)
       ram_data <= BRAM[i_raddr];
   
   generate
      genvar     i;
      for (i = 0; i < NB_COL; i = i+1) begin: byte_write
         always @(posedge i_clk)
           if (i_wen[i])
             BRAM[i_waddr][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= i_din[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
      end
   endgenerate

   assign o_dout = ram_data;
   
   //  The following function calculates the address width based on specified RAM depth
   function integer clogb2;
      input integer                   depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
   endfunction
   
endmodule
