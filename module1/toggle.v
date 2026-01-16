module toggle(input wire in_clock,
              output reg out_data);
  initial out_data = 0;
  always @(posedge in_clock) begin
    out_data <= ~out_data;
  end

endmodule
