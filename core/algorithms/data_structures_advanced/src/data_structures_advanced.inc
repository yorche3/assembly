; data_structures_advanced.inc — contrato del módulo 07 para la ABI System V
; AMD64 (familia F3, linaje C).
;
; Convenciones de la ABI que usa todo el módulo:
;   * Argumentos en rdi, rsi, rdx por orden de firma; resultado en rax.
;   * Enteros y punteros ocupan 64 bits.
;   * Salvados por el destinatario: rbx, rbp, r12-r15. Volátiles: rax, rcx,
;     rdx, rsi, rdi, r8-r11 (no sobreviven a un `call`).
;
; Indicadores: FAILURE = -1 (la operación falla), ABSENT = 0 (ausencia de
; enlace, de vértice o lista vacía) y SUCCESS = 1. Son valores distintos a
; propósito: el contrato exige distinguir «vértice aislado» de «vértice
; inexistente».
;
; Los nodos salen de alloc.asm (montículo monótono sobre `brk`, sin
; liberación), porque el contrato no tiene operación de destrucción.

%ifndef DATA_STRUCTURES_ADVANCED_INC
%define DATA_STRUCTURES_ADVANCED_INC

%define FAILURE -1
%define ABSENT   0
%define SUCCESS  1

; Base del módulo: SOLO el valor. No tiene enlaces, no valida nada y no se
; instancia por sí sola; los hijos la reutilizan por valor EMBEBIDO.
struc Node
    .value: resq 1
endstruc

; Nodo del ABB: el valor va primero (herencia por composición) y después los
; dos enlaces. Un enlace ausente representa un subárbol vacío.
struc TreeNode
    .value: resq 1
    .left:  resq 1
    .right: resq 1
endstruc

; ABB sin capacidad contractual: raíz y número de valores distintos.
struc BinaryTree
    .root:  resq 1
    .count: resq 1
endstruc

; Almacenamiento enlazado manual, compartido por la adyacencia del grafo y
; por las copias independientes que devuelve graph_get_neighbors.
struc NeighborNode
    .label: resq 1
    .next:  resq 1
endstruc

; Vértice del registro canónico: etiqueta heredada, adyacencia propia y
; enlace al siguiente vértice del registro. Sin índices ni capacidad.
struc GraphNode
    .value:       resq 1
    .neighbours:  resq 1
    .next_vertex: resq 1
endstruc

; Grafo dirigido: registro de vértices y dos contadores separados.
struc Graph
    .vertices:     resq 1
    .vertex_total: resq 1
    .edges:        resq 1
endstruc

; Los cuerpos viven en src/data_structures_advanced.asm. Estas firmas son el
; contrato que implementan.

; node_init(Node *node, int64_t value) -> void (solo inicializa la base)
; node_get_value(const Node *node) -> int64_t (no falla)

; tree_node_init(TreeNode *node, int64_t value) -> void
; tree_node_get_value(const TreeNode *node) -> int64_t (no falla)
; tree_node_get_left(const TreeNode *node) -> TreeNode * (ABSENT si no hay)
; tree_node_get_right(const TreeNode *node) -> TreeNode * (ABSENT si no hay)
; tree_node_set_left(TreeNode *node, TreeNode *left) -> void
; tree_node_set_right(TreeNode *node, TreeNode *right) -> void
; Los setters aceptan ABSENT para desenlazar y no cambian el contador del
; árbol que contenga al nodo.

; binary_tree_init(BinaryTree *tree) -> void
; binary_tree_insert(BinaryTree *tree, int64_t value) -> int64_t (SUCCESS)
; binary_tree_contains(const BinaryTree *tree, int64_t value)
;   -> int64_t (SUCCESS o FAILURE)
; binary_tree_is_empty(const BinaryTree *tree) -> int64_t (0 o 1)
; binary_tree_size(const BinaryTree *tree) -> int64_t
; La inicialización deja la raíz ausente y el contador a cero. Un duplicado
; devuelve SUCCESS sin aumentar el contador; no hay capacidad contractual ni
; estado «lleno».

; graph_node_init(GraphNode *node, int64_t label) -> void (interno a Graph)

; graph_init(Graph *graph) -> void
; graph_add_vertex(Graph *graph, int64_t label) -> int64_t (SUCCESS)
; graph_add_edge(Graph *graph, int64_t u, int64_t v)
;   -> int64_t (SUCCESS o FAILURE si falta algún extremo)
; graph_has_edge(const Graph *graph, int64_t u, int64_t v)
;   -> int64_t (SUCCESS o FAILURE)
; graph_get_neighbors(const Graph *graph, int64_t u)
;   -> NeighborNode * en rax, o FAILURE si `u` no existe
; graph_is_empty(const Graph *graph) -> int64_t (0 o 1)
; graph_vertex_count(const Graph *graph) -> int64_t
; graph_edge_count(const Graph *graph) -> int64_t
;
; La inicialización deja el registro ausente y los dos contadores a cero.
; Registrar un vértice o una arista repetidos devuelve SUCCESS sin cambiar
; los contadores; los bucles son válidos. Un extremo inexistente falla sin
; mutar nada. Las etiquetas son VALORES, no índices de array.
;
; Los vecinos son una copia enlazada ascendente y sin duplicados: ABSENT
; significa «vértice existente pero aislado». Comprueba FAILURE antes de
; recorrer rax. Cambiar una copia devuelta, o añadir aristas después, no
; modifica una copia anterior.
;
; Registro y adyacencia son enlaces manuales, sin capacidad contractual.

%endif
