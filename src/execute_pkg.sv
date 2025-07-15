// src/execute_pkg.sv
package execute_pkg;
  typedef struct packed {
    logic [31:0] alu_result;
    logic [31:0] rs2_data;
    logic  [4:0] rd;
    logic        MemRead, MemWrite, MemToReg, RegWrite;
  } ex_mem_t;
endpackage
