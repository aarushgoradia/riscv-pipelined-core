// A single 32-bit program-counter register with enable and reset.
module pc_reg (
    input  logic        clk,       // clock
    input  logic        reset,     // synchronous reset
    input  logic        we,        // write-enable
    input  logic [31:0] next_pc,   // next PC value
    output logic [31:0] pc         // current PC
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'd0;
        end else if (we) begin
            pc <= next_pc;
        end
    end
endmodule
