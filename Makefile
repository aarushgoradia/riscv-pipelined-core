# Makefile for Verilator + GTKWave simulation of the pipelined RV32I CPU

# Directories
SRC_DIR := src
TB_DIR  := tb

# Top-level testbench module (in tb/tb_cpu.sv)
TOP := tb_cpu

# Tools
VERILATOR := verilator
GTKWAVE   := gtkwave

# Verilator options
VERILATOR_FLAGS := \
  -Wall \
  --trace \
  --cc \
  --top-module $(TOP)

# Source lists
TB_SV  := $(TB_DIR)/tb_cpu.sv

RTL_SV := \
  $(SRC_DIR)/fetch_pkg.sv  \
  $(SRC_DIR)/decode_pkg.sv \
  $(SRC_DIR)/execute_pkg.sv\
  $(SRC_DIR)/memory_pkg.sv \
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

# The simulator binary Verilator will produce
SIM_EXE := obj_dir/V$(TOP)

.PHONY: all sim wave clean

all: $(SIM_EXE)

# Build the Verilator simulation
$(SIM_EXE): $(TB_SV) $(RTL_SV)
	@echo "=== Verilating $(TOP) ==="
	$(VERILATOR) $(VERILATOR_FLAGS) $(TB_SV) --exe $(RTL_SV)
	@echo "=== Building C++ simulator ==="
	$(MAKE) -C obj_dir -f V$(TOP).mk -j

# Run the simulator
sim: all
	@echo "=== Running simulation ==="
	$(SIM_EXE)

# Launch GTKWave on the dumped VCD
wave: sim
	@echo "=== Launching GTKWave ==="
	$(GTKWAVE) tb_cpu.vcd &

# Clean up build and waves
clean:
	@echo "=== Cleaning ==="
	rm -rf obj_dir *.vcd

