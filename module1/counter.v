module counter(
  input wire in_clock,
  input wire in_reset,
  input wire in_enable,

  output reg [8:0] out_value
);

  always @(posedge in_clock) begin 
    out_value <= in_reset ? 0 : out_value + in_enable;
  end

endmodule
