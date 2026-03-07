module serializer(input  wire in_clock,
                  input  wire in_write,
                  input  wire [7:0] in_data,
                  input  wire in_enable,
                  output reg out_bit);
  reg [7:0] internal_register;

  always @(posedge in_clock) begin
    if (in_write) begin
      internal_register <= in_data;
      out_bit <= in_data[7];
    end
    else if (in_enable) begin
      out_bit <= internal_register[6];
      internal_register <= internal_register << 1;
    end
  end
endmodule
