`timescale 1ns / 1ps

module tb;

reg tb_clk;
reg tb_rst_button;
reg tb_pause_button;
reg tb_adj_switch;
reg tb_sel_switch;
wire [3:0] tb_an;
wire [6:0] tb_seg;
wire tb_dp;

// Create an instance of the arbiter module
arbiter uut (
    .clk(tb_clk),
    .rst_button(tb_rst_button),
    .pause_button(tb_pause_button),
    .adj_switch(tb_adj_switch),
    .sel_switch(tb_sel_switch),
    .an(tb_an),
    .seg(tb_seg),
    .dp(tb_dp)
);

// clock signal
always begin
    tb_clk = 1'b0; #5; // 50MHz clock
    tb_clk = 1'b1; #5;
end

  
initial begin
    
    
end

endmodule
