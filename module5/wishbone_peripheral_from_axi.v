module wishbone_peripheral_from_axi #(
    parameter DATA_WIDTH = 8
) (
    input  wire                     in_clock,
    input  wire                     in_reset,
    input  wire                     in_wb_cyc,
    input  wire                     in_wb_stb,
    input  wire                     in_wb_we,
    input  wire [(DATA_WIDTH/8)-1:0] in_wb_sel,
    output reg                      out_wb_ack,
    output reg                      out_wb_err,
    output wire [DATA_WIDTH-1:0]    out_wb_dat,
    input  wire                     in_sink_valid,
    output reg                      out_sink_ready,
    input  wire [DATA_WIDTH-1:0]    in_sink_data
);

  localparam s_IDLE = 2'b00;
  localparam s_WAIT = 2'b01;
  localparam s_DONE = 2'b10;

  reg [1:0] state;
  reg [DATA_WIDTH-1:0] data;

  assign out_wb_dat = in_wb_cyc ? data : 0;

  wire issue_command = in_wb_cyc & in_wb_stb;

  always @(posedge in_clock) begin
    if (in_reset) begin
      state <= s_IDLE;
      out_wb_ack <= 0;
      out_wb_err <= 0;
      out_sink_ready <= 0;
      data <= 0;
    end else begin
      out_wb_ack <= 0;
      out_wb_err <= 0;

      case (state)
        s_IDLE: begin
          if (issue_command) begin
            if (in_wb_we || !(&in_wb_sel)) begin
              out_wb_err <= 1;
              state <= s_DONE;
            end else begin
              out_sink_ready <= 1;
              state <= s_WAIT;
            end
          end
        end

        s_WAIT: begin
          if (in_sink_valid) begin
            out_sink_ready <= 0;
            data <= in_sink_data;
            out_wb_ack <= 1;
            state <= s_DONE;
          end
        end

        s_DONE: begin
          state <= s_IDLE;
        end

        default: state <= s_IDLE;
      endcase
    end
  end

endmodule
