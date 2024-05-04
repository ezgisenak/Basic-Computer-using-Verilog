`timescale 1ns/1ns
module register #(
     parameter WIDTH=16)
    (
	  input  clk, reset,write,increment,
	  input	[WIDTH-1:0] DATA,
	  output reg [WIDTH-1:0] A
    );
	 
always@(posedge clk) begin
	if (reset) begin
        A <= 0; // Synchronous reset
    end
    else if (write) begin
        A <= DATA; // Parallel load
    end
    else if (increment) begin
        A <= A + 1; // Increment
    end
end
	 
endmodule	 