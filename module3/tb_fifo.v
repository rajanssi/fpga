`default_nettype none
`timescale 1ns / 1ns

module tb_fifo;
  // DUT simulation signals
  reg in_clock;
  reg in_reset;
  reg in_take;
  reg in_put;
  reg [7:0] in_data;

  wire out_empty;
  wire out_full;
  wire [7:0] out_data;

  wire [2:0] i_nets;
  wire [1:0] o_nets;

  assign i_nets = {in_take, in_put, in_reset};
  assign o_nets = {out_empty, out_full};

  // Device under test
  fifo DUT (
      .in_clock(in_clock),
      .in_reset(in_reset),
      .in_take (in_take),
      .in_put  (in_put),

      .out_empty(out_empty),
      .out_full(out_full),
      .out_write_pointer(out_write_pointer),
      .out_read_pointer(out_read_pointer)
  );

  initial in_clock = 1;
  always #1 in_clock = ~in_clock;

  // the main simulation
  initial begin
    $monitor("Time=%4t | Reset=%b | Put=%b Take=%b | Empty=%b Full=%b | W_Ptr=%d R_Ptr=%d", $time,
             in_reset, in_put, in_take, out_empty, out_full, out_data, in_data);
    $dumpfile("tb_fifo.vcd");
    $dumpvars(0, tb_fifo_controller);

    // Initial State
    in_reset = 0;
    in_put   = 0;
    in_take  = 0;
    in_data  = 0;

    // 1. Trigger Reset
    #(2);
    in_reset = 1;
    #(2);  // Hold for a full clock cycle
    in_reset = 0;
    #(2);

    // 2. Fill the FIFO (ASIZE=4 means 16 slots)
    $display("--- Starting Fill Operation ---");
    in_put = 1;
    repeat (16) @(posedge in_clock);

    // At this point, out_full should be 1
    in_put = 0;
    #(4);

    // 3. Try to 'Put' into a Full FIFO (should have no effect)
    in_put = 1;
    #(2);
    in_put = 0;

    // 4. Empty the FIFO
    $display("--- Starting Empty Operation ---");
    in_take = 1;
    repeat (16) @(posedge in_clock);

    // At this point, out_empty should be 1
    in_take = 0;
    #(10);

    $finish;
  end

endmodule
