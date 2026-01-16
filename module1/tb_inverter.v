// The following assumes that this file is saved as "tb_inverter.v" and the inverter is saved in "inverter.v", and that the development environment is active.
//   # Compile simulation:
//   iverilog -o inverter -s tb_inverter -Wall -g2005 tb_inverter.v inverter.v
//   # Run the simulation:
//   vvp inverter
//   # Render the simulation timing diagram:
//   gtkwave tb_inverter.vcd
//

//`timescale 1ns / 1ps // If "inverter.v" has timescale, uncomment this line

module tb_inverter();
    reg tb_in;
    wire tb_out;

    initial begin
        tb_in = 1'b0;

        $monitor("%g\t reset:%b enable:%b", $time, tb_in, tb_out);
        $dumpfile("tb_inverter.vcd");
        $dumpvars(0,tb_inverter);
        $display("time\t in out");

        #2 tb_in = 1'b1;
        #2 tb_in = 1'b0;
        #2 tb_in = 1'b1;
        #2 tb_in = 1'b0;
        #10 $finish;
    end

    inverter DUT(
    .reset(tb_in),
    .enable(tb_out)
    );
endmodule
