`timescale 1ns / 1ps

module arbiter (
    input wire clk,     // master clock
    input wire rst_button,
    input wire pause_button,
    input wire adj_switch,
    input wire sel_switch,
  	output wire [3:0] Anode_Activate,   // for the 7-segment display
  	output wire [6:0] LED_out   // for the 7-segment display
);

// Debounced inputs
wire pause, adj, sel, rst;

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
    .rst(rst),
    .clk_2hz(clk_2hz),
    .clk_1hz(clk_1hz),
    .clk_fast(clk_fast),
    .clk_blink(clk_blink)
);

// Debouncer modules instantiation
debouncer rst_deb (.clk(clk_fast), .button_in(rst_button), .button_out(rst));
debouncer pause_deb (.clk(clk_fast), .button_in(pause_button), .button_out(pause));
debouncer adj_deb (.clk(clk_fast), .button_in(adj_switch), .button_out(adj));
debouncer sel_deb (.clk(clk_fast), .button_in(sel_switch), .button_out(sel));
  

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

 //Display instantiation
display display_mux (
    .clk_fast(clk_fast),
    .minutes(minutes),
    .seconds(seconds),
    .adjust(adj),
    .select(sel),
    .blink_clk(clk_blink),
    .Anode_Activate(Anode_Activate),
    .LED_out(LED_out)
);

// Handle the pause functionality with a simple state machine
always @(posedge pause) begin
        paused <= ~paused;  // Toggle pause state on button press
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
 parameter DIVISOR_2hz = 28'd25000000;
 parameter DIVISOR_1hz = 28'd50000000;
 parameter DIVISOR_fast = 28'd100000;
 parameter DIVISOR_blink = 28'd10000000;
// parameter DIVISOR_2hz = 28'd5;
// parameter DIVISOR_1hz = 28'd10;
// parameter DIVISOR_fast = 28'd2;
// parameter DIVISOR_blink = 28'd2;

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
    wire selected_clk;
  assign selected_clk = (!adjust) ? clk : adjust_clk;

  initial begin
    minutes = 0;
    seconds = 0;
  end
  
  always@(posedge selected_clk or posedge reset) begin
    if(reset) begin
      minutes <= 0;
      seconds <= 0;
      
    end else if (!adjust && !pause) begin
    
      if(seconds < 59) seconds <= seconds+1;
      else begin
        seconds <= 0;
        if(minutes < 59) minutes <= minutes + 1;
        else begin
          minutes <=0;
        end
      end
      
    end else if (adjust && !pause) begin
      //Check select pin
      if(select) begin
        //Increment minutes
        if(minutes < 59) minutes <= minutes + 1;
        else begin
          minutes <=0;
        end
      end else begin
        //Increment seconds
        if(seconds < 59) seconds <= seconds+1;
      	else seconds <= 0;
      end  
    end  
  end
endmodule


module display(
    input clk_fast,
    input [5:0] minutes,
    input [5:0] seconds,
    input adjust,
    input select,
    input blink_clk,
    output reg [3:0] Anode_Activate,
    output reg [6:0] LED_out
    );
    reg [3:0] LED_BCD;
    reg [19:0] refresh_counter; // 20-bit for creating 10.5ms refresh period or 380Hz refresh rate
             // the first 2 MSB bits for creating 4 LED-activating signals with 2.6ms digit period
    reg [1:0] LED_activating_counter; 
                 // count     0    ->  1  ->  2  ->  3
              // activates    LED1    LED2   LED3   LED4
             // and repeat
    initial 
    begin
    LED_activating_counter = 0;
    end
  	
    always @(posedge clk_fast) begin
        LED_activating_counter <= LED_activating_counter + 1;
    end

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
        
        if(blink_clk && adjust)begin
                if(select && ( Anode_Activate == 4'b0111 || Anode_Activate == 4'b1011)) 
                    begin
                     LED_out = 7'b1111111;
                    end
                else if(!select && (Anode_Activate == 4'b1101 || Anode_Activate == 4'b1110))
                    begin
                        LED_out = 7'b1111111;
                        $display(select);

                    end
           
                
              else begin
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
            end else begin
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
    end
    // Cathode patterns of the 7-segment LED display 
//    always @(*)
//    begin
//        if(blink_clk && adjust)begin
//        if(select && ( Anode_Activate == 4'b0111 || Anode_Activate == 4'b1011)) 
//            begin
//             LED_out = 7'b1111111;
//            end
//        else if(!select && (Anode_Activate == 4'b1101 || Anode_Activate == 4'b1110))
//            begin
//                LED_out = 7'b1111111;
//            end
//       end
   
        
//      else begin
//        case(LED_BCD)
//        4'b0000: LED_out = 7'b0000001; // "0"     
//        4'b0001: LED_out = 7'b1001111; // "1" 
//        4'b0010: LED_out = 7'b0010010; // "2" 
//        4'b0011: LED_out = 7'b0000110; // "3" 
//        4'b0100: LED_out = 7'b1001100; // "4" 
//        4'b0101: LED_out = 7'b0100100; // "5" 
//        4'b0110: LED_out = 7'b0100000; // "6" 
//        4'b0111: LED_out = 7'b0001111; // "7" 
//        4'b1000: LED_out = 7'b0000000; // "8"     
//        4'b1001: LED_out = 7'b0000100; // "9" 
//        default: LED_out = 7'b0000001; // "0"
//        endcase
//      end
//    end
 endmodule
 
  module debouncer (
   input clk,
   input button_in,
   output reg button_out
 );
     
    reg [1:0] count;
    parameter DEBOUNCE_THRESHOLD = 3;
   
   initial begin
     count = 0;
     button_out <= 0;
   end
 
   always @(posedge clk) begin
       if (button_in == button_out) begin
           count <= 0;
       end else begin
           count <= count + 1;
           if (count >= DEBOUNCE_THRESHOLD) begin
               button_out <= button_in;
               count <= 0;
           end
       end
   end
 endmodule
 
 
 
 
