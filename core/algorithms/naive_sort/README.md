# Naive Sort — Assembly (NASM x86-64)

Implementación de la especificación [05_Naive_Sort](https://yorche3.github.io/programming_languages/core/algorithms/05_Naive_Sort/) en **Assembly x86-64** con **NASM**, con un enfoque manual y minimalista, sin bibliotecas externas.

Implementation of the [05_Naive_Sort](https://yorche3.github.io/programming_languages/core/algorithms/05_Naive_Sort/) specification in **x86-64 Assembly** with **NASM**, manual and minimalist, without external libraries.

---

## 📂 Archivos y estructura / Files & Structure

### Fuentes / Sources (`src/`)

| Archivo / File | Propósito / Purpose |
|---|---|
| [`src/selection_sort.asm`](src/selection_sort.asm) | Función `selection_sort` |
| [`src/bubble_sort.asm`](src/bubble_sort.asm) | Función `bubble_sort`, con salida temprana por bandera `swapped` |
| [`src/insertion_sort.asm`](src/insertion_sort.asm) | Función `insertion_sort` |

### Pruebas / Tests (`test/`)

| Archivo / File | Propósito / Purpose |
|---|---|
| [`test/naive_sort_fixtures.asm`](test/naive_sort_fixtures.asm) | Datos de prueba compartidos por los tres algoritmos y el `scratch_buffer` para copias in-place |
| [`test/naive_sort_cases.asm`](test/naive_sort_cases.asm) | Motor único de casos (`run_naive_sort_cases`, `report_case`); recibe un puntero a función y ejecuta los 8 casos |
| [`test/selection_sort_tests.asm`](test/selection_sort_tests.asm) / [`bubble_sort_tests.asm`](test/bubble_sort_tests.asm) / [`insertion_sort_tests.asm`](test/insertion_sort_tests.asm) | Wrappers delgados: pasan la función y el encabezado al motor compartido |
| [`test/run_tests.asm`](test/run_tests.asm) | Punto de entrada (`_start`) — ejecuta las 3 suites e imprime el resumen |
| [`test/test_utils.asm`](test/test_utils.asm) | Utilidades compartidas: `print_string`, `assert`, `assert_array`, `copy_qwords`, `print_summary` |
| [`test/test_macros.inc`](test/test_macros.inc) | Macro NASM compartida (`print_str`) vía `%include` |

### Infraestructura / Infrastructure

| Archivo / File | Propósito / Purpose |
|---|---|
| [`Makefile`](Makefile) | Automatización de compilación (`make`, `make build`, `make run`, `make clean`) |
| [`.gitignore`](.gitignore) | Ignora `obj/` y el ejecutable de pruebas |

**Estructura de directorios / Directory structure:**

```text
naive_sort/
├── src/
│   ├── selection_sort.asm
│   ├── bubble_sort.asm
│   └── insertion_sort.asm
├── test/
│   ├── naive_sort_fixtures.asm
│   ├── naive_sort_cases.asm
│   ├── selection_sort_tests.asm
│   ├── bubble_sort_tests.asm
│   ├── insertion_sort_tests.asm
│   ├── run_tests.asm
│   ├── test_utils.asm
│   └── test_macros.inc
├── Makefile
├── .gitignore
└── obj/          # objetos (generado) / objects (generated)
```

---

## 🛠️ Enfoque y construcción / Approach & Build

**ES:** Mismo patrón que [`numbers`](../../foundations/numbers/README.md): tres módulos fuente independientes (uno por algoritmo) y un marco de pruebas casero. A diferencia de `numbers`, aquí los datos son **arrays**, no enteros sueltos, así que el marco añade `assert_array` (comparación elemento a elemento) y `copy_qwords` (copia defensiva de los fixtures antes de cada ordenamiento in-place).

**EN:** Same pattern as [`numbers`](../../foundations/numbers/README.md): three independent source modules (one per algorithm) and a homemade test framework. Unlike `numbers`, the data here are **arrays**, not single integers, so the framework adds `assert_array` (element-wise comparison) and `copy_qwords` (defensive copy of the fixtures before each in-place sort).

### Convención de llamada / Calling Convention

```text
Argumentos / Arguments:  rdi = puntero al array (qwords) / array pointer (qwords)
                         rsi = cantidad de elementos / element count
Retorno / Return value:  rax = mismo puntero, ordenado in-place / same pointer, sorted in place
                         rax = 0 si rdi es null (indicador de fallo) / 0 if rdi is null (failure indicator)
                         Si rsi = 0, retorna rdi sin modificar / If rsi = 0, returns rdi unchanged
Registros preservados:   rbx, rbp, r12–r15 (callee-saved)
Registros volátiles:     rax, rcx, rdx, rsi, rdi, r8–r11 (caller-saved)
```

**ES:** A diferencia de Ada (donde el array es un tipo por valor y `null` no es representable), en Assembly el array es un puntero crudo, así que `null` **sí es representable** y se prueba explícitamente (caso 8).

**EN:** Unlike Ada (where the array is a value type and `null` is not representable), in Assembly the array is a raw pointer, so `null` **is representable** and is explicitly tested (case 8).

---

## 🚀 Compilación y ejecución / Build & Run

```bash
make          # Build + Run
make build    # Solo compilar / Build only
make run      # Solo ejecutar / Run only
make clean    # Limpiar / Clean
```

**Salida real / Actual output:**

```text
=== Naive Sort Module Tests ===

=== Selection Sort Tests ===
  PASSED: sorts a standard unsorted array
  PASSED: preserves an already sorted array
  PASSED: sorts a reverse-order array
  PASSED: preserves equal elements
  PASSED: sorts negative values
  PASSED: preserves a single-element array
  PASSED: preserves an empty array
  PASSED: returns the null failure indicator for a null pointer

=== Bubble Sort Tests ===
  PASSED: sorts a standard unsorted array
  PASSED: preserves an already sorted array
  PASSED: sorts a reverse-order array
  PASSED: preserves equal elements
  PASSED: sorts negative values
  PASSED: preserves a single-element array
  PASSED: preserves an empty array
  PASSED: returns the null failure indicator for a null pointer

=== Insertion Sort Tests ===
  PASSED: sorts a standard unsorted array
  PASSED: preserves an already sorted array
  PASSED: sorts a reverse-order array
  PASSED: preserves equal elements
  PASSED: sorts negative values
  PASSED: preserves a single-element array
  PASSED: preserves an empty array
  PASSED: returns the null failure indicator for a null pointer

tests runned 24
passed 24
failed 0
```

---

## 🧠 Algoritmos / Algorithms

| Algoritmo / Algorithm | Estrategia / Strategy | Complejidad temporal / Time complexity | In-place |
|---|---|---|:---:|
| `selection_sort` | Busca el mínimo del resto no ordenado y lo ubica al inicio / Finds the minimum of the unsorted remainder and places it at the front | $O(n^2)$ siempre / always | ✅ |
| `bubble_sort` | Compara e intercambia adyacentes; corta antes con la bandera `swapped` / Compares and swaps adjacent elements; exits early with the `swapped` flag | $O(n^2)$ peor/promedio, $O(n)$ mejor / worst-average, best | ✅ |
| `insertion_sort` | Construye el sub-array ordenado insertando cada elemento en su posición / Builds the sorted sub-array by inserting each element into place | $O(n^2)$ peor/promedio, $O(n)$ mejor / worst-average, best | ✅ |

### Casos cubiertos por las pruebas / Cases covered by the tests

Cada algoritmo verifica los mismos 8 casos (24 aserciones en total) / Each algorithm checks the same 8 cases (24 assertions total):

| Caso / Case | Entrada / Input | Salida esperada / Expected output |
|---|---|---|
| Desordenado / Unsorted | `[5, 2, 9, 1, 5, 6]` | `[1, 2, 5, 5, 6, 9]` |
| Ya ordenado / Already sorted | `[1, 2, 3, 4, 5]` | `[1, 2, 3, 4, 5]` |
| Orden inverso / Reverse order | `[5, 4, 3, 2, 1]` | `[1, 2, 3, 4, 5]` |
| Idénticos / Identical | `[7, 7, 7, 7]` | `[7, 7, 7, 7]` |
| Negativos / Negatives | `[3, -1, 4, -5, 0]` | `[-5, -1, 0, 3, 4]` |
| Un elemento / Single element | `[42]` | `[42]` |
| Vacío / Empty | longitud 0 / length 0 | mismo puntero, sin cambios / same pointer, unchanged |
| Puntero nulo / Null pointer | `rdi = 0` | `rax = 0` (indicador de fallo / failure indicator) |

---

## 📝 Notas de implementación / Implementation Notes

### 🧮 Protección de los fixtures / Fixture protection

**ES:** Los tres algoritmos ordenan **in-place**. Como el motor de pruebas reutiliza los mismos arrays de entrada para los tres algoritmos, cada caso copia el fixture a `scratch_buffer` con `copy_qwords` antes de llamar a la función bajo prueba, de modo que ningún algoritmo mute los datos que usarán los demás.

**EN:** All three algorithms sort **in-place**. Since the test engine reuses the same input arrays for all three algorithms, each case copies the fixture into `scratch_buffer` with `copy_qwords` before calling the function under test, so no algorithm mutates the data the others will use.

### 🔁 Salida temprana en Bubble Sort / Early exit in Bubble Sort

**ES:** `bubble_sort` usa `r10` como bandera `swapped` (no `esi`/`rsi`, que ya contiene la longitud del array) y corta el bucle externo en cuanto una pasada no produce intercambios, cumpliendo el criterio de aceptación de la especificación.

**EN:** `bubble_sort` uses `r10` as the `swapped` flag (not `esi`/`rsi`, which already holds the array length) and exits the outer loop as soon as a pass produces no swaps, satisfying the specification's acceptance criterion.

### ⚠️ Indicador de fallo / Failure indicator

**ES:** El contrato define `rax = 0` como indicador de fallo cuando `rdi` es un puntero nulo, y `rax` igual al puntero recibido en cualquier otro caso (incluido el array vacío, que se devuelve sin modificar). Esto es posible porque, a diferencia de Ada, el array se pasa como puntero crudo y `null` es una representación válida del lenguaje/API.

**EN:** The contract defines `rax = 0` as the failure indicator when `rdi` is a null pointer, and `rax` equal to the received pointer in every other case (including the empty array, which is returned unmodified). This is possible because, unlike Ada, the array is passed as a raw pointer and `null` is a valid language/API representation.

### 🧩 Preservación de registros / Register preservation

**ES:** `bubble_sort` y `selection_sort` usan `rbx` como escrutinio y lo preservan con `push`/`pop`, siguiendo la convención x86-64 SysV de registros *callee-saved*. `insertion_sort` no usa `rbx`.

**EN:** `bubble_sort` and `selection_sort` use `rbx` as scratch and preserve it with `push`/`pop`, following the x86-64 SysV *callee-saved* register convention. `insertion_sort` does not use `rbx`.

---

### 🌐 Otras implementaciones / Other implementations

Este proyecto también está implementado en otros lenguajes. Explora el [repositorio principal](https://github.com/yorche3/programming_languages) para ver todas las versiones.

This project is also implemented in other languages. Explore the [main repository](https://github.com/yorche3/programming_languages) to see all the versions.

---

*[← Volver al Roadmap](https://yorche3.github.io/programming_languages/ROADMAP/)*

*🌐 [github.com/yorche3/programming_languages](https://github.com/yorche3/programming_languages) · [GitHub Pages](https://yorche3.github.io/programming_languages/)*
