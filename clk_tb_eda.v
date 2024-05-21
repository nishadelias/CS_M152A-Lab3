// Clk_div testbench

`timescale 1ns / 1ps

module tb;

//TB inputs and outputs
  reg tb_clk;
  wire tb_clk_2hz, tb_clk_1hz, tb_clk_fast, tb_clk_blink;
  
clk_div clk_div_inst(
  .clock_in(tb_clk),
  .clk_2hz(tb_clk_2hz),
  .clk_1hz(tb_clk_1hz),
  .clk_fast(tb_clk_fast),
  .clk_blink(tb_clk_blink)
);
  
  
  initial begin
    tb_clk = 0;
  end
  
  always begin
    #5 tb_clk = ~tb_clk;  //100 MHz clock
  end
  
  //Testing
  initial begin
    //Dump waves
    $dumpfile("waveform.vcd");  // Specify the name of the dump file
    $dumpvars(0, tb);   
    #10000
    $finish;
  end
endmodule
