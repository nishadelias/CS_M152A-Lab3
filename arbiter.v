`timescale 1ns / 1ps

module arbiter (
    input wire clk,     // master clock
    input wire rst_button,
    input wire pause_button,
    input wire adj_button,
    input wire sel_button,
  	output wire [3:0] Anode_Activate,   // for the 7-segment display
  	output wire [6:0] LED_out   // for the 7-segment display
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
clk_div clk_divider (
    .clock_in(clk),
    .rst(rst_button),
    .clk_2hz(clk_2hz),
    .clk_1hz(clk_1hz),
    .clk_fast(clk_fast),
    .clk_blink(clk_blink)
);

// Debouncer modules instantiation
//debouncer rst_deb (.clk(clk_fast), .button_in(rst_button), .button_out(rst));
//debouncer pause_deb (.clk(clk_fast), .button_in(pause_button), .button_out(pause));
//debouncer adj_deb (.clk(clk_fast), .switch_in(adj_switch), .switch_out(adj));
//debouncer sel_deb (.clk(clk_fast), .switch_in(sel_switch), .switch_out(sel));
  

// Counter module instantiation
counter stopwatch_counter (
    .clk(clk_1hz),
    .reset(rst_button),
    .pause(paused),
    .adjust(adj),
    .select(sel),
    .adjust_clk(clk_2hz),
    .minutes(minutes),
    .seconds(seconds)
);

 //Display multiplexer instantiation
display display_mux (
    .clk(clk_fast),
    .minutes(minutes),
    .seconds(seconds),
    //.blink_en(adj),
    //.blink_clk(clk_blink),
    .Anode_Activate(Anode_Activate),
    .LED_out(LED_out)
    //.seg(seg),
    //.dp(dp)
);

// Handle the pause functionality with a simple state machine
always @(posedge clk_fast) begin
    if (rst_button) begin
        paused <= 0;
    end else if (pause) begin
        paused <= ~paused;  // Toggle pause state on button press
    end
end

endmodule

//MODULES
module clk_div(
input clock_in, // 100 MHz master clock, V10 on board
input rst,
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
 parameter DIVISOR_2hz = 28'd50000000;
 parameter DIVISOR_1hz = 28'd100000000;
 parameter DIVISOR_fast = 28'd200000;
 parameter DIVISOR_blink = 28'd20000000;
   
 // The frequency of the output clk_out =  The frequency of the input clk_in divided by DIVISOR
 always @(posedge clock_in or posedge rst)
 begin
 if (rst)
 begin
 //Zero out evertyhing
counter_2hz <= 0;
counter_1hz <= 0;
counter_fast <= 0;
counter_blink <= 0;
clk_2hz_reg <= 0;
clk_1hz_reg <= 0;
clk_fast_reg <= 0;
clk_blink_reg <= 0;
 end
 
 else begin
  //Increment counters
  counter_2hz <= counter_2hz + 28'd1;
  counter_1hz <= counter_1hz + 28'd1;
  counter_fast <= counter_fast + 28'd1;
  counter_blink <= counter_blink + 28'd1;
   
   // Generate clock outputs based on counters
   if (counter_2hz == DIVISOR_2hz) begin
       clk_2hz_reg <= ~clk_2hz;
       counter_2hz <= 0;
   end
   if (counter_1hz == DIVISOR_1hz) begin
       clk_1hz_reg <= ~clk_1hz;
       counter_1hz <= 0;
   end
   if (counter_fast == DIVISOR_fast) begin
       clk_fast_reg <= ~clk_fast;
       counter_fast <= 0;
   end
   if (counter_blink == DIVISOR_blink) begin 
       clk_blink_reg <= ~clk_blink;
       counter_blink <= 0;
   end
 end
 end
 
 assign clk_2hz = clk_2hz_reg;
 assign clk_1hz = clk_1hz_reg;
 assign clk_fast = clk_fast_reg;
 assign clk_blink = clk_blink_reg;
 
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
    seconds = 0;
    
    
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


module display(
    input clk,
    input [5:0] minutes,
    input [5:0] seconds,
//    .blink_en(adj),
//    .blink_clk(clk_blink),
    output reg [6:0] Anode_Activate,
    output reg [3:0] LED_out
//    .seg(seg),
//    .dp(dp)


//    input clock_100Mhz, // 100 Mhz clock source on Basys 3 FPGA
//    input reset, // reset
//    output reg [3:0] Anode_Activate, // anode signals of the 7-segment LED display
//    output reg [6:0] LED_out// cathode patterns of the 7-segment LED display
    );
    reg [26:0] one_second_counter; // counter for generating 1 second clock enable
    wire one_second_enable;// one second enable for counting numbers
    reg [15:0] displayed_number; // counting number to be displayed
    reg [3:0] LED_BCD;
    reg [19:0] refresh_counter; // 20-bit for creating 10.5ms refresh period or 380Hz refresh rate
             // the first 2 MSB bits for creating 4 LED-activating signals with 2.6ms digit period
    wire [1:0] LED_activating_counter; 
                 // count     0    ->  1  ->  2  ->  3
              // activates    LED1    LED2   LED3   LED4
             // and repeat
    
   
    
    // anode activating signals for 4 LEDs, digit period of 2.6ms
    // decoder to generate anode signals 
    always @(*)
    begin
        case(LED_activating_counter)
        2'b00: begin
            Anode_Activate = 4'b0111; 
            // activate LED1 and Deactivate LED2, LED3, LED4
            LED_BCD = minutes/10;
            // the first digit of the 16-bit number
              end
        2'b01: begin
            Anode_Activate = 4'b1011; 
            // activate LED2 and Deactivate LED1, LED3, LED4
            LED_BCD = minutes%10;
            // the second digit of the 16-bit number
              end
        2'b10: begin
            Anode_Activate = 4'b1101; 
            // activate LED3 and Deactivate LED2, LED1, LED4
            LED_BCD = seconds/10;
            // the third digit of the 16-bit number
                end
        2'b11: begin
            Anode_Activate = 4'b1110; 
            // activate LED4 and Deactivate LED2, LED3, LED1
            LED_BCD = seconds%10;
            // the fourth digit of the 16-bit number    
               end
        endcase
    end
    // Cathode patterns of the 7-segment LED display 
    always @(*)
    begin
        case(LED_BCD)
        4'b0000: LED_out = 7'b0000001; // "0"     
        4'b0001: LED_out = 7'b1001111; // "1" 
        4'b0010: LED_out = 7'b0010010; // "2" 
        4'b0011: LED_out = 7'b0000110; // "3" 
        4'b0100: LED_out = 7'b1001100; // "4" 
        4'b0101: LED_out = 7'b0100100; // "5" 
        4'b0110: LED_out = 7'b0100000; // "6" 
        4'b0111: LED_out = 7'b0001111; // "7" 
        4'b1000: LED_out = 7'b0000000; // "8"     
        4'b1001: LED_out = 7'b0000100; // "9" 
        default: LED_out = 7'b0000001; // "0"
        endcase
    end
 endmodule
 
