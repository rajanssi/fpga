module top;

  reg [128:1] str = "Hello wolrd!";

  initial
  begin
    $dumpfile("hello.vcd"); // Create waveform file
    $dumpvars;
    #1;
    $display("%s", str);
    $finish;
  end

endmodule
