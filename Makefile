# Makefile for Verilator + GTKWave simulation of the pipelined RV32I CPU

# directories
SRC_DIR := src
TB_DIR  := tb

# top-level testbench (module + harness)
TOP    := tb_simple
TB_SV  := $(TB_DIR)/tb_simple.sv
TB_CPP := $(TB_DIR)/tb_simple.cpp

# tools
VERILATOR := verilator
GTKWAVE   := gtkwave

# Verilator options
VERILATOR_FLAGS := \
    -Wall \
    --trace \
    --no-timing \
    --Wno-fatal \
    --cc \
    --top-module $(TOP)

# all your RTL
RTL_SV := \
    $(SRC_DIR)/fetch_pkg.sv   \
    $(SRC_DIR)/decode_pkg.sv  \
    $(SRC_DIR)/execute_pkg.sv \
    $(SRC_DIR)/memory_pkg.sv  \
    $(SRC_DIR)/pc_reg.sv      \
    $(SRC_DIR)/imem.sv        \
    $(SRC_DIR)/fetch.sv       \
    $(SRC_DIR)/regfile.sv     \
    $(SRC_DIR)/imm_gen.sv     \
    $(SRC_DIR)/main_control.sv\
    $(SRC_DIR)/hazard_detect.sv\
    $(SRC_DIR)/decode.sv      \
    $(SRC_DIR)/forwarding_unit.sv \
    $(SRC_DIR)/alu_control.sv \
    $(SRC_DIR)/alu.sv         \
    $(SRC_DIR)/branch.sv      \
    $(SRC_DIR)/execute.sv     \
    $(SRC_DIR)/dmem.sv        \
    $(SRC_DIR)/memory.sv      \
    $(SRC_DIR)/writeback.sv   \
    $(SRC_DIR)/cpu.sv

# the Verilator‑built simulator
SIM_EXE := obj_dir/V$(TOP)

.PHONY: all sim wave clean

all: $(SIM_EXE)

# build the Verilator simulation (SV TB + C++ harness + RTL)
$(SIM_EXE): $(TB_SV) $(TB_CPP) $(RTL_SV)
	@echo "=== Verilating $(TOP) ==="
	$(VERILATOR) $(VERILATOR_FLAGS) \
	    $(TB_SV) $(TB_CPP) \
	    --exe $(RTL_SV)
	@echo "=== Building C++ simulator ==="
	$(MAKE) -C obj_dir -f V$(TOP).mk -j

# run the simulator
sim: all
	@echo "=== Running simulation ==="
	$(SIM_EXE)

# open GTKWave on the resulting VCD
wave: sim
	@echo "=== Launching GTKWave ==="
	$(GTKWAVE) tb_simple.vcd &

# clean out all auto‑generated files
clean:
	@echo "=== Cleaning ==="
	rm -rf obj_dir *.vcd
