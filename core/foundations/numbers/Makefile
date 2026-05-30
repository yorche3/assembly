# Makefile for Numbers Unit Tests (NASM x86-64 Linux)
# ============================================================
# Tests three approaches: recursive, accumulator-based, iterative
#
# Usage:
#   make          - Build and run tests
#   make build    - Assemble and link all files
#   make run      - Run the tests
#   make clean    - Remove object files and binary

ASM      := nasm
LD       := ld
LDFLAGS  := -m elf_x86_64

SRC_DIR  := src
TEST_DIR := test
OBJ_DIR  := obj

ASMFLAGS := -f elf64 -g -F dwarf -I$(TEST_DIR)/

# Source files (3 approaches)
SRC_REC      := $(SRC_DIR)/numbers_recursive.asm
SRC_ACC      := $(SRC_DIR)/numbers_with_acc.asm
SRC_ITE      := $(SRC_DIR)/numbers_iterative.asm

# Object files for sources
REC_OBJ  := $(OBJ_DIR)/numbers_recursive.o
ACC_OBJ  := $(OBJ_DIR)/numbers_with_acc.o
ITE_OBJ  := $(OBJ_DIR)/numbers_iterative.o

# Test files
TEST_REC      := $(TEST_DIR)/recursive_tests.asm
TEST_ACC      := $(TEST_DIR)/recursive_with_acc_tests.asm
TEST_ITE      := $(TEST_DIR)/iterative_tests.asm
TEST_RUN      := $(TEST_DIR)/run_tests.asm
TEST_UTILS    := $(TEST_DIR)/test_utils.asm

# Object files for tests
REC_TEST_OBJ := $(OBJ_DIR)/recursive_tests.o
ACC_TEST_OBJ := $(OBJ_DIR)/recursive_with_acc_tests.o
ITE_TEST_OBJ := $(OBJ_DIR)/iterative_tests.o
RUN_OBJ      := $(OBJ_DIR)/run_tests.o
UTILS_OBJ    := $(OBJ_DIR)/test_utils.o

TARGET   := $(TEST_DIR)/run_tests

.PHONY: all build run clean

all: build run

build: $(OBJ_DIR) $(TARGET)

$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

# Assemble source files (3 approaches)
$(REC_OBJ): $(SRC_REC) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(ACC_OBJ): $(SRC_ACC) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(ITE_OBJ): $(SRC_ITE) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

# Assemble test files
$(REC_TEST_OBJ): $(TEST_REC) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(ACC_TEST_OBJ): $(TEST_ACC) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(ITE_TEST_OBJ): $(TEST_ITE) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(RUN_OBJ): $(TEST_RUN) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(UTILS_OBJ): $(TEST_UTILS) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

# Link all object files into the test executable
$(TARGET): $(REC_OBJ) $(ACC_OBJ) $(ITE_OBJ) $(REC_TEST_OBJ) $(ACC_TEST_OBJ) $(ITE_TEST_OBJ) $(RUN_OBJ) $(UTILS_OBJ)
	$(LD) $(LDFLAGS) $^ -o $@

run: $(TARGET)
	@echo "=== Running Numbers Unit Tests ==="
	@./$(TARGET)

clean:
	@rm -rf $(OBJ_DIR) $(TARGET)
	@echo "Cleaned up."
