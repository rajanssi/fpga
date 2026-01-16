module inverter(input wire reset, output wire enable);
  assign enable = ~reset;
endmodule
