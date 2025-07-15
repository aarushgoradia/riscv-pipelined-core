`timescale 1ns/1ps

import memory_pkg::*;
import decode_pkg::*;

module writeback (
    input logic clk,
    input logic reset,
    input mem_wb_t mem_wb,
    output logic [4:0]  wb_addr,     // to regfile in decode
    output logic [31:0] wb_data,     // to regfile in decode
    output logic        wb_we        // to regfile in decode
);

    // Select between memory data and ALU result
    assign wb_data = (mem_wb.MemToReg) ? mem_wb.mem_data : mem_wb.alu_result;

    // Write-back address and enable signal
    assign wb_addr = mem_wb.rd;
    assign wb_we = mem_wb.RegWrite;

endmodule
