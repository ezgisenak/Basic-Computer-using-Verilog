`timescale 1ns/1ns
module ALU #(parameter W = 16)  // Parameter W for the data width
(
    input [W-1:0] AC, DR,  // Two W-bit data inputs
    input E,               // 1-bit input
    input [2:0] OP,        // 3-bit operation select input
    output wire [W-1:0] Result, // W-bit result output
    output wire CO, OVF, N, Z   // Status outputs: Carry-out, Overflow, Negative, Zero
);

// Internal variables
reg [W:0] extended_result;  // Extended result for handling carry-out and overflow

// ALU Operations
always @(*) begin
    case (OP)
        3'b000: extended_result = {1'b0, AC} + {1'b0, DR}; // Addition
        3'b001: extended_result = AC & DR;                 // AND
        3'b010: extended_result = DR;                      // Transfer DR
        3'b011: extended_result = ~AC;                     // Complement AC
        3'b100: extended_result = {E, AC[W-1:1]};          // Shift Right
        3'b101: extended_result = {AC[W-2:0], E};          // Shift Left
        default: extended_result = 0;
    endcase
    // Assign the result (without the extended bit)
end
    assign Result = extended_result[W-1:0];
    // Set the status bits
    assign CO = extended_result[W];   // Carry-out
    assign OVF = (AC[W-1] == DR[W-1]) && (Result[W-1] != AC[W-1]); // Overflow
    assign Z = (Result == 0);         // Zero
    assign N = Result[W-1];           // Negative

endmodule
