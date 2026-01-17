module multiplexer(input wire I0,
                   input wire I1,
                   input wire I2,
                   input wire I3,
                   input wire [1:0] S,

                   output wire O);
  always @(*) begin
    if (S == 0) begin
      O <= I0;
    end
    if (S == 1) begin
      O <= I1;
    end
    if (S == 2) begin
      O <= I2;
    end
    if (S == 3) begin
      O <= I3;
    end
  end
endmodule
