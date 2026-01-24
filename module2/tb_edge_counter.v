`default_nettype none
`timescale 1ns / 1ns

module tb_edge_counter;
  // DUT simulation signals
  reg in_clock;
  reg in_reset;
  reg in_signal;

  wire [2:0] in_nets;

  wire out_pulse;
  wire [7:0] out_value;

  assign in_nets = { in_clock, in_reset, in_signal};

  // Device Under Test
  edge_counter
  DUT
  (
    .in_clock(in_clock),
    .in_reset(in_reset),
    .in_signal(in_signal),
  
    .out_pulse(out_pulse),
    .out_count(out_value)
  );
 
  initial in_clock = 0;
  always #1 in_clock = ~in_clock;

  // The main simulation
  initial
  begin
    // Added output formatting
    $monitor("Time=%4t | Clock=%b | Inputs (Clk,Rst,En)=%b | Output=%d | Pulse=%b", 
             $time, in_clock, in_nets, out_value, out_pulse);
    $dumpfile("edge_counter.vcd");
    $dumpvars;
    $display;
    

    // Initialize inputs
    in_reset  = 1; // Start with reset active (assuming active high)
    in_signal = 0;

    // Wait for a few cycles, then release reset
    #2;
    in_reset  = 0;
    in_signal = 0;
    
    #4;
    in_signal = 1;

    #2;
    in_signal = 0;

    #6;
    in_signal = 1;

    // Run simulation for specific time
    #40;
    
    $finish; // End simulation
  end
endmodule
