module combinational_button(input wire button0,
                            input wire button1,
                            input wire button2,
                            output wire LED0,
                            output wire LED1,
                            output wire LED2);
  wire button0_on = ~button0;
  wire button1_on = ~button1;
  wire button2_on = ~button2;

  wire led0_on = button0_on  & ~button1_on & button2_on;
  wire led1_on = ~button0_on & button1_on  & button2_on;
  wire led2_on = button0_on  & button1_on  & button2_on;

  assign LED0 = ~led0_on;
  assign LED1 = ~led1_on;
  assign LED2 = ~led2_on;
endmodule
