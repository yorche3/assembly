# Data Structures Advanced — Assembly (NASM x86-64)

Implementación de la especificación [07_Data_Structures_Advanced](https://yorche3.github.io/programming_languages/core/algorithms/07_Data_Structures_Advanced/) en **Assembly x86-64** con **NASM**, con un enfoque manual y minimalista: sin bibliotecas externas, montículo propio con `syscall` (`brk`) y enlaces directos sin colecciones de biblioteca.

Implementation of the [07_Data_Structures_Advanced](https://yorche3.github.io/programming_languages/core/algorithms/07_Data_Structures_Advanced/) specification in **x86-64 Assembly** with **NASM**, manual and minimalist: no external libraries, custom heap via `syscall` (`brk`), and direct links with no library collections.

---

## 📂 Archivos y estructura / Files & Structure

### Fuentes / Sources (`src/`)

| Archivo / File | Propósito / Purpose |
|---|---|
| [`src/data_structures_advanced.inc`](src/data_structures_advanced.inc) | **Contrato compartido**: definiciones de `FAILURE` (-1), `ABSENT` (0) y `SUCCESS` (1); estructuras `Node`, `TreeNode`, `BinaryTree`, `NeighborNode`, `GraphNode` y `Graph`; y firmas de la API. Se incluye con `%include`. |
| [`src/alloc.asm`](src/alloc.asm) | **Heap del módulo**: asignador de avance (*bump allocator*) sobre la llamada al sistema `sys_brk` (`alloc_bytes`). |
| [`src/data_structures_advanced.asm`](src/data_structures_advanced.asm) | Implementación de las operaciones del contrato: base `Node`, nodo y árbol binario `TreeNode`/`BinaryTree`, y nodo y grafo dirigido `GraphNode`/`Graph`. |

### Pruebas / Tests (`test/`)

| Archivo / File | Propósito / Purpose |
|---|---|
| [`test/data_structures_advanced_tests.asm`](test/data_structures_advanced_tests.asm) | Suite de pruebas modularizada orientada a datos (tabla de 23 casos del contrato y ejecutor `execute_operation`). |
| [`test/run_tests.asm`](test/run_tests.asm) | Punto de entrada (`_start`) — cabecera, invocación del ejecutor de pruebas, resumen y salida de proceso. |
| [`test/test_utils.asm`](test/test_utils.asm) | Utilidades compartidas: `print_string`, `print_number`, `assert`, contadores globales y `print_summary`. |
| [`test/test_macros.inc`](test/test_macros.inc) | Macros NASM (`operation`, `step`, `case_entry`, inicializadores de fixtures) vía `%include`. |

### Infraestructura / Infrastructure

| Archivo / File | Propósito / Purpose |
|---|---|
| [`Makefile`](Makefile) | Automatización de construcción (`make`, `make build`, `make run`, `make clean`). |
| [`.gitignore`](.gitignore) | Exclusión de artefactos compilados (`obj/`, binario de pruebas). |

**Estructura de directorios / Directory structure:**

```text
data_structures_advanced/
├── src/
│   ├── data_structures_advanced.inc   # Contrato y estructuras / Contract and structures
│   ├── alloc.asm                      # Heap (brk) / Heap allocator (brk)
│   └── data_structures_advanced.asm   # Implementación del contrato / Contract implementation
├── test/
│   ├── data_structures_advanced_tests.asm
│   ├── run_tests.asm
│   ├── test_utils.asm
│   └── test_macros.inc
├── Makefile
├── .gitignore
└── obj/                               # Objetos generados / Generated objects
```

**Desviación respecto a la ubicación esperada / Deviation from the expected location:** la especificación propone `src/data_structures_advanced.ext` y `test/data_structures_advanced_test.ext` + `test/run_tests.ext`. En este proyecto se separa el montículo en [`src/alloc.asm`](src/alloc.asm) y el contrato de estructuras en [`src/data_structures_advanced.inc`](src/data_structures_advanced.inc), compartiendo utilidades de prueba en [`test/test_utils.asm`](test/test_utils.asm) y macros en [`test/test_macros.inc`](test/test_macros.inc). Sigue la misma estructura y convención idiomática que los módulos homologados [`data_structures_basics`](../data_structures_basics/README.md) y [`naive_sort`](../naive_sort/README.md).

**Deviation from the expected location:** the specification proposes `src/data_structures_advanced.ext` and `test/data_structures_advanced_test.ext` + `test/run_tests.ext`. Here, memory allocation is separated into [`src/alloc.asm`](src/alloc.asm) and contract declarations into [`src/data_structures_advanced.inc`](src/data_structures_advanced.inc), while test helpers reside in [`test/test_utils.asm`](test/test_utils.asm) and macros in [`test/test_macros.inc`](test/test_macros.inc). This aligns with the conventions established in homologated modules [`data_structures_basics`](../data_structures_basics/README.md) and [`naive_sort`](../naive_sort/README.md).

---

## 🛠️ Enfoque y construcción / Approach & Build

**ES:** El proyecto se construye sin frameworks externos ni libc, usando `nasm` (ensamblador para arquitectura x86-64 en formato ELF64) y `ld` (GNU linker). La memoria dinámica requerida para los nodos de árbol, vértices y adyacencia de grafo se gestiona mediante un *bump allocator* monótono construido con la llamada al sistema Linux `sys_brk` (`syscall 12`). Las pruebas se estructuran como una tabla de casos donde cada paso ejecuta una operación con sus parámetros esperados, reportando individualmente `PASSED`/`FAILED` y contabilizando el resumen.

**EN:** The project is built without external frameworks or libc, relying on `nasm` (x86-64 assembler targeting ELF64) and `ld` (GNU linker). Dynamic memory required for tree nodes, graph vertices, and adjacency sequences is handled by a monotonic bump allocator built upon Linux `sys_brk` (`syscall 12`). Tests are driven by a table-oriented runner where each step invokes an operation with expected arguments, printing `PASSED`/`FAILED` status and a summary tally.

### Convención de llamada / Calling Convention

```text
Argumentos / Arguments:  rdi = primer argumento (puntero a estructura o nodo) / first argument (struct or node pointer)
                         rsi = segundo argumento (valor, puntero o etiqueta u) / second argument (value, pointer, or label u)
                         rdx = tercer argumento (etiqueta v para aristas) / third argument (label v for edges)
Retorno / Return value:  rax = valor, puntero a nodo/lista, SUCCESS (1), FAILURE (-1) o booleano (0/1)
Registros preservados:   rbx, rbp, r12–r15 (callee-saved)
Registros volátiles:     rax, rcx, rdx, rsi, rdi, r8–r11 (caller-saved)
Alineación de pila:      rsp alineado a 16 bytes antes de cada instrucción `call` / 16-byte alignment before `call`
```

**Salida de estilos y avisos / Style and warning output:** el código ensambla de forma limpia con `nasm -w+all` y enlaza sin advertencias ni errores.

**Style and warning output:** clean assembly using `nasm -w+all` and linking without warnings or errors.

---

## 📄 Configuración clave / Key Configuration

| Archivo / File | Qué aporta / What it provides |
|---|---|
| [`Makefile`](Makefile) | Reglas `all`, `build`, `run` y `clean`. Ensambla archivos `.asm` a objetos en `obj/` y genera el ejecutable `test/run_tests` mediante `ld -m elf_x86_64`. |
| [`src/data_structures_advanced.inc`](src/data_structures_advanced.inc) | Constantes `FAILURE` (-1), `ABSENT` (0), `SUCCESS` (1) y offsets de campos para `Node`, `TreeNode`, `BinaryTree`, `NeighborNode`, `GraphNode` y `Graph`. |
| [`.gitignore`](.gitignore) | Exclusión de `obj/`, `test/run_tests` y binarios temporales. |

---

## 🚀 Compilación y ejecución / Build & Run

```bash
make clean
make build
make run
```

**Salida real / Actual output:**

```text
Cleaned up.
nasm -f elf64 -g -F dwarf -Isrc/ -Itest/ src/alloc.asm -o obj/src_alloc.o
nasm -f elf64 -g -F dwarf -Isrc/ -Itest/ src/data_structures_advanced.asm -o obj/src_data_structures_advanced.o
nasm -f elf64 -g -F dwarf -Isrc/ -Itest/ test/data_structures_advanced_tests.asm -o obj/test_data_structures_advanced_tests.o
nasm -f elf64 -g -F dwarf -Isrc/ -Itest/ test/test_utils.asm -o obj/test_test_utils.o
nasm -f elf64 -g -F dwarf -Isrc/ -Itest/ test/run_tests.asm -o obj/test_run_tests.o
ld -m elf_x86_64 obj/src_alloc.o obj/src_data_structures_advanced.o obj/test_data_structures_advanced_tests.o obj/test_test_utils.o obj/test_run_tests.o -o test/run_tests
make[1]: 'test/run_tests' is up to date.
=== Running Data Structures Advanced Unit Tests ===
=== Data Structures Advanced Module Tests ===
  PASSED: TreeNode/create a tree node
  PASSED: TreeNode/absent initial links
  PASSED: TreeNode/link two children
  PASSED: TreeNode/traverse each link
  PASSED: TreeNode/unlink children
  PASSED: BinaryTree/create empty
  PASSED: BinaryTree/insert the root
  PASSED: BinaryTree/insert lower and higher
  PASSED: BinaryTree/multilevel branches
  PASSED: BinaryTree/missing value in nonempty tree
  PASSED: BinaryTree/idempotent duplicate
  PASSED: BinaryTree/ordered insertions
  PASSED: Graph/create empty
  PASSED: Graph/isolated vertex
  PASSED: Graph/nonconsecutive labels and directed edge
  PASSED: Graph/duplicate vertex preserves adjacency
  PASSED: Graph/duplicate edge
  PASSED: Graph/missing endpoint without mutation
  PASSED: Graph/sorted neighbours and counts
  PASSED: Graph/missing-edge query
  PASSED: Graph/neighbours of missing vertex
  PASSED: Graph/self-loop and duplicate
  PASSED: Graph/neighbour-result isolation
tests run 23
passed 23
failed 0
```

---

## 🧠 Algoritmos y operaciones / Algorithms & Operations

| Operación / Operation | Entrada → salida / Input → output | Complejidad / Complexity | Notas / Notes |
|---|---|---|---|
| `node_init` | `(Node*, int64_t) → void` | `O(1)` | Inicializa el valor en la base sin enlaces ni validaciones. |
| `node_get_value` | `const Node* → int64_t` | `O(1)` | Retorna el valor contenido en la base. |
| `tree_node_init` | `(TreeNode*, int64_t) → void` | `O(1)` | Valor embebido; inicializa enlaces izquierdo y derecho a `ABSENT` (0). |
| `tree_node_get_value` | `const TreeNode* → int64_t` | `O(1)` | Retorna el valor del nodo de árbol. |
| `tree_node_get_left` | `const TreeNode* → TreeNode*` | `O(1)` | Retorna puntero al hijo izquierdo o `ABSENT` (0). |
| `tree_node_get_right` | `const TreeNode* → TreeNode*` | `O(1)` | Retorna puntero al hijo derecho o `ABSENT` (0). |
| `tree_node_set_left` | `(TreeNode*, TreeNode*) → void` | `O(1)` | Asigna o desenlaza (recibe `ABSENT`) el hijo izquierdo. |
| `tree_node_set_right` | `(TreeNode*, TreeNode*) → void` | `O(1)` | Asigna o desenlaza (recibe `ABSENT`) el hijo derecho. |
| `binary_tree_init` | `BinaryTree* → void` | `O(1)` | Inicializa raíz a `ABSENT` y contador de elementos a 0. |
| `binary_tree_insert` | `(BinaryTree*, int64_t) → int64_t` | `O(h)` | Inserción iterativa siguiendo invariante BST; duplica no incrementa tamaño; retorna `SUCCESS` (1) o `FAILURE` (-1) si falla memoria. |
| `binary_tree_contains` | `(const BinaryTree*, int64_t) → int64_t` | `O(h)` | Búsqueda iterativa en ABB; retorna `SUCCESS` (1) o `FAILURE` (-1). |
| `binary_tree_is_empty` | `const BinaryTree* → int64_t` | `O(1)` | Retorna 1 si raíz es `ABSENT`, 0 si contiene nodos. |
| `binary_tree_size` | `const BinaryTree* → int64_t` | `O(1)` | Retorna el contador de valores distintos insertados. |
| `graph_node_init` | `(GraphNode*, int64_t) → void` | `O(1)` | Inicializa etiqueta con valor embebido; adyacencia y siguiente vértice a `ABSENT`. |
| `graph_init` | `Graph* → void` | `O(1)` | Inicializa lista de vértices a `ABSENT`, contadores de vértices y aristas a 0. |
| `graph_add_vertex` | `(Graph*, int64_t) → int64_t` | `O(V)` | Búsqueda lineal previa; si existe, idempotente (`SUCCESS`); si no, añade en cabeza del registro e incrementa contador. |
| `graph_add_edge` | `(Graph*, int64_t, int64_t) → int64_t` | `O(V + d(u))` | Verifica existencia de `u` y `v`; si falta alguno retorna `FAILURE` sin mutar; inserta ordenado en adyacencia de `u`; duplicado idempotente. |
| `graph_has_edge` | `(const Graph*, int64_t, int64_t) → int64_t` | `O(V + d(u))` | Verifica extremos; recorre lista ordenada de vecinos de `u`; retorna `SUCCESS` (1) o `FAILURE` (-1). |
| `graph_get_neighbors` | `(const Graph*, int64_t) → NeighborNode*` | `O(V + d(u))` | Busca `u`; si no existe retorna `FAILURE` (-1); si existe aislado retorna `ABSENT` (0); si tiene adyacencia retorna una copia enlazada independiente. |
| `graph_is_empty` | `const Graph* → int64_t` | `O(1)` | Retorna 1 si `vertex_total == 0`, 0 en caso contrario. |
| `graph_vertex_count` | `const Graph* → int64_t` | `O(1)` | Retorna el total de vértices registrados. |
| `graph_edge_count` | `const Graph* → int64_t` | `O(1)` | Retorna el total de aristas dirigidas distintas. |

---

## 🧩 Decisiones de diseño / Design decisions

| Decisión / Decision | Alternativa considerada / Alternative | Razón / Reason |
|---|---|---|
| Reutilización por valor embebido (composición binaria) | Herencia por tabla de punteros o wrappers | Assembly no ofrece herencia tipada de alto nivel. Colocar `.value` como primer campo (`offset 0`) en `TreeNode` y `GraphNode` permite compatibilidad binaria transparente con `Node` cumpliendo la forma canónica A2 de la especificación. |
| Distinción estricta de centinelas (`ABSENT = 0`, `FAILURE = -1`) | Usar `0` para ambos estados de error y ausencia | La especificación exige diferenciar un vértice existente aislado (`get_neighbors` retorna secuencia vacía/`ABSENT`) de un vértice no registrado en el grafo (`get_neighbors` retorna fallo/`FAILURE`). |
| Registro canónico de vértices en lista enlazada manual | Tabla hash o vector dinámico indexado | El módulo prohíbe explícitamente colecciones prefabricadas o tablas hash para el registro de vértices; la lista enlazada garantiza implementación manual pura respetando la cota `O(V)`. |
| Inserción ordenada manual con cursor de dirección de enlace (`lea r14, [r13 + offset]`) | Búsqueda separada y posterior inserción con puntero previo y actual | Manejar la dirección del puntero indirecto en un registro unifica la inserción en cabeza, intermedia y al final en una única lógica libre de casos especiales. |

---

## 🔀 Adaptaciones idiomáticas / Idiomatic adaptations

| Especificación / Specification | Adaptación / Adaptation | Justificación / Justification |
|---|---|---|
| Base `Node(value)` polimórfica | `struc Node` con campo `.value` repetido al inicio de `TreeNode` y `GraphNode` | En ensamblador la herencia se materializa mediante composición física a nivel de memoria (valor embebido), manteniendo la firma y acceso idénticos sin sobrecarga de indirección. |
| `TreeNode` inmutable (caso condicional) | No aplica / Omitido (`TreeNode` mutable in-place) | El lenguaje Assembly en esta arquitectura opera mediante mutación de memoria directa; no es un entorno puramente funcional y los setters actualizan los punteros de los nodos existentes. |
| `LinkedList<T>` de biblioteca para adyacencia de `Graph` | `struc NeighborNode` manual sobre el heap | Assembly no dispone de biblioteca estándar de colecciones sin enlazar con un runtime externo. Se implementa una estructura enlazada minimalista manual. |
| Secuencia de vecinos devuelta como colección | Puntero a lista enlazada de `NeighborNode` en heap | Al no disponer de tipos abstractos de iterador o listas dinámicas del lenguaje, se retorna la cabecera de una copia enlazada independiente; el fin de la lista se indica con puntero nulo (`ABSENT`). |

---

## 🚨 Indicadores de fallo / Failure indicators

| Operación / Operation | Situación de fallo / Failure situation | Indicador / Indicator | Ejemplo / Example |
|---|---|---|---|
| `node_init`, `node_get_value` | Memoria válida requerida | No falla (void / valor) | `node_get_value(&node) → 10` |
| `tree_node_get_left`, `tree_node_get_right` | Subárbol hijo ausente o no enlazado | `ABSENT` (`0`) | `tree_node_get_left(&leaf) → 0` |
| `tree_node_set_left`, `tree_node_set_right` | Desenlazado explícito de subárbol | Acepta `ABSENT` (`0`) | `tree_node_set_left(&node, 0)` |
| `binary_tree_insert` | Agotamiento del montículo del sistema | `FAILURE` (`-1`) | Retorna `-1` si `alloc_bytes` falla |
| `binary_tree_contains` | Valor no presente en el ABB / árbol vacío | `FAILURE` (`-1`) | `binary_tree_contains(&empty, 50) → -1` |
| `graph_add_vertex` | Agotamiento del montículo del sistema | `FAILURE` (`-1`) | Retorna `-1` si `alloc_bytes` falla |
| `graph_add_edge` | Extremo `u` o `v` inexistente en el registro / fallo de memoria | `FAILURE` (`-1`) | `graph_add_edge(&g, 10, 99) → -1` (no muta grafo) |
| `graph_has_edge` | Extremo `u` o `v` inexistente, o arista `(u, v)` no presente | `FAILURE` (`-1`) | `graph_has_edge(&g, 10, 30) → -1` |
| `graph_get_neighbors` | Vértice `u` inexistente en el registro de vértices | `FAILURE` (`-1`) | `graph_get_neighbors(&g, 99) → -1` |
| `graph_get_neighbors` | Vértice `u` registrado y existente pero sin vecinos salientes (aislado) | `ABSENT` (`0`) | `graph_get_neighbors(&g, 10) → 0` |

---

## ✅ Cobertura de pruebas / Test coverage

| Caso de la especificación / Specification case | Cubierto / Covered | Prueba / Test | Notas / Notes |
|---|---|:--:|---|
| Crear un nodo de árbol / Create a tree node | Sí | `TreeNode/create a tree node` | Verifica valor inicial 10. |
| Enlaces iniciales ausentes / Absent initial links | Sí | `TreeNode/absent initial links` | Verifica que `get_left` y `get_right` retornan `ABSENT` (0). |
| Enlazar dos hijos / Link two children | Sí | `TreeNode/link two children` | Enlaza hijos 20 y 30 en el padre y verifica valores de los hijos. |
| Recorrer cada enlace / Traverse each link | Sí | `TreeNode/traverse each link` | Recorre enlaces de padre e hijos comprobando que los hijos no tienen enlaces. |
| Desenlazar hijos / Unlink children | Sí | `TreeNode/unlink children` | Desenlaza izquierdo y luego derecho pasando `ABSENT`; valida retención de valores y enlaces restantes. |
| Adaptación inmutable (si aplica) / Immutable adaptation | Omitido | — | No aplica en Assembly: los nodos son mutables in-place; se documenta en adaptaciones idiomáticas. |
| Crear vacío / Create empty | Sí | `BinaryTree/create empty` | Comprueba `is_empty() == 1`, `size() == 0` y `contains(50) == FAILURE`. |
| Insertar la raíz / Insert the root | Sí | `BinaryTree/insert the root` | Inserta 50; comprueba `size() == 1`, `is_empty() == 0` y `contains(50) == SUCCESS`. |
| Insertar menor y mayor / Insert lower and higher | Sí | `BinaryTree/insert lower and higher` | Inserta 50, 30, 70; verifica éxito, tamaño 3 y pertenencia de los tres. |
| Ramas de varios niveles / Multilevel branches | Sí | `BinaryTree/multilevel branches` | Inserta 50, 30, 70, 20, 40; verifica tamaño 5 y pertenencia de cada valor. |
| Valor ausente en árbol no vacío / Missing value in nonempty tree | Sí | `BinaryTree/missing value in nonempty tree` | Inserta 50; consulta `contains(99) == FAILURE`; verifica tamaño 1 y presencia de 50. |
| Duplicado idempotente / Idempotent duplicate | Sí | `BinaryTree/idempotent duplicate` | Inserta 50, 30, 70, 30; verifica tamaño 3 y preservación de los elementos. |
| Inserciones ordenadas / Ordered insertions | Sí | `BinaryTree/ordered insertions` | Inserta 20, 30, 40, 50, 70 en orden; verifica tamaño 5, presencia y fallo de 99. |
| Crear vacío / Create empty | Sí | `Graph/create empty` | Comprueba `is_empty() == 1`, `vertex_count() == 0`, `edge_count() == 0`, `has_edge(10,30) == FAILURE` y `get_neighbors(10) == FAILURE`. |
| Vértice aislado / Isolated vertex | Sí | `Graph/isolated vertex` | Registra 10; verifica `is_empty() == 0`, 1 vértice, 0 aristas y vecinos de 10 retornan `ABSENT` (0). |
| Etiquetas no consecutivas y arista dirigida / Nonconsecutive labels and directed edge | Sí | `Graph/nonconsecutive labels and directed edge` | Registra 10 y 70; añade (10,70); verifica `has_edge(10,70) == SUCCESS`, `has_edge(70,10) == FAILURE`, 2 vértices y 1 arista. |
| Vértice duplicado conserva adyacencia / Duplicate vertex preserves adjacency | Sí | `Graph/duplicate vertex preserves adjacency` | Registra 10 y 30; añade (10,30); re-registra 10; valida 2 vértices, 1 arista y vecinos de 10 iguales a `[30]`. |
| Arista duplicada / Duplicate edge | Sí | `Graph/duplicate edge` | Registra 10 y 30; añade (10,30) dos veces; valida 2 vértices, 1 arista y vecinos `[30]`. |
| Extremo inexistente sin mutación / Missing endpoint without mutation | Sí | `Graph/missing endpoint without mutation` | Intenta aristas con extremos faltantes; valida que retornan `FAILURE` y contadores/adyacencias permanecen inalterados. |
| Vecinos ordenados y contadores / Sorted neighbours and counts | Sí | `Graph/sorted neighbours and counts` | Registra 10, 30, 50, 70; añade (10,70), (10,30), (10,50), (30,50); valida orden ascendente `[30, 50, 70]`, 4 vértices y 4 aristas. |
| Consulta de arista ausente / Missing-edge query | Sí | `Graph/missing-edge query` | Registra 10 y 30; consulta arista no añadida; verifica `FAILURE`, 2 vértices y 0 aristas. |
| Vecinos de vértice inexistente / Neighbours of missing vertex | Sí | `Graph/neighbours of missing vertex` | Registra 10; consulta vecinos de 99; verifica `FAILURE` (-1) diferenciado de vecinos vacíos (`ABSENT`). |
| Bucle y duplicado / Self-loop and duplicate | Sí | `Graph/self-loop and duplicate` | Registra 10; añade (10,10) dos veces; verifica arista presente, 1 vértice, 1 arista y vecinos `[10]`. |
| Aislamiento del resultado de vecinos / Neighbour-result isolation | Sí | `Graph/neighbour-result isolation` | Obtiene vecinos de 10 (`[30]`); añade arista posterior (10,50); comprueba que la lista devuelta previamente no muta y una nueva consulta refleja `[30, 50]`. |

---

## ⚠️ Limitaciones conocidas / Known limitations

| Limitación / Limitation | Impacto / Impact | Alternativa o plan / Workaround or plan |
|---|---|---|
| Asignador monótono sin liberación (`alloc.asm`) | La memoria asignada para nodos, vértices y copias de vecinos no se libera hasta la finalización del proceso | El contrato del módulo no define operaciones de destrucción (`destroy` o `free`). Es una decisión explícita para evitar dependencias con libc en ensamblador puro. |
| Dependencia de la llamada al sistema Linux `sys_brk` | El binario sólo es ejecutable en sistemas operativos compatibles con el ABI de Linux x86-64 | Es la plataforma homologada del proyecto. Para otros sistemas operativos requeriría adaptar la llamada al sistema de reserva de memoria. |
| Árbol binario sin balanceo automático (ABB estándar) | Inserciones estrictamente ordenadas degradan la altura del árbol a `O(n)` | Cumple estrictamente la especificación del módulo, que se enfoca en ABB básico sin exigir AVL o Red-Black Tree. |

---

## 📝 Notas de implementación / Implementation Notes

### 🧱 Base `Node` y valor embebido / Base `Node` and embedded value

**ES:** El módulo implementa la forma canónica A2 de la especificación: una base `Node` con un único campo `.value` de 64 bits. Tanto `TreeNode` como `GraphNode` sitúan el valor como primer miembro de su estructura, permitiendo que cualquier función receptora de `Node*` pueda operar sobre ellos. La inicialización y validación de enlaces se mantiene aislada en cada estructura derivada.

**EN:** The module implements the specification's canonical A2 form: a `Node` base structure containing a single 64-bit `.value` field. Both `TreeNode` and `GraphNode` embed the value as their first field, enabling standard `Node*` handling while keeping link management and validation contained within each specialized child structure.

### 🧮 Gestión de memoria y aislamiento / Memory management and isolation

**ES:** El asignador en [`src/alloc.asm`](src/alloc.asm) alinea todas las solicitudes a 16 bytes. Si una reserva supera el break actual del proceso, solicita un bloque adicional de 64 KiB para amortizar el coste de las syscalls `sys_brk`. La operación `graph_get_neighbors` reserva una nueva secuencia de nodos [`NeighborNode`](src/data_structures_advanced.inc) para cada consulta, garantizando que el llamante reciba una vista aislada e inmutable respecto a mutaciones posteriores del grafo.

**EN:** The allocator in [`src/alloc.asm`](src/alloc.asm) aligns all allocations to 16-byte boundaries. When an allocation crosses the current process break, it requests an additional 64 KiB block to amortize `sys_brk` syscall overhead. The `graph_get_neighbors` function allocates a fresh chain of [`NeighborNode`](src/data_structures_advanced.inc) nodes for each query, ensuring the caller receives an isolated snapshot immune to subsequent graph modifications.

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
| Especificación / Specification | [`07_Data_Structures_Advanced.md`](https://yorche3.github.io/programming_languages/core/algorithms/07_Data_Structures_Advanced/) |
| Primera base del lenguaje / First language reference | [`data_structures_basics`](../data_structures_basics/README.md) |
| Segunda base del lenguaje / Second language reference | [`numbers`](../../foundations/numbers/README.md) |
| Guía de inicialización / Initialisation guide | [`core/00_Project_Initialization_Guide.md`](https://yorche3.github.io/programming_languages/core/00_Project_Initialization_Guide/) |
| Adaptaciones idiomáticas / Idiomatic adaptations | [`AGENT_Template.md`](https://yorche3.github.io/programming_languages/AGENT_Template/) |
| Validación de la documentación / Documentation validation | [`WORKFLOW.md`](https://yorche3.github.io/programming_languages/WORKFLOW/) |
| Plantilla del README / README template | [`README_Template.md`](https://yorche3.github.io/programming_languages/README_Template/) |
| Documentación oficial del lenguaje / Language official docs | [NASM Manual](https://www.nasm.us/xdoc/2.16.01/html/nasmdoc0.html) · [System V AMD64 ABI](https://gitlab.com/x86-psABIs/x86-64-ABI) · [Linux System Calls (syscalls(2))](https://man7.org/linux/man-pages/man2/syscalls.2.html) |

---

*[← Volver a Algoritmos Puros](../../../docs/core/algorithms/README.md) | [↑ Inicio](../../../docs/index.md)*

*🌐 [github.com/yorche3/programming_languages](https://github.com/yorche3/programming_languages) · [GitHub Pages](https://yorche3.github.io/programming_languages/)*
