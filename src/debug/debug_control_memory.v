module debug_control_memory
  #(
    parameter NB_LATCH = 32,
    parameter NB_INPUT_SIZE = 32,
    parameter NB_CONTROL_FRAME = 32,
    parameter CONTROLLER_ID = 6'b0000_00
    )
   (
    output wire [NB_CONTROL_FRAME-1:0] o_frame_to_interface,
    output wire                        o_mem_re,
    output wire                        o_writing,

    input wire [6-1:0]                 i_request_select,
    input wire [NB_INPUT_SIZE-1:0]     i_data_from_mips,

    input wire                         i_clock,
    input wire                         i_reset
    ) ;

   //Quick instance
   /*
   debug_control_memory
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_INPUT_SIZE        ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_ID        )
       )
   u_debug_control_memory
     (
      .o_frame_to_interface (o_frame_to_interface ),
      .o_mem_re             (o_mem_re             ),
      .o_writing            (o_writing            ),
      .i_request_select     (i_request_select     ),
      .i_data_from_mips     (i_data_from_mips     ),
      .i_clock              (i_clock              ),
      .i_reset              (i_reset              )
      ) ;
  */
   localparam NB_TIMER = 5;

   reg                                 timer_enable;
   reg [NB_TIMER-1:0]                  timer;
   wire                                request_match;
   reg                                 request_match_reg;
   wire                                request_match_pos;
   wire                                data_done;
   reg                                 tx_finished;

   assign o_frame_to_interface = i_data_from_mips;
   assign o_mem_re = request_match_pos;
   assign o_writing = timer_enable;

   assign request_match = i_request_select == CONTROLLER_ID;
   assign data_done = (NB_INPUT_SIZE/NB_LATCH) + (NB_INPUT_SIZE%NB_LATCH>0) == timer;

   always @(posedge i_clock)
     if (i_reset)
       request_match_reg <= 1'b0;
     else
       request_match_reg <= request_match;

   assign request_match_pos = request_match & ~request_match_reg;

   always @(posedge i_clock)
     if (i_reset | request_match_pos)
       tx_finished <= 1'b0;
     else if (data_done == 1'b1)
       tx_finished <= 1'b1;

   always @(posedge i_clock)
     if ((data_done | tx_finished) | i_reset)
       timer_enable <= 1'b0;
     else if (request_match)
       timer_enable <= 1'b1;

   always @(posedge i_clock)
     begin
        if (i_reset | tx_finished)
          timer <= {NB_TIMER{1'b0}};
        else if (request_match & ~(data_done | tx_finished))
          timer <= timer + 1'b1;
     end

endmodule
