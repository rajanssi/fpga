module picobus_wishbone_bridge (
    input  wire        in_clock,
    input  wire        in_reset,
    input  wire        in_pico_valid,
    input  wire [31:0] in_pico_address,
    input  wire [ 3:0] in_pico_wstrobe,
    input  wire [31:0] in_pico_wdata,
    output reg         out_pico_ready,
    output reg         out_pico_error,
    output reg  [31:0] out_pico_rdata,
    output reg         out_wb_cyc,
    output reg         out_wb_stb,
    output wire        out_wb_we,
    output wire [21:0] out_wb_adr,
    output wire [ 3:0] out_wb_sel,
    output wire [31:0] out_wb_wdat,
    input  wire        in_wb_ack,
    input  wire        in_wb_err,
    input  wire [31:0] in_wb_rdat
);

  wire acceptable = in_pico_address[31:24] == 8'b01000101;

  // Continuous assignments for non-registered Wishbone signals
  assign out_wb_wdat = in_pico_wdata;
  assign out_wb_adr  = in_pico_address[23:2];
  assign out_wb_we   = (in_pico_wstrobe != 0);
  assign out_wb_sel  = (in_pico_wstrobe == 0) ? 4'b1111 : in_pico_wstrobe;

  always @(posedge in_clock) begin
    if (in_reset) begin
      out_wb_cyc     <= 0;
      out_wb_stb     <= 0;
      out_pico_ready <= 0;
      out_pico_error <= 0;
    end else begin
      out_pico_ready <= 0;
      out_pico_error <= 0;
      if (in_pico_valid && acceptable && !out_wb_cyc && !out_pico_ready) begin
        out_wb_cyc <= 1;
        out_wb_stb <= 1;
      end

      if (out_wb_cyc) begin
        if (in_wb_ack) begin
          out_pico_ready <= 1;
          out_pico_error <= 0;
          out_pico_rdata <= in_wb_rdat;
          out_wb_cyc     <= 0;
          out_wb_stb     <= 0;
        end else if (in_wb_err) begin
          out_pico_ready <= 1;
          out_pico_error <= 1;
          out_wb_cyc     <= 0;
          out_wb_stb     <= 0;
        end
      end
    end
  end

endmodule
