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
  execute_pkg::ex_mem_t ex_mem;   // EX → MEM
  memory_pkg::mem_wb_t  mem_wb;   // MEM → WB

  // stall/flush control
  logic load_use_stall;  
  logic take_branch;     
  logic write_en = ~(load_use_stall || take_branch);

  // Fetch stage
  logic [31:0] branch_target;
  fetch fetch_i (
    .clk           (clk),
    .reset         (reset),
    .we            (write_en),
    .take_branch   (take_branch),
    .branch_target (branch_target),
    .if_id         (if_id)
  );

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
    .load_use_stall (load_use_stall),
    .id_ex          (id_ex)
  );

  // Execute stage
  execute execute_i (
    .clk         (clk),
    .reset       (reset),
    .id_ex       (id_ex),
    .ex_mem_old  (ex_mem),
    .mem_wb      (mem_wb),
    .take_branch (take_branch),
    .ex_mem      (ex_mem)
  );
  assign branch_target = ex_mem.alu_result;

  // Memory stage
  memory memory_i (
    .clk    (clk),
    .reset  (reset),
    .ex_mem (ex_mem),
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
