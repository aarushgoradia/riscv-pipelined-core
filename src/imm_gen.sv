`timescale 1ps/1ps

module imm_gen(
  input  logic [31:0] instr,
  output logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j
);

  // Immediate generation for I-type instructions
  assign imm_i = {{20{instr[31]}}, instr[31:20]};

  // Immediate generation for S-type instructions
  assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};

  // Immediate generation for B-type instructions
  assign imm_b = {{20{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

  // Immediate generation for U-type instructions
  assign imm_u = {instr[31:12], 12'b0};

  // Immediate generation for J-type instructions
  assign imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

endmodule
