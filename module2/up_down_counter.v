module up_down_counter(
  input wire in_clock,
  input wire in_reset,
  input wire in_start,
  output wire out_ready,      // Changed from 'reg' to 'wire'
  output reg [3:0] out_value
);
  reg [1:0] state;
  
  localparam
    s_IDLE       = 2'd0,
    s_COUNT_UP   = 2'd1,
    s_COUNT_DOWN = 2'd2;

  assign out_ready = (state == s_IDLE);

  always @(posedge in_clock) begin
    if (in_reset) begin
      out_value <= 0;
      state <= s_IDLE;
    end
    else begin
      case (state)
        s_IDLE: begin
          if (in_start)
            state <= s_COUNT_UP;
        end
        s_COUNT_UP: begin
          out_value <= out_value + 1;
          if (out_value == 4'b1110)
            state <= s_COUNT_DOWN;
        end
        s_COUNT_DOWN: begin
          out_value <= out_value - 1;
          if (out_value == 4'b0001)
            state <= s_IDLE;
        end
      endcase
    end
  end
endmodule
