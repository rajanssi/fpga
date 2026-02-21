module pulse_extender(
  input  wire in_clock,
  input  wire in_reset,
  input  wire in_set,
  input  wire[7:0] in_value,
  output reg  out_ack,
  input  wire in_signal,
  output reg  out_signal
);
  reg [7:0] pulse_width;
  reg [7:0] active_pulse_width;
  reg [7:0] counter;

  always @(posedge in_clock) begin
    if (in_reset) begin
      pulse_width <= 1;
      out_ack <= 0;
      out_signal <= 0;
      counter <= 0;
    end
    else begin 
      if (in_set) begin
        pulse_width <= in_value;
        out_ack <= 1;
      end
      else begin
        out_ack <= 0;
      end
      if (out_signal == 0) begin
        active_pulse_width <= pulse_width;
        if (in_signal) begin
          out_signal <= 1;
          counter <= 0;
        end
      end
      else begin
        if (counter != (active_pulse_width - 1)) begin
          counter <= counter + 1;
        end 
        if (counter == (active_pulse_width - 1) && !in_signal) begin
          out_signal <= 0;
        end
      end
    end
  end
endmodule
