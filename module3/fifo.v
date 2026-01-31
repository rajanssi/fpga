module fifo #(
    parameter FIFO_ASIZE = 4,
    DATA_WIDTH = 8
) (
    input  wire in_clock,
    input  wire in_reset,
    input  wire in_take,
    input  wire in_put,
    output wire out_empty,
    output wire out_full,
    output wire [DATA_WIDTH-1:0] out_data,
    input  wire [DATA_WIDTH-1:0] in_data
);
  reg  [DATA_WIDTH-1:0] memory[(1<< FIFO_ASIZE)];
  wire [FIFO_ASIZE-1:0] write_pointer;
  wire [FIFO_ASIZE-1:0] read_pointer;

  fifo_controller #(FIFO_ASIZE) u_fifo_controller (
      .in_clock(in_clock),
      .in_reset(in_reset),
      .in_take(in_take),
      .in_put(in_put),
      .out_empty(out_empty),
      .out_full(out_full),
      .out_write_pointer(write_pointer),
      .out_read_pointer(read_pointer)
  );

  assign out_data = memory[read_pointer];

  always @(posedge in_clock) begin
    if (!out_full && in_put) begin
      memory[write_pointer] <= in_data;
    end
  end

endmodule

