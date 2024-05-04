`timescale 1ns/1ns
module memory_unit (
    input clk,
    input write_enable,
    input [15:0] write_data,
    input [11:0] address,
    output [15:0] read_data
);

    // Memory array
    reg [15:0] memory_array [0:4095];

    initial begin
        $readmemh("memory_content.hex", memory_array);
    end

    // Combinational read
    assign read_data = memory_array[address];

    // Sequential write
    always @(posedge clk) begin
        if (write_enable) begin
            memory_array[address] <= write_data;
        end
    end

endmodule
