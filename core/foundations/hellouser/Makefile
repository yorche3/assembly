# Makefile para hello_user.asm (NASM + x86_64 Linux)
# Uso: make       -> compila
#      make run   -> compila y ejecuta
#      make clean -> elimina archivos generados

ASM      = nasm
ASMFLAGS = -f elf64
LINK     = ld

TARGET   = hello_user
SRC      = hello_user.asm
OBJ      = hello_user.o

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
