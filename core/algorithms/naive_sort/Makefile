# Makefile for Naive Sort Unit Tests (NASM x86-64 Linux)
# ============================================================
# Tests three algorithms: selection, bubble, insertion
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

# Source files (3 algorithms)
SRC_SELECTION := $(SRC_DIR)/selection_sort.asm
SRC_BUBBLE    := $(SRC_DIR)/bubble_sort.asm
SRC_INSERTION := $(SRC_DIR)/insertion_sort.asm

# Object files for sources
SELECTION_OBJ := $(OBJ_DIR)/selection_sort.o
BUBBLE_OBJ    := $(OBJ_DIR)/bubble_sort.o
INSERTION_OBJ := $(OBJ_DIR)/insertion_sort.o

# Test files
TEST_SELECTION := $(TEST_DIR)/selection_sort_tests.asm
TEST_BUBBLE    := $(TEST_DIR)/bubble_sort_tests.asm
TEST_INSERTION := $(TEST_DIR)/insertion_sort_tests.asm
TEST_CASES     := $(TEST_DIR)/naive_sort_cases.asm
TEST_FIXTURES  := $(TEST_DIR)/naive_sort_fixtures.asm
TEST_RUN       := $(TEST_DIR)/run_tests.asm
TEST_UTILS     := $(TEST_DIR)/test_utils.asm

# Object files for tests
SELECTION_TEST_OBJ := $(OBJ_DIR)/selection_sort_tests.o
BUBBLE_TEST_OBJ    := $(OBJ_DIR)/bubble_sort_tests.o
INSERTION_TEST_OBJ := $(OBJ_DIR)/insertion_sort_tests.o
CASES_OBJ          := $(OBJ_DIR)/naive_sort_cases.o
FIXTURES_OBJ       := $(OBJ_DIR)/naive_sort_fixtures.o
RUN_OBJ            := $(OBJ_DIR)/run_tests.o
UTILS_OBJ          := $(OBJ_DIR)/test_utils.o

TARGET   := $(TEST_DIR)/run_tests

.PHONY: all build run clean

all: build run

build: $(OBJ_DIR) $(TARGET)

$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

# Assemble source files (3 algorithms)
$(SELECTION_OBJ): $(SRC_SELECTION) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(BUBBLE_OBJ): $(SRC_BUBBLE) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(INSERTION_OBJ): $(SRC_INSERTION) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

# Assemble test files
$(SELECTION_TEST_OBJ): $(TEST_SELECTION) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(BUBBLE_TEST_OBJ): $(TEST_BUBBLE) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(INSERTION_TEST_OBJ): $(TEST_INSERTION) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(CASES_OBJ): $(TEST_CASES) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(FIXTURES_OBJ): $(TEST_FIXTURES) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(RUN_OBJ): $(TEST_RUN) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(UTILS_OBJ): $(TEST_UTILS) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

# Link all object files into the test executable
$(TARGET): $(SELECTION_OBJ) $(BUBBLE_OBJ) $(INSERTION_OBJ) $(SELECTION_TEST_OBJ) $(BUBBLE_TEST_OBJ) $(INSERTION_TEST_OBJ) $(CASES_OBJ) $(FIXTURES_OBJ) $(RUN_OBJ) $(UTILS_OBJ)
	$(LD) $(LDFLAGS) $^ -o $@

run: $(TARGET)
	@echo "=== Running Naive Sort Unit Tests ==="
	@./$(TARGET)

clean:
	@rm -rf $(OBJ_DIR) $(TARGET)
	@echo "Cleaned up."
