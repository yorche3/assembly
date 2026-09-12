# Hello, World! — Assembly

Implementación de la especificación [01_Hello_World](https://yorche3.github.io/programming_languages/core/foundations/01_Hello_World/) en **Assembly (x86_64 NASM)**, para **Linux x86_64** y **Windows x86_64**.

---

## 📂 Archivos y estructura / Files & Structure

| Archivo | Propósito |
|---------|-----------|
| [`hello_world.asm`](hello_world.asm) | Código fuente NASM: imprime `"Hello, World! from Assembly"` en la consola y sale con código 0. |
| [`Makefile`](Makefile) | Compilación en Linux: `nasm` + `ld`. |
| [`build.ps1`](build.ps1) | Compilación en Windows: `nasm` + `golink` (PowerShell). |

**Estructura de directorios esperada:**

```text
helloworld/
├── hello_world.asm    # Código fuente NASM
├── Makefile           # Build para Linux
├── build.ps1          # Build para Windows
├── README.md          # Este archivo
├── hello_world        # Ejecutable (generado, Linux)
├── hello_world.exe    # Ejecutable (generado, Windows)
├── hello_world.o      # Objeto (generado, Linux)
└── hello_world.obj    # Objeto (generado, Windows)
```

---

## 🛠️ Enfoque y construcción / Approach & Build

**ES:** Este proyecto usa **NASM** (Netwide Assembler) con sintaxis Intel para x86_64. Se emplean **llamadas directas al sistema** (`syscall`) en lugar de la biblioteca C estándar, lo que da control total sobre el binario generado.

Características:
- **Sin libc** — el punto de entrada es `_start`, no `main`
- **Solo syscalls** — `sys_write` (1) para escribir, `sys_exit` (60) para salir (Linux)
- **Ejecutable estático** — no necesita librerías dinámicas
- **Portable entre Linux y Windows** (cada uno con su propio linker)

**EN:** This project uses **NASM** (Netwide Assembler) with Intel syntax for x86_64. It uses **direct system calls** (`syscall`) instead of the C standard library, giving full control over the generated binary.

Features:
- **No libc** — entry point is `_start`, not `main`
- **Syscalls only** — `sys_write` (1) to write, `sys_exit` (60) to exit (Linux)
- **Static executable** — no dynamic libraries needed
- **Portable between Linux and Windows** (each with its own linker)

---

## 📄 Archivos de configuración clave / Key Configuration Files

### `hello_world.asm`

**ES:** Código fuente en NASM. Se divide en dos secciones:

**EN:** NASM source code. Divided into two sections:

```asm
section .data
    msg db 'Hello, World! from Assembly', 0xA  ; mensaje con salto de línea
    len equ $ - msg                              ; longitud calculada en tiempo de ensamblado

section .text
    global _start

_start:
    ; syscall write (stdout)
    mov eax, 1        ; número de syscall: sys_write
    mov edi, 1        ; fd: stdout
    mov rsi, msg      ; buffer
    mov edx, len      ; longitud
    syscall

    ; syscall exit
    mov eax, 60       ; número de syscall: sys_exit
    xor rdi, rdi      ; código de salida: 0
    syscall
```

- **`.data`**: datos estáticos (el mensaje y su longitud)
- **`.text`**: código ejecutable
- `len equ $ - msg`: la longitud se calcula en tiempo de ensamblado, no en ejecución

### `Makefile`

**ES:** Para Linux. Compila con `nasm` y enlaza con `ld`:

**EN:** For Linux. Compiles with `nasm` and links with `ld`:

```makefile
ASM      = nasm
ASMFLAGS = -f elf64
LINK     = ld

TARGET   = hello_world
SRC      = hello_world.asm
OBJ      = hello_world.o
```

| Target | Acción |
|--------|--------|
| `make` | Compila `hello_world` |
| `make run` | Compila y ejecuta |
| `make clean` | Elimina `.o` y ejecutable |

### `build.ps1`

**ES:** Para Windows. Compila con `nasm` y enlaza con `GoLink`:

**EN:** For Windows. Compiles with `nasm` and links with `GoLink`:

```powershell
.\build.ps1          # compila
.\build.ps1 -Run     # compila y ejecuta
.\build.ps1 -Clean   # limpia archivos generados
```

> Requiere [NASM](https://www.nasm.us/) y [GoLink](https://www.godevtool.com/) en el PATH.

---

## 🚀 Compilación y ejecución / Build & Run

### Linux

```bash
# Compilar
make

# Ejecutar
./hello_world
```

**Salida esperada / Expected output:**

```text
Hello, World! from Assembly
```

### Windows (PowerShell)

```powershell
# Compilar
.\build.ps1

# Compilar y ejecutar
.\build.ps1 -Run
```

**Salida esperada / Expected output:**

```text
Hello, World! from Assembly
```

### Manualmente (sin Makefile ni script)

```bash
# Linux
nasm -f elf64 hello_world.asm -o hello_world.o
ld hello_world.o -o hello_world
./hello_world
```

```powershell
# Windows
nasm -f win64 hello_world.asm -o hello_world.obj
golink /console hello_world.obj /entry _start
hello_world.exe
```

---

## 📝 Notas de implementación / Implementation Notes

- **ES:** NASM no tiene un sistema de construcción integrado; se usan `Makefile` (Linux) y `build.ps1` (Windows) como envoltorios.
- **EN:** NASM has no built-in build system; `Makefile` (Linux) and `build.ps1` (Windows) are used as wrappers.
- **ES:** El punto de entrada es `_start`, no `main`, porque no se usa libc.
- **EN:** The entry point is `_start`, not `main`, because no libc is used.

---

### 🌐 Otras implementaciones / Other implementations

Este proyecto también está implementado en otros lenguajes. Explora el [repositorio principal](https://github.com/yorche3/programming_languages) para ver todas las versiones.

---

*🌐 [github.com/yorche3/programming_languages](https://github.com/yorche3/programming_languages) · [GitHub Pages](https://yorche3.github.io/programming_languages/)*
