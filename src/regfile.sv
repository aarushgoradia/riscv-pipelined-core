`timescale 1ps/1ps

module regfile(
    input logic clk,               // clock
    input logic we,                // write-enable
    input logic [4:0] ra1,         // rs1 address
    input logic [4:0] ra2,         // rs2 address
    input logic [4:0] wa,          // write address
    input logic [31:0] wd,         // write data
    output logic [31:0] rd1,       // read data 1
    output logic [31:0] rd2        // read data 2
);

    // Register file memory array
    logic [31:0] regs [31:0];

    // Read ports
    assign rd1 = (ra1 != 5'd0) ? regs[ra1] : 32'd0;
    assign rd2 = (ra2 != 5'd0) ? regs[ra2] : 32'd0;

    always_ff @(posedge clk) begin
        if (we && (wa != 5'd0)) begin
            $display("Time %0t: Writing reg[%0d] = %h", $time, wa, wd);
            regs[wa] <= wd;
        end
    end

endmodule
