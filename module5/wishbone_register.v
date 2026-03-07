module wishbone_register #(
    parameter [31:0] INITIAL_VALUE = 32'h0,
    parameter [31:0] READ_ONLY_BITS = 32'h0,
    parameter [31:0] LIVE_BITS = 32'h0
) (
    input  wire        in_clock,
    input  wire        in_reset,
    input  wire        in_wb_cyc,
    input  wire        in_wb_stb,
    input  wire        in_wb_we,
    input  wire [ 3:0] in_wb_sel,
    input  wire [31:0] in_wb_dat,
    output reg         out_wb_ack,
    output wire [31:0] out_wb_dat,
    output reg  [31:0] out_contents,
    input  wire [31:0] in_live_value
);

  // Internal register to capture the read value so it stays stable during ACK
  reg [31:0] read_data_buffer;
  wire [31:0] writable_mask = ~READ_ONLY_BITS;
  wire transfer_active = in_wb_cyc && in_wb_stb;

  assign out_wb_dat = in_wb_cyc ? read_data_buffer : 0;

  integer i;
  always @(posedge in_clock) begin
    if (in_reset) begin
      out_wb_ack       <= 0;
      out_contents     <= INITIAL_VALUE;
      read_data_buffer <= 0;
    end else begin
      out_wb_ack <= 0;

      if (transfer_active && !out_wb_ack) begin
        out_wb_ack <= 1;

        if (in_wb_we) begin
          // WRITE CYCLE
          for (i = 0; i < 4; i = i + 1) begin
            if (in_wb_sel[i]) begin
              out_contents[(i*8) +: 8] <= (in_wb_dat[(i*8) +: 8] & writable_mask[(i*8) +: 8]) |
                (INITIAL_VALUE[(i*8) +: 8] & READ_ONLY_BITS[(i*8) +: 8]);
            end
          end
        end else begin
          // READ CYCLE
          read_data_buffer <= (in_live_value & LIVE_BITS) | (out_contents & ~LIVE_BITS);
        end
      end
    end
  end
endmodule
