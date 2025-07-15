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

    // Synchronous write
    always_ff @(posedge clk) begin
        if (we) begin
            mem[addr] <= din;
        end
    end

    // Synchronous read
    always_ff @(posedge clk) begin
        dout <= mem[addr];
    end
endmodule
