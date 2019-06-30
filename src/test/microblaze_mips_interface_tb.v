module microblaze_mips_interface_tb ();
   //==========================================================================
   // LOCAL PARAMETERS.
   //==========================================================================
   localparam NB_CONTROL_FRAME = 32;
   localparam NB_ADDR_DATA = 16;
   localparam NB_INSTR_ADDR = 9;
   //==========================================================================
   // INTERNAL SIGNALS.
   //==========================================================================
   wire [NB_CONTROL_FRAME-1:0]  frame_to_blaze_o;
   wire                         valid_o;
   wire                         reset_o;
   wire [NB_ADDR_DATA-1:0]      instr_data_o;
   wire [NB_INSTR_ADDR-1:0]     instr_addr_o;
   wire [4-1:0]                 instr_mem_we_o;
   wire                         read_request_o;
   wire [NB_ADDR_DATA-1:0]      mem_addr_o;
   wire [6-1:0]                 request_select_o;
   wire [NB_CONTROL_FRAME-1:0]  frame_from_blaze_i;
   wire [NB_CONTROL_FRAME-1:0]  frame_from_mips_i;

   wire                         tb_reset_i ;
   reg                          tb_clock_i = 1'b0 ;
   integer                      tb_timer = 0 ;

   reg [6-1:0]                  instruction_code;
   reg                          instruction_valid;
   reg [9-1:0]                  addr_type;
   reg [16-1:0]                 address;

   //==========================================================================
   // CONNECTION TO DUT
   //==========================================================================

   microblaze_mips_interface
     #(
       .NB_CONTROL_FRAME  (NB_CONTROL_FRAME),
       .NB_ADDR_DATA      (NB_ADDR_DATA    ),
       .NB_INSTR_ADDR     (NB_INSTR_ADDR   )
       )
   u_microblaze_mips_interface
     (
      .o_frame_to_blaze   (frame_to_blaze_o ),
      .o_valid            (valid_o          ),
      .o_reset            (reset_o          ),
      .o_instr_data       (instr_data_o     ),
      .o_instr_addr       (instr_addr_o     ),
      .o_instr_mem_we     (instr_mem_we_o   ),
      .o_read_request     (read_request_o   ),
      .o_mem_addr         (mem_addr_o       ),
      .o_request_select   (request_select_o ),
      .i_frame_from_blaze (frame_from_blaze_i),
      .i_frame_from_mips  (frame_from_mips_i),
      .i_clock            (tb_clock_i       ),
      .i_reset            (tb_reset_i       )
      );

   //==========================================================================
   // ALGORITHM.
   //==========================================================================
   always
     begin
        #(50) tb_clock_i = ~tb_clock_i ;
     end

   always @ ( posedge tb_clock_i )
     begin
        tb_timer   <= tb_timer + 1;
     end

   assign tb_reset_i = (tb_timer == 2) ; // Reset at time 2

   assign frame_from_blaze_i = {instruction_code,instruction_valid,addr_type,address};

   always @ (*)
     begin
        case(tb_timer)
          4: begin
             instruction_code = 6'b0010_10; //NADA2
             instruction_valid = 1'b0;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
          5: begin
             instruction_code = 6'b0000_10;
             instruction_valid = 1'b1;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
          6: begin
             instruction_code = 6'b0010_10; //NADA2
             instruction_valid = 1'b0;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
          7: begin
             instruction_code = 6'b0001_00; //LOAD LSB
             instruction_valid = 1'b1;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
          8: begin
             instruction_code = 6'b0010_10; //NADA2
             instruction_valid = 1'b0;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
          9: begin
             instruction_code = 6'b0001_01; //LOAD MSB
             instruction_valid = 1'b1;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
          10: begin
             instruction_code = 6'b0010_10; //NADA2
             instruction_valid = 1'b0;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
          11: begin
             instruction_code = 6'b0010_10; //SET STEP
             instruction_valid = 1'b1;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
          12: begin
             instruction_code = 6'b0010_10; //NADA2
             instruction_valid = 1'b0;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
          13: begin
             instruction_code = 6'b1000_00; //STEP
             instruction_valid = 1'b1;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
          14: begin
             instruction_code = 6'b1000_00; //NADA
             instruction_valid = 1'b0;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
          15: begin
             instruction_code = 6'b0000_11; //REQ DATA
             instruction_valid = 1'b1;
             addr_type = 9'b0000_0001_0; //REQ REG 2
             address= 16'b0000_0000_0000;
          end
          default: begin
             instruction_code = 6'b0000_10; //REQ DATA
             instruction_valid = 1'b1;
             addr_type = 9'b0000_0000_0;
             address= 16'b0000_0000_0000;
          end
        endcase
     end

endmodule
