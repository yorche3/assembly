# Makefile para hello_world.asm (NASM + x86_64 Linux)
# Uso: make       -> compila
#      make run   -> compila y ejecuta
#      make clean -> elimina archivos generados

ASM      = nasm
ASMFLAGS = -f elf64
LINK     = ld

TARGET   = hello_world
SRC      = hello_world.asm
OBJ      = hello_world.o

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(OBJ)
	$(LINK) $(OBJ) -o $(TARGET)

$(OBJ): $(SRC)
	$(ASM) $(ASMFLAGS) $(SRC) -o $(OBJ)

run: all
	./$(TARGET)

clean:
	rm -f $(OBJ) $(TARGET)
