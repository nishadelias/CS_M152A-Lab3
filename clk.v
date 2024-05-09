// Code your design here
module clk_div(input clk input rst, output clk_2hz,output clk_1hz, output clk_fast, output clk_blink)

);
  input clock_in; // 100 MHz master clock, V10 on board
output reg clock_out; // output clocks
output reg clk_2hz;
output reg clk_1hz;
output reg clk_fast;
output reg clk_blink;

  reg[27:0] counter_2hz=28'd0;
  reg[27:0] counter_1hz=28'd0;
  reg[27:0] counter_fast=28'd0;
  reg[27:0] counter_blink=28'd0;
parameter DIVISOR_2hz = 28'd50000000;
parameter DIVISOR_1hz = 28'd100000000;
parameter DIVISOR_fast = 28'd200000;
parameter DIVISOR_blink = 28'd14285714;
  
// The frequency of the output clk_out =  The frequency of the input clk_in divided by DIVISOR
always @(posedge clock_in)
begin
 //Increment counters
 counter_2hz <= counter_2hz + 28'd1;
 counter_1hz <= counter_1hz + 28'd1;
 counter_fast <= counter_fast + 28'd1;
 counter_blink <= counter_blink + 28'd1;
  
  // Generate clock outputs based on counters
  if (counter_2hz == DIVISOR_2hz) begin
      clk_2hz <= ~clk_2hz;
      counter_2hz <= 0;
  end
  if (counter_1hz == DIVISOR_1hz) begin
      clk_1hz <= ~clk_1hz;
      counter_1hz <= 0;
  end
  if (counter_fast == DIVISOR_fast) begin
      clk_fast <= ~clk_fast;
      counter_fast <= 0;
  end
  if (counter_blink == DIVISOR_blink) begin 
      clk_blink <= ~clk_blink;
      counter_blink <= 0;
  end
end
  
endmodule
