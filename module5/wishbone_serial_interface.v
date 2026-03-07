module wishbone_serial_interface #(
    parameter FIFO_WIDTH  = 8,
    parameter FIFO_DEPTH  = 3,
    parameter STATUS_MASK = 0
) (
    input  wire        in_clock,
    input  wire        in_reset,
    output wire [31:0] out_control,
    input  wire [23:0] in_live_status,

    // Wishbone interface
    input  wire        in_wb_cyc,
    input  wire        in_wb_stb,
    input  wire        in_wb_we,
    input  wire [ 3:0] in_wb_sel,
    input  wire [ 3:0] in_wb_adr,
    input  wire [31:0] in_wb_wdat,
    output wire        out_wb_ack,
    output wire        out_wb_err,
    output wire [31:0] out_wb_rdat,

    // AXI-Stream source interface
    output wire                  out_source_valid,
    output wire [FIFO_WIDTH-1:0] out_source_data,
    input  wire                  in_source_ready,

    // AXI-Stream sink interface
    input  wire                  in_sink_valid,
    input  wire [FIFO_WIDTH-1:0] in_sink_data,
    output wire                  out_sink_ready
);

  wire wb_cyc_reg = in_wb_cyc & (in_wb_adr == 4'd0);
  wire wb_cyc_src = in_wb_cyc & (in_wb_adr == 4'd1);
  wire wb_cyc_sink = in_wb_cyc & (in_wb_adr == 4'd2);

  wire control_ack;
  wire [31:0] control_dat;

  wire source_ack;
  wire source_err;

  wire sink_ack;
  wire sink_err;
  wire [FIFO_WIDTH-1:0] sink_dat_raw;
  wire [31:0] sink_dat = sink_dat_raw;  // Implicit zero extension

  // AXI-Stream internal links
  wire wb_src_valid;
  wire wb_src_ready;
  wire [FIFO_WIDTH-1:0] wb_src_data;

  wire wb_sink_valid;
  wire wb_sink_ready;
  wire [FIFO_WIDTH-1:0] wb_sink_data;

  // FIFO status signals
  wire source_fifo_empty;
  wire source_fifo_full;
  wire sink_fifo_empty;
  wire sink_fifo_full;

  wire [31:0] status = {
    in_live_status, 4'b0000, source_fifo_empty, source_fifo_full, sink_fifo_empty, sink_fifo_full
  };

  wishbone_register #(
      .INITIAL_VALUE(0),
      .READ_ONLY_BITS(STATUS_MASK | 32'h0000_000F),
      .LIVE_BITS(STATUS_MASK | 32'h0000_000F)
  ) u_control_register (
      .in_clock(in_clock),
      .in_reset(in_reset),
      .in_wb_cyc(wb_cyc_reg),
      .in_wb_stb(in_wb_stb),
      .in_wb_we(in_wb_we),
      .in_wb_sel(in_wb_sel),
      .in_wb_dat(in_wb_wdat),
      .out_wb_ack(control_ack),
      .out_wb_dat(control_dat),
      .out_contents(out_control),
      .in_live_value(status)
  );

  wishbone_peripheral_to_axi #(
      .DATA_WIDTH(FIFO_WIDTH)
  ) u_wishbone_source_peripheral (
      .in_clock(in_clock),
      .in_reset(in_reset),
      .in_wb_cyc(wb_cyc_src),
      .in_wb_stb(in_wb_stb),
      .in_wb_we(in_wb_we),
      .in_wb_dat(in_wb_wdat[FIFO_WIDTH-1:0]),
      .in_wb_sel(in_wb_sel[(FIFO_WIDTH/8)-1:0]),
      .out_wb_ack(source_ack),
      .out_wb_err(source_err),
      .out_source_valid(wb_src_valid),
      .in_source_ready(wb_src_ready),
      .out_source_data(wb_src_data)
  );


  // AXI handshakes for Source FIFO
  assign wb_src_ready = !source_fifo_full;
  wire source_fifo_put = wb_src_valid && wb_src_ready;

  assign out_source_valid = !source_fifo_empty;
  wire source_fifo_take = in_source_ready && out_source_valid;

  fifo #(
      .FIFO_ASIZE(FIFO_DEPTH),
      .DATA_WIDTH(FIFO_WIDTH)
  ) u_source_fifo (
      .in_clock(in_clock),
      .in_reset(in_reset),
      .in_put(source_fifo_put),
      .in_take(source_fifo_take),
      .out_empty(source_fifo_empty),
      .out_full(source_fifo_full),
      .out_data(out_source_data),
      .in_data(wb_src_data)
  );

  // AXI handshakes for Sink FIFO
  assign out_sink_ready = !sink_fifo_full;
  wire sink_fifo_put = in_sink_valid && out_sink_ready;

  assign wb_sink_valid = !sink_fifo_empty;
  wire sink_fifo_take = wb_sink_ready && wb_sink_valid;

  fifo #(
      .FIFO_ASIZE(FIFO_DEPTH),
      .DATA_WIDTH(FIFO_WIDTH)
  ) u_sink_fifo (
      .in_clock(in_clock),
      .in_reset(in_reset),
      .in_put(sink_fifo_put),
      .in_take(sink_fifo_take),
      .out_empty(sink_fifo_empty),
      .out_full(sink_fifo_full),
      .out_data(wb_sink_data),
      .in_data(in_sink_data)
  );

  wishbone_peripheral_from_axi #(
      .DATA_WIDTH(FIFO_WIDTH)
  ) u_wishbone_sink_peripheral (
      .in_clock(in_clock),
      .in_reset(in_reset),
      .in_wb_cyc(wb_cyc_sink),
      .in_wb_stb(in_wb_stb),
      .in_wb_we(in_wb_we),
      .in_wb_sel(in_wb_sel[(FIFO_WIDTH/8)-1:0]),
      .out_wb_ack(sink_ack),
      .out_wb_err(sink_err),
      .out_wb_dat(sink_dat_raw),
      .in_sink_valid(wb_sink_valid),
      .out_sink_ready(wb_sink_ready),
      .in_sink_data(wb_sink_data)
  );

  // Address Error Logic
  reg err_addr_q;
  reg err_addr_active;

  always @(posedge in_clock) begin
    if (in_reset) begin
      err_addr_q      <= 1'b0;
      err_addr_active <= 1'b0;
    end else begin
      if (in_wb_cyc && in_wb_stb && (in_wb_adr >= 4'd3)) begin
        if (!err_addr_active) begin
          err_addr_q      <= 1'b1;
          err_addr_active <= 1'b1;
        end else begin
          err_addr_q <= 1'b0;
        end
      end else begin
        err_addr_q      <= 1'b0;
        err_addr_active <= 1'b0;
      end
    end
  end

  // Logical combinations per instructions
  assign out_wb_ack  = control_ack | source_ack | sink_ack;
  assign out_wb_err  = err_addr_q | source_err | sink_err;

  // Directly bitwise OR the read data as required.
  // Masking with `ack` causes cycle mismatches in standard assertions unless specified.
  assign out_wb_rdat = control_dat | sink_dat;

endmodule
