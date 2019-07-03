module debug_control_tb ();
   //==========================================================================
   // LOCAL PARAMETERS.
   //==========================================================================
   localparam NB_LATCH = 32;
   localparam NB_INPUT_SIZE1 = 96;
   localparam NB_INPUT_SIZE2 = 104;
   localparam NB_INPUT_SIZE3 = 144;
   localparam NB_CONTROL_FRAME = 32;
   localparam CONTROLLER_ID1 = 6'b0000_01;
   localparam CONTROLLER_ID2 = 6'b0000_10;
   localparam CONTROLLER_ID3 = 6'b0000_11;

   //==========================================================================
   // INTERNAL SIGNALS.
   //==========================================================================
   reg  [10-1:0]             tb_timer = 'b0;

   wire [NB_CONTROL_FRAME-1:0] frame_to_interface_1;
   wire writing_1;
   wire [NB_CONTROL_FRAME-1:0] frame_to_interface_2;
   wire writing_2;
   wire [NB_CONTROL_FRAME-1:0] frame_to_interface_3;
   wire writing_3;

   reg [6-1:0]               request_select;
   wire [NB_INPUT_SIZE1-1:0] data_from_mips_1;
   wire [NB_INPUT_SIZE2-1:0] data_from_mips_2;
   wire [NB_INPUT_SIZE3-1:0] data_from_mips_3;
   reg                       tb_clock_i = 1'b0;
   wire                      tb_reset_i;

   //==========================================================================
   // CONNECTION TO DUT
   //==========================================================================
   debug_control
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_INPUT_SIZE1        ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_ID1        )
       )
   u_debug_control1
     (
      .o_frame_to_interface (frame_to_interface_1 ),
      .o_writing            (writing_1            ),
      .i_request_select     (request_select     ),
      .i_data_from_mips     (data_from_mips_1     ),
      .i_clock              (tb_clock_i              ),
      .i_reset              (tb_reset_i              )
      ) ;

   debug_control
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_INPUT_SIZE2        ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_ID2        )
       )
   u_debug_control2
     (
      .o_frame_to_interface (frame_to_interface_2 ),
      .o_writing            (writing_2            ),
      .i_request_select     (request_select     ),
      .i_data_from_mips     (data_from_mips_2     ),
      .i_clock              (tb_clock_i              ),
      .i_reset              (tb_reset_i              )
      ) ;

   debug_control
     #(
       .NB_LATCH            (NB_LATCH             ),
       .NB_INPUT_SIZE       (NB_INPUT_SIZE3       ),
       .NB_CONTROL_FRAME    (NB_CONTROL_FRAME     ),
       .CONTROLLER_ID       (CONTROLLER_ID3       )
       )
   u_debug_control3
     (
      .o_frame_to_interface (frame_to_interface_3 ),
      .o_writing            (writing_3            ),
      .i_request_select     (request_select     ),
      .i_data_from_mips     (data_from_mips_3     ),
      .i_clock              (tb_clock_i              ),
      .i_reset              (tb_reset_i              )
      ) ;
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

   assign data_from_mips_1 = {NB_INPUT_SIZE1/4{4'hA}};
   assign data_from_mips_2 = {NB_INPUT_SIZE2/4{4'hB}};
   assign data_from_mips_3 = {NB_INPUT_SIZE3/4{4'hC}};

   always @ (*)
     begin
        case(tb_timer)
          4: begin
             request_select = CONTROLLER_ID1;
          end
          10: begin
             request_select = CONTROLLER_ID2;
          end
          20: begin
             request_select = CONTROLLER_ID3;
          end
          40: begin
             request_select = CONTROLLER_ID1;
          end

          default: begin
          end
        endcase
     end

endmodule
