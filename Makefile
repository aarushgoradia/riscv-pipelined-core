## Makefile for Icarus Verilog (iverilog + vvp) simulation of the pipelined RV32I CPU

SRC_DIR := src
TB_DIR  := tb
BUILD   := build

TOP     := tb_simple
TB_SV   := $(TB_DIR)/tb_simple.sv

RTL_SV := \
    $(SRC_DIR)/fetch_pkg.sv \
    $(SRC_DIR)/decode_pkg.sv \
    $(SRC_DIR)/execute_pkg.sv \
    $(SRC_DIR)/memory_pkg.sv \
    $(SRC_DIR)/pc_reg.sv \
    $(SRC_DIR)/imem.sv \
    $(SRC_DIR)/fetch.sv \
    $(SRC_DIR)/regfile.sv \
    $(SRC_DIR)/imm_gen.sv \
    $(SRC_DIR)/main_control.sv \
    $(SRC_DIR)/hazard_detect.sv \
    $(SRC_DIR)/decode.sv \
    $(SRC_DIR)/forwarding_unit.sv \
    $(SRC_DIR)/alu_control.sv \
    $(SRC_DIR)/alu.sv \
    $(SRC_DIR)/branch.sv \
    $(SRC_DIR)/execute.sv \
    $(SRC_DIR)/dmem.sv \
    $(SRC_DIR)/memory.sv \
    $(SRC_DIR)/writeback.sv \
    $(SRC_DIR)/cpu.sv

VVP     := $(BUILD)/$(TOP).vvp

ICARUS_FLAGS := -g2012 -Wall

.PHONY: all sim wave clean dirs

all: sim

dirs:
	@mkdir -p $(BUILD)

$(VVP): dirs $(TB_SV) $(RTL_SV) imem_init.hex
	@echo "=== Compiling with Icarus (iverilog) ==="
	iverilog $(ICARUS_FLAGS) -o $(VVP) $(RTL_SV) $(TB_SV)

sim: $(VVP)
	@echo "=== Running simulation (vvp) ==="
	vvp $(VVP)

wave: sim
	@echo "Open tb_simple.vcd with GTKWave (if installed)"
	@which gtkwave >/dev/null 2>&1 && gtkwave tb_simple.vcd & || echo "gtkwave not found"

clean:
	@echo "=== Cleaning (Icarus) ==="
	rm -rf $(BUILD) *.vcd
