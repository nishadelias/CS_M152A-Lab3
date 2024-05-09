`timescale 1ns / 1ps

module arbiter (
    input wire clk,     // master clock
    input wire rst_button,
    input wire pause_button,
    input wire adj_button,
    input wire sel_button,
  	output wire [3:0] anode_signal,   // for the 7-segment display
  	output wire [6:0] cathode_signal,   // for the 7-segment display
);

// Debounced inputs
wire rst, pause, adj, sel;

// Clocks
wire clk_2hz, clk_1hz, clk_fast, clk_blink;

// Counter outputs
wire [5:0] minutes, seconds;

// state for pause
reg paused;

// Initialize the pause state
initial begin
    paused = 0;
end

// Clock divider module instantiation
clock_divider clk_div (
    .clk(clk),
    .rst(rst),
    .clk_2hz(clk_2hz),
    .clk_1hz(clk_1hz),
    .clk_fast(clk_fast),
    .clk_blink(clk_blink)
);

// Debouncer modules instantiation
debouncer rst_deb (.clk(clk_fast), .button_in(rst_button), .button_out(rst));
debouncer pause_deb (.clk(clk_fast), .button_in(pause_button), .button_out(pause));
debouncer adj_deb (.clk(clk_fast), .switch_in(adj_switch), .switch_out(adj));
debouncer sel_deb (.clk(clk_fast), .switch_in(sel_switch), .switch_out(sel));
  

// Counter module instantiation
counter stopwatch_counter (
    .clk(clk_1hz),
    .reset(rst),
    .pause(paused),
    .adjust(adj),
    .select(sel),
    .adjust_clk(clk_2hz),
    .minutes(minutes),
    .seconds(seconds)
);

// Display multiplexer instantiation
display_mux display (
    .clk(clk_fast),
    .minutes(minutes),
    .seconds(seconds),
    .blink_en(adj),
    .blink_clk(clk_blink),
    .an(an),
    .seg(seg),
    .dp(dp)
);

// Handle the pause functionality with a simple state machine
always @(posedge clk_fast) begin
    if (rst) begin
        paused <= 0;
    end else if (pause) begin
        paused <= ~paused;  // Toggle pause state on button press
    end
end

endmodule


module counter (
  input wire clk,
  input wire reset,
  input wire pause,
  input wire adjust,
  input wire select,
  input wire adjust_clk,
  output reg [5:0] minutes,
  output reg [5:0] seconds
);
  
  initial begin
    minutes = 0;
    seconds = 0
  end
  
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      seconds <= 0;
      minutes <= 0;
    
    end else if (!pause && !adjust) begin
      if (seconds < 59) begin
        seconds <= seconds + 1;
        
      end else begin
        seconds <= 0;
        if (minutes < 59) begin
          minutes <= minutes + 1;
          
        end else begin
          minutes <= 0;
          
        end
      end
    end
  end
  
  
  always @(posedge adjust_clk) begin
    if (!reset && adjust) begin
      if (select) begin
        if (seconds < 59) begin
          seconds <= seconds + 1;
        end else begin
          seconds <= 0;
        end
        
      end else begin
        if (minutes < 59) begin
          minutes <= minutes + 1;
        end else begin
          minutes <= 0;
        end
      end
    end
  end
  
  
endmodule

