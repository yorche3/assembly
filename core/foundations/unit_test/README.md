# Unit Testing — Assembly (NASM x86-64)

Implementación de la especificación [03_Unit_Test_Calculator](https://yorche3.github.io/programming_languages/core/foundations/03_Unit_Test_Calculator/) en **Assembly x86-64**.

---

## 📂 Contenido / Contents

```text
unit_test/
└── calculator/           # Calculadora con operaciones aritméticas básicas
    ├── src/
    │   └── calculator.asm         # Módulo Calculator
    ├── test/
    │   ├── calculator_test.asm    # Suite de pruebas unitarias
    │   ├── run_tests.asm          # Punto de entrada
    │   └── print_utils.asm        # Utilidades de impresión
    ├── Makefile                   # Build automation (Linux/WSL)
    ├── run_tests.ps1              # Build automation (Windows PowerShell)
    └── README.md                  # Documentación del módulo
```

---

## 📖 Módulos / Modules

| Módulo | Especificación | Descripción | Estado |
|--------|---------------|-------------|--------|
| `calculator` | [03_Unit_Test_Calculator](https://yorche3.github.io/programming_languages/core/foundations/03_Unit_Test_Calculator/) | Calculadora con `addition`, `subtraction`, `multiplication` (suma repetitiva), `division` (resta repetitiva) y `modulus` | ✅ |

### Enfoque / Approach

**ES:** A diferencia de lenguajes de alto nivel que tienen frameworks de pruebas estándar (`unittest` en Python, AUnit en Ada, JUnit en Java), Assembly no tiene ninguno. Este proyecto implementa un **marco de pruebas casero** usando:

- **NASM macros** (`%macro`) para abstraer la ejecución de pruebas y generar etiquetas únicas.
- **Convención System V AMD64**: argumentos en `rdi`/`rsi`, retorno en `rax` (`0` = éxito, `1` = fallo).
- **Contadores en memoria estática** para llevar el total de pruebas pasadas/falladas.
- **`syscall`** para E/S (sin dependencias externas).
- **Módulo compartido** `print_utils.asm` para evitar duplicación de código de impresión.

**EN:** Unlike high-level languages that have standard testing frameworks (`unittest` in Python, AUnit in Ada, JUnit in Java), Assembly has none. This project implements a **custom test harness** using:

- **NASM macros** (`%macro`) to abstract test execution and generate unique labels.
- **System V AMD64 convention**: arguments in `rdi`/`rsi`, return in `rax` (`0` = pass, `1` = fail).
- **Static memory counters** to track total passed/failed tests.
- **`syscall`** for I/O (no external dependencies).
- **Shared module** `print_utils.asm` to avoid print code duplication.

---

## 🚀 Compilación / Build

```bash
# Linux / WSL
cd calculator && make run

# Windows PowerShell
cd calculator; .\run_tests.ps1
```

---

*[← Volver a Foundations](../../README.md)*
