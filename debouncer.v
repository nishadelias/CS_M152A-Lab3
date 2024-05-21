module debouncer (
  input clk,
  input button_in,
  output button_out
);

  reg [1:0] count;
  
  initial begin
    count = 0;
    button_out = 0;
  end

  always @(clk) begin
    if (button_in != 1 or count == 3) begin
      count <= 0;
    end else begin
      count <= count + 1;
    end
    if (count == 3) begin
      button_out <= 1;
    end else begin
      button_out <= 0;
    end
  end
endmodule
