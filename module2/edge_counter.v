module edge_detector(
  input wire in_clock,
  input wire in_signal,
  output wire out_strobe
);

  reg asserted = 0;
  always @(posedge in_clock) begin
    asserted <= in_signal;
  end

  assign out_strobe = ~asserted & in_signal;
endmodule

module counter(
  input wire in_clock,
  input wire in_reset,
  input wire in_enable,

  output reg [7:0] out_value
);

  always @(posedge in_clock) begin 
    out_value <= in_reset ? 0 : out_value + in_enable;
  end

endmodule

module edge_counter(
  input wire in_clock,
  input wire in_reset,
  input wire in_signal,
  output wire out_pulse,
  output wire [7:0] out_count
);

  edge_detector u_edge_detector( in_clock, in_signal, out_pulse);
  counter u_counter( in_clock, in_reset, out_pulse, out_count);

endmodule
