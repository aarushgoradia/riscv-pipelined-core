// src/fetch.sv
`timescale 1ns/1ps

module fetch #(
  parameter ADDR_WIDTH = 10
)(
  input  logic        clk,
  input  logic        reset,
  input  logic        we,             // ~(stall || flush)
  input  logic        take_branch,    // from EX stage
  input  logic [31:0] branch_target,  // computed branch PC
  output logic [31:0] pc,             // current PC
  output logic [31:0] pc_plus4,       // PC + 4
  output logic [31:0] instr           // fetched instruction
);

  // Internal nets
  logic [31:0] next_pc;
  logic [ADDR_WIDTH-1:0] imem_addr;
  
  // PC register
  pc_reg u_pc_reg (
    .clk     (clk),
    .reset   (reset),
    .we      (we),
    .next_pc (next_pc),
    .pc      (pc)
  );

  // Combinational logic: PC+4, next_pc MUX, and IMEM address
  always_comb begin
    pc_plus4  = pc + 32'd4;
    next_pc   = take_branch ? branch_target : pc_plus4;
    imem_addr = pc[ADDR_WIDTH+1:2];
  end

  // Instruction memory
  imem #(.ADDR_WIDTH(ADDR_WIDTH)) u_imem (
    .clk  (clk),
    .addr (imem_addr),
    .data (instr)
  );

endmodule
