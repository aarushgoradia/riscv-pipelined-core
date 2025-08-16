module dmem #(
    parameter ADDR_WIDTH = 10
)(
    input logic clk,
    input logic we,
    input logic [ADDR_WIDTH-1:0] addr,  // word-aligned address
    input logic [31:0] din, // store data (rs2)
    output logic [31:0] dout // load data (rd)
);

    // Memory
    logic [31:0] mem [0:(1<<ADDR_WIDTH)-1];

    // Initialize memory contents to zero to avoid X propagation on first loads
    integer i;
    initial begin
        for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin
            mem[i] = 32'h0000_0000;
        end
    end

    // Synchronous write
    always_ff @(posedge clk) begin
        if (we) begin
            mem[addr] <= din;
        end
    end

    // Asynchronous read so load data is available in the same cycle the address
    // is presented (matches current single-cycle MEM stage expectation).
    // NOTE: For FPGA block RAM inference you may need a synchronous read; in that
    // case add a pipeline register and adjust hazard logic accordingly.
    always_comb begin
        dout = mem[addr];
    end
endmodule
