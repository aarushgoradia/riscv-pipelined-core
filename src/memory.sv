`timescale 1ns/1ps

module memory (
    input logic clk,               // clock
    input logic reset,             // synchronous reset
    input execute_pkg::ex_mem_t ex_mem,
    output memory_pkg::mem_wb_t mem_wb
);

    import execute_pkg::*;
    import memory_pkg::*;


    logic [31:0] dmem_data; // Data read from memory

    dmem #(
        .ADDR_WIDTH(ADDR_WIDTH) // Assuming a 1024-word memory
    ) u_dmem (
        .clk(clk),
        .we(ex_mem.MemWrite),
        .addr(ex_mem.alu_result[ADDR_WIDTH-1:2]), // Word-aligned address
        .din(ex_mem.rs2_data), // Data to write (from rs2)
        .dout(dmem_data) // Data read (to be used in MEM/WB)
    );

    always _ff @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_wb <= '0; // Reset MEM/WB register
        end else begin
            mem_wb.mem_data <= dmem_data;
            mem_wb.rd <= ex_mem.alu_result;
            mem_wb.rd <= ex_mem.rd;
            mem_wb.RegWrite <= ex_mem.RegWrite;
            mem_wb.MemToReg <= ex_mem.MemToReg;
            };
        end
    end
endmodule
