`default_nettype none
`timescale 1ns / 1ns

module tb_mixed_logic_unit;

  // DUT simulation signals
  reg i_clock;
  reg i_q, i_w, i_e, i_r;
  wire o_a, o_b, o_c;

  // Internal simulation signals.
  // In iverilog, $monitor requires explicit signals as arguments,
  // i.e. a concatenated signal {i_r, i_e, i_w, i_q} is not a valid argument.
  wire [3:0] i_nets;
  wire [2:0] o_nets;
  assign i_nets = {i_r, i_e, i_w, i_q};
  assign o_nets = {o_c, o_b, o_a};

  // Device Under Test
  mixed_logic_unit
  DUT
  (
    .i_clock(i_clock),
    .i_q(i_q),
    .i_w(i_w),
    .i_e(i_e),
    .i_r(i_r),

    .o_a(o_a),
    .o_b(o_b),
    .o_c(o_c)
  );

  // The main simulation
  initial
  begin
    // Prints out a formatted text from given arguments.
    $monitor("Time=%4t, clock=%b : inputs=%b, outputs=%b", $time, i_clock, i_nets, o_nets);

    // Set initial values
    i_clock = 0;
    {i_r, i_e, i_w, i_q} = 4'b0; // Same as setting each individually

    // Repeats following block 16 times
    // A similar structure could be created with a for- or while-loop.
    repeat (16)
    begin
      #(1);
      // Set next clock edge (positive edge),
      // and increment inputs.
      i_clock <= 1'b1;
      {i_r, i_e, i_w, i_q} <= {i_r, i_e, i_w, i_q} + 4'b0001;

      #(1);
      // Set next clock edge (negative edge).
      i_clock <= 1'b0;
    end

    // Wait a delay and then exit simulation.
    #(1);
    $finish;
  end

endmodule
