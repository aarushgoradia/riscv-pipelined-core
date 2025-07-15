`timescale 1ps / 1ps

module forwarding_unit (
    // ID/EX source registers
    input logic [4:0] id_ex_rs1,
    input logic [4:0] id_ex_rs2,
    // EX/MEM destintaion
    input logic [4:0] ex_mem_rd,
    input logic ex_mem_reg_write,
    // MEM/WB destination
    input logic [4:0] mem_wb_rd,
    input logic mem_wb_reg_write,

    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);

  // Forwarding logic for rs1
  always_comb begin
    if (ex_mem_reg_write && ex_mem_rd != 5'd0 && ex_mem_rd == id_ex_rs1)
      forward_a = 2'b01;  // from EX/MEM
    else if (mem_wb_reg_write && mem_wb_rd != 5'd0 && mem_wb_rd == id_ex_rs1)
      forward_a = 2'b10;  // from MEM/WB
    else forward_a = 2'b00;  // no forward, use ID/EX.rs1_data
  end

  // Forwarding logic for rs2
  always_comb begin
    if (ex_mem_reg_write && ex_mem_rd != 5'd0 && ex_mem_rd == id_ex_rs2)
      forward_b = 2'b01;  // from EX/MEM
    else if (mem_wb_reg_write && mem_wb_rd != 5'd0 && mem_wb_rd == id_ex_rs2)
      forward_b = 2'b10;  // from MEM/WB
    else forward_b = 2'b00;  // no forward, use ID/EX.rs2_data
  end
endmodule
