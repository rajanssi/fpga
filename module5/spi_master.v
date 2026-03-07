module spi_master (
    input  wire       in_clock,
    input  wire       in_reset,
    input  wire [7:0] in_divider_value,
    input  wire       in_sck_pol,
    input  wire       in_spi_enable,
    output wire       out_spi_idle,
    input  wire       in_sink_valid,
    output wire       out_sink_ready,
    input  wire [7:0] in_sink_data,
    output wire       out_source_valid,
    input  wire       in_source_ready,
    output wire [7:0] out_source_data,
    output wire       CS_N,
    output wire       SCK,
    input  wire       SDI,
    output wire       SDO
);

  wire shift_in;
  wire shift_out;

  wire serializer_write = in_sink_valid & out_sink_ready;

  spi_master_control_fsm u_spi_master_control_fsm (
      .in_clock(in_clock),
      .in_reset(in_reset),
      .in_divider_value(in_divider_value),
      .in_sck_pol(in_sck_pol),
      .in_spi_enable(in_spi_enable),
      .out_spi_idle(out_spi_idle),
      .in_sink_valid(in_sink_valid),
      .out_sink_ready(out_sink_ready),
      .out_source_valid(out_source_valid),
      .in_source_ready(in_source_ready),
      .out_shift_out(shift_out),
      .out_shift_in(shift_in),
      .CS_N(CS_N),
      .SCK(SCK)
  );


  deserializer u_deserializer (
      .in_clock(in_clock),
      .in_enable(shift_in),
      .in_bit(SDI),
      .out_data(out_source_data)
  );
  serializer u_serializer (
      .in_clock (in_clock),
      .in_write (serializer_write),
      .in_data  (in_sink_data),
      .in_enable(shift_out),
      .out_bit  (SDO)
  );

endmodule
