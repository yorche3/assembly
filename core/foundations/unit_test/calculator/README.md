# Calculator — Assembly (NASM x86-64)

Implementación de la especificación [03_Unit_Test_Calculator](https://yorche3.github.io/programming_languages/core/foundations/03_Unit_Test_Calculator/) en **Assembly x86-64** con **NASM**, usando únicamente la biblioteca estándar del sistema (`syscall`) para E/S y un marco de pruebas minimalista casero.

---

## 📂 Archivos / Files

| Archivo | Propósito |
|---------|-----------|
| [`src/calculator.asm`](src/calculator.asm) | Implementación del módulo `calculator` — `addition`, `subtraction`, `multiplication`, `division`, `modulus`. |
| [`test/calculator_test.asm`](test/calculator_test.asm) | Suite de pruebas unitarias — 5 casos (`test_addition`, `test_subtraction`, `test_multiplication`, `test_division`, `test_modulus`). |
| [`test/run_tests.asm`](test/run_tests.asm) | Punto de entrada (`_start`) — ejecuta la suite y muestra resumen. |
| [`test/print_utils.asm`](test/print_utils.asm) | Utilidades compartidas de impresión — `print_string`, `print_number`, `calculate_string_length`. |
| [`Makefile`](Makefile) | Automatización de compilación (`make`, `make build`, `make run`, `make clean`) para Linux/WSL. |
| [`run_tests.ps1`](run_tests.ps1) | Script PowerShell equivalente para Windows (requiere WSL o MSYS2). |

---

## 🏗️ Enfoque / Approach

**ES:** A diferencia de Ada (que usa AUnit) o Python (que usa `unittest`), Assembly no tiene un framework de pruebas estándar. Este proyecto implementa un **marco de pruebas casero** con:

1. **Convención de llamada** x86-64 System V AMD64: argumentos en `rdi`, `rsi`; retorno en `rax`.
2. Cada función de prueba devuelve `0` (éxito) o `1` (fallo) en `rax`.
3. Macros NASM (`%macro`) para abstraer la lógica de ejecución de pruebas.
4. Contadores en memoria estática (`tests_total`, `tests_passed`, `tests_failed`).
5. Utilidades de impresión compartidas (`print_utils.asm`) para evitar duplicación.

**EN:** Unlike Ada (which uses AUnit) or Python (which uses `unittest`), Assembly has no standard testing framework. This project implements a **custom test harness** with:

1. **x86-64 System V AMD64 calling convention**: arguments in `rdi`, `rsi`; return in `rax`.
2. Each test function returns `0` (pass) or `1` (fail) in `rax`.
3. NASM macros (`%macro`) to abstract test execution logic.
4. Static memory counters (`tests_total`, `tests_passed`, `tests_failed`).
5. Shared print utilities (`print_utils.asm`) to avoid duplication.

### Convención de llamada / Calling Convention

```text
Argumentos / Arguments:  rdi = a, rsi = b
Retorno / Return value:  rax = resultado / result
Registros preservados:   rbx, rbp, r12–r15 (callee-saved)
Registros volátiles:     rax, rcx, rdx, rsi, rdi, r8–r11 (caller-saved)
```

---

## 🚀 Compilar y ejecutar / Build & Run

### Linux / WSL

```bash
make          # Build + Run
make build    # Solo compilar / Build only
make run      # Solo ejecutar / Run only
make clean    # Limpiar / Clean
```

### Windows (PowerShell)

```powershell
.\run_tests.ps1            # Build + Run
.\run_tests.ps1 -Build     # Solo compilar / Build only
.\run_tests.ps1 -Run       # Solo ejecutar / Run only
.\run_tests.ps1 -Clean     # Limpiar / Clean
.\run_tests.ps1 -Help      # Ayuda / Help
```

**Salida esperada / Expected output:**

```
=== Calculator Unit Tests ===
  PASSED: test_addition
  PASSED: test_subtraction
  PASSED: test_multiplication
  PASSED: test_division
  PASSED: test_modulus

  PASSED: 5
  FAILED: 0
```

> **ES:** La salida puede variar ligeramente según la implementación del terminal, pero todas las pruebas deben pasar (5 PASSED, 0 FAILED) y el código de salida debe ser 0.  
> **EN:** Output may vary slightly depending on terminal implementation, but all tests must pass (5 PASSED, 0 FAILED) and the exit code must be 0.

---

## 🔧 Flujo de compilación / Build Flow

```text
src/calculator.asm       ──nasm -f elf64──►  obj/calculator.o
test/calculator_test.asm ──nasm -f elf64──►  obj/calculator_test.o
test/run_tests.asm       ──nasm -f elf64──►  obj/run_tests.o
test/print_utils.asm     ──nasm -f elf64──►  obj/print_utils.o

                                          ──ld -m elf_x86_64──►  test/run_tests
```

---

## 🧪 Operaciones / Operations

| Función / Function | Implementación / Implementation | Cumple / Complies |
|-------------------|-------------------------------|-------------------|
| `addition(a, b)` | `a + b` (suma directa / direct addition) | ✅ No usa operadores educativos |
| `subtraction(a, b)` | `a - b` (resta directa / direct subtraction) | ✅ No usa operadores educativos |
| `multiplication(a, b)` | Suma repetitiva de `a`, `b` veces / Repeated addition (`a` added to itself `b` times) | ✅ No usa `*` |
| `division(a, b)` | Resta repetitiva: cuántas veces cabe `b` en `a` / Repeated subtraction (count how many times `b` fits into `a`) | ✅ No usa `/` |
| `modulus(a, b)` | `a - (division(a, b) * multiplication(division(a, b), b))` usando `division` y `multiplication` | ✅ No usa `%` |

### Detalles de implementación / Implementation Details

#### `multiplication` (suma repetitiva / repeated addition)

```asm
multiplication_function:
    xor rax, rax        ; result = 0
    mov rcx, rsi        ; rcx = b (loop counter)
    cmp rcx, 0
    je .done
.loop:
    add rax, rdi        ; result += a
    dec rcx
    jnz .loop
.done:
    ret
```

#### `division` (resta repetitiva / repeated subtraction)

```asm
division_function:
    xor rax, rax        ; quotient = 0
    cmp rsi, 0
    je .error           ; division by zero → return -1
.loop:
    cmp rdi, rsi        ; while a >= b
    jl .done
    sub rdi, rsi        ; a -= b
    inc rax             ; quotient++
    jmp .loop
.error:
    mov rax, -1
.done:
    ret
```

#### `modulus` (usando division y multiplication)

```asm
modulus_function:
    push rdi            ; save a
    push rsi            ; save b
    call division_function  ; rax = division(a, b) = q
    mov rcx, rax        ; rcx = q
    cmp rcx, -1
    je .error           ; division by zero
    pop rsi             ; restore b
    pop rdi             ; restore a
    push rdi            ; save a again
    push rsi            ; save b again
    mov rdi, rcx        ; rdi = q
    call multiplication_function  ; rax = multiplication(q, b) = p
    mov rcx, rax        ; rcx = p
    pop rsi             ; cleanup
    pop rdi             ; restore a
    sub rdi, rcx        ; a - p
    mov rax, rdi
    ret
```

---

## 📁 Estructura / Structure

```text
calculator/
├── src/
│   └── calculator.asm            # Módulo Calculator / Calculator module
├── test/
│   ├── calculator_test.asm       # Suite de pruebas / Test suite
│   ├── run_tests.asm             # Punto de entrada / Entry point
│   └── print_utils.asm           # Utilidades de impresión / Print utilities
├── obj/                          # Objetos (generado por make)
├── Makefile                      # Build automation (Linux/WSL)
├── run_tests.ps1                 # Build automation (Windows PowerShell)
└── README.md                     # Este archivo / This file
```

---

## 📝 Notas / Notes

- **ES:** Este proyecto usa exclusivamente la biblioteca estándar del sistema operativo (`syscall`). No tiene dependencias externas.
- **EN:** This project uses only the OS standard library (`syscall`). No external dependencies.
- **ES:** La suite de pruebas se implementa con NASM macros para mantener el código legible y educativo.
- **EN:** The test suite is implemented with NASM macros to keep the code readable and educational.
- **ES:** El manejo de errores (división por cero) usa `-1` como valor centinela ya que assembly no tiene excepciones.
- **EN:** Error handling (division by zero) uses `-1` as a sentinel value since assembly has no exceptions.

---

*🌐 [github.com/yorche3/programming_languages](https://github.com/yorche3/programming_languages) · [GitHub Pages](https://yorche3.github.io/programming_languages/)*
