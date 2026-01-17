module alu(input wire in_clock,
           input wire in_valid,
           input wire [7:0] in_lhs,
           input wire [7:0] in_rhs,
           input wire [2:0] in_function,
           output reg out_valid,
           output reg [7:0] out_result);

  always @(posedge in_clock) begin
    if (in_valid) begin
      case (in_function)
        3'b000 : out_result <= in_lhs +  in_rhs;
        3'b001 : out_result <= in_lhs -  in_rhs;
        3'b010 : out_result <= in_lhs &  in_rhs;
        3'b011 : out_result <= in_lhs |  in_rhs;
        3'b100 : out_result <= in_lhs ^  in_rhs;
        3'b101 : out_result <= in_lhs << in_rhs;
        3'b110 : out_result <= in_lhs >> in_rhs;
        // 3'b111 should be left undefined
      endcase
      out_valid <= 1;
    end
    else begin
      out_valid <= 0;
    end
  end
endmodule
