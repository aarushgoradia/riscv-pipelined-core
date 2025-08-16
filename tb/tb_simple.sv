// Generic core testbench: loads program from imem, applies reset, runs N cycles,
// then reads expected register values from an expectations file.
`timescale 1ns/1ps

module tb_simple;
  // Clock & reset
  logic clk = 0;
  logic reset = 1;
  always #5 clk = ~clk; // 100MHz

  // DUT
  cpu dut (.clk(clk), .reset(reset));

  // Parameters via plusargs / configuration
  integer cycles = 400; // default run length
  // Widened to 1024 bits (128 chars) so long relative paths like tb/tb_programs/04_branch_not_taken.exp are not truncated
  reg [1023:0] exp_file = "expected.exp"; // expectations file (plusarg EXP)

  // Expectation / bookkeeping variables (declare at module scope for Icarus compatibility)
  integer f, r, idx; 
  integer fails = 0; 
  integer total = 0; 
  reg [31:0] exp; 
  reg [31:0] got;
  initial begin
    if ($value$plusargs("CYCLES=%d", cycles)) begin end
  if ($value$plusargs("EXP=%s", exp_file)) begin end
    $display("[TB] cycles=%0d exp_file=%s", cycles, exp_file);
  end

  // Waveform
  initial begin
    $dumpfile("tb_simple.vcd");
    $dumpvars(0, tb_simple);
  end

  // Reset sequence
  initial begin
    #40; // keep reset asserted for a few cycles
    reset = 0;
  end

  // Run then check expectations
  initial begin
    // Wait for the requested number of clock cycles (variable delay friendly to Icarus)
    repeat (cycles) @(posedge clk);
    // Open expectations file
    f = $fopen(exp_file, "r");
    if (f == 0) begin
      $display("[TB][ERROR] Could not open expectation file %s", exp_file);
      $finish;
    end
    while (!$feof(f)) begin
      r = $fscanf(f, "%d %h\n", idx, exp);
      if (r == 2) begin
        total++;
        if (idx == 0) got = 32'd0; else got = dut.decode_i.u_regfile.regs[idx];
        if (got === exp) $display("[PASS] x%0d = %08x", idx, got);
        else begin
          fails++;
          $display("[FAIL] x%0d expected %08x got %08x", idx, exp, got);
        end
      end
    end
    $fclose(f);
    if (fails == 0) $display("=== ALL %0d CHECKS PASSED ===", total);
    else            $display("=== %0d / %0d CHECKS FAILED ===", fails, total);
    $finish;
  end
endmodule
