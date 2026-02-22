module axi_stream_pwm (
    input  wire       in_clock,
    input  wire       in_reset,
    input  wire       in_valid,
    input  wire [4:0] in_data,
    output reg        out_ready,
    output reg        out_data
);

  reg [4:0] counter;
  reg [4:0] latched_data;

  always @(posedge in_clock) begin
    if (in_reset) begin
      out_ready    <= 1;
      out_data     <= 0;
      counter      <= 0;
      latched_data <= 0;
    end else begin
      if (out_ready) begin
        if (in_valid) begin
          out_ready    <= 0;
          latched_data <= in_data;
          counter      <= 1;

          if (in_data > 0) begin
            out_data <= 1;
          end else begin
            out_data <= 0;
          end
        end else begin
          out_data <= 0;
        end
      end else begin
        counter <= counter + 1;
        if (counter < latched_data) begin
          out_data <= 1;
        end else begin
          out_data <= 0;
        end
        if (counter == 31) begin
          out_ready <= 1;
        end
      end
    end
  end

endmodule
