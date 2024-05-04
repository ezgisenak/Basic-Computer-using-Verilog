`timescale 1ns/1ns
module multiplexer #(parameter W = 16) (
    input [W-1:0] in0, in1, in2, in3, in4, in5, in6, in7, // 16 W-bit wide inputs
    input [2:0] select,                                   // 3-bit select input
    output reg [W-1:0] out                                // W-bit wide output
);

    always @ (*)
    begin
        case(select)
            3'b000: out = in0;
            3'b001: out = in1;
            3'b010: out = in2;
            3'b011: out = in3;
            3'b100: out = in4;
            3'b101: out = in5;
            3'b110: out = in6;
            3'b111: out = in7;
            default: out = {W{1'b0}}; // default case to handle undefined states
        endcase
    end
endmodule
