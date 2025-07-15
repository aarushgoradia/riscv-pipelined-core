`timescale 1ns / 1ps

module decode (
    input  logic clk,
    input  logic reset,
    input  logic we,              // ~(stall || flush)
    // IF/ID pipeline register inputs
    input  fetch_pkg::if_id_t if_id,           // {pc, pc_plus4, instr}
    // Write-back inputs
    input  logic [31:0] wb_data,         // from MEM/WB
    input  logic [4:0] wb_addr,
    input  logic wb_we,
    input  logic take_branch,
    // Hazard detection output
    output logic load_use_stall,
    // ID/EX pipeline register output
    output decode_pkg::id_ex_t id_ex
);
  import fetch_pkg::*;
  import decode_pkg::*;

  // Unpack instruction fields
  logic [6:0] opcode;
  logic [4:0] rd, rs1, rs2;
  logic [2:0] funct3;
  logic       funct7_5;

  assign opcode = if_id.instr[6:0];
  assign rd = if_id.instr[11:7];
  assign funct3 = if_id.instr[14:12];
  assign rs1 = if_id.instr[19:15];
  assign rs2 = if_id.instr[24:20];
  assign funct7_5 = if_id.instr[30];

  // Register file
  logic [31:0] rs1_data, rs2_data;
  regfile u_regfile (
      .clk(clk),
      .we (wb_we),
      .ra1(rs1),
      .ra2(rs2),
      .wa (wb_addr),
      .wd (wb_data),
      .rd1(rs1_data),
      .rd2(rs2_data)
  );

  // Immediate generation
  logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
  imm_gen u_imm_gen (
      .instr(if_id.instr),
      .imm_i(imm_i),
      .imm_s(imm_s),
      .imm_b(imm_b),
      .imm_u(imm_u),
      .imm_j(imm_j)
  );

  // Main control
  logic RegWrite, MemRead, MemWrite, MemToReg, Branch, ALUSrc;
  logic [1:0] ALUOp;
  logic [2:0] ImmSel;
  main_control u_main_ctrl (
      .opcode    (opcode),
      .funct3    (funct3),
      .funct7_5  (funct7_5),
      .reg_write (RegWrite),
      .mem_read  (MemRead),
      .mem_write (MemWrite),
      .mem_to_reg(MemToReg),
      .branch    (Branch),
      .alu_op    (ALUOp),
      .alu_src   (ALUSrc),
      .imm_sel   (ImmSel)
  );

  // Hazard detection for load-use
  hazard_detect u_hazard (
      .id_ex_mem_read(id_ex.MemRead),
      .id_ex_rd      (id_ex.rd),
      .if_id_rs1     (rs1),
      .if_id_rs2     (rs2),
      .load_use_stall(load_use_stall)
  );

  // Immediate select constants (matching main_control.sv)
  localparam [2:0] IMM_I = 3'd0;
  localparam [2:0] IMM_S = 3'd1;
  localparam [2:0] IMM_B = 3'd2;
  localparam [2:0] IMM_U = 3'd3;
  localparam [2:0] IMM_J = 3'd4;

  // Immediate select
  logic [31:0] selected_imm;
  always_comb begin
    case (ImmSel)
      IMM_I: selected_imm = imm_i;
      IMM_S: selected_imm = imm_s;
      IMM_B: selected_imm = imm_b;
      IMM_U: selected_imm = imm_u;
      IMM_J: selected_imm = imm_j;
      default: selected_imm = 32'd0;
    endcase
  end

  // ID/EX pipeline register
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      id_ex <= '0;
    end else if (take_branch) begin
      id_ex <= '0;
    end else if (we) begin
      id_ex.pc_plus4 <= if_id.pc_plus4;
      id_ex.rs1_data <= rs1_data;
      id_ex.rs2_data <= rs2_data;
      id_ex.imm <= selected_imm;
      id_ex.rs1 <= rs1;
      id_ex.rs2 <= rs2;
      id_ex.rd <= rd;
      id_ex.funct3 <= funct3;
      id_ex.funct7_5 <= funct7_5;
      // control signals
      id_ex.RegWrite <= RegWrite;
      id_ex.MemRead <= MemRead;
      id_ex.MemWrite <= MemWrite;
      id_ex.MemToReg <= MemToReg;
      id_ex.Branch <= Branch;
      id_ex.ALUOp <= ALUOp;
      id_ex.ALUSrc <= ALUSrc;
      id_ex.ImmSel <= ImmSel;
    end
  end
endmodule

