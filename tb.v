`timescale 1ns / 1ps

module tb;

reg tb_clk;
reg tb_clk_2hz;
reg tb_clk_1hz;
reg tb_clk_fast;
reg tb_clk_blink;

reg tb_rst_button;
reg tb_pause_button;
reg tb_adj_switch;
reg tb_sel_switch;
wire [3:0] tb_an;
wire [6:0] tb_seg;
wire tb_dp;

// Create an instance of the arbiter module
//arbiter uut (
//    .clk(tb_clk),
//    .rst_button(tb_rst_button),
//    .pause_button(tb_pause_button),
//    .adj_switch(tb_adj_switch),
//    .sel_switch(tb_sel_switch),
//    .Anode_Activate(tb_an),
//    .LED_out(tb_seg),
//);

clk_div uut (
    .clock_in(tb_clk), // 100 MHz master clock, V10 on board
    .clk_2hz(tb_clk_2hz),
    .clk_1hz(tb_clk_1hz),
    .clk_fast(tb_clk_fast),
    .clk_blink(tb_clk_blink)
    );

// clock signal
always begin
    tb_clk = 1'b0; #10; // 100MHz clock
    tb_clk = 1'b1; #10;
end

  
initial begin
    
    
end

