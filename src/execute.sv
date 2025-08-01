`timescale 1ns/1ps
    
import decode_pkg::*;
import execute_pkg::*;
import memory_pkg::*;

module execute(
    input logic clk,
    input logic reset,
    // ID/EX pipeline register inputs
    input decode_pkg::id_ex_t id_ex,
    // EX/MEM pipeline register inputs
    input execute_pkg::ex_mem_t ex_mem_old,
    // MEM/WB pipeline register inputs
    input memory_pkg::mem_wb_t mem_wb,
    // Outputs
    output logic take_branch,
    output execute_pkg::ex_mem_t ex_mem
);

    // Forwarding unit
    logic [1:0] forward_a, forward_b;
    forwarding_unit u_forwarding_unit (
        .id_ex_rs1(id_ex.rs1),
        .id_ex_rs2(id_ex.rs2),
        .ex_mem_rd(ex_mem_old.rd),
        .ex_mem_reg_write(ex_mem_old.RegWrite),
        .mem_wb_rd(mem_wb.rd),
        .mem_wb_reg_write(mem_wb.RegWrite),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    // Compute MEM/WB write-back data
    logic [31:0] wb_data_mux;
    assign wb_data_mux = (mem_wb.MemToReg) ? mem_wb.mem_data : mem_wb.alu_result;

    // Forwarding muxes
    logic [31:0] fwdA_data, fwdB_data;
    always_comb begin
        case (forward_a)
            2'b01: fwdA_data = ex_mem_old.alu_result; // Forward from EX/MEM
            2'b10: fwdA_data = wb_data_mux;              // Forward from MEM/WB
            default: fwdA_data = id_ex.rs1_data;    // Use ID/EX rs1 data
        endcase

        case (forward_b)
            2'b01: fwdB_data = ex_mem_old.alu_result; // Forward from EX/MEM
            2'b10: fwdB_data = wb_data_mux;              // Forward from MEM/WB
            default: fwdB_data = id_ex.rs2_data;    // Use ID/EX rs2 data
        endcase
    end

    // ALU operation selection
    logic [31:0] alu_in1, alu_in2;
    assign alu_in1 = id_ex.Branch ? id_ex.pc_plus4 : fwdA_data;
    assign alu_in2 = id_ex.ALUSrc ? id_ex.imm : fwdB_data;

    // ALU Control
    logic [3:0] alu_control;
    alu_control u_alu_control (
        .ALUOp(id_ex.ALUOp),
        .funct3(id_ex.funct3),
        .funct7_5(id_ex.funct7_5),
        .alu_ctrl(alu_control)
    );

    // ALU operation
    logic [31:0] alu_result;
    logic zero_flag, lt_flag;
    alu u_alu (
        .in1(alu_in1),
        .in2(alu_in2),
        .alu_control(alu_control),
        .result(alu_result),
        .zero_flag(zero_flag),
        .lt_flag(lt_flag)
    );

    // Branch unit
    branch u_branch_unit (
        .branch(id_ex.Branch),
        .funct3(id_ex.funct3),
        .zero_flag(zero_flag),
        .lt_flag(lt_flag),
        .take_branch(take_branch)
    );

    // EX/MEM pipeline register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_mem <= '0;
        end else begin
            ex_mem.alu_result <= alu_result;
            ex_mem.rs2_data <= fwdB_data; // Data to be written back
            ex_mem.rd <= id_ex.rd;
            ex_mem.RegWrite <= id_ex.RegWrite;
            ex_mem.MemRead <= id_ex.MemRead;
            ex_mem.MemWrite <= id_ex.MemWrite;
            ex_mem.MemToReg <= id_ex.MemToReg;
        end
    end
endmodule
