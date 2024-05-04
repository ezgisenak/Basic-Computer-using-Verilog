`timescale 1ns/1ns
module controller(
    input clk,
    input [15:0] IR, AC, DR, 
    input [11:0] AR, PC,
    input E, FGI, CO, Z, N, OVF,
    output reg clear_e, comp_e, set_e,
    output reg [2:0] alu_op,  // ALU operation
    output reg reset_ar, reset_pc, reset_dr, reset_tr, reset_ac, // Reset signal */
    output reg write_ar, write_pc, write_dr, write_tr, write_ir, write_ac,
    output reg increment_ar, increment_pc, increment_dr, increment_tr, increment_ac,
    output reg memory_write, memory_read,
    output reg read_ar, read_pc, read_dr, read_tr, read_ir, read_ac,
    output reg IEN
);
    // Define the opcode and the I bit
    reg [2:0] opcode;
    reg I;
    reg R = 0;
    
    // Sequence Counter
    reg [3:0] SC;
    
    initial begin
        // Reset signals
        reset_ar = 1;
        reset_pc = 1;
        reset_dr = 1;
        reset_tr = 1;
        reset_ac = 1;
        // Write signals
        write_ar = 0;
        write_pc = 0;
        write_dr = 0;
        write_tr = 0;
        write_ir = 0;
        write_ac = 0;
        // Increment signals
        increment_ar = 0;
        increment_pc = 0;
        increment_dr = 0;
        increment_tr = 0;
        increment_ac = 0;
        // Memory signals
        memory_write = 0;
        memory_read = 0;
        // Read signals
        read_ar = 0;
        read_pc = 0;
        read_dr = 0;
        read_tr = 0;
        read_ir = 0;
        read_ac = 0;
        // E 
        clear_e = 0;
        comp_e = 0;
        set_e = 0;
        SC = 0;
        IEN = 0;
    end
    
    
    always @(posedge clk)
    begin 
        if (R == 0) begin 
            //FETCH
            if (SC == 0) begin
                // Reset signals
                reset_ar = 0;
                reset_pc = 0;
                reset_dr = 0;
                reset_tr = 0;
                reset_ac = 0;
                // Reset
                write_ac <= 0;
                clear_e <= 0;
                write_ac <= 0;
                comp_e <= 0;
                set_e <= 0;
                increment_ac <= 0;
                increment_pc <= 0;
                read_ac <= 0;     
                memory_write <= 0;
                read_ar <= 0;
                write_pc <= 0;
                read_dr <= 0;
                // Set
                read_pc <= 1;
                write_ar <= 1; 
                SC <= SC + 1; end
            
            else if (SC == 1) begin
                // Reset
                read_pc <= 0; 
                write_ar <= 0;
                // Set
                memory_read <= 1;  
                write_ir <= 1;  
                increment_pc <= 1; 
                SC <= SC + 1; end
            
            else if (SC == 2) begin
                // Reset
                memory_read <= 0;
                write_ir <= 0;
                increment_pc <= 0;
                // Set
                write_ar <= 1; 
                read_ir <= 1;
                opcode <= IR[14:12];
                I <= IR[15];
                SC <= SC + 1; end
            else begin // EXECUTION
                if (IEN == 1 && FGI == 1)
                    R <= 1;
                write_ar <= 0;
                read_ir <= 0;
                if (opcode == 3'b111 && I == 0) begin // Register reference
                    if (AR == 12'h800) begin // CLA
                        reset_ac <= 1;
                        SC <= 0; end
                    else if (AR == 12'h400) begin // CLE
                        clear_e <= 1;
                        SC <= 0; end
                    else if (AR == 12'h200) begin // CMA
                        alu_op <= 3'b011;    
                        write_ac <= 1;
                        SC <= 0; end
                    else if (AR == 12'h100) begin // CME
                        comp_e <= 1;
                        SC <= 0; end
                    else if (AR == 12'h080) begin // CIR
                        alu_op <= 3'b100;
                        write_ac <= 1;
                        if (AC[0] == 0)
                            clear_e <= 1;
                        else
                            set_e <= 1;
                        SC <= 0; end
                    else if (AR == 12'h040) begin // CIL
                        alu_op <= 3'b101;
                        write_ac <= 1;
                        if (AC[15] == 0)
                            clear_e <= 1;
                        else
                            set_e <= 1;
                        SC <= 0; end
                    else if (AR == 12'h020) begin // INC
                        increment_ac <= 1;
                        SC <= 0; end
                    else if (AR == 12'h010) begin // SPA
                        if (!Z && !N)
                            increment_pc <= 1;
                        SC <= 0; end
                    else if (AR == 12'h008) begin // SNA
                        if (N)
                            increment_pc <= 1;
                        SC <= 0; end
                    else if (AR == 12'h004) begin // SZA
                        if (Z)
                            increment_pc <= 1;
                        SC <= 0; end
                    else if (AR == 12'h002) begin // SZE
                        if (E == 0)
                            increment_pc <= 1;
                        SC <= 0; end
                    else if (AR == 12'h001) begin // HLT
                        SC <= 0; end
                end
                else if (opcode == 3'b111 && I == 1) begin
                    if (AR == 12'h080) 
                        IEN <= 1;
                    else if (AR == 12'h040)
                        IEN <= 0;
                end
                else begin // Memory reference instructions 
                    if (SC == 3) begin
                        if(I == 1) begin // indirect
                            memory_read <= 1;
                            write_ar <= 1;
                            SC <= SC + 1; end
                        else  // direct
                            SC <= SC + 1;
                    end
                    else begin
                        memory_read <= 0;
                        write_ar <= 0;
                        if(opcode == 3'b000) begin //AND
                            if(SC == 4) begin
                                write_dr <= 1; 
                                memory_read <= 1;
                                SC <= SC + 1; end
                            else begin
                                write_dr <= 0; 
                                memory_read <= 0;
                                alu_op <= 3'b001;
                                write_ac <= 1;
                                SC <= 0; end
                        end
                        else if(opcode == 3'b001) begin //ADD
                            if(SC == 4) begin
                                write_dr <= 1; 
                                memory_read <= 1;
                                SC <= SC + 1; end
                            else begin
                                write_dr <= 0; 
                                memory_read <= 0;
                                alu_op <= 3'b000;
                                write_ac <= 1;
                                if (CO == 1)
                                    set_e <= 1;
                                else 
                                    clear_e <= 1;
                                SC <= 0; end
                        end
                        else if(opcode == 3'b010) begin //LDA
                            if(SC == 4) begin
                                write_dr <= 1; 
                                memory_read <= 1;
                                SC <= SC + 1; end
                            else begin
                                write_dr <= 0; 
                                memory_read <= 0;
                                alu_op <= 3'b010;
                                write_ac <= 1;
                                SC <= 0; end
                        end
                        else if(opcode == 3'b011) begin //STA
                            read_ac <= 1;
                            memory_write <= 1;
                            SC <= 0;
                        end
                        else if(opcode == 3'b100) begin //BUN
                            read_ar <= 1;
                            write_pc <= 1;
                            SC <= 0;
                        end
                        else if(opcode == 3'b101) begin //BSA
                            if(SC == 4) begin
                                read_pc <= 1; 
                                memory_write <= 1;
                                increment_ar <= 1;
                                SC <= SC + 1; end
                            else begin
                                read_pc <= 0; 
                                memory_write <= 0;
                                increment_ar <= 0;
                                write_pc <= 1;
                                read_ar <= 1;
                                SC <= 0; end
                        end
                        else if(opcode == 3'b110) begin //ISZ
                            if(SC == 4) begin
                                write_dr <= 1; 
                                memory_read <= 1;
                                SC <= SC + 1; end
                            else if(SC ==5) begin
                                write_dr <= 0; 
                                memory_read <= 0;
                                increment_dr <= 1; end
                            else begin
                                increment_dr <= 0;
                                memory_write <= 1;
                                read_dr <= 1;
                                if(DR == 0)
                                    increment_pc <= 1;
                                SC <= 0; end
                        end
                   end
                end 
            end
        end else begin // R == 1 
            if (SC == 0) begin
                // Reset
                // Reset signals
                reset_ar = 0;
                reset_pc = 0;
                reset_dr = 0;
                reset_tr = 0;
                reset_ac = 0;
                write_ac <= 0;	
                clear_e <= 0;
                write_ac <= 0;
                comp_e <= 0;
                set_e <= 0;
                increment_ac <= 0;
                read_ac <= 0;     
                memory_write <= 0;
                read_ar <= 0;
                write_pc <= 0;
                read_dr <= 0;
                increment_pc <= 0;
                // Set
                reset_ar <= 1;
                read_pc <= 1;
                write_tr <= 1;
                SC <= SC + 1;
            end
            else if (SC == 1) begin
                // Reset
                reset_ar <= 0;
                read_pc <= 0;
                write_tr <= 0;
                // Set
                reset_pc <= 1;
                read_tr <= 1;
                memory_write <= 1;
                SC <= SC + 1;
            end
            else if (SC == 2) begin
                // Reset
                reset_pc <= 0;
                read_tr <= 0;
                memory_write <= 0;
                // Set
                increment_pc <= 1;
                IEN <= 0;
                R <= 0;                
                SC <= 0;
            end
        end
    end
endmodule
