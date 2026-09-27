# Data Structures Basics — Assembly (NASM x86-64)

Implementación de la especificación [06_Data_Structures_Basics](https://yorche3.github.io/programming_languages/core/algorithms/06_Data_Structures_Basics/) en **Assembly x86-64** con **NASM**, con un enfoque manual y minimalista: sin bibliotecas externas, solo `syscall` para el sistema.

Implementation of the [06_Data_Structures_Basics](https://yorche3.github.io/programming_languages/core/algorithms/06_Data_Structures_Basics/) specification in **x86-64 Assembly** with **NASM**, manual and minimalist: no external libraries, only `syscall` for the system.

---

## 📂 Archivos y estructura / Files & Structure

### Fuentes / Sources (`src/`)

| Archivo / File | Propósito / Purpose |
|---|---|
| [`src/data_structures_basics.inc`](src/data_structures_basics.inc) | **Contrato compartido**: `FAILURE`/`ABSENT` y los `struc` de `Node`, `LinkedList`, `Stack` y `Queue`, con las firmas documentadas. Se incluye con `%include`. |
| [`src/alloc.asm`](src/alloc.asm) | **Heap del módulo**: bump allocator sobre la syscall `brk` (`alloc_bytes`). |
| [`src/node.asm`](src/node.asm) | `Node` y su asignación compartida (`node_create`). |
| [`src/linked_list.asm`](src/linked_list.asm) | `LinkedList` sobre el `Node` común. |
| [`src/stack.asm`](src/stack.asm) | `Stack` (LIFO) sobre el `Node` común. |
| [`src/queue.asm`](src/queue.asm) | `Queue` (FIFO) sobre el `Node` común. |

### Pruebas / Tests (`test/`)

| Archivo / File | Propósito / Purpose |
|---|---|
| [`test/node_tests.asm`](test/node_tests.asm) | Casos de `Node` (2 pasos) |
| [`test/linked_list_tests.asm`](test/linked_list_tests.asm) | Casos de `LinkedList` (5 pasos) |
| [`test/stack_tests.asm`](test/stack_tests.asm) | Casos de `Stack` (4 pasos) |
| [`test/queue_tests.asm`](test/queue_tests.asm) | Casos de `Queue` (4 pasos) |
| [`test/run_tests.asm`](test/run_tests.asm) | Punto de entrada (`_start`) — ejecuta las cuatro suites e imprime el resumen |
| [`test/test_utils.asm`](test/test_utils.asm) | Utilidades compartidas: `print_string`, `print_number`, `assert`, contadores y `print_summary` |
| [`test/test_macros.inc`](test/test_macros.inc) | Macros NASM (`print_str`, `run_test`, `assert_result`) vía `%include` |

### Infraestructura / Infrastructure

| Archivo / File | Propósito / Purpose |
|---|---|
| [`Makefile`](Makefile) | Compilación (`make`, `make build`, `make run`, `make clean`) |
| [`.gitignore`](.gitignore) | Ignora `obj/` y el ejecutable de pruebas |

**Estructura de directorios / Directory structure:**

```text
data_structures_basics/
├── src/
│   ├── data_structures_basics.inc   # Contrato compartido / Shared contract
│   ├── alloc.asm                    # Heap (brk) / Heap (brk)
│   ├── node.asm
│   ├── linked_list.asm
│   ├── stack.asm
│   └── queue.asm
├── test/
│   ├── node_tests.asm
│   ├── linked_list_tests.asm
│   ├── stack_tests.asm
│   ├── queue_tests.asm
│   ├── run_tests.asm
│   ├── test_utils.asm
│   └── test_macros.inc
├── Makefile
├── .gitignore
└── obj/          # objetos (generado) / objects (generated)
```

**Desviación respecto a la ubicación esperada / Deviation from the expected location:** la especificación propone `src/data_structures_basics.ext` y `test/data_structures_basics_test.ext` + `test/run_tests.ext` — **un fichero por carpeta**. La implementación usa **seis ficheros en `src/`** (contrato, heap y una unidad por ADT) y siete en `test/`. Es la convención de los dos módulos de Assembly ya homologados: `foundations/numbers/` divide en tres ficheros (uno por variante) y `algorithms/naive_sort/` en tres (uno por algoritmo). La especificación autoriza el cambio: «El layout real puede seguir las convenciones del lenguaje; toda desviación se declara en el README».

**Deviation from the expected location:** the specification proposes `src/data_structures_basics.ext` and `test/data_structures_basics_test.ext` + `test/run_tests.ext` — **one file per folder**. The implementation uses **six files in `src/`** (contract, heap and one unit per ADT) and seven in `test/`. It is the convention of both already-homologated Assembly modules: `foundations/numbers/` splits into three files (one per variant) and `algorithms/naive_sort/` into three (one per algorithm).

---

## 🛠️ Enfoque y construcción / Approach & Build

**ES:** Mismo patrón que [`naive_sort`](../naive_sort/README.md) y [`numbers`](../../foundations/numbers/README.md): fuentes independientes en `src/` y un marco de pruebas casero. La diferencia es que aquí **hay memoria dinámica**: `LinkedList`, `Stack` y `Queue` crean un `Node` al insertar, y el módulo no enlaza con libc, así que el heap es propio. El andamiaje se creó a mano (`Makefile` y `.gitignore`), sin generador.

**EN:** Same pattern as [`naive_sort`](../naive_sort/README.md) and [`numbers`](../../foundations/numbers/README.md): independent sources in `src/` and a homemade test framework. The difference here is **dynamic memory**: `LinkedList`, `Stack` and `Queue` create a `Node` on insertion, and the module does not link against libc, so the heap is its own. The scaffolding was written by hand (`Makefile` and `.gitignore`), with no generator.

### Convención de llamada / Calling Convention

```text
Argumentos / Arguments:  rdi = puntero a la estructura o al nodo / structure or node pointer
                         rsi = valor, o segundo puntero según la operación / value, or second pointer
Retorno / Return value:  rax = valor, puntero o indicador de la operación / value, pointer or indicator
Registros preservados:   rbx, rbp, r12–r15 (callee-saved)
Registros volátiles:     rax, rcx, rdx, rsi, rdi, r8–r11 (caller-saved)
```

**ES:** Las operaciones que reservan un nodo (`linked_list_insert_head`, `linked_list_insert_tail`, `stack_push`, `queue_enqueue`) preservan `rbx` con `push`/`pop`, porque lo usan para no perder el puntero a la estructura durante la llamada al heap. `syscall` destruye `rcx` y `r11`, y el código no los usa.

**EN:** The operations that allocate a node (`linked_list_insert_head`, `linked_list_insert_tail`, `stack_push`, `queue_enqueue`) preserve `rbx` with `push`/`pop`, because they use it to keep the structure pointer across the heap call. `syscall` clobbers `rcx` and `r11`, and the code does not use them.

**Salida de estilos y avisos / Style and warning output:** una compilación limpia ensambla los once ficheros y enlaza sin **un solo aviso** de NASM y sin errores.

**Style and warning output:** a clean build assembles all eleven files and links with **no NASM warning at all** and no errors.

---

## 📄 Configuración clave / Key Configuration

| Archivo / File | Qué aporta / What it provides |
|---|---|
| `Makefile` | `ASMFLAGS := -f elf64 -g -F dwarf -I$(SRC_DIR)/ -I$(TEST_DIR)/`. Las dos rutas de inclusión son lo que hace resolver `%include "data_structures_basics.inc"` y `%include "test_macros.inc"`. |
| `Makefile` | `SRC_FILES := $(wildcard $(SRC_DIR)/*.asm)` y `TEST_FILES := $(filter-out $(TEST_DIR)/run_tests.asm,$(wildcard $(TEST_DIR)/*.asm))`: **cada `.asm` es una unidad de traducción y sale un objeto por fichero**, sin listar nada a mano. El `.inc` no se ensambla (no acaba en `.asm`). |
| `Makefile` | `TARGET := test/run_tests`, enlazado con `ld -m elf_x86_64`; `all: run` hace compilar y ejecutar de una vez. |
| `.gitignore` | Ignora `obj/` y `test/run_tests`. |

**ES:** El `Makefile` conserva una guarda para el caso pendiente: si no hay ningún `.asm` en `src/`, avisa con `Implementation is pending` y no intenta enlazar.

**EN:** The `Makefile` keeps a guard for the pending case: if there is no `.asm` in `src/`, it warns with `Implementation is pending` and does not attempt to link.

---

## 🚀 Compilación y ejecución / Build & Run

```bash
make          # Compilar y ejecutar / Build and run
make build    # Solo compilar / Build only
make run      # Solo ejecutar / Run only
make clean    # Limpiar / Clean
```

**Salida real / Actual output:**

```text
$ make run
make[1]: 'test/run_tests' is up to date.
=== Running Data Structures Basics Unit Tests ===
=== Data Structures Basics Module Tests ===

=== Node Tests ===
  PASSED: initialize and observe value/link
  PASSED: initialize another node, link and traverse

=== LinkedList Tests ===
  PASSED: empty state
  PASSED: insert at both ends
  PASSED: delete first occurrence
  PASSED: absent value
  PASSED: empty the list

=== Stack Tests ===
  PASSED: empty state and failed removal
  PASSED: LIFO and non-mutating peek
  PASSED: removal and reuse
  PASSED: empty after removal

=== Queue Tests ===
  PASSED: empty state and failed removal
  PASSED: FIFO and non-mutating peek
  PASSED: removal and reuse
  PASSED: empty after removal

tests run 15
passed 15
failed 0
```

**ES:** Salida copiada de la última ejecución real del 2026-09-26, sin editar. El acta completa del sprint está en [`docs/evidence/algorithms/data_structures_basics/assembly.md`](https://github.com/yorche3/programming_languages/blob/main/docs/evidence/algorithms/data_structures_basics/assembly.md). El ejecutable sale con el **número de fallos** como código de salida.

**EN:** Output copied from the last real run on 2026-09-26, unedited. The full sprint record is in [`docs/evidence/algorithms/data_structures_basics/assembly.md`](https://github.com/yorche3/programming_languages/blob/main/docs/evidence/algorithms/data_structures_basics/assembly.md). The executable exits with the **failure count** as its status code.

---

## 🧠 Algoritmos y operaciones / Algorithms & Operations

### `Node` — `src/node.asm`

| Operación / Operation | Entrada → salida / Input → output | Complejidad / Complexity | Notas / Notes |
|---|---|---|---|
| `node_init` | `(Node *, int64_t) → —` | `O(1)` | Asigna el valor y deja el enlace en `ABSENT`. El nodo lo provee el llamador. |
| `node_get_value` | `const Node * → int64_t` | `O(1)` | No muta. |
| `node_get_next` | `const Node * → Node *` | `O(1)` | `0` cuando el enlace está ausente. |
| `node_set_next` | `(Node *, Node *) → —` | `O(1)` | Enlaza o desenlaza. |

### `LinkedList` — `src/linked_list.asm`

| Operación / Operation | Entrada → salida / Input → output | Complejidad / Complexity | Notas / Notes |
|---|---|---|---|
| `linked_list_init` | `LinkedList * → —` | `O(1)` | `head`/`tail` a `ABSENT` y `count` a `0`. |
| `linked_list_is_empty` | `const LinkedList * → 0\|1` | `O(1)` | Lee `count`. |
| `linked_list_size` | `const LinkedList * → int64_t` | `O(1)` | Lee `count`. |
| `linked_list_get_head` | `const LinkedList * → int64_t` | `O(1)` | `FAILURE` si está vacía. |
| `linked_list_insert_head` | `(LinkedList *, int64_t) → —` | `O(1)` | Ajusta `tail` si la lista estaba vacía. |
| `linked_list_insert_tail` | `(LinkedList *, int64_t) → —` | `O(1)` | Ajusta `head` y `tail` si estaba vacía. |
| `linked_list_delete` | `(LinkedList *, int64_t) → 1\|-1` | `O(n)` | Elimina la **primera** aparición; si borra el último nodo, `tail` pasa al anterior. |

### `Stack` — `src/stack.asm`

| Operación / Operation | Entrada → salida / Input → output | Complejidad / Complexity | Notas / Notes |
|---|---|---|---|
| `stack_init` | `Stack * → —` | `O(1)` | `top` a `ABSENT` y `count` a `0`. |
| `stack_is_empty` | `const Stack * → 0\|1` | `O(1)` | Lee `count`. |
| `stack_size` | `const Stack * → int64_t` | `O(1)` | Lee `count`. |
| `stack_push` | `(Stack *, int64_t) → —` | `O(1)` | El nodo nuevo queda por delante de `top`. |
| `stack_peek` | `const Stack * → int64_t` | `O(1)` | Observa sin extraer; `FAILURE` si está vacía. |
| `stack_pop` | `Stack * → int64_t` | `O(1)` | Extrae el tope y mueve `top` al siguiente. |

### `Queue` — `src/queue.asm`

| Operación / Operation | Entrada → salida / Input → output | Complejidad / Complexity | Notas / Notes |
|---|---|---|---|
| `queue_init` | `Queue * → —` | `O(1)` | `front`/`rear` a `ABSENT` y `count` a `0`. |
| `queue_is_empty` | `const Queue * → 0\|1` | `O(1)` | Lee `count`. |
| `queue_size` | `const Queue * → int64_t` | `O(1)` | Lee `count`. |
| `queue_enqueue` | `(Queue *, int64_t) → —` | `O(1)` | Encadena tras `rear`; ajusta `front` si estaba vacía. |
| `queue_peek` | `const Queue * → int64_t` | `O(1)` | Observa sin extraer; `FAILURE` si está vacía. |
| `queue_dequeue` | `Queue * → int64_t` | `O(1)` | Extrae `front` y deja `rear` en `ABSENT` si la cola queda vacía. |

---

## 🧩 Decisiones de diseño / Design decisions

| Decisión / Decision | Alternativa considerada / Alternative | Razón / Reason |
|---|---|---|
| Un fichero por unidad lógica en `src/` | Un único `src/data_structures_basics.asm` | Es la convención de los dos módulos de Assembly ya homologados (`numbers`, `naive_sort`): cada unidad se revisa y se cambia sin tocar las demás. |
| Heap propio con `brk` (`src/alloc.asm`) | Enlazar con libc y usar `malloc`; o un pool estático en `.bss` | El módulo no enlaza libc y no quiere meterle un runtime; y un pool estático sería un **límite artificial de capacidad**, que la especificación prohíbe. `brk` no impone ese límite. |
| `node_create` como símbolo interno (no del contrato) | Añadirlo al contrato como operación pública | El contrato define `node_init(node, value)` sobre un nodo que **ya existe**; la creación es un paso interno que comparten las cuatro operaciones que insertan. Añadirlo al contrato sería ampliarlo. |
| El contrato en un `.inc` compartido | Repetir `%define` y los `struc` en cada fichero | Los cuatro ficheros necesitan la misma definición del `Node`; repetirla permitiría que se desincronizaran. |
| `FAILURE = -1` y `ABSENT = 0` como constantes del contrato | Devolver `0` como fallo, o usar `-errno` | `0` es un valor **válido** y la ausencia de enlace; un indicador que se confundiera con un dato real haría la suite incapaz de distinguir el caso de fallo. Los valores de prueba son positivos y no chocan. |
| Una suite por ADT, con pasos sucesivos sobre la misma instancia | Un fichero de casos compartido, o un test por operación | El estado del ADT es lo que se comprueba: la instancia se inicializa una vez y las operaciones se encadenan en el orden de la especificación. Aquí no hay casos compartidos entre estructuras, así que no hay motor común que extraer. |

---

## 🔀 Adaptaciones idiomáticas / Idiomatic adaptations

| Especificación / Specification | Adaptación / Adaptation | Justificación / Justification |
|---|---|---|
| `init` como nombre conceptual uniforme | `node_init`, `linked_list_init`, `stack_init`, `queue_init` | En Assembly no hay espacios de nombres ni métodos: el nombre de la operación lleva delante la estructura para evitar colisiones de símbolos en el enlace. |
| Ausencia de enlace «nativa» | `0` (`ABSENT`) en los punteros | Es la representación natural de un puntero nulo en x86-64. |
| `delete(value)` devuelve éxito o fallo | Devuelve `1` o `FAILURE` en `rax` | Un único valor de retorno en `rax`; el contrato fija `1` para el éxito, que no colisiona con ningún indicador de fallo. |
| `pop()`, `dequeue()`, `peek()` y `get_head()` devuelven el valor o un fallo | Devuelven el valor en `rax`, o `FAILURE` | Igual que arriba: no hay tuplas ni parámetros de salida, así que el fallo viaja en el mismo registro. |
| Ubicación esperada: `src/…ext` y un fichero de pruebas | `src/` con seis ficheros y `test/` con siete | Convención del repositorio para Assembly; la propia especificación remite a las convenciones del lenguaje y pide declarar la desviación. |
| El nodo lo crea la estructura al insertar | `node_create` reserva en el heap con `brk` | El contrato solo recibe `(estructura, valor)` en las inserciones, así que el nodo no puede venir de fuera. |
| Valores de prueba enteros positivos | `10, 20, 30, 40, 5, 99` | No colisionan con `FAILURE = -1` ni con `ABSENT = 0`. |
| Caso de entrada nula o inválida | **No aplicable** en la firma de los ADT | Las operaciones reciben punteros a estructuras que el llamador declara; no hay un «ADT nulo» representable, y la especificación solo pide el caso nulo cuando el tipo lo admite. |

---

## 🚨 Indicadores de fallo / Failure indicators

| Operación / Operation | Situación de fallo / Failure situation | Indicador / Indicator | Ejemplo / Example |
|---|---|---|---|
| `node_init`, `node_get_value`, `node_get_next`, `node_set_next` | No aplica: no fallan | — | — |
| `linked_list_get_head` | Lista vacía | `FAILURE` (`-1`) en `rax` | `linked_list_get_head(list) = -1` |
| `linked_list_delete` | El valor no está en la lista | `FAILURE` (`-1`) en `rax` | `linked_list_delete(list, 99) = -1` |
| `stack_peek`, `stack_pop` | Pila vacía | `FAILURE` (`-1`) en `rax` | `stack_pop(s) = -1` |
| `queue_peek`, `queue_dequeue` | Cola vacía | `FAILURE` (`-1`) en `rax` | `queue_dequeue(q) = -1` |
| `node_create` (interno) | El kernel rechaza crecer el heap | `0` en `rax`, y la inserción no modifica la estructura | `insert_tail(list, v)` deja `count` igual |
| Entrada nula o inválida | **No representable** para los ADT | — | No aplica: no existe un valor «ADT ausente»; la ausencia solo existe en los enlaces (`Node.next = 0`). |

---

## ✅ Cobertura de pruebas / Test coverage

La salida real declara **15 pruebas**, todas correctas: los 15 pasos de la especificación, uno por fila de sus tablas de casos.

The real output states **15 tests**, all successful: the 15 steps of the specification, one per row of its test-case tables.

### `Node` — `test/node_tests.asm`

| Caso de la especificación / Specification case | Cubierto / Covered | Prueba / Test | Notas / Notes |
|---|:--:|---|---|
| Inicializar y observar valor/enlace | Sí / Yes | `test_initialize_and_observe` | `node_get_value = 10` y `node_get_next = 0`. |
| Inicializar otro nodo, enlazar y recorrer | Sí / Yes | `test_link_and_traverse` | `node_set_next` y recorrido hasta `20`. |

### `LinkedList` — `test/linked_list_tests.asm`

| Caso de la especificación / Specification case | Cubierto / Covered | Prueba / Test | Notas / Notes |
|---|:--:|---|---|
| Estado vacío | Sí / Yes | `test_empty_state` | `is_empty = 1`, `size = 0`, `get_head = FAILURE`. |
| Insertar por ambos extremos | Sí / Yes | `test_insert_both_ends` | `size = 4` y cabeza `5`. |
| Eliminar primera aparición | Sí / Yes | `test_delete_first_occurrence` | Tras borrar `10`, la cabeza sigue siendo `5` y el tamaño baja a `3`. |
| Valor ausente | Sí / Yes | `test_absent_value` | Devuelve `FAILURE` y el estado no cambia. |
| Vaciar | Sí / Yes | `test_empty_list` | Vuelve a `is_empty = 1`, `size = 0` y `FAILURE`. |

### `Stack` — `test/stack_tests.asm`

| Caso de la especificación / Specification case | Cubierto / Covered | Prueba / Test | Notas / Notes |
|---|:--:|---|---|
| Estado vacío y extracción fallida | Sí / Yes | `test_empty_state` | `peek` y `pop` devuelven `-1` y el estado sigue vacío. |
| LIFO y `peek` no mutante | Sí / Yes | `test_lifo_peek` | `peek = 30` y `size = 3` tras los tres `push`. |
| Extracción y reutilización | Sí / Yes | `test_removal_reuse` | `30`, `40`, `20`, `10`; al final vacía y `size = 0`. |
| Vacío tras extracción | Sí / Yes | `test_empty_after_removal` | `pop` falla y la pila sigue vacía. |

### `Queue` — `test/queue_tests.asm`

| Caso de la especificación / Specification case | Cubierto / Covered | Prueba / Test | Notas / Notes |
|---|:--:|---|---|
| Estado vacío y extracción fallida | Sí / Yes | `test_empty_state` | `peek` y `dequeue` devuelven `-1` y el estado sigue vacío. |
| FIFO y `peek` no mutante | Sí / Yes | `test_fifo_peek` | `peek = 10` y `size = 3` tras los tres `enqueue`. |
| Extracción y reutilización | Sí / Yes | `test_removal_reuse` | `10`, `20`, `30`, `40`; al final vacía y `size = 0`. |
| Vacío tras extracción | Sí / Yes | `test_empty_after_removal` | `dequeue` falla y la cola sigue vacía. |

**ES:** La suite tiene que **poder fallar**, y se comprobó: rompiendo a propósito `node_init` para que guardara `0` en vez del valor, fallan **exactamente** los dos casos de `Node` (`tests run 15`, `passed 13`, `failed 2`) y ningún otro, porque los tres ADT insertan con `node_create` y no pasan por `node_init`. Revertido el cambio, la suite vuelve a `15/15`.

**EN:** The suite must be **able to fail**, and it was checked: deliberately breaking `node_init` so that it stored `0` instead of the value makes **exactly** the two `Node` cases fail (`tests run 15`, `passed 13`, `failed 2`) and no other, because the three ADTs insert through `node_create` and never go through `node_init`. With the change reverted, the suite goes back to `15/15`.

---

## ⚠️ Limitaciones conocidas / Known limitations

| Limitación / Limitation | Impacto / Impact | Alternativa o plan / Workaround or plan |
|---|---|---|
| **No hay liberación**: el contrato no tiene `destroy` ni `free`, así que un nodo que sale de una estructura no se reutiliza y el heap solo crece | Un programa de larga duración que inserte y borre en bucle consume memoria sin devolverla | Es lo que el contrato pide (y lo que la especificación describe): la liberación sería una operación nueva. `alloc_bytes` sí reutiliza el hueco libre del bloque actual, así que no hay desperdicio por asignación. |
| El heap se pide con `brk`, que puede no estar disponible en otros sistemas | El módulo es específico de Linux x86-64 | Es la plataforma del repositorio; el resto de módulos de Assembly también usan `syscall` de Linux. |
| `node_create` devuelve `0` si el kernel rechaza crecer el heap y la inserción no se completa | Una inserción puede no ocurrir sin avisar al llamador | El contrato de las inserciones no tiene canal de error (no devuelven nada); se documenta aquí y `count` no cambia, que es lo observable. |

---

## 📝 Notas de implementación / Implementation Notes

### 🧱 Un `Node` compartido y tres estructuras independientes / One shared `Node`, three independent structures

**ES:** `LinkedList`, `Stack` y `Queue` operan sobre el mismo `Node` y cada uno mantiene solo sus punteros: `Stack` usa `top`; `Queue`, `front` y `rear`. Ninguno delega en `LinkedList` ni envuelve una colección: las tres recorren el nodo directamente.

**EN:** `LinkedList`, `Stack` and `Queue` operate on the same `Node` and each keeps only its own pointers: `Stack` uses `top`; `Queue`, `front` and `rear`. None delegates to `LinkedList` or wraps a collection: all three walk the node directly.

### 🧮 El heap, con detalle / The heap, in detail

**ES:** `alloc_bytes(size)` redondea a 16 bytes y devuelve el siguiente hueco libre; si el bloque no cabe, mueve el *program break* con `brk` y pide un margen de 64 KiB para no gastar una llamada al sistema por asignación. La primera llamada lee el break actual con `brk(0)`. No hay `free`, y por eso el módulo no puede devolver memoria: es la limitación declarada arriba.

**EN:** `alloc_bytes(size)` rounds up to 16 bytes and returns the next free slot; if the block does not fit, it moves the *program break* with `brk` and asks for a 64 KiB margin so that not every allocation costs a system call. The first call reads the current break with `brk(0)`. There is no `free`, which is why the module cannot return memory: that is the limitation declared above.

### 🎫 Convenciones de la ABI / ABI conventions

**ES:** Se sigue la convención System V AMD64: argumentos en `rdi`, `rsi`; retorno en `rax`; `rbx` preservado con `push`/`pop` donde se usa. No hay alineación de pila que cuidar porque ninguna operación llama a funciones que la requieran más allá de `node_create`/`alloc_bytes`, que no usan SSE ni `printf`.

**EN:** The System V AMD64 convention is followed: arguments in `rdi`, `rsi`; return in `rax`; `rbx` preserved with `push`/`pop` where used. There is no stack alignment to watch because no operation calls a function requiring it beyond `node_create`/`alloc_bytes`, which use neither SSE nor `printf`.

### 🧪 Estructura de las pruebas / Test structure

**ES:** Cada suite declara sus propios datos (`section .data`) y su instancia (`section .bss`), y encadena los pasos de la especificación sin reiniciar el escenario: la instancia se inicializa una vez y los casos siguientes continúan sobre ella, que es como la especificación define los casos. Los macros `run_test` (contador + PASS/FAIL) y `assert_result` (comparación) mantienen las suites en pocas líneas y el resumen lo imprime `print_summary`.

**EN:** Each suite declares its own data (`section .data`) and instance (`section .bss`), and chains the specification's steps without resetting the scenario: the instance is initialised once and the following cases continue on it, which is how the specification defines the cases. The `run_test` (counter + PASS/FAIL) and `assert_result` (comparison) macros keep the suites short, and `print_summary` prints the summary.

### 🌐 Otras implementaciones / Other implementations

Este proyecto también está implementado en otros lenguajes. Explora el [repositorio principal](https://github.com/yorche3/programming_languages) para ver todas las versiones.

This project is also implemented in other languages. Explore the [main repository](https://github.com/yorche3/programming_languages) to see all the versions.

---

## 🔍 Checklist de validación / Validation checklist

- [x] La suite nativa se ejecutó y su salida real está copiada en este README.
- [x] Cada caso de la especificación tiene su fila en _Cobertura de pruebas_ (o `Omitido` con razón).
- [x] Cada desviación del pseudocódigo o de la ubicación esperada está en _Adaptaciones idiomáticas_.
- [x] Cada operación con fallo posible está en _Indicadores de fallo_.
- [x] No hay rutas absolutas del autor, credenciales ni salidas inventadas.
- [x] Los enlaces relativos resuelven dentro del repositorio y el documento es bilingüe.
- [x] Ninguna sección repite lo que ya dice la especificación.

---

## 📚 Referencias / References

| Tipo / Kind | Referencia / Reference |
|---|---|
| Especificación / Specification | [`06_Data_Structures_Basics.md`](https://yorche3.github.io/programming_languages/core/algorithms/06_Data_Structures_Basics/) |
| Acta de evidencia / Evidence record | [`docs/evidence/algorithms/data_structures_basics/assembly.md`](https://github.com/yorche3/programming_languages/blob/main/docs/evidence/algorithms/data_structures_basics/assembly.md) |
| Módulo homologado del lenguaje / Homologated module | [`../naive_sort/README.md`](../naive_sort/README.md) |
| Guía de inicialización / Initialisation guide | [`core/00_Project_Initialization_Guide.md`](https://yorche3.github.io/programming_languages/core/00_Project_Initialization_Guide/) |
| Adaptaciones idiomáticas / Idiomatic adaptations | [`AGENT_Template.md`](https://yorche3.github.io/programming_languages/AGENT_Template/) |
| Validación de la documentación / Documentation validation | [`WORKFLOW.md`](https://yorche3.github.io/programming_languages/WORKFLOW/) |
| Plantilla del README / README template | [`README_Template.md`](https://yorche3.github.io/programming_languages/README_Template/) |
| Documentación oficial / Official docs | [NASM](https://www.nasm.us/xdoc/2.16.01/html/nasmdoc0.html) · [syscalls (Linux x86-64)](https://man7.org/linux/man-pages/man2/brk.2.html) |

---

*[← Volver al Roadmap](https://yorche3.github.io/programming_languages/ROADMAP/)*

*🌐 [github.com/yorche3/programming_languages](https://github.com/yorche3/programming_languages) · [GitHub Pages](https://yorche3.github.io/programming_languages/)*
