module memory_access
  #(
    parameter NB_REG = 32,
    parameter NB_MEM = 5,
    parameter NB_WB = 8,
    parameter N_ADDR = 2048,
    parameter DATA_FILE = ""
    )
   (
    output reg [NB_REG-1:0]  o_reg_wb,
    output reg [NB_REG-1:0]  o_ext_mem_o,
    output reg [NB_WB-1:0]   o_wb,
    output reg [NB_REG-1:0]  o_pc,

    //For debugging
    output wire [NB_REG-1:0] o_debug_datamem_data,

    input wire [NB_REG-1:0]  i_alu_o,
    input wire [NB_REG-1:0]  i_b_o,
    input wire [NB_MEM-1:0]  i_mem,
    input wire [NB_WB-1:0]   i_wb,
    input wire [NB_REG-1:0]  i_pc,

    //For debugging
    input wire [16-1:0]      i_debug_datamem_addr,
    input wire               i_debug_datamem_re,

    input wire               i_reset,
    input wire               i_clock,
    input wire               i_valid
) ;
   localparam NB_ADDR = NB_REG ;

   //Data mem signals
   wire                      re;
   wire                      we;
   wire [NB_MEM-3-1:0]       dsize;
   //Sign extension
   wire                      s_u;

   wire [2-1:0]              offset; //Selectors for multiplexers in address

   wire [NB_REG-1:0]         mem_o ;

   reg [NB_REG-1:0]          extended_mem_o ; //after sign extension

   //Write enable cables
   wire [NB_REG/8-1:0]       extended_we ;
   wire                      we_0;
   wire                      we_1;

   wire                      we_00;
   wire                      we_01;
   wire                      we_10;
   wire                      we_11;

   //Mplexers for memory
   wire [NB_ADDR/2-1:0]      mux_16 ;
   wire [NB_ADDR/4-1:0]      mux_8;

   assign {re,we,s_u,dsize} = i_mem ;

   assign offset = i_b_o[1:0];

   assign mux_16 = (offset[1]) ? mem_o[NB_REG-1-:NB_REG/2] : mem_o[NB_REG/2-1-:NB_REG/2];
   assign mux_8 = (offset[0]) ? mux_16[NB_REG/2-1-:NB_REG/4] : mux_16[NB_REG/4-1-:NB_REG/4];

   assign we_0 = !offset[1] & we;
   assign we_1 = offset[1] & we;
   assign we_00 = we_0 & !offset[0];
   assign we_01 = we_0 & offset[0];
   assign we_10 = we_1 & !offset[1];
   assign we_11 = we_1 & offset[1];

   assign extended_we = {{4{we & dsize[1]}} | {{2{we_1}},{2{we_0}}} & {4{dsize[0]}} | {we_00,we_01,we_10,we_11} &  {4{(~&dsize)}}} ; //

   always @ (*)
     begin
        case (dsize) //Do sign extension if signaled by s_u
          2'b00: extended_mem_o = (s_u) ? {{(NB_REG-NB_REG/4){1'b0}}, mux_8} : {{(NB_REG-NB_REG/4){mux_8[NB_ADDR/4-1]}}, mux_8} ;
          2'b01: extended_mem_o = (s_u) ? {{(NB_REG-NB_REG/2){1'b0}}, mux_16} : {{(NB_REG-NB_REG/2){mux_16[NB_ADDR/2-1]}}, mux_16};
          2'b10: extended_mem_o = mem_o;
          default:
            extended_mem_o = mem_o ;
        endcase
     end

   always @ (posedge i_clock)
     begin
        if (i_reset) begin
           o_reg_wb <= {NB_REG{1'b0}};
        o_ext_mem_o <= {NB_REG{1'b0}};
        o_wb <= {NB_WB{1'b0}};
        o_pc <= {NB_REG{1'b0}};
     end else if (i_valid) begin
        o_reg_wb <= i_alu_o ;
        o_wb <= i_wb ;
        o_pc <= i_pc ;
        o_ext_mem_o <= extended_mem_o ;
     end
     end // always @ (posedge i_clock)

   byte_enabled_dual_port
     #(
       .NB_COL          (4                ),
       .COL_WIDTH       (8                ),
       .RAM_DEPTH       (N_ADDR           ),
       .RAM_PERFORMANCE ("RAM_PERFORMANCE"),
       .INIT_FILE       (DATA_FILE        )
       )
   u_instruction_memory
     (
      .o_data_a         (mem_o                  ),
      .o_data_b         (o_debug_datamem_data   ), //For debugging
      .i_addr_a         (i_alu_o                ),
      .i_addr_b         (i_debug_datamem_addr   ),
      .i_data_a         (i_b_o                  ),
      .i_data_b         (/*   NOT CONNECTED   */),
      .i_clock          (i_clock                ),
      .wea              (extended_we            ),
      .web              (1'b0                   ),
      .ena              (1'b1                   ),
      .enb              (1'b1                   ),
      .i_reset_a        (i_reset                ),
      .i_reset_b        (i_reset                ),
      .i_rea            (re                     ),
      .i_reb            (i_debug_datamem_re     )
      );

/*
  byte_enabled_ram #(
    .NB_COL(NB_REG/8),                           // Specify number of columns (number of bytes)
    .COL_WIDTH(8),                        // Specify column width (byte width, typically 8 or 9)
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .INIT_FILE(DATA_FILE),                        // Specify name/location of RAM initialization file if using one (leave blank if not)
    .NB_ADDR(NB_ADDR)
  )
   u_byte_enabled_ram (
    .douta(mem_o),
    .addra(i_alu_o),     // Address bus, width determined from RAM_DEPTH
    .dina(i_b_o),       // RAM input data, width determined from NB_COL*COL_WIDTH
    .clka(i_clock),       // Clock
    .wea(extended_we),         // Byte-write enable, width determined from NB_COL
    .ena(re)         // RAM Enable, for additional power savings, disable port when not in use
  );*/

endmodule
