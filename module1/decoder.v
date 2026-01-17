module decoder (in_address, out_select, out_error);
  parameter NUM_OUTPUT = 4;

  localparam N = NUM_OUTPUT;
  localparam M = $clog2(NUM_OUTPUT);

  input wire [M-1:0] in_address;
  output reg [N-1:0] out_select;
  output reg out_error;

  assign out_select = (in_address >= N) ? 0 : (1 << in_address);
  assign out_error  = (in_address >= N) ? 1 : 0;

  always @(*) begin
    if (in_address >= N) begin
      out_select <= 0;
      out_error <= 1;
    end
    else begin
      out_select <= 1 << in_address;
      out_error <= 0;
    end
  end

endmodule
