module spi_master_control_fsm (
    input  wire       in_clock,
    input  wire       in_reset,
    input  wire [7:0] in_divider_value,
    input  wire       in_sck_pol,
    input  wire       in_spi_enable,
    output reg        out_spi_idle,
    input  wire       in_sink_valid,
    output reg        out_sink_ready,
    output reg        out_source_valid,
    input  wire       in_source_ready,
    output reg        out_shift_out,
    output reg        out_shift_in,
    output reg        CS_N,
    output reg        SCK
);

  localparam s_IDLE = 8'b00000001;
  localparam s_SETUP = 8'b00000010;
  localparam s_SINK = 8'b00000100;
  localparam s_SHIFT_IN = 8'b00001000;
  localparam s_SHIFT_OUT = 8'b00010000;
  localparam s_SOURCE = 8'b00100000;
  localparam s_EXIT_SCK = 8'b01000000;
  localparam s_EXIT_CS_N = 8'b10000000;

  reg [7:0] state;
  reg [7:0] wait_cycles;
  reg [3:0] bits_shifted;

  always @(posedge in_clock) begin
    if (in_reset) begin
      out_spi_idle     <= 1;
      out_sink_ready   <= 0;
      out_source_valid <= 0;
      out_shift_out    <= 0;
      out_shift_in     <= 0;
      CS_N             <= 1;
      wait_cycles      <= 0;
      bits_shifted     <= 0;
      SCK              <= 0;
      state            <= s_IDLE;
    end else begin
      out_shift_in  <= 0;
      out_shift_out <= 0;

      case (state)
        s_IDLE: begin
          if (in_spi_enable) begin
            state        <= s_SETUP;
            out_spi_idle <= 0;
            SCK          <= in_sck_pol;
          end
        end

        s_SETUP: begin
          if (wait_cycles < in_divider_value) begin
            wait_cycles <= wait_cycles + 1;
          end else begin
            wait_cycles    <= 0;
            CS_N           <= 0;
            out_sink_ready <= 1;
            state          <= s_SINK;
          end
        end

        s_SINK: begin
          if (in_sink_valid) begin
            out_sink_ready <= 0;
            state          <= s_SHIFT_IN;
            bits_shifted   <= 0;
            if (in_divider_value == 0) out_shift_in <= 1;
          end else if (!in_sink_valid & !in_spi_enable) begin
            out_sink_ready <= 0;
            state          <= s_EXIT_SCK;
          end
        end

        s_SHIFT_IN: begin
          if (wait_cycles < in_divider_value) begin
            wait_cycles <= wait_cycles + 1;
            if (wait_cycles + 1 == in_divider_value) begin
              out_shift_in <= 1;
            end
          end else begin
            wait_cycles <= 0;
            SCK         <= ~SCK;
            state       <= s_SHIFT_OUT;
            if (in_divider_value == 0) out_shift_out <= 1;
          end
        end

        s_SHIFT_OUT: begin
          if (wait_cycles < in_divider_value) begin
            wait_cycles <= wait_cycles + 1;
            if (wait_cycles + 1 == in_divider_value) begin
              out_shift_out <= 1;
            end
          end else begin
            wait_cycles <= 0;
            SCK         <= ~SCK;
            if (bits_shifted == 7) begin
              state            <= s_SOURCE;
              out_source_valid <= 1;
            end else begin
              bits_shifted <= bits_shifted + 1;
              state        <= s_SHIFT_IN;
              if (in_divider_value == 0) out_shift_in <= 1;
            end
          end
        end

        s_SOURCE: begin
          if (in_source_ready) begin
            out_source_valid <= 0;
            if (in_spi_enable) begin
              out_sink_ready <= 1;
              state          <= s_SINK;
            end else begin
              state <= s_EXIT_SCK;
            end
          end
        end

        s_EXIT_SCK: begin
          if (wait_cycles < in_divider_value) begin
            wait_cycles <= wait_cycles + 1;
          end else begin
            wait_cycles <= 0;
            CS_N        <= 1;
            state       <= s_EXIT_CS_N;
          end
        end

        s_EXIT_CS_N: begin
          if (wait_cycles < in_divider_value) begin
            wait_cycles <= wait_cycles + 1;
          end else begin
            wait_cycles  <= 0;
            out_spi_idle <= 1;
            state        <= s_IDLE;
          end
        end

        default: state <= s_IDLE;
      endcase
    end
  end
endmodule
