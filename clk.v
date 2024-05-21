module clk_div(
input clock_in, // 100 MHz master clock, V10 on board
output clk_2hz,
output clk_1hz,
output clk_fast,
output clk_blink
);
 
 reg[27:0] counter_2hz=28'd0;
 reg[27:0] counter_1hz=28'd0;
 reg[27:0] counter_fast=28'd0;
 reg[27:0] counter_blink=28'd0;
 reg clk_2hz_reg;
 reg clk_1hz_reg;
 reg clk_fast_reg;
 reg clk_blink_reg;
 parameter DIVISOR_2hz = 28'd5;
 parameter DIVISOR_1hz = 28'd10;
 parameter DIVISOR_fast = 28'd2;
 parameter DIVISOR_blink = 28'd2;

 initial begin
counter_2hz <= 0;
 counter_1hz <= 0;
 counter_fast <= 0;
 counter_blink <= 0;
 clk_2hz_reg <= 0;
 clk_1hz_reg <= 0;
 clk_fast_reg <= 0;
 clk_blink_reg <= 0;
 end
 
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
       clk_2hz_reg <= ~clk_2hz_reg;
       counter_2hz <= 0;
   end
   if (counter_1hz == DIVISOR_1hz) begin
       clk_1hz_reg <= ~clk_1hz_reg;
       counter_1hz <= 0;
   end
   if (counter_fast == DIVISOR_fast) begin
       clk_fast_reg <= ~clk_fast_reg;
       counter_fast <= 0;
   end
   if (counter_blink == DIVISOR_blink) begin 
       clk_blink_reg <= ~clk_blink_reg;
       counter_blink <= 0;
   end
 end
 
 assign clk_2hz = clk_2hz_reg;
 assign clk_1hz = clk_1hz_reg;
 assign clk_fast = clk_fast_reg;
 assign clk_blink = clk_blink_reg;
endmodule

