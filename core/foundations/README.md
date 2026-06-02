# Foundations — Assembly (NASM x86-64)

Proyectos fundamentales en **Assembly x86-64** con **NASM**, implementando las especificaciones de [Core Foundations](https://yorche3.github.io/programming_languages/core/foundations/).

Cada proyecto usa únicamente la biblioteca estándar del sistema (`syscall`) y se enlaza con `ld` (Linux) o `golink` (Windows), sin dependencias externas.

---

## 📂 Proyectos / Projects

| Proyecto | Especificación | Conceptos introducidos |
|----------|---------------|----------------------|
| [`helloworld/`](helloworld/) | [01_Hello_World](https://yorche3.github.io/programming_languages/core/foundations/01_Hello_World/) | `sys_write`, punto de entrada `_start`, secciones `.data`/`.text` |
| [`hellouser/`](hellouser/) | [02_Hello_User](https://yorche3.github.io/programming_languages/core/foundations/02_Hello_User/) | `sys_read`, buffer `.bss`, saltos condicionales, procesamiento de entrada |
| [`unit_test/calculator/`](unit_test/calculator/) | [03_Unit_Test_Calculator](https://yorche3.github.io/programming_languages/core/foundations/03_Unit_Test_Calculator/) | Pruebas unitarias caseras, macros NASM (`%macro`), varios archivos fuente, `Makefile` |
| [`numbers/`](numbers/)  | [04_Numbers](https://yorche3.github.io/programming_languages/core/foundations/04_Numbers/) | 3 enfoques (recursivo, acumulador, iterativo), `%include` de macros, función `assert`, contadores globales compartidos |

---

## 📈 Progresión de conceptos

```text
helloworld/         hellouser/           unit_test/calculator/        numbers/
────────────────    ────────────────     ───────────────────────     ─────────────────
_start (.text)     sys_read (stdin)     Múltiples archivos fuente    3 módulos fuente
sys_write (1)      buffer .bss          Macros NASM (%macro)         %include + assert
section .data      cmp / jne            Makefile multi-archivo       Contadores globales
secciones básicas  dec / procesar       Pruebas unitarias caseras    11 tests × 3 enfoques
                   salto de línea       print_utils compartido       = 33 tests totales
```

---

## 🛠️ Patrón común / Common Pattern

Cada proyecto comparte estas características:

| Característica | Descripción |
|---------------|-------------|
| **Sin libc** | Punto de entrada `_start`, no `main`. Solo `syscall`. |
| **NASM Intel syntax** | Todos los fuentes usan sintaxis Intel (NASM). |
| **Ejecutable estático** | No necesita librerías dinámicas. Binarios de ~1-8 KB. |
| **Makefile** | Compilación con `nasm -f elf64` + `ld -m elf_x86_64` |
| **Windows support** | `build.ps1` usando `nasm -f win64` + `golink` (en helloworld y hellouser) |
| **Código de salida** | `0` en éxito, número de fallos en pruebas (si aplica). |

### Herramientas necesarias / Required tools

| Herramienta | Linux/WSL | Windows |
|-------------|-----------|---------|
| [NASM](https://www.nasm.us/) | `sudo apt install nasm` | `winget install nasm` |
| `ld` (GNU binutils) | `sudo apt install binutils` | — |
| [GoLink](https://www.godevtool.com/) | — | Descargar y agregar al PATH |
| `make` | `sudo apt install make` | `winget install GnuWin32.Make` (o WSL) |

---

## 🚀 Compilación rápida / Quick Build

### Linux / WSL

```bash
# Hello, World!
cd helloworld && make run

# Hello, User!
cd hellouser && make run

# Calculator Tests
cd unit_test/calculator && make run

# Numbers Tests
cd numbers && make run
```

### Windows (PowerShell)

```powershell
cd helloworld; .\build.ps1 -Run
cd hellouser; .\build.ps1 -Run
```

> Calculator y Numbers requieren WSL o MSYS2 en Windows para `make` y `ld`.

---

## 📁 Estructura / Structure

```text
foundations/
├── helloworld/              # 01_Hello_World
│   ├── hello_world.asm      # Imprime "Hello, World!"
│   ├── Makefile             # Build Linux
│   ├── build.ps1            # Build Windows
│   ├── .gitignore           # Ignora *.o, ejecutables
│   └── README.md
│
├── hellouser/               # 02_Hello_User
│   ├── hello_user.asm       # Lee nombre y saluda
│   ├── Makefile             # Build Linux
│   ├── build.ps1            # Build Windows
│   ├── .gitignore           # Ignora *.o, ejecutables
│   └── README.md
│
├── unit_test/
│   └── calculator/          # 03_Unit_Test_Calculator
│       ├── src/
│       │   └── calculator.asm
│       ├── test/
│       │   ├── calculator_test.asm
│       │   ├── run_tests.asm
│       │   └── print_utils.asm
│       ├── Makefile
│       ├── run_tests.ps1
│       ├── .gitignore
│       └── README.md
│
└── numbers/                 # 04_Numbers
    ├── src/
    │   ├── numbers_recursive.asm
    │   ├── numbers_with_acc.asm
    │   └── numbers_iterative.asm
    ├── test/
    │   ├── recursive_tests.asm
    │   ├── recursive_with_acc_tests.asm
    │   ├── iterative_tests.asm
    │   ├── run_tests.asm
    │   ├── test_utils.asm
    │   └── test_macros.inc
    ├── Makefile
    ├── .gitignore
    └── README.md
```

---

### 🌐 Otras implementaciones / Other implementations

Este proyecto también está implementado en otros lenguajes. Explora el [repositorio principal](https://github.com/yorche3/programming_languages) para ver todas las versiones.

---

## 📦 Requisitos / Requirements

### Linux / WSL

```bash
sudo apt update
sudo apt install nasm binutils make
```

### Windows

```powershell
winget install nasm
```

Y descargar [GoLink](https://www.godevtool.com/) para enlazar en Windows nativo, o usar WSL para los proyectos multi-archivo.

---

## ▶️ Siguiente / Next

👉 Después de fundamentos, continúa con [Fase 1 — Algoritmos Puros](https://yorche3.github.io/programming_languages/ROADMAP/#fase-1--algoritmos-puros--algorithms-pure-).
👉 After foundations, continue with [Phase 1 — Algorithms Pure](https://yorche3.github.io/programming_languages/ROADMAP/#fase-1--algoritmos-puros--algorithms-pure-).

---

*[← Volver a Assembly](../../README.md)*

*🌐 [github.com/yorche3/programming_languages](https://github.com/yorche3/programming_languages) · [GitHub Pages](https://yorche3.github.io/programming_languages/)*
