module wishbone_peripheral_to_axi #(parameter DATA_WIDTH = 8) 
(
    input  wire                     in_clock,
    input  wire                     in_reset,
    input  wire                     in_wb_cyc,
    input  wire                     in_wb_stb,
    input  wire                     in_wb_we,
    input  wire [DATA_WIDTH-1:0]    in_wb_dat,
    input  wire [(DATA_WIDTH/8)-1:0] in_wb_sel,
    output reg                      out_wb_ack,
    output reg                      out_wb_err,
    output reg                      out_source_valid,
    input  wire                     in_source_ready,
    output reg [DATA_WIDTH-1:0]     out_source_data);

  localparam s_IDLE = 2'b00;
  localparam s_WAIT = 2'b01;
  localparam s_DONE = 2'b10;

  reg [1:0] state;

  wire issue_command = in_wb_cyc & in_wb_stb;
  wire write_command = in_wb_we & (&in_wb_sel);

  always @(posedge in_clock) begin
    if (in_reset) begin
      out_wb_ack <= 0;
      out_wb_err <= 0;
      out_source_valid <= 0;
      state <= s_IDLE;
    end else begin
      out_wb_err <= 0;
      out_wb_ack <= 0;

      case (state) 
        s_IDLE: begin
          if (issue_command) begin
            if (write_command) begin
              out_source_valid <= 1;
              out_source_data <= in_wb_dat;
              state <= s_WAIT;
            end else begin
              out_wb_err <= 1;
              state <= s_DONE;
            end
          end
        end

        s_WAIT: begin
          if (in_source_ready) begin
            out_wb_ack <= 1;
            out_source_valid <= 0;
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
