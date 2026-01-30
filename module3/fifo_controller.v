module fifo_controller #(parameter FIFO_ASIZE = 4) 
(
  input  wire in_clock,
  input  wire in_reset,         
  input  wire in_take,
  input  wire in_put,
  output reg out_empty,
  output reg out_full,
  output reg[FIFO_ASIZE-1:0] out_write_pointer,
  output reg[FIFO_ASIZE-1:0] out_read_pointer
);
  
  reg[FIFO_ASIZE:0] read_counter;
  reg[FIFO_ASIZE:0] write_counter;

  initial out_write_pointer = 0;
  initial out_read_pointer = 0;
  
  always @(posedge in_clock) begin
    if (in_reset) begin
      out_write_pointer <= 0;
      out_read_pointer <= 0;
      out_empty <= 1;
      out_full <= 0;
    end
  end


endmodule
