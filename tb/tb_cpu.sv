// tb/tb_cpu.sv
`timescale 1ns/1ps

module tb_cpu (
    input logic clk,
    input logic reset
);
  // DUT instantiation
  cpu dut (
    .clk   (clk),
    .reset (reset)
  );

  // Waveform dumping
  initial begin
    $dumpfile("tb_cpu.vcd");
    $dumpvars(0, tb_cpu);
  end

  // Test timeout / finish
  initial begin
    #10000;
    $display("**** TIMEOUT ****");
    $finish;
  end
endmodule
