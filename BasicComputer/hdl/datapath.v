`timescale 1ns/1ns
module datapath(
    input clk,  // Clock signal
    input reset_ar, reset_pc, reset_dr, reset_tr, reset_ac, // Reset signal */
    input write_ar, write_pc, write_dr, write_tr, write_ir, write_ac,
    input increment_ar, increment_pc, increment_dr, increment_tr, increment_ac,
    input memory_write, memory_read,
    input read_ar, read_pc, read_dr, read_tr, read_ir, read_ac,
    input [2:0] alu_op,  // ALU operation code 
    input IEN,
    output wire [11:0] PC,
    output wire [11:0] AR,
    output wire [15:0] IR,
    output wire [15:0] AC,
    output wire [15:0] DR,
    output wire CO, OVF, N, Z   // Status outputs: Carry-out, Overflow, Negative, Zero
    
);
    // Parameters for data width, etc.
    parameter DATA_WIDTH = 16;
    
    wire [DATA_WIDTH-1:0] common_bus;
    wire [DATA_WIDTH-1:0] memory_out;
    
    // Define wires for interconnecting modules
    wire [DATA_WIDTH-1:0] TR;
    
    // Define control signals
    wire [2:0] mux_select;  // Multiplexer selection
    reg [15:0] alu_out;

    // Instantiate the ALU
    ALU #(DATA_WIDTH) alu (
        .AC(AC),
        .DR(DR),
        .E(E),
        .OP(alu_op),
        .Result(alu_out),
        .CO(CO),
        .OVF(OVF),
        .N(N),
        .Z(Z)
    );

    
    // Instantiate the multiplexer
    multiplexer #(DATA_WIDTH) mux (
        .in0({DATA_WIDTH{1'b0}}),
        .in1({4'b0000, AR}),
        .in2({4'b0000, PC}),
        .in3(DR),
        .in4(AC),
        .in5(IR),
        .in6(TR),
        .in7(memory_out),
        .select(mux_select),
        .out(common_bus)
    );

    // Instantiate the memory unit
    memory_unit memory (
        .clk(clk),
        .write_enable(memory_write),
        .write_data(common_bus),
        .address(AR), // output of AR is connected to the memory unit directly 
        .read_data(memory_out)
    );
  
    // Instantiate Accumulator Register
    register #(DATA_WIDTH) reg_AC (
        .clk(clk),
        .reset(reset_ac),
        .write(write_ac),
        .increment(increment_ac),
        .DATA(alu_out),
        .A(AC)
    ); 

    // Instantiate Data Register
    register #(DATA_WIDTH) reg_DR (
        .clk(clk),
        .reset(reset_dr),
        .write(write_dr),
        .increment(increment_dr),
        .DATA(common_bus),
        .A(DR)
    );

    // Instantiate Instruction Register
    register #(DATA_WIDTH) reg_IR (
        .clk(clk),
        .reset(1'b0),        // Inactive reset
        .write(write_ir),
        .increment(1'b0),        // Inactive increment
        .DATA(common_bus),
        .A(IR)
    );
    
    // Instantiate Program Counter
    register #(12) reg_PC (
        .clk(clk),
        .reset(reset_pc),
        .write(write_pc),
        .increment(increment_pc),
        .DATA(common_bus[11:0]),
        .A(PC)
    );

    // Instantiate Address Register
    register #(12) reg_AR (
        .clk(clk),
        .reset(reset_ar),
        .write(write_ar),
        .increment(increment_ar),
        .DATA(common_bus[11:0]),
        .A(AR)
    );
    
    // Instantiate Address Register
    register #(DATA_WIDTH) reg_TR (
        .clk(clk),
        .reset(reset_tr),
        .write(write_tr),
        .increment(increment_tr),
        .DATA(common_bus),
        .A(TR)
    );


assign mux_select = (read_ar) ? 3'b001 : 
                    (read_pc) ? 3'b010 : 
                    (read_dr) ? 3'b011 : 
                    (read_ac) ? 3'b100 : 
                    (read_ir) ? 3'b101 : 
                    (read_tr) ? 3'b110 : 
                    (memory_read) ? 3'b111 :
                    3'b000; // Default case when no control signals are active

endmodule
