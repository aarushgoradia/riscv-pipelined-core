`timescale 1ns/1ps

module branch(
    input logic branch,               // Branch signal
    input logic [2:0] funct3,         // Function code for branch type
    input logic zero_flag,           // Zero flag from ALU
    input logic lt_flag,             // Less than flag from ALU
    output logic take_branch        // Output signal indicating if branch is taken
);

    always_comb begin
        case (funct3)
            3'b000: take_branch = branch && zero_flag; // BEQ
            3'b001: take_branch = branch && !zero_flag; // BNE
            3'b100: take_branch = branch && lt_flag; // BLT
            3'b101: take_branch = branch && !lt_flag; // BGE
            default: take_branch = 1'b0; // No branch taken
        endcase
    end
endmodule
