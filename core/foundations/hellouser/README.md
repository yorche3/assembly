# Hello, User! — Assembly

Implementación de la especificación [02_Hello_User](https://yorche3.github.io/programming_languages/core/foundations/02_Hello_User/) en **Assembly (x86_64 NASM)**, para **Linux x86_64** y **Windows x86_64**.

Lee un nombre desde la entrada estándar y saluda al usuario.

---

## 📂 Archivos y estructura / Files & Structure

| Archivo | Propósito |
|---------|-----------|
| [`hello_user.asm`](hello_user.asm) | Código fuente NASM: pide un nombre, lo lee, imprime `"Hello, <nombre>!"`. |
| [`Makefile`](Makefile) | Compilación en Linux: `nasm` + `ld`. |
| [`build.ps1`](build.ps1) | Compilación en Windows: `nasm` + `golink` (PowerShell). |

**Estructura de directorios esperada:**

```text
hellouser/
├── hello_user.asm     # Código fuente NASM
├── Makefile           # Build para Linux
├── build.ps1          # Build para Windows
├── README.md          # Este archivo
├── hello_user         # Ejecutable (generado, Linux)
├── hello_user.exe     # Ejecutable (generado, Windows)
├── hello_user.o       # Objeto (generado, Linux)
└── hello_user.obj     # Objeto (generado, Windows)
```

---

## 🛠️ Enfoque y construcción / Approach & Build

**ES:** Este programa introduce dos conceptos nuevos respecto a `hello_world`:

1. **Lectura de entrada** (`sys_read`): usa la syscall `0` (Linux) para leer desde `stdin` (fd `0`) hacia un buffer en la sección `.bss`.
2. **Procesamiento del nombre**: elimina el salto de línea (`0xA`) que `sys_read` incluye al presionar Enter, para que el saludo quede limpio.

**EN:** This program introduces two new concepts compared to `hello_world`:

1. **Input reading** (`sys_read`): uses syscall `0` (Linux) to read from `stdin` (fd `0`) into a buffer in the `.bss` section.
2. **Name processing**: removes the newline (`0xA`) that `sys_read` includes when pressing Enter, so the greeting is clean.

---

## 📄 Archivos de configuración clave / Key Configuration Files

### `hello_user.asm`

**ES:** El flujo del programa es:

1. Imprimir `"Enter your name: "` (sys_write)
2. Leer hasta 64 bytes desde stdin (sys_read) → buffer `.bss`
3. Buscar y eliminar el `\n` final del buffer
4. Imprimir `"Hello, "` + nombre + `\n`
5. Salir con código 0

**EN:** Program flow:

1. Print `"Enter your name: "` (sys_write)
2. Read up to 64 bytes from stdin (sys_read) → `.bss` buffer
3. Find and remove trailing `\n` from buffer
4. Print `"Hello, "` + name + `\n`
5. Exit with code 0

```asm
section .bss
    name resb 64          ; buffer de 64 bytes para el nombre

section .data
    prompt db 'Enter your name: ', 0xA
    greeting db 'Hello, '
    newline db 0xA

section .text
    global _start

_start:
    ; print prompt
    mov rax, 1        ; sys_write
    mov rdi, 1        ; stdout
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; read input
    mov rax, 0        ; sys_read
    mov rdi, 0        ; stdin
    mov rsi, name
    mov rdx, 64       ; max bytes
    syscall
    mov rbx, rax      ; guardar cantidad de bytes leídos

    ; eliminar el \n final si existe
    dec rbx
    mov rsi, name
    add rsi, rbx
    cmp byte [rsi], 0xA
    jne skip
    mov byte [rsi], 0

skip:
    ; print "Hello, " + name + newline
    ...
```

**Secciones:**

| Sección | Contenido |
|---------|-----------|
| `.bss` | Datos sin inicializar (buffer de 64 bytes para el nombre) |
| `.data` | Datos inicializados (prompt, greeting, newline) |
| `.text` | Código ejecutable |

**Nuevas instrucciones respecto a `hello_world`:**

| Instrucción | Propósito |
|-------------|-----------|
| `resb 64` | Reserva 64 bytes sin inicializar |
| `mov rax, 0` / `syscall` | Syscall `sys_read` |
| `cmp byte [rsi], 0xA` | Compara un byte en memoria con el salto de línea |
| `jne skip` | Salta si no es igual (conditional jump) |
| `dec rbx` | Decrementa el contador de bytes |

### `Makefile`

**ES:** Idéntico al de `hello_world`. Compila con `nasm` y enlaza con `ld`:

**EN:** Same as `hello_world`. Compiles with `nasm` and links with `ld`:

| Target | Acción |
|--------|--------|
| `make` | Compila `hello_user` |
| `make run` | Compila y ejecuta |
| `make clean` | Elimina `.o` y ejecutable |

### `build.ps1`

**ES:** Para Windows con NASM + GoLink:

**EN:** For Windows with NASM + GoLink:

| Comando | Acción |
|---------|--------|
| `.\build.ps1` | Compila |
| `.\build.ps1 -Run` | Compila y ejecuta |
| `.\build.ps1 -Clean` | Limpia |

---

## 🚀 Compilación y ejecución / Build & Run

### Linux

```bash
make
./hello_user
```

**Salida esperada / Expected output:**

```text
Enter your name:
Ada
Hello, Ada
```

### Windows

```powershell
.\build.ps1 -Run
```

**Salida esperada / Expected output:**

```text
Enter your name:
Ada
Hello, Ada
```

---

## 📦 Requisitos / Requirements

| Herramienta | Linux | Windows |
|-------------|-------|---------|
| [NASM](https://www.nasm.us/) | `sudo apt install nasm` | `winget install nasm` |
| `ld` (GNU binutils) | `sudo apt install binutils` | — |
| [GoLink](https://www.godevtool.com/) | — | Descargar y agregar al PATH |

---

---

## 📝 Notas de implementación / Implementation Notes

- **ES:** `hello_user` introduce `sys_read` (syscall 0), buffer en `.bss` con `resb`, y procesamiento del `\n` final con `cmp`/`jne`.
- **EN:** `hello_user` introduces `sys_read` (syscall 0), `.bss` buffer with `resb`, and trailing `\n` processing with `cmp`/`jne`.
- **ES:** El buffer es de 64 bytes fijos; si el nombre excede ese tamaño, se trunca.
- **EN:** The buffer is fixed at 64 bytes; if the name exceeds that size, it gets truncated.

---

### 🌐 Otras implementaciones / Other implementations

Este proyecto también está implementado en otros lenguajes. Explora el [repositorio principal](https://github.com/yorche3/programming_languages) para ver todas las versiones.

---

*🌐 [github.com/yorche3/programming_languages](https://github.com/yorche3/programming_languages) · [GitHub Pages](https://yorche3.github.io/programming_languages/)*
