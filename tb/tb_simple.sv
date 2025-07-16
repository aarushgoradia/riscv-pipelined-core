// tb/tb_simple.sv
`timescale 1ns/1ps

module tb_simple;
  // clock & reset
  logic clk = 0;
  logic reset = 1;
  always #5 clk = ~clk;    // 100 MHz

  // instantiate your CPU
  cpu dut (
    .clk   (clk),
    .reset (reset)
  );

  // waveform dump
  initial begin
    integer errors = 0;
    $dumpfile("tb_simple.vcd");
    $dumpvars(0, tb_simple);

    // 1) apply reset
    #20;
    reset = 0;

    // 2) run long enough for 3 instructions to retire
    //    (adjust as needed for your pipeline depth + imem latency)
    #200;

    // 3) check the register file directly
    //    Hierarchical path may vary—this assumes your regfile is
    //    instantiated as u_regfile inside decode, and memory is `mem[]`.

    if (dut.decode_i.u_regfile.regs[1] === 32'd5) 
      $display("[PASS] ADDI x1, x0, 5");
    else begin
      $display("[FAIL] ADDI x1, x0, 5: got %0d", dut.decode_i.u_regfile.regs[1]);
      errors++;
    end

    if (dut.decode_i.u_regfile.regs[2] === 32'd10) 
      $display("[PASS] ADDI x2, x0,10");
    else begin
      $display("[FAIL] ADDI x2, x0,10: got %0d", dut.decode_i.u_regfile.regs[2]);
      errors++;
    end

    if (dut.decode_i.u_regfile.regs[3] === 32'd15) 
      $display("[PASS]  ADD x3, x1, x2");
    else begin
      $display("[FAIL]  ADD x3, x1, x2: got %0d", dut.decode_i.u_regfile.regs[3]);
      errors++;
    end

    // 4) summary
    if (errors == 0) $display("=== ALL TESTS PASSED ===");
    else             $display("=== %0d TEST(S) FAILED ===", errors);

    $finish;
  end
endmodule
