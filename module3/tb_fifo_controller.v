`default_nettype none
`timescale 1ns/1ns

module tb_fifo_controller;
// DUT simulation signals
  reg in_clock;
  reg in_reset;
  reg in_take;
  reg in_put;

  wire out_empty;
  wire out_full;
  wire [3:0] out_write_pointer;
  wire [3:0] out_read_pointer;

  wire [2:0] i_nets;
  wire [1:0] o_nets;

  assign i_nets = {in_take, in_put, in_reset};
  assign o_nets = {out_empty, out_full};

  // Device under test
  fifo_controller
  DUT
  (
   .in_clock(in_clock), 
   .in_reset(in_reset), 
   .in_take(in_take), 
   .in_put(in_put), 

   .out_empty(out_empty), 
   .out_full(out_full), 
   .out_write_pointer(out_write_pointer), 
   .out_read_pointer(out_read_pointer)
  );

  initial in_clock = 1;
  always #1 in_clock = ~in_clock;

  // the main simulation
  initial begin
    $monitor("Time=%4t, clock=%b : inputs=%b, outputs=%b", $time, in_clock, i_nets, o_nets);
    $dumpfile("tb_fifo_controller.vcd");
    $dumpvars(0,tb_fifo_controller);

    in_reset = 0;

    #(2);
    in_reset = 1;
    #(2);
    in_reset = 0;
    in_put   = 0;
    in_take  = 0;
    #(2);
    in_put   = 1;
    #(20);
    $finish;

  end

endmodule
