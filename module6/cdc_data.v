module cdc_data #(
    parameter CDC_LENGTH = 2
) (
    input  wire       in_tx_clock,
    input  wire       in_tx_send,
    input  wire [7:0] in_tx_data,
    output wire       out_tx_ack,
    input  wire       in_rx_clock,
    output wire       out_rx_strobe,
    output wire [7:0] out_rx_data
);

  reg  [7:0] tx_data_reg = 0;
  wire       tx_send_edge;
  wire       rx_flag_sync;
  wire       rx_flag_edge;

  edge_detector tx_edge_det (
      .in_clock  (in_tx_clock),
      .in_signal (in_tx_send),
      .out_strobe(tx_send_edge)
  );

  always @(posedge in_tx_clock) begin
    if (tx_send_edge) begin
      tx_data_reg <= in_tx_data;
    end
  end

  cdc_flag #(
      .CDC_LENGTH(CDC_LENGTH)
  ) cdc_handshake (
      .in_tx_clock(in_tx_clock),
      .in_tx_flag (in_tx_send),
      .out_tx_ack (out_tx_ack),
      .in_rx_clock(in_rx_clock),
      .in_rx_ack  (1),
      .out_rx_flag(rx_flag_sync)
  );

  edge_detector rx_edge_det (
      .in_clock  (in_rx_clock),
      .in_signal (rx_flag_sync),
      .out_strobe(rx_flag_edge)
  );

  always @(posedge in_rx_clock) begin
    out_rx_strobe <= rx_flag_edge;

    if (rx_flag_edge) begin
      out_rx_data <= tx_data_reg;
    end
  end

endmodule
