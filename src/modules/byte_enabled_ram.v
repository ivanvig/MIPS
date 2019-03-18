module byte_enabled_ram #(
  parameter NB_COL = 4,                           // Specify number of columns (number of bytes)
  parameter COL_WIDTH = 8,                        // Specify column width (byte width, typically 8 or 9)
  parameter RAM_DEPTH = 1024,                     // Specify RAM depth (number of entries)
  parameter INIT_FILE = "",                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  parameter NB_ADDR = 32
) (
   output [(NB_COL*COL_WIDTH)-1:0] douta, // RAM output data
   input [NB_ADDR-1:0]             addra, // Address bus, width determined from RAM_DEPTH
   input [(NB_COL*COL_WIDTH)-1:0]  dina, // RAM input data
   input                           clka, // Clock
   input [NB_COL-1:0]              wea, // Byte-write enable
   input                           ena                            // RAM Enable, for additional power savings, disable port when not in use
);

  reg [(NB_COL*COL_WIDTH)-1:0] BRAM [RAM_DEPTH-1:0];
  reg [(NB_COL*COL_WIDTH)-1:0] ram_data = {(NB_COL*COL_WIDTH){1'b0}};

   wire [clogb2(RAM_DEPTH-1)-1:0] truncated_addra;

   assign truncated_addra = addra[clogb2(RAM_DEPTH-1)-1:0];

  // Address bus, width determined from RAM_DEPTH
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

  always @(negedge clka)
    if (ena) begin
      ram_data <= BRAM[truncated_addra];
    end

   generate
      genvar i;
      for (i = 0; i < NB_COL; i = i+1) begin: byte_write
         always @(negedge clka)
           if (wea[i])
             BRAM[truncated_addra][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= dina[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
      end
   endgenerate

   assign douta = ram_data;


  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction

endmodule

// The following is an instantiation template for byte_enabled_ram
/*
  //  Xilinx Single Port Byte-Write Read First RAM
  byte_enabled_ram #(
    .NB_COL(4),                           // Specify number of columns (number of bytes)
    .COL_WIDTH(9),                        // Specify column width (byte width, typically 8 or 9)
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE("")                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) your_instance_name (
    .truncated_addra(truncated_addra),     // Address bus, width determined from RAM_DEPTH
    .dina(dina),       // RAM input data, width determined from NB_COL*COL_WIDTH
    .clka(clka),       // Clock
    .wea(wea),         // Byte-write enable, width determined from NB_COL
    .ena(ena),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rsta),       // Output reset (does not affect memory contents)
    .regcea(regcea),   // Output register enable
    .douta(douta)      // RAM output data, width determined from NB_COL*COL_WIDTH
  );
*/
