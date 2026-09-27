ASM      := nasm
LD       := ld
LDFLAGS  := -m elf_x86_64

SRC_DIR  := src
TEST_DIR := test
OBJ_DIR  := obj
TARGET   := $(TEST_DIR)/run_tests

ASMFLAGS := -f elf64 -g -F dwarf -I$(TEST_DIR)/

SRC_FILES    := $(wildcard $(SRC_DIR)/*.asm)
TEST_FILES   := $(filter-out $(TEST_DIR)/run_tests.asm,$(wildcard $(TEST_DIR)/*.asm))
SRC_OBJECTS  := $(patsubst $(SRC_DIR)/%.asm,$(OBJ_DIR)/src_%.o,$(SRC_FILES))
TEST_OBJECTS := $(patsubst $(TEST_DIR)/%.asm,$(OBJ_DIR)/test_%.o,$(TEST_FILES))
RUN_OBJECT   := $(OBJ_DIR)/test_run_tests.o

.PHONY: all build run clean

all: run

build:
	@test -f $(TEST_DIR)/run_tests.asm || { echo "Test suite is pending: expected $(TEST_DIR)/run_tests.asm."; exit 1; }
	@test -n "$(SRC_FILES)" || { echo "Implementation is pending: expected $(SRC_DIR)/*.asm."; exit 1; }
	@$(MAKE) --no-print-directory $(TARGET)

run: build
	@echo "=== Running Data Structures Basics Unit Tests ==="
	@./$(TARGET)

$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

$(OBJ_DIR)/src_%.o: $(SRC_DIR)/%.asm | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(OBJ_DIR)/test_%.o: $(TEST_DIR)/%.asm | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(TARGET): $(SRC_OBJECTS) $(TEST_OBJECTS) $(RUN_OBJECT) | $(OBJ_DIR)
	$(LD) $(LDFLAGS) $^ -o $@

clean:
	@rm -rf $(OBJ_DIR) $(TARGET) $(TARGET).exe
	@echo "Cleaned up."
