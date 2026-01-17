`timescale 100ps / 1ps // This will be covered in this section.

module mixed_logic_unit
(
  input wire i_clock,
  // With declaration as below,
  // each of the ports have a same type.
  input wire i_q, i_w, i_e, i_r,

  output reg o_a, o_b,
  output wire o_c
);

  // As with ports, same declaration can be
  // used with internal signals.
  // As in general, newlines do not matter.
  wire tmp_a,
       tmp_b;

  // Following statements have been given a delay,
  // which will be covered in following section.
  assign #3.3 tmp_a = i_q || i_w;
  assign #3.5 tmp_b = i_e && i_r;
  assign #1.2 o_c = tmp_a ^ tmp_b;

  always @(posedge i_clock)
  begin
    o_a <= tmp_a;
    o_b <= tmp_b;
  end

endmodule

