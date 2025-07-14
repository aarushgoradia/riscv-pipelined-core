# 5-Stage Pipelined RV32I Core

This repository contains a work-in-progress SystemVerilog implementation of a 5-stage pipelined RV32I (base integer) RISC-V core, along with a UVM testbench (coming soon). The goal of this project is to gain hands-on experience with RISC-V instruction encoding, pipeline organization, and hazard mitigation techniques.

---

## Motivation & Design Choices

- **From single-cycle to pipeline**  
  Having previously implemented a simple single-cycle (LC3 ISA) CPU, I wanted to deepen my understanding of modern microarchitectures by targeting the industry-standard RISC-V ISA and adding pipelining for higher throughput.

- **Why RV32I & five stages**  
  RV32I provides a clean, well-documented base ISA. A classic five-stage pipeline (IF → ID → EX → MEM → WB) balances simplicity with performance, letting us process one instruction per cycle once the pipeline is full.

- **Modular, incremental development**  
  Each stage is in its own `.sv` file, with a small `typedef struct packed { … }` for each pipeline-register boundary. This makes it easy to compile and test one stage at a time before wiring everything together in `cpu.sv`.

---

## Pipeline Overview

1. **Instruction Fetch (IF)**  
   - PC register with gated write-enable for stalls/flushes  
   - PC+4 adder and synchronous IMEM read  
   - 2-to-1 PC-mux for fall-through vs. branch target  

2. **Instruction Decode (ID)**  
   - Unpack full 32-bit instruction into `opcode`, `rs1`, `rs2`, `rd`, `funct3`, `funct7`, immediates  
   - Shared 32×32 register file (two async read ports, one sync write port)  
   - Main Control Unit → generates `RegWrite`, `MemRead`, `MemWrite`, `MemToReg`, `Branch`, `ALUOp`, `ALUSrc`, `ImmSel`  
   - Immediate generator builds I-, S-, B-, U-, J-type immediates in parallel  
   - **Hazard Detection Unit** → detects load–use RAW hazards, stalls IF & ID (injects a NOP into EX)  

3. **Execute (EX)**  
   - Two-level forwarding network on both ALU inputs:  
     1. Forward from EX/MEM.alu_result  
     2. Forward from MEM/WB.wb_data  
     3. Otherwise use ID/EX.rs?_data  
   - ALU Operand-muxes select forwarded data vs. `pc_plus4` or immediate  
   - Subtractor → generates `zero` and `lt` flags  
   - `funct3`-controlled comparator → selects BEQ/BNE/BLT/BGE conditions  
   - `take_branch = Branch & cond_true` → drives PC-mux and triggers flush of IF/ID & ID/EX

4. **Memory Access (MEM)**  
   - Synchronous DMEM read/write using `ex_mem.alu_result` as address and `ex_mem.rs2_data` as store data  
   - Data and control bits are latched into MEM/WB  

5. **Write-Back (WB)**  
   - 2-to-1 MUX selects between `mem_wb.mem_data` (loads) and `mem_wb.alu_result` (ALU ops)  
   - Write port of register file driven by `mem_wb.rd`, `wb_data`, and `mem_wb.RegWrite`  

---

## Hazard Protections

- **Structural hazards**  
  - Harvard-style split: separate IMEM & DMEM  
  - Dual-ported register file (2 read, 1 write)

- **Data hazards**  
  - **Forwarding (bypass)**: EX→EX and MEM→EX bypass paths eliminate most RAW stalls  
  - **Load–use interlock**: Hazard Detection Unit stalls the pipeline for one cycle when an instruction immediately following a load needs its result

- **Control hazards**  
  - **Static predict-not-taken**: PC-mux redirects on branch resolution in EX  
  - **Flush gating**: on a taken branch, IF/ID and ID/EX write-enables are disabled for one cycle to squash wrong-path instructions  

*(Dynamic branch prediction and more advanced flush schemes are planned for future extensions.)*

---

## Next Steps

- **Complete UVM testbench** with directed and constrained-random tests, functional coverage  
- **Add dynamic branch predictor** (1-bit/2-bit BHT, BTB) for control-hazard reduction  
- **Synthesis & FPGA prototyping** on a small development board  
- **Documentation**: finalize datapath diagram (computer drawn instead of by hand) and include timing/performance analysis  

---

## Datapath Diagram



---

_This project is under active development. Code and testbench components are a work in progress; feedback and contributions are welcome._


