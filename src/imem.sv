// Synchronous instruction memory (ROM/BRAM).
module imem #(
    parameter ADDR_WIDTH = 10       // depth = 2^ADDR_WIDTH
) (
    input  logic                    clk,   // clock
    input  logic [ADDR_WIDTH-1:0]  addr,   // word-aligned address
    output logic [31:0]            data    // fetched instruction
);
  // declare your memory array
    logic [31:0] mem [0:(1<<ADDR_WIDTH)-1];

  // Initialize memory with a hex file
  initial begin
    $readmemh("imem_init.hex", mem);
  end

  // synchronous read
    always_ff @(posedge clk) begin
        data <= mem[addr];
    end
endmodule
