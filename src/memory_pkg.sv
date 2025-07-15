// src/memory_pkg.sv
package memory_pkg;
  typedef struct packed {
    logic [31:0] mem_data;
    logic [31:0] alu_result;
    logic  [4:0] rd;
    logic        RegWrite, MemToReg;
  } mem_wb_t;
endpackage
