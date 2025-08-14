`timescale 1ps/1ps

module hazard_detect(
  input  logic        id_ex_mem_read,
  input  logic [4:0]  id_ex_rd,
  input  logic [4:0]  if_id_rs1,
  input  logic [4:0]  if_id_rs2,
  output logic        load_use_stall
);

  // Load-use hazard detection
  always_comb begin
    load_use_stall = 1'b0;
    if ( id_ex_mem_read
        && (id_ex_rd != 5'd0)
        && ( (id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2) ) ) begin
      load_use_stall = 1'b1; // Stall if a load is followed by a dependent instr
    end
  end
endmodule
