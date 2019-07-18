module debug_control_latches
  #(
    parameter NB_LATCH = 32,
    parameter NB_INPUT_SIZE = 32,
    parameter NB_CONTROL_FRAME = 32,
    parameter CONTROLLER_ID = 6'b0000_00
    )
   (
    output wire [NB_CONTROL_FRAME-1:0] o_frame_to_interface,
    output wire                        o_writing,

    input wire [6-1:0]                 i_request_select,
    input wire [NB_INPUT_SIZE-1:0]     i_data_from_mips,

    input wire                         i_clock,
    input wire                         i_reset
    ) ;

   //Quick instance
   /*
   debug_control
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_INPUT_SIZE        ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_ID        )
       )
   u_debug_control
     (
      .o_frame_to_interface (o_frame_to_interface ),
      .o_writing            (o_writing            ),
      .i_request_select     (i_request_select     ),
      .i_data_from_mips     (i_data_from_mips     ),
      .i_clock              (i_clock              ),
      .i_reset              (i_reset              )
      ) ;
  */

   localparam NB_TIMER = 5;
   localparam NB_PADDING = (NB_INPUT_SIZE%NB_LATCH==0) ? 0 : NB_LATCH-(NB_INPUT_SIZE%NB_LATCH);
   localparam NB_PADDED_DATA = NB_INPUT_SIZE + NB_PADDING;

   reg [NB_TIMER-1:0]                  timer;
   wire                                request_match;
   reg                                 request_match_reg;
   wire                                request_match_pos;
   reg                                 processing_reg;
   wire                                data_done;
   reg                                 data_done_reg;

   wire [NB_PADDED_DATA-1:0]           padded_data_from_mips;

   assign o_frame_to_interface = padded_data_from_mips[NB_PADDED_DATA-(timer*NB_LATCH)-1-:NB_LATCH];
   assign o_writing = processing_reg & ~data_done_reg;

   assign padded_data_from_mips = {i_data_from_mips, {NB_PADDING{1'b0}}};
   assign request_match = i_request_select == CONTROLLER_ID;
   assign data_done = (NB_INPUT_SIZE/NB_LATCH) + (NB_INPUT_SIZE%NB_LATCH>0) == timer+1;

   always @(posedge i_clock)
     if (i_reset) begin
       request_match_reg <= 1'b0;
        data_done_reg <= 1'b0;
     end else begin
       request_match_reg <= request_match;
        data_done_reg <= data_done;
     end

   always @(posedge i_clock)
     if (i_reset | data_done)
       processing_reg <= 1'b0;
     else if (request_match_pos)
       processing_reg <= 1'b1;

   assign request_match_pos = request_match & ~request_match_reg;

   always @(posedge i_clock)
     begin
        if (i_reset | data_done)
          timer <= {NB_TIMER{1'b0}};
        else if (processing_reg & ~data_done)
          timer <= timer + 1'b1;
     end
endmodule
