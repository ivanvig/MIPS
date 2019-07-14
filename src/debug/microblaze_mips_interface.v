/* Con el request de tiras de latches, viaja una señal de control a los escritores de cada bloque
Las tiras son de tamaño fijo igual al tamaño de la mayor tira, cuando termina se manda un EoD
 */



module microblaze_mips_interface
  #(
    parameter NB_CONTROL_FRAME = 32,
    parameter NB_ADDR_DATA = 16,
    parameter NB_INSTR_ADDR = 9
    )
   (
    output reg [NB_CONTROL_FRAME-1:0] o_frame_to_blaze,
    output wire                       o_valid,
    output reg                        o_reset,
    output wire [NB_ADDR_DATA-1:0]    o_instr_data,
    output wire [NB_INSTR_ADDR-1:0]   o_instr_addr,
    output reg [4-1:0]                o_instr_mem_we,
    //output reg                        //o_read_request,
    output wire [NB_ADDR_DATA-1:0]    o_mem_addr,
    output wire [6-1:0]               o_request_select, //Select latch group/reg/PC/

    input wire [NB_CONTROL_FRAME-1:0] i_frame_from_blaze,
    input wire [NB_CONTROL_FRAME-1:0] i_frame_from_mips,
    input wire                        i_eod,
    input wire                        i_eop,

    input wire                        i_clock,
    input wire                        i_reset
    );

   // 32 INSTR CODE 26 | 25 ADDR_TYPE 16 | 15 DATA 0 |
   localparam NB_INSTR_CODE_FIELD = 6;
   localparam NB_ADDR_TYPE_FIELD = 10;
   localparam NB_INSTR_ADDRESS_FIELD = 16;

   //INSTRUCTION CODES
   localparam START                = 6'b0000_01;
   localparam RESET                = 6'b0000_10;
   localparam LOAD_INSTR_LSB       = 6'b0001_00;
   localparam LOAD_INSTR_MSB       = 6'b0001_01;
   localparam REQ_DATA             = 6'b0000_11;
   localparam MODE_GET             = 6'b0010_00;
   localparam MODE_SET_CONT        = 6'b0010_01;
   localparam MODE_SET_STEP        = 6'b0010_10;
   localparam STEP                 = 6'b1000_00;

   //INSTRUCTION TYPE
   localparam REQ_MEM_DATA         = 9'b000_0000_01;
   localparam REQ_MEM_INSTR        = 9'b000_0000_10;
   localparam REQ_REG              = 9'b000_0001_00;
   localparam REQ_REG_PC           = 9'b000_0001_01;
   localparam REQ_LATCH_FETCH_DATA = 9'b000_0010_00;
   localparam REQ_LATCH_FETCH_CTRL = 9'b000_0010_01;
   localparam REQ_LATCH_DECO_DATA  = 9'b000_0100_00;
   localparam REQ_LATCH_DECO_CTRL  = 9'b000_0100_01;
   localparam REQ_LATCH_EXEC_DATA  = 9'b000_1000_00;
   localparam REQ_LATCH_EXEC_CTRL  = 9'b000_1000_01;
   localparam REQ_LATCH_MEM_DATA   = 9'b001_0000_00;
   localparam REQ_LATCH_MEM_CTRL   = 9'b001_0000_01;

   wire [NB_INSTR_CODE_FIELD-1:0]      instruction_code;
   wire [NB_ADDR_TYPE_FIELD-1:0]       address_type;
   wire [NB_INSTR_ADDRESS_FIELD-1:0]   instruction_data;

   reg                                 valid;
   reg                                 set_mode;
   reg                                 return_mode;
   reg                                 use_type_lut;

   reg                                 execution_mode;
   reg                                 instr_valid_d;

   wire                                pos_instr_valid;

   reg [6-1:0]                         request_select;

   //Interface to blaze
   //cuando llega EOD, cambiar request_select a algo que no matchee con ningun ID para no dejar el match de los
   //comparadores con el ID en alto


   //Interface to mips

   //assign o_frame_to_blaze = i_frame_from_mips;
   assign o_instr_data = instruction_data;
   assign o_instr_addr = (instruction_code == REQ_DATA) ? instruction_data : address_type[NB_INSTR_ADDR:0];
   assign o_mem_addr = instruction_data;
   assign o_request_select = request_select;

   assign {instruction_code, address_type, instruction_data} = i_frame_from_blaze;

   //address_type[9] use as instruction valid in microblaze
   always @(posedge i_clock)
     begin
        instr_valid_d <= address_type[9];
     end
   assign pos_instr_valid = address_type[9] & ~instr_valid_d;

   always @(posedge i_clock)
     begin
        if (i_reset)
          execution_mode <= 1'b0;
        else
          execution_mode <= set_mode;
     end

   //Activate valid according to mode set
   // always @(posedge i_clock) begin
   //   if (i_reset)
   //     o_valid <= 1'b0;
   //   else if (execution_mode) //Step mode
   //     o_valid <= valid & pos_instr_valid;
   //   else //Continuous mode
   //     o_valid <= valid;
   // end
   assign o_valid = (execution_mode) ? valid & pos_instr_valid : valid;


   always @(*)
     begin
        o_reset = 1'b0;
        o_instr_mem_we = 4'b0000;
        //o_read_request = 1'b0;
        use_type_lut = 1'b0;
        return_mode = 1'b0;
        if (pos_instr_valid) begin
           casez (instruction_code)
             START: begin
                valid = 1'b1;
                o_reset = 1'b0;
                o_instr_mem_we = 4'b0000;
                //o_read_request = 1'b0;
                use_type_lut = 1'b0;
                return_mode = 1'b0;
             end
             RESET: begin
                valid = 1'b0;
                o_reset = 1'b1;
                o_instr_mem_we = 4'b0000;
                //o_read_request = 1'b0;
                use_type_lut = 1'b0;
                return_mode = 1'b0;
             end
             LOAD_INSTR_LSB: begin
                o_reset = 1'b0;
                o_instr_mem_we = 4'b0011;
                //o_read_request = 1'b0;
                use_type_lut = 1'b0;
                return_mode = 1'b0;
             end
             LOAD_INSTR_MSB: begin
                o_reset = 1'b0;
                o_instr_mem_we = 4'b1100;
                //o_read_request = 1'b0;
                use_type_lut = 1'b0;
                return_mode = 1'b0;
             end
             REQ_DATA: begin
                o_reset = 1'b0;
                o_instr_mem_we = 4'b0000;
                //o_read_request = 1'b1;
                use_type_lut = 1'b1;
                return_mode = 1'b0;
             end
             MODE_GET: begin
                o_reset = 1'b0;
                o_instr_mem_we = 4'b0000;
                //o_read_request = 1'b0;
                use_type_lut = 1'b0;
                return_mode = 1'b1;
             end
             MODE_SET_CONT: begin
                set_mode = 1'b0;

                o_reset = 1'b0;
                o_instr_mem_we = 4'b0000;
                //o_read_request = 1'b0;
                use_type_lut = 1'b0;
                return_mode = 1'b0;
             end
             MODE_SET_STEP: begin
                set_mode = 1'b1;

                o_reset = 1'b0;
                o_instr_mem_we = 4'b0000;
                //o_read_request = 1'b0;
                use_type_lut = 1'b0;
                return_mode = 1'b0;
             end
             STEP: begin
                valid = 1'b1;

                o_reset = 1'b0;
                o_instr_mem_we = 4'b0000;
                //o_read_request = 1'b0;
                use_type_lut = 1'b0;
                return_mode = 1'b0;
             end
             default: begin
                o_reset = 1'b0;
                o_instr_mem_we = 4'b0000;
                //o_read_request = 1'b0;
                use_type_lut = 1'b0;
                return_mode = 1'b0;
             end
           endcase // casez (instruction_code)
        end
     end // always @ (*)

   //For requesting data
   always @(*)
     begin
        if (pos_instr_valid) begin
           if (use_type_lut)
             casez (address_type[NB_INSTR_ADDR-1:0])
               REQ_MEM_DATA: request_select = 6'b1000_00 ;
               REQ_MEM_INSTR: request_select = 6'b1000_01 ;
               REQ_REG: request_select = {1'b0,instruction_data[5-1:0]}; //Last 5 bits in instruction data have the request REG
               REQ_REG_PC: request_select = 6'b1000_10 ;
               REQ_LATCH_FETCH_DATA: request_select = 6'b1001_00 ;
               REQ_LATCH_FETCH_CTRL: request_select = 6'b1001_01 ;
               REQ_LATCH_DECO_DATA: request_select = 6'b1001_10 ;
               REQ_LATCH_DECO_CTRL: request_select = 6'b1001_11 ;
               REQ_LATCH_EXEC_DATA: request_select = 6'b1010_00 ;
               REQ_LATCH_EXEC_CTRL: request_select = 6'b1010_01 ;
               REQ_LATCH_MEM_DATA: request_select = 6'b1010_10 ;
               REQ_LATCH_MEM_CTRL: request_select = 6'b1010_11 ;
               default: request_select = 6'b0000_00;
             endcase // casez (address_type)
        end // if (pos_instr_valid)
     end



endmodule
