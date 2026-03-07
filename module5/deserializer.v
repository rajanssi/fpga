module deserializer(input  wire in_clock,
                    input  wire in_enable,
                    input  wire in_bit,
                    output reg [7:0] out_data);

  always @(posedge in_clock) begin
    if (in_enable) begin
      out_data <= {out_data[6:0], in_bit};
    end
  end
endmodule
