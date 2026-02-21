`default_nettype none
`timescale 1ns / 1ns

module tb_picobus_wishbone_bridge;

  reg        in_clock;
  reg        in_reset;
  reg        in_pico_valid;
  reg [31:0] in_pico_address;
  reg [ 3:0] in_pico_wstrobe;
  reg [31:0] in_pico_wdata;

  initial in_clock = 1;
  always #1 in_clock = ~in_clock;

  initial begin
    $monitor(
        "Time=%4t | Reset=%b | Pico Valid=%b | Pico Address=%d | Pico Wstrobe=%d | Pico Wdata=%d",
        $time, in_reset, in_pico_valid, in_pico_address, in_pico_wstrobe, in_pico_wdata);

    $dumpfile("tb_picobus_wishbone_bridge.vcd");
    $dumpvars(0, tb_picobus_wishbone_bridge);

    in_reset = 1;

    #(2);
    in_reset      = 0;
    in_pico_valid = 0;
    #(2);
    in_pico_valid   = 1;
    in_pico_address = 32'h45000024;
    in_pico_wstrobe = 4'b1111;
    in_pico_wdata   = 32'hdeadbeef;
    #(8);
    in_pico_valid   = 0;
    in_pico_address = 0;
    in_pico_wstrobe = 0;
    in_pico_wdata   = 0;

    #(10);
    $finish;
  end


endmodule
