module main_control (
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    intput logic funct7_5, // Need to figure this out
    output logic reg_write,
    output logic mem_read,
    output logic mem_write,
    output logic mem_to_reg,
    output logic branch,
    output logic [1:0] alu_op,
    output logic alu_src,
    output logic [2:0] imm_sel
);

    always_comb begin
        // defaults
        reg_write = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;
        branch = 1'b0;
        alu_op = 2'b00;
        alu_src = 1'b0;
        imm_sel = IMM_I;

        case (opcode)
            7'b000011: begin // LOAD
                mem_read = 1'b1;
                reg_write = 1'b1;
                mem_to_reg = 1'b1;
                alu_op = 2'b00;
                alu_src = 1'b1;
                imm_sel = IMM_I;
            end
            7'b0100011: begin // STORE
                mem_write = 1'b1;
                alu_op = 2'b00;
                alu_src = 1'b1;
                imm_sel = IMM_S;
            end
            7'b1100011: begin // BRANCH
                branch = 1'b1;
                alu_op = 2'b01;
                alu_src = 1'b1;
                imm_sel = IMM_B;
            end
            7'b0010011: begin // ALU-IMM
                reg_write = 1'b1;
                alu_op = 2'b10;
                alu_src = 1'b1;
                imm_sel = IMM_I;
            end
            7'b0110011: begin // ALU-R
                reg_write = 1'b1;
                alu_op = 2'b10;
                alu_src = 1'b0;
            end
            // Keep adding cases for other opcodes.
