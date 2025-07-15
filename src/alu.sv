`timescale 1ps/1ps

module alu(
    input logic [31:0] in1, // First operand
    input logic [31:0] in2, // Second operand
    input logic [3:0] alu_control, // ALU control signal
    output logic [31:0] result, // ALU result
    output logic zero_flag, // result == 0
    output logic lt_flag // signed(in1 < in2)
);

    always_comb begin
        result = 32'd0; // Default result
        zero_flag = 1'b0; // Default zero flag
        lt_flag = 1'b0; // Default less than flag

        // ALU operation based on control signal
        case(alu_control)
            4'b0010: result = in1 + in2; // ADD
            4'b0110: result = in1 - in2; // SUB
            4'b0100: result = in1 << in2[4:0]; // SLL
            4'b1000: result = ($signed(in1) < $signed(in2)) ? 32'd1 : 32'd0; // SLT
            4'b1001: result = (in1 < in2) ? 32'd1 : 32'd0; // SLTU
            4'b0011: result = in1 ^ in2; // XOR
            4'b0101: result = in1 >> in2[4:0]; // SRL
            4'b0111: result = $signed(in1) >>> in2[4:0]; // SRA
            4'b0001: result = in1 | in2; // OR
            4'b0000: result = in1 & in2; // AND
        endcase

        // Set flags
        zero_flag = (result == 32'd0);
        lt_flag = ($signed(in1) < $signed(in2));
    end
