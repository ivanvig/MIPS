//  Xilinx True Dual Port RAM Byte Write, Write First Single Clock RAM
//  This code implements a parameterizable true dual port memory (both ports can read and write).
//  The behavior of this RAM is when data is written, the new memory contents at the write
//  address are presented on the output port.

module byte_enabled_dual_port
  #(
    parameter NB_COL = 4,                       // Specify number of columns (number of bytes)
    parameter COL_WIDTH = 8,                  // Specify column width (byte width, typically 8 or 9)
    parameter RAM_DEPTH = 2048,                  // Specify RAM depth (number of entries)
    parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    parameter INIT_FILE = ""                       // Specify name/location of RAM initialization file if using one (leave blank if not)
    )
   (
    output wire [(NB_COL*COL_WIDTH)-1:0] o_data_a, // Port A RAM output data
    output wire [(NB_COL*COL_WIDTH)-1:0] o_data_b, // Port B RAM output data

    input wire [clogb2(RAM_DEPTH-1)-1:0] i_addr_a, // Port A address bus, width determined from RAM_DEPTH
    input wire [clogb2(RAM_DEPTH-1)-1:0] i_addr_b, // Port B address bus, width determined from RAM_DEPTH
    input wire [(NB_COL*COL_WIDTH)-1:0]  i_data_a, // Port A RAM input data
    input wire [(NB_COL*COL_WIDTH)-1:0]  i_data_b, // Port B RAM input data
    input wire                           i_clock, // Clock
    input wire [NB_COL-1:0]              wea, // Port A write enable
    input wire [NB_COL-1:0]              web, // Port B write enable
    input wire                           ena, // Port A RAM Enable, for additional power savings, disable BRAM when not in use
    input wire                           enb, // Port B RAM Enable, for additional power savings, disable BRAM when not in use
    input wire                           i_reset_a, // Port A output reset (does not affect memory contents)
    input wire                           i_reset_b, // Port B output reset (does not affect memory contents)
    input wire                           i_rea, // Port A output register enable
    input wire                           i_reb // Port B output register enable
    );

   /*
   byte_enabled_dual_port
     #(
       .NB_COL          (NB_COL          ),
       .COL_WIDTH       (COL_WIDTH       ),
       .RAM_DEPTH       (RAM_DEPTH       ),
       .RAM_PERFORMANCE (RAM_PERFORMANCE ),
       .INIT_FILE       (INIT_FILE       )
       )
   u_byte_enabled_dual_port
     (
      .o_data_a         (o_data_a        ),
      .o_data_b         (o_data_b        ),
      .i_addr_a         (i_addr_a        ),
      .i_addr_b         (i_addr_b        ),
      .i_data_a         (i_data_a        ),
      .i_data_b         (i_data_b        ),
      .i_clock          (i_clock         ),
      .wea              (wea             ),
      .web              (web             ),
      .ena              (ena             ),
      .enb              (enb             ),
      .i_reset_a        (i_reset_a       ),
      .i_reset_b        (i_reset_b       ),
      .i_rea            (i_rea           ),
      .i_reb            (i_reb           )
      );
    */

  reg [(NB_COL*COL_WIDTH)-1:0] BRAM [RAM_DEPTH-1:0];
  reg [(NB_COL*COL_WIDTH)-1:0] ram_data_a = {(NB_COL*COL_WIDTH){1'b0}};
  reg [(NB_COL*COL_WIDTH)-1:0] ram_data_b = {(NB_COL*COL_WIDTH){1'b0}};

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

  generate
  genvar i;
     for (i = 0; i < NB_COL; i = i+1) begin: byte_write
       always @(posedge i_clock)
         if (ena)
           if (wea[i]) begin
             BRAM[i_addr_a][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= i_data_a[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
             ram_data_a[(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= i_data_a[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
           end else begin
             ram_data_a[(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= BRAM[i_addr_a][(i+1)*COL_WIDTH-1:i*COL_WIDTH];
           end

       always @(posedge i_clock)
         if (enb)
           if (web[i]) begin
             BRAM[i_addr_b][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= i_data_b[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
             ram_data_b[(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= i_data_b[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
           end else begin
             ram_data_b[(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= BRAM[i_addr_b][(i+1)*COL_WIDTH-1:i*COL_WIDTH];
           end
     end
  endgenerate

  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign o_data_a = ram_data_a;
       assign o_data_b = ram_data_b;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [(NB_COL*COL_WIDTH)-1:0] douta_reg = {(NB_COL*COL_WIDTH){1'b0}};
      reg [(NB_COL*COL_WIDTH)-1:0] doutb_reg = {(NB_COL*COL_WIDTH){1'b0}};

      always @(posedge i_clock)
        if (i_reset_a)
          douta_reg <= {(NB_COL*COL_WIDTH){1'b0}};
        else if (i_rea)
          douta_reg <= ram_data_a;

      always @(posedge i_clock)
        if (i_reset_b)
          doutb_reg <= {(NB_COL*COL_WIDTH){1'b0}};
        else if (i_reb)
          doutb_reg <= ram_data_b;

      assign o_data_a = douta_reg;
      assign o_data_b = doutb_reg;

    end
  endgenerate

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction // clogb2

endmodule
