`timescale 1ns/1ps
    
import decode_pkg::*;
import execute_pkg::*;
import memory_pkg::*;

module execute(
    // ID/EX pipeline register inputs
    input decode_pkg::id_ex_t id_ex,
    // Registered EX/MEM from previous cycle (for forwarding)
    input execute_pkg::ex_mem_t ex_mem_prev,
    // MEM/WB pipeline register inputs (for forwarding)
    input memory_pkg::mem_wb_t mem_wb,
    // Outputs (combinational)
    output logic take_branch,
    output execute_pkg::ex_mem_t ex_mem_next,
    output logic [31:0] branch_target
);

    // Forwarding unit
    logic [1:0] forward_a, forward_b;
    forwarding_unit u_forwarding_unit (
        .id_ex_rs1(id_ex.rs1),
        .id_ex_rs2(id_ex.rs2),
        .ex_mem_rd(ex_mem_prev.rd),
        .ex_mem_reg_write(ex_mem_prev.RegWrite),
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
            2'b01: fwdA_data = ex_mem_prev.alu_result; // Forward from EX/MEM
            2'b10: fwdA_data = wb_data_mux;              // Forward from MEM/WB
            default: fwdA_data = id_ex.rs1_data;    // Use ID/EX rs1 data
        endcase

        case (forward_b)
            2'b01: fwdB_data = ex_mem_prev.alu_result; // Forward from EX/MEM
            2'b10: fwdB_data = wb_data_mux;              // Forward from MEM/WB
            default: fwdB_data = id_ex.rs2_data;    // Use ID/EX rs2 data
        endcase
    end

    // ALU operation selection
    logic [31:0] alu_in1, alu_in2;
    wire  [31:0] pc_ex = id_ex.pc_plus4 - 32'd4; // PC of the instruction in EX

    // Immediate select values we care about
    localparam [2:0] IMM_I = 3'd0;
    localparam [2:0] IMM_J = 3'd4;

    logic is_jal_ex;
    logic is_jalr_ex;
    assign is_jal_ex  = (id_ex.ImmSel == IMM_J) && id_ex.ALUSrc && (id_ex.ALUOp == 2'b00) && id_ex.RegWrite;
    assign is_jalr_ex = (id_ex.ImmSel == IMM_I) && id_ex.ALUSrc && (id_ex.ALUOp == 2'b00) && id_ex.RegWrite && (id_ex.funct3 == 3'b000);

    // Choose ALU operands:
    // - For normal ALU / load/store: rs1 / (imm or rs2)
    // - For jal: use PC (already in pc_ex) + imm (ALUSrc=1)
    // - For jalr: rs1 + imm
    // Branch performs rs1 - rs2 via ALUOp=01
    always_comb begin
        // Operand A
        if (is_jal_ex)
            alu_in1 = pc_ex;           // jal: base is PC
        else
            alu_in1 = fwdA_data;       // default / jalr / branch

        // Operand B
        if (id_ex.ALUSrc)
            alu_in2 = id_ex.imm;
        else
            alu_in2 = fwdB_data;
    end

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
    
    // Branch unit (re-use existing module: subtract result (rs1-rs2) gives zero/lt flags)
    branch u_branch_unit (
        .branch(id_ex.Branch),
        .funct3(id_ex.funct3),
        .zero_flag(zero_flag),
        .lt_flag(lt_flag),
        .take_branch(take_branch)
    );

    // Proper branch/jump target (not the subtraction result!)
    assign branch_target = (is_jal_ex)  ? (pc_ex + id_ex.imm) :
                           (is_jalr_ex) ? ((fwdA_data + id_ex.imm) & 32'hFFFF_FFFE) :
                           (id_ex.Branch ? (pc_ex + id_ex.imm) : 32'h0);

    // Produce next EX/MEM values combinationally; registered in top-level
    always_comb begin
        ex_mem_next = '0;
        // For jal / jalr, write-back value is PC+4 (link)
        if (is_jal_ex || is_jalr_ex) begin
            ex_mem_next.alu_result = id_ex.pc_plus4;
        end else begin
            ex_mem_next.alu_result = alu_result;
        end
        ex_mem_next.rs2_data   = fwdB_data;
        ex_mem_next.rd         = id_ex.rd;
        ex_mem_next.RegWrite   = id_ex.RegWrite;
        ex_mem_next.MemRead    = id_ex.MemRead;
        ex_mem_next.MemWrite   = id_ex.MemWrite;
        ex_mem_next.MemToReg   = id_ex.MemToReg;
    end
endmodule
