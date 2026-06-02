# Numbers — Assembly (NASM x86-64)

Implementación de la especificación [04_Numbers](https://yorche3.github.io/programming_languages/core/foundations/04_Numbers/) en **Assembly x86-64** con **NASM**, usando únicamente la biblioteca estándar del sistema (`syscall`) para E/S.

Tres enfoques de implementación para los mismos 5 algoritmos: **recursivo directo**, **recursivo con acumulador** e **iterativo**.

---

## 📂 Archivos / Files

### Fuentes / Sources (`src/`)

| Archivo | Enfoque | Funciones |
|---------|---------|-----------|
| [`src/numbers_recursive.asm`](src/numbers_recursive.asm) | Recursivo directo | `sum_of_first_n_rec`, `factorial_rec`, `fibonacci_rec`, `greatest_common_divisor_rec`, `least_common_multiple_rec` |
| [`src/numbers_with_acc.asm`](src/numbers_with_acc.asm) | Recursivo con acumulador | `sum_of_first_n_acc`, `factorial_acc`, `fibonacci_acc`, `greatest_common_divisor_acc`, `least_common_multiple_acc` |
| [`src/numbers_iterative.asm`](src/numbers_iterative.asm) | Iterativo | `sum_of_first_n_ite`, `factorial_ite`, `fibonacci_ite`, `greatest_common_divisor_ite`, `least_common_multiple_ite` |

### Pruebas / Tests (`test/`)

| Archivo | Propósito |
|---------|-----------|
| [`test/recursive_tests.asm`](test/recursive_tests.asm) | 11 tests para el enfoque recursivo |
| [`test/recursive_with_acc_tests.asm`](test/recursive_with_acc_tests.asm) | 11 tests para el enfoque con acumulador |
| [`test/iterative_tests.asm`](test/iterative_tests.asm) | 11 tests para el enfoque iterativo |
| [`test/run_tests.asm`](test/run_tests.asm) | Punto de entrada (`_start`) — ejecuta las 3 suites |
| [`test/test_utils.asm`](test/test_utils.asm) | Utilidades compartidas: `print_string`, `assert`, `print_summary` |
| [`test/test_macros.inc`](test/test_macros.inc) | Macros NASM compartidas (`run_test`, `print_str`) vía `%include` |

### Infraestructura / Infrastructure

| Archivo | Propósito |
|---------|-----------|
| [`Makefile`](Makefile) | Automatización de compilación (`make`, `make build`, `make run`, `make clean`) |
| [`.gitignore`](.gitignore) | Ignora `obj/` y el ejecutable de pruebas |
| [`README.md`](README.md) | Este archivo |

---

## 🏗️ Enfoque / Approach

**ES:** Este proyecto sigue el mismo patrón que [Calculator](../unit_test/calculator/) pero con **tres módulos fuente separados** (uno por enfoque) y **tres suites de prueba independientes**. Se usa un marco de pruebas casero con:

1. **`test_utils.asm`** — funciones compartidas: `print_string`, `print_number`, `assert` (compara dos valores y retorna 1 si son iguales), `print_summary`.
2. **`test_macros.inc`** — macros NASM incluidas con `%include`: `run_test` (ejecuta una función de test, imprime PASSED/FAILED, actualiza contadores globales).
3. **Contadores globales** — `tests_total`, `tests_passed`, `tests_failed` en memoria estática, compartidos entre todos los archivos vía `extern`/`global`.
4. **`assert`** — función común que reduce cada test a 4 líneas: llamar a la función bajo prueba → pasar resultado y esperado a `assert` → retornar.

### Comparativa: test con y sin `assert`

**Sin `assert`** (12 líneas por test):
```asm
test_sum_0:
    push rbp
    mov rbp, rsp
    mov rdi, 0
    call sum_of_first_n_rec
    cmp rax, 0
    jne .fail
    xor rax, rax
    jmp .done
.fail: mov rax, 1
.done: pop rbp
    ret
```

**Con `assert`** (4 líneas por test):
```asm
test_sum_0:
    mov rdi, 0
    call sum_of_first_n_rec
    mov rdi, rax        ; resultado real
    mov rsi, 0          ; valor esperado
    call assert         ; rax = 1 si pasó, 0 si falló
    ret
```

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
make build    # Solo compilar
make run      # Solo ejecutar
make clean    # Limpiar
```

**Salida esperada / Expected output:**

```
=== Numbers Module Tests ===

=== Recursive Tests ===
  PASSED: sum_of_first_n_rec(0)
  PASSED: sum_of_first_n_rec(3)
  PASSED: factorial_rec(0)
  PASSED: factorial_rec(4)
  PASSED: fibonacci_rec(0)
  PASSED: fibonacci_rec(1)
  PASSED: fibonacci_rec(6)
  PASSED: greatest_common_divisor_rec(12, 8)
  PASSED: greatest_common_divisor_rec(7, 5)
  PASSED: least_common_multiple_rec(4, 6)
  PASSED: least_common_multiple_rec(6, 8)

=== Recursive with Accumulator Tests ===
  PASSED: sum_of_first_n_acc(0)
  PASSED: sum_of_first_n_acc(3)
  PASSED: factorial_acc(0)
  PASSED: factorial_acc(4)
  PASSED: fibonacci_acc(0)
  PASSED: fibonacci_acc(1)
  PASSED: fibonacci_acc(6)
  PASSED: greatest_common_divisor_acc(12, 8)
  PASSED: greatest_common_divisor_acc(7, 5)
  PASSED: least_common_multiple_acc(4, 6)
  PASSED: least_common_multiple_acc(6, 8)

=== Iterative Tests ===
  PASSED: sum_of_first_n_ite(0)
  PASSED: sum_of_first_n_ite(3)
  PASSED: factorial_ite(0)
  PASSED: factorial_ite(4)
  PASSED: fibonacci_ite(0)
  PASSED: fibonacci_ite(1)
  PASSED: fibonacci_ite(6)
  PASSED: greatest_common_divisor_ite(12, 8)
  PASSED: greatest_common_divisor_ite(7, 5)
  PASSED: least_common_multiple_ite(4, 6)
  PASSED: least_common_multiple_ite(6, 8)

tests runned 33
passed 33
failed 0
```

> Todos los tests deben pasar (33 PASSED, 0 FAILED) con código de salida 0.

---

## 🔧 Flujo de compilación / Build Flow

```text
src/numbers_recursive.asm       ──►  obj/numbers_recursive.o
src/numbers_with_acc.asm        ──►  obj/numbers_with_acc.o
src/numbers_iterative.asm       ──►  obj/numbers_iterative.o

test/recursive_tests.asm        ──►  obj/recursive_tests.o     ──┐
test/recursive_with_acc_tests.asm  ──►  obj/recursive_with_acc_tests.o  │
test/iterative_tests.asm        ──►  obj/iterative_tests.o     │
test/run_tests.asm              ──►  obj/run_tests.o           ├── ld ──► test/run_tests
test/test_utils.asm             ──►  obj/test_utils.o          ┘

(usando nasm -f elf64 -Itest/ y ld -m elf_x86_64)
```

---

## 🧪 Algoritmos / Algorithms

### 3 enfoques × 5 algoritmos = 33 tests

| Algoritmo | Casos de prueba | Recursivo | Con acumulador | Iterativo |
|-----------|----------------|-----------|----------------|-----------|
| `Sum_Of_First_N` | `(0) = 0`, `(3) = 6` | ✅ | ✅ | ✅ |
| `Factorial` | `(0) = 1`, `(4) = 24` | ✅ | ✅ | ✅ |
| `Fibonacci` | `(0) = 0`, `(1) = 1`, `(6) = 8` | ✅ | ✅ | ✅ |
| `Greatest_Common_Divisor` | `(12, 8) = 4`, `(7, 5) = 1` | ✅ | ✅ | ✅ |
| `Least_Common_Multiple` | `(4, 6) = 12`, `(6, 8) = 24` | ✅ | ✅ | ✅ |

**Total: 11 tests por enfoque × 3 enfoques = 33 tests.**

---

## 📁 Estructura / Structure

```text
numbers/
├── src/
│   ├── numbers_recursive.asm      # Enfoque recursivo directo
│   ├── numbers_with_acc.asm       # Enfoque recursivo con acumulador
│   └── numbers_iterative.asm      # Enfoque iterativo
├── test/
│   ├── recursive_tests.asm        # Tests del enfoque recursivo
│   ├── recursive_with_acc_tests.asm  # Tests del enfoque con acumulador
│   ├── iterative_tests.asm        # Tests del enfoque iterativo
│   ├── run_tests.asm              # Punto de entrada (_start)
│   ├── test_utils.asm             # Utilidades compartidas (print, assert, summary)
│   └── test_macros.inc            # Macros compartidas (%include)
├── obj/                           # Objetos (generado por make)
├── Makefile                       # Build automation
├── .gitignore                     # Ignora obj/ y ejecutables
└── README.md                      # Este archivo
```

---

### 🌐 Otras implementaciones / Other implementations

Este proyecto también está implementado en otros lenguajes. Explora el [repositorio principal](https://github.com/yorche3/programming_languages) para ver todas las versiones.

---

## 📝 Notas / Notes

- **ES:** Este proyecto usa exclusivamente la biblioteca estándar del sistema operativo (`syscall`). No tiene dependencias externas.
- **EN:** This project uses only the OS standard library (`syscall`). No external dependencies.
- **ES:** Las macros NASM (`%include "test_macros.inc"`) evitan duplicar el código de gestión de tests en los 3 archivos de prueba.
- **EN:** NASM macros (`%include "test_macros.inc"`) avoid duplicating test management code across the 3 test files.
- **ES:** El uso de `assert` reduce cada test de 12 a 4 líneas de código, eliminando 264 líneas de repetición en total.
- **EN:** Using `assert` reduces each test from 12 to 4 lines of code, eliminating 264 lines of repetition in total.
- **ES:** La función `assert` compara dos enteros (resultado real vs. esperado) y retorna 1 si son iguales, 0 si no.
- **EN:** The `assert` function compares two integers (actual vs. expected) and returns 1 if equal, 0 otherwise.

---

*[← Volver a Foundations](../README.md)*

*🌐 [github.com/yorche3/programming_languages](https://github.com/yorche3/programming_languages) · [GitHub Pages](https://yorche3.github.io/programming_languages/)*
