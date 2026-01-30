module spram(
  input wire in_clock,
  input wire in_reset,
  input wire in_enable,
  input wire in_write,
  input wire [9:0] in_address,
  input wire [15:0] in_data,
  output reg [15:0] out_data
);

  reg [15:0] memory [0:1023];

  always @(posedge in_clock) begin
    if (in_reset) begin
      out_data <= 0;
    end
    else if (in_enable & ~in_write) begin
      out_data <= memory[in_address];
    end
    else if (in_enable & in_write) begin
      memory[in_address] <= in_data;
    end
  end

endmodule
