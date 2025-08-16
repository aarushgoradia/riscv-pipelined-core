// Synchronous instruction memory (ROM/BRAM).
module imem #(
    parameter ADDR_WIDTH = 10       // depth = 2^ADDR_WIDTH
) (
    input  logic                    clk,   // (unused for async read)
    input  logic [ADDR_WIDTH-1:0]   addr,  // word-aligned address
    output logic [31:0]             data   // fetched instruction
);
  // Memory array
  logic [31:0] mem [0:(1<<ADDR_WIDTH)-1];

  // Initialize all locations to NOP (ADDI x0,x0,0 = 0x00000013) then load program
  integer i;
  initial begin
    for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin
      mem[i] = 32'h00000013; // NOP
    end
    $readmemh("imem_init.hex", mem);
  end

  // Asynchronous ROM read (avoids 1-cycle latency & X propagation into pipeline)
  always_comb begin
    data = mem[addr];
  end
endmodule
