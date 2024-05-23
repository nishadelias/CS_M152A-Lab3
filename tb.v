`timescale 1ns / 1ps

module tb;

//TB inputs and outputs
  reg tb_clk;
  wire tb_clk_2hz, tb_clk_1hz, tb_clk_fast, tb_clk_blink;
  
//Counter
  reg tb_reset;
  reg tb_pause;
  reg tb_adjust;
  reg tb_select;
  wire [5:0] tb_minutes;  // minutes output from counter
  wire [5:0] tb_seconds;  // seconds output from counter
  
//Display
wire [3:0] Anode_Activate;
wire [6:0] LED_out;
  
  
clk_div clk_div_inst(
  .clock_in(tb_clk),
  .clk_2hz(tb_clk_2hz),
  .clk_1hz(tb_clk_1hz),
  .clk_fast(tb_clk_fast),
  .clk_blink(tb_clk_blink)
);

  counter counter_inst(
        .clk(tb_clk_1hz),
        .reset(tb_reset),
        .pause(tb_pause),
        .adjust(tb_adjust),
        .select(tb_select),
        .adjust_clk(tb_clk_2hz),
        .minutes(tb_minutes),
        .seconds(tb_seconds)
    );
display display_inst(
.clk_fast(tb_clk_fast),
    .minutes(tb_minutes),
    .seconds(tb_seconds),
    .adjust(tb_adjust),
    .select(tb_select),
    .blink_clk(tb_clk_blink),
    .Anode_Activate(Anode_Activate),
    .LED_out(LED_out)
    );
  
  
  initial begin
    tb_clk = 0;
    tb_adjust = 0;
    tb_select = 0;
    tb_pause = 0;
    tb_reset = 0;
  end
  
  always begin
    #5 tb_clk = ~tb_clk;  //100 MHz clock
  end
  
  //Testing
  initial begin 
    //Test adjust mode
    #1000
    tb_select = 1;
    tb_adjust = 1;
    #10000
    tb_adjust = 0;
    
    
    //Test pause mode
    #1000
    tb_pause = 1;
    #1000
    tb_pause = 0;
    
    //Test reset mode
    #1000
    tb_reset = 1;
    #1000
    tb_reset = 0;
    
    
    #50000
    $finish;
  end
endmodule

