# Makefile for Calculator Unit Tests (NASM x86-64 Linux)
# ============================================================
# Usage:
#   make          - Build and run tests
#   make build    - Assemble and link all files
#   make run      - Run the tests
#   make clean    - Remove object files and binary

ASM      := nasm
ASMFLAGS := -f elf64 -g -F dwarf
LD       := ld
LDFLAGS  := -m elf_x86_64

SRC_DIR  := src
TEST_DIR := test
OBJ_DIR  := obj

SRC       := $(SRC_DIR)/calculator.asm
CALC_OBJ  := $(OBJ_DIR)/calculator.o
TEST_OBJ  := $(OBJ_DIR)/calculator_test.o
RUN_OBJ   := $(OBJ_DIR)/run_tests.o
PRINT_OBJ := $(OBJ_DIR)/print_utils.o

TARGET   := $(TEST_DIR)/run_tests

.PHONY: all build run clean

all: build run

build: $(OBJ_DIR) $(TARGET)

$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

$(CALC_OBJ): $(SRC) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(TEST_OBJ): $(TEST_DIR)/calculator_test.asm | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(RUN_OBJ): $(TEST_DIR)/run_tests.asm | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(PRINT_OBJ): $(TEST_DIR)/print_utils.asm | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(TARGET): $(CALC_OBJ) $(TEST_OBJ) $(RUN_OBJ) $(PRINT_OBJ)
	$(LD) $(LDFLAGS) $^ -o $@

run: $(TARGET)
	@echo "=== Running Calculator Unit Tests ==="
	@./$(TARGET)

clean:
	@rm -rf $(OBJ_DIR) $(TARGET)
	@echo "Cleaned up."

