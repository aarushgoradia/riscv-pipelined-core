import fetch_pkg::*;
import decode_pkg::*;
import execute_pkg::*;
import memory_pkg::*;

module cpu (
    input logic clk,
    input logic reset
);

    // Pipeline registers
    fetch_pkg::if_id_t   if_id;      // between IF and ID
    decode_pkg::id_ex_t  id_ex;      // between ID and EX
    execute_pkg::ex_mem_t ex_mem;    // between EX and MEM
    memory_pkg::mem_wb_t  mem_wb;     // between MEM and WB

    // Control signals
    logic load_use_stall;  // from hazard_detect in decode
    logic take_branch;     // from branch_unit in execute

    // Global write-enable for IF/ID and ID/EX
    logic write_en = ~(load_use_stall || take_branch);

    // Fetch stage
    logic [31:0] branch_target;
    fetch fetch_i (
        .clk(clk),
        .reset(reset),
        .we(write_en),
        .take_branch(take_branch),
        .branch_target(branch_target),
        .if_id(if_id)
    );

    // Decode stage
    // Write back interface
    logic [4:0] wb_addr
    logic [31:0] wb_data;
    logic wb_we;
    decode decode_i (
        .clk(clk),
        .reset(reset),
        .we(write_en),
        .if_id(if_id),
        .wb_data(wb_data),
        .wb_addr(wb_addr),
        .wb_we(wb_we),
        .load_use_stall(load_use_stall),
        .id_ex(id_ex)
    );

    // Execute stage
    execute execute_i (
        .clk(clk),
        .reset(reset),
        .id_ex_(id_ex),
        .ex_mem_old(ex_mem),
        .mem_wb(mem_wb),
        .take_branch(take_branch),
        .ex_mem(ex_mem)
    );

    // This is just the ALU result computed for a branch
    assign branch_target = ex_mem.alu_result

    // Memory stage
    memory memory_i (
        .clk(clk),
        .reset(reset),
        .ex_mem(ex_mem),
        .mem_wb(mem_wb)
    );

    // Writeback stage
    writeback writeback_i (
        .clk(clk),
        .reset(reset),
        .mem_wb(mem_wb),
        .wb_addr(wb_addr),
        .wb_data(wb_data),
        .wb_we(wb_we)
    );
endmodule
