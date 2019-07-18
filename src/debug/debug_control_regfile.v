module debug_control_regfile
  #(
    parameter NB_LATCH = 32,
    parameter NB_INPUT_SIZE = 32,
    parameter NB_CONTROL_FRAME = 32,
    parameter CONTROLLER_ID = 6'b0000_00
    )
   (
    output wire [NB_CONTROL_FRAME-1:0] o_frame_to_interface,
    output wire [5-1:0]                o_reg_addr,
    output wire                        o_writing,

    input wire [6-1:0]                 i_request_select,
    input wire [NB_INPUT_SIZE-1:0]     i_data_from_mips,

    input wire                         i_clock,
    input wire                         i_reset
    ) ;

   //Quick instance
   /*
   debug_control_regfile
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_INPUT_SIZE        ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_ID        )
       )
   u_debug_control_regfile
     (
      .o_frame_to_interface (o_frame_to_interface ),
      .o_reg_addr           (o_reg_addr           ),
      .o_writing            (o_writing            ),
      .i_request_select     (i_request_select     ),
      .i_data_from_mips     (i_data_from_mips     ),
      .i_clock              (i_clock              ),
      .i_reset              (i_reset              )
      ) ;
  */
   wire                                request_match;
   reg                                 request_match_reg;

   assign o_frame_to_interface = i_data_from_mips;
   assign o_reg_addr = i_request_select[5-1:0];
   assign o_writing = request_match_reg;

   assign request_match = i_request_select[5] == 1'b0;

   always @(posedge i_clock)
     if (i_reset)
       request_match_reg <= 1'b0;
     else
       request_match_reg <= request_match;

endmodule
