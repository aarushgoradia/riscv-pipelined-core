// src/cpu.sv
`timescale 1ns/1ps

import fetch_pkg::*;
import decode_pkg::*;
import execute_pkg::*;
import memory_pkg::*;

module cpu (
  input  logic clk,    // clock
  input  logic reset   // reset, active high
);

  // pipeline registers
  fetch_pkg::if_id_t    if_id;    // IF → ID
  decode_pkg::id_ex_t   id_ex;    // ID → EX
  execute_pkg::ex_mem_t ex_mem_reg;   // EX → MEM registered
  execute_pkg::ex_mem_t ex_mem_next;  // combinational from execute
  memory_pkg::mem_wb_t  mem_wb;   // MEM → WB

  // stall/flush control
  logic load_use_stall;  
  logic take_branch;     
  logic write_en; // PC / IF enable
  assign write_en = ~load_use_stall; // continuous so it isn't stuck at X

  // Fetch stage
  logic [31:0] branch_target;
  logic [31:0] pc, pc_plus4, instr;
  
  fetch fetch_i (
    .clk           (clk),
    .reset         (reset),
    .we            (write_en),
    .take_branch   (take_branch),
    .branch_target (branch_target),
    .pc            (pc),
    .pc_plus4      (pc_plus4),
    .instr         (instr)
  );

  // Pack fetch outputs into IF/ID pipeline register
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      if_id <= '0;
    end else if (take_branch) begin
      if_id <= '0;  // Flush on taken branch immediately (same cycle branch resolves)
    end else if (write_en) begin
      if_id.pc <= pc;
      if_id.pc_plus4 <= pc_plus4;
      if_id.instr <= instr;
    end
  end

  // Decode stage
  logic [4:0]  wb_addr;   // write-back register index
  logic [31:0] wb_data;   // write-back data
  logic        wb_we;     // write-back enable
  decode decode_i (
    .clk            (clk),
    .reset          (reset),
    .we             (write_en),
    .if_id          (if_id),
    .wb_data        (wb_data),
    .wb_addr        (wb_addr),
    .wb_we          (wb_we),
    .take_branch    (take_branch),
    .load_use_stall (load_use_stall),
    .id_ex          (id_ex)
  );

  // Execute stage
  execute execute_i (
    .id_ex        (id_ex),
    .ex_mem_prev  (ex_mem_reg),
    .mem_wb       (mem_wb),
    .take_branch  (take_branch),
    .ex_mem_next  (ex_mem_next),
    .branch_target(branch_target)
  );

  // EX/MEM pipeline register
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      ex_mem_reg <= '0;
    end else begin
      ex_mem_reg <= ex_mem_next;
    end
  end

  // Memory stage
  memory memory_i (
    .clk    (clk),
    .reset  (reset),
    .ex_mem (ex_mem_reg),
    .mem_wb (mem_wb)
  );

  // Write-back stage
  writeback writeback_i (
    .clk     (clk),
    .reset   (reset),
    .mem_wb  (mem_wb),
    .wb_addr (wb_addr),
    .wb_data (wb_data),
    .wb_we   (wb_we)
  );

endmodule
