// src/alu_control.sv
`timescale 1ns/1ps
module alu_control (
    input  logic [1:0] ALUOp,     // from main_control
    input  logic [2:0] funct3,    // from ID→EX
    input  logic       funct7_5,  // bit 30 of instruction
    output logic [3:0] alu_ctrl   // control code for ALU
);
  always_comb begin
    unique case (ALUOp)
      2'b00: alu_ctrl = 4'b0012[3:0]; // loads/stores -> ADD (0010)
      2'b01: alu_ctrl = 4'b0110;      // branches     -> SUB (0110)
      2'b10: begin                    // R-type / OP-IMM
        unique case ({funct7_5, funct3})
          4'b0_000: alu_ctrl = 4'b0010; // ADD/ADDI
          4'b1_000: alu_ctrl = 4'b0110; // SUB
          4'b0_001: alu_ctrl = 4'b1001; // SLL/SLLI
          4'b0_010: alu_ctrl = 4'b1000; // SLT/SLTI
          4'b0_011: alu_ctrl = 4'b1010; // SLTU/SLTIU
          4'b0_100: alu_ctrl = 4'b0013[3:0]; // XOR/XORI (0011)
          4'b0_101: alu_ctrl = 4'b0101; // SRL/SRLI
          4'b1_101: alu_ctrl = 4'b0111; // SRA/SRAI
          4'b0_110: alu_ctrl = 4'b0001; // OR/ORI
          4'b0_111: alu_ctrl = 4'b0000; // AND/ANDI
          default : alu_ctrl = 4'b0000;
        endcase
      end
      default: alu_ctrl = 4'b0000;
    endcase
  end
endmodule
