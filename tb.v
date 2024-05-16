`timescale 1ns / 1ps

module tb;

    // Define testbench signals
    reg tb_clock_in;  // clock input
    reg tb_reset;     // reset signal
    reg tb_pause;     // pause signal
    reg tb_adjust;    // adjust signal
    reg tb_select;    // select signal
    wire tb_clk_2hz, tb_clk_1hz, tb_clk_fast, tb_clk_blink; 
    wire [5:0] tb_minutes;  // minutes output from counter
    wire [5:0] tb_seconds;  // seconds output from counter

    // Instantiate the clock divider
    clk_div clk_div_inst(
        .clock_in(tb_clock_in),
        .rst(tb_reset),
        .clk_2hz(tb_clk_2hz),
        .clk_1hz(tb_clk_1hz),
        .clk_fast(tb_clk_fast),
        .clk_blink(tb_clk_blink)
        // Additional clock outputs (e.g., clk_fast, clk_blink) can be added if required
    );

    // Instantiate the counter
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

    // Generate a 100 MHz clock signal (assuming your FPGA's clock frequency is 100 MHz)
    initial begin
        tb_clock_in = 0;
        forever #5 tb_clock_in = ~tb_clock_in;  // 10 ns period for 100 MHz
    end

    // Test procedure
    initial begin
        // Initialize all inputs
        tb_reset = 1;  // Assert reset initially
        tb_pause = 0;
        tb_adjust = 0;
        tb_select = 0;
        #100;         // Wait 100ns for global reset
        
        tb_reset = 0;  // Deassert reset
        #990000000;      // Wait enough time to observe a few seconds counting

        // Test pausing functionality
        tb_pause = 1;
        #20;
        tb_pause = 0;
        #200000;      // Observe pause

        // // Test adjusting functionality for seconds
        // tb_adjust = 1;
        // #20;
        // tb_select = 1;  // Select seconds
        // #200000;       // Observe seconds being adjusted
        // tb_select = 0;  // back to minutes adjustment
        // #200000;
        // tb_adjust = 0;  // Stop adjusting

        // Finish simulation after an additional time period
        #2000000;
        $finish;
    end
