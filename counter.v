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
