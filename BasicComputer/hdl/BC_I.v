`timescale 1ns/1ns

module BC_I (
    input clk,
    input FGI,
    output [11:0] PC,
    output [11:0] AR,
    output [15:0] IR,
    output [15:0] AC,
    output [15:0] DR
);

    // Signals for connecting the controller and datapath
    wire clear_e, comp_e, set_e;
    wire [2:0] alu_op;
    wire reset_ar, reset_pc, reset_dr, reset_tr, reset_ac;
    wire write_ar, write_pc, write_dr, write_tr, write_ir, write_ac;
    wire increment_ar, increment_pc, increment_dr, increment_tr, increment_ac;
    wire memory_write, memory_read;
    wire read_ar, read_pc, read_dr, read_tr, read_ir, read_ac;
    wire IEN, CO, Z, N;
    reg E; 
    
    always @(*) begin
        if (clear_e)
            E = 0;
        else if (set_e)
            E = 1;
        else if (comp_e)
            E = ~E;
    end

    // Instantiate the controller
    controller ctrl(
        .clk(clk),
        .IR(IR),
        .AR(AR),
        .PC(PC),
        .AC(AC),
        .DR(DR),
        .E(E), 
        .FGI(FGI),
        .CO(CO),
        .OVF(OVF),
        .N(N),
        .Z(Z),
        .clear_e(clear_e),
        .comp_e(comp_e),
        .set_e(set_e),
        .alu_op(alu_op),
        .reset_ar(reset_ar),
        .reset_pc(reset_pc),
        .reset_dr(reset_dr),
        .reset_tr(reset_tr),
        .reset_ac(reset_ac),
        .write_ar(write_ar),
        .write_pc(write_pc),
        .write_dr(write_dr),
        .write_tr(write_tr),
        .write_ir(write_ir),
        .write_ac(write_ac),
        .increment_ar(increment_ar),
        .increment_pc(increment_pc),
        .increment_dr(increment_dr),
        .increment_tr(increment_tr),
        .increment_ac(increment_ac),
        .memory_write(memory_write),
        .memory_read(memory_read),
        .read_ar(read_ar),
        .read_pc(read_pc),
        .read_dr(read_dr),
        .read_tr(read_tr),
        .read_ir(read_ir),
        .read_ac(read_ac),
        .IEN(IEN)
    );

    // Instantiate the datapath
    datapath dp(
        .clk(clk),
        .reset_ar(reset_ar),
        .reset_pc(reset_pc),
        .reset_dr(reset_dr),
        .reset_tr(reset_tr),
        .reset_ac(reset_ac),
        .write_ar(write_ar),
        .write_pc(write_pc),
        .write_dr(write_dr),
        .write_tr(write_tr),
        .write_ir(write_ir),
        .write_ac(write_ac),
        .increment_ar(increment_ar),
        .increment_pc(increment_pc),
        .increment_dr(increment_dr),
        .increment_tr(increment_tr),
        .increment_ac(increment_ac),
        .memory_write(memory_write),
        .memory_read(memory_read),
        .read_ar(read_ar),
        .read_pc(read_pc),
        .read_dr(read_dr),
        .read_tr(read_tr),
        .read_ir(read_ir),
        .read_ac(read_ac),
        .alu_op(alu_op),
        .IEN(IEN),
        .PC(PC),
        .AR(AR),
        .IR(IR),
        .AC(AC),
        .DR(DR),
        .CO(CO),
        .OVF(OVF),
        .N(N),
        .Z(Z)
    );
    

endmodule
