// src/fetch_pkg.sv
package fetch_pkg;
  typedef struct packed {
    logic [31:0] pc;
    logic [31:0] pc_plus4;
    logic [31:0] instr;
  } if_id_t;
endpackage
