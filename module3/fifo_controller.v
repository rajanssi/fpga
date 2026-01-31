module fifo_controller #(parameter FIFO_ASIZE = 4) 
(
  input  wire in_clock,
  input  wire in_reset,         
  input  wire in_take,
  input  wire in_put,
  output wire out_empty,
  output wire out_full,
  output wire[FIFO_ASIZE-1:0] out_write_pointer,
  output wire[FIFO_ASIZE-1:0] out_read_pointer
);
  
  reg[FIFO_ASIZE:0] write_counter;
  reg[FIFO_ASIZE:0] read_counter;

  assign out_empty = (write_counter == read_counter);

  assign out_full  = (write_counter[FIFO_ASIZE] != read_counter[FIFO_ASIZE]) &&
                   (write_counter[FIFO_ASIZE-1:0] == read_counter[FIFO_ASIZE-1:0]);

  assign out_write_pointer = write_counter[FIFO_ASIZE-1:0];
  assign out_read_pointer  = read_counter[FIFO_ASIZE-1:0];
  
  always @(posedge in_clock) begin
    if (in_reset) begin
      write_counter <= 0;
      read_counter <= 0;
    end else begin
      if (in_put && !out_full) begin
        write_counter = write_counter + 1;
      end
      if (in_take && !out_empty) begin
        read_counter = read_counter + 1;
      end
    end
  end
endmodule
