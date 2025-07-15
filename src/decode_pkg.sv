// src/decode_pkg.sv
package decode_pkg;
  typedef struct packed {
    logic [31:0] pc_plus4;
    logic [31:0] rs1_data, rs2_data;
    logic [31:0] imm;
    logic  [4:0] rs1, rs2, rd;
    logic [2:0] funct3;
    logic       funct7_5;
    logic       RegWrite, MemRead, MemWrite, MemToReg, Branch, ALUSrc;
    logic [1:0] ALUOp;
    logic [2:0] ImmSel;
  } id_ex_t;
endpackage
