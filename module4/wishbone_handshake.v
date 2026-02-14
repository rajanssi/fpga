module wishbone_handshake (
    input  wire in_clock,
    input  wire in_reset,
    input  wire in_wb_cyc,
    input  wire in_wb_stb,
    output reg  out_wb_ack
);

  always @(posedge in_clock) begin
    if (in_reset) begin
      out_wb_ack <= 0;
    end else begin
      if (out_wb_ack) begin
        out_wb_ack <= 0;
      end else if (in_wb_cyc & in_wb_stb) begin
        out_wb_ack <= 1;
      end
    end
  end

endmodule

