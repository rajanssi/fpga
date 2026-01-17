`default_nettype none
`timescale 1ns / 1ns

module tb_counter;
  // DUT simulation signals
  reg in_clock;
  reg in_reset;
  reg in_enable;

  wire [2:0] in_nets;
  wire [8:0] out_value;

  assign in_nets = { in_clock, in_reset, in_enable};

  // Device Under Test
  counter
  DUT
  (
    .in_clock(in_clock),
    .in_reset(in_reset),
    .in_enable(in_enable),
  
    .out_value(out_value)
  );
 
  initial in_clock = 0;
  always #1 in_clock = ~in_clock;

  // The main simulation
  initial
  begin
    // Added output formatting
    $monitor("Time=%4t | Clock=%b | Inputs (Clk,Rst,En)=%b | Output=%d", 
             $time, in_clock, in_nets, out_value);

    // Initialize inputs
    in_reset  = 1; // Start with reset active (assuming active high)
    in_enable = 0;

    // Wait for a few cycles, then release reset
    #4;
    in_reset  = 0;
    
    #2;
    in_enable = 1;

    // Run simulation for specific time
    #40;
    
    $finish; // End simulation
  end
endmodule
