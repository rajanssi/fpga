module cdc_flag #(
    parameter CDC_LENGTH = 2
) (
    input  wire in_tx_clock,
    input  wire in_tx_flag,
    output wire out_tx_ack,
    input  wire in_rx_clock,
    input  wire in_rx_ack,
    output wire out_rx_flag
);
  reg flag_tx = 0;
  reg flag_rx = 0;

  reg [CDC_LENGTH-1:0] sync_rx_to_tx = {CDC_LENGTH{0}};
  reg [CDC_LENGTH-1:0] sync_tx_to_rx = {CDC_LENGTH{0}};

  always @(posedge in_tx_clock) begin
    flag_tx <= in_tx_flag;

    sync_rx_to_tx <= {sync_rx_to_tx[CDC_LENGTH-2:0], flag_rx};
  end

  assign out_tx_ack = (sync_rx_to_tx[CDC_LENGTH-1] == in_tx_flag);

  always @(posedge in_rx_clock) begin
    sync_tx_to_rx <= {sync_tx_to_rx[CDC_LENGTH-2:0], flag_tx};

    if (in_rx_ack) begin
      flag_rx <= sync_tx_to_rx[CDC_LENGTH-1];
    end
  end

  assign out_rx_flag = sync_tx_to_rx[CDC_LENGTH-1];

endmodule
