module edge_detector(input wire in_clock,
                     input wire in_signal,
                     output wire out_strobe);
  reg asserted = 0;
  always @(posedge in_clock) begin
    asserted <= in_signal;
  end

  assign out_strobe = ~asserted & in_signal;
endmodule
