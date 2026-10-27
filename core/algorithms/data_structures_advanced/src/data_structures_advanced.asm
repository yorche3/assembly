; data_structures_advanced.asm
;
; Implementación del módulo 07 para la familia F3 (linaje C) sobre la ABI
; System V AMD64. Lo que cambia respecto del contrato canónico es la FORMA,
; no el QUÉ:
;
;   * No hay herencia: el valor de `Node` se declara EMBEBIDO como primer
;     campo de `TreeNode` y de `GraphNode` (forma A2 del módulo).
;   * La ausencia de enlace es el puntero nulo (`ABSENT = 0`), y el fallo de
;     una operación es `FAILURE = -1`. Son valores distintos a propósito: un
;     vértice aislado devuelve ABSENT y un vértice inexistente FAILURE.
;   * No hay capacidad contractual: `binary_tree_init` y `graph_init` dejan
;     estructuras vacías utilizables y el montículo crece a demanda.
;   * El registro de vértices y la adyacencia son enlaces propios y manuales,
;     como exige la especificación: nada de tablas ni conjuntos de biblioteca.
;
; ABI: argumentos en rdi, rsi, rdx por orden de firma; resultado en rax.
; Los registros rbx y r12-r15 son del destinatario y se salvan si se usan;
; rax, rcx, rdx, rsi, rdi, r8-r11 son volátiles y NO sobreviven a un `call`.
; Antes de cada `call`, rsp queda alineado a 16 bytes.
;
; Memoria: los nodos salen de `alloc_bytes` (alloc.asm), un montículo de
; crecimiento monótono sobre `brk` que NO libera. El contrato del módulo no
; tiene operación de destrucción, así que la memoria de una estructura se
; libera con el proceso. Consecuencia asumida: `graph_get_neighbors` entrega
; una copia enlazada que el llamante no puede devolver al montículo.

%include "data_structures_advanced.inc"

section .text
    global node_init, node_get_value
    global tree_node_init, tree_node_get_value
    global tree_node_get_left, tree_node_get_right
    global tree_node_set_left, tree_node_set_right
    global binary_tree_init, binary_tree_insert, binary_tree_contains
    global binary_tree_is_empty, binary_tree_size
    global graph_node_init
    global graph_init, graph_add_vertex, graph_add_edge, graph_has_edge
    global graph_get_neighbors, graph_is_empty
    global graph_vertex_count, graph_edge_count
    extern alloc_bytes

; ============================================================
; node_init: fija el valor de la base.
; Argumentos: rdi = Node *, rsi = valor
; Devuelve: nada
; La base solo guarda el valor: no valida ni enlaza nada.
; ============================================================
node_init:
    mov [rdi + Node.value], rsi
    ret

; ============================================================
; node_get_value: lee el valor de la base.
; Argumentos: rdi = const Node *
; Devuelve: rax = valor
; ============================================================
node_get_value:
    mov rax, [rdi + Node.value]
    ret

; ============================================================
; tree_node_init: nodo de árbol con enlaces ausentes.
; Argumentos: rdi = TreeNode *, rsi = valor
; Devuelve: nada
; No escribe más que la memoria del nodo: por eso no puede fallar. La
; validación de los enlaces es responsabilidad de los setters.
; ============================================================
tree_node_init:
    mov [rdi + TreeNode.value], rsi
    mov qword [rdi + TreeNode.left], ABSENT
    mov qword [rdi + TreeNode.right], ABSENT
    ret

; ============================================================
; tree_node_get_value: valor del nodo de árbol.
; Argumentos: rdi = const TreeNode *
; Devuelve: rax = valor
; ============================================================
tree_node_get_value:
    mov rax, [rdi + TreeNode.value]
    ret

; ============================================================
; tree_node_get_left: enlace izquierdo.
; Argumentos: rdi = const TreeNode *
; Devuelve: rax = TreeNode * o ABSENT si no hay enlace
; ============================================================
tree_node_get_left:
    mov rax, [rdi + TreeNode.left]
    ret

; ============================================================
; tree_node_get_right: enlace derecho.
; Argumentos: rdi = const TreeNode *
; Devuelve: rax = TreeNode * o ABSENT si no hay enlace
; ============================================================
tree_node_get_right:
    mov rax, [rdi + TreeNode.right]
    ret

; ============================================================
; tree_node_set_left: escribe el enlace izquierdo.
; Argumentos: rdi = TreeNode *, rsi = TreeNode * o ABSENT
; Devuelve: nada
; Acepta ABSENT para desenlazar; no toca el contador del árbol que lo
; contenga, porque el nodo no conoce a su dueño.
; ============================================================
tree_node_set_left:
    mov [rdi + TreeNode.left], rsi
    ret

; ============================================================
; tree_node_set_right: escribe el enlace derecho.
; Argumentos: rdi = TreeNode *, rsi = TreeNode * o ABSENT
; Devuelve: nada
; ============================================================
tree_node_set_right:
    mov [rdi + TreeNode.right], rsi
    ret

; ============================================================
; binary_tree_init: árbol vacío utilizable.
; Argumentos: rdi = BinaryTree *
; Devuelve: nada
; Sin capacidad: raíz ausente y contador a cero son el estado inicial
; completo. No hay estado «lleno» ni instancia inutilizable.
; ============================================================
binary_tree_init:
    mov qword [rdi + BinaryTree.root], ABSENT
    mov qword [rdi + BinaryTree.count], 0
    ret

; ============================================================
; binary_tree_insert: alta en el ABB.
; Argumentos: rdi = BinaryTree *, rsi = valor
; Devuelve: rax = SUCCESS, o FAILURE si el montículo no puede crecer
;
; Se baja por la invariante «menores a la izquierda, mayores a la derecha»
; hasta el enlace ausente donde cuelga el nodo nuevo; un valor repetido sale
; por `je .success` sin crear nodo ni tocar el contador. r13 lleva la
; DIRECCIÓN del enlace que se inspecciona, así que enlazar es un solo
; `mov [r13], rax` sin distinguir raíz, izquierda ni derecha.
;
; El puntero del nodo nuevo se guarda en un hueco de pila ([rsp]) porque rdi
; es volátil: después de `call tree_node_init` no se puede suponer que siga
; valiendo. El `sub rsp, 16` deja además la pila alineada a 16.
; ============================================================
binary_tree_insert:
    push rbx                    ; rbx = árbol (para el contador)
    push r12                    ; r12 = valor que se inserta
    push r13                    ; r13 = dirección del enlace inspeccionado
    sub rsp, 16                 ; hueco estable para el nodo nuevo
    mov rbx, rdi
    mov r12, rsi
    lea r13, [rbx + BinaryTree.root]
.descend:
    mov rax, [r13]              ; rax = nodo actual del enlace
    test rax, rax
    jz .attach                  ; enlace ausente: aquí cuelga el nodo nuevo
    cmp r12, [rax + TreeNode.value]
    je .success                 ; duplicado: alta idempotente
    jl .go_left
    lea r13, [rax + TreeNode.right]
    jmp .descend
.go_left:
    lea r13, [rax + TreeNode.left]
    jmp .descend
.attach:
    mov rdi, TreeNode_size
    call alloc_bytes
    test rax, rax
    jz .failure                 ; el montículo no creció: no se mutó nada
    mov [rsp], rax              ; guarda el nodo: rdi no sobrevive al `call`
    mov rdi, rax
    mov rsi, r12
    call tree_node_init
    mov rax, [rsp]
    mov [r13], rax              ; enlaza en el hueco encontrado
    inc qword [rbx + BinaryTree.count]
.success:
    mov eax, SUCCESS
    jmp .done
.failure:
    mov rax, FAILURE
.done:
    add rsp, 16
    pop r13
    pop r12
    pop rbx
    ret

; ============================================================
; binary_tree_contains: pertenencia por la invariante del ABB.
; Argumentos: rdi = const BinaryTree *, rsi = valor
; Devuelve: rax = SUCCESS si está, FAILURE si no
; Baja comparando en cada nivel: O(h) comparaciones, sin recorrer secuencias.
; Un árbol vacío no entra en el bucle: sale por `.missing`.
; ============================================================
binary_tree_contains:
    mov rax, [rdi + BinaryTree.root]
.descend:
    test rax, rax
    jz .missing
    cmp rsi, [rax + TreeNode.value]
    je .found
    jl .go_left
    mov rax, [rax + TreeNode.right]
    jmp .descend
.go_left:
    mov rax, [rax + TreeNode.left]
    jmp .descend
.found:
    mov eax, SUCCESS
    ret
.missing:
    mov rax, FAILURE
    ret

; ============================================================
; binary_tree_is_empty
; Argumentos: rdi = const BinaryTree *
; Devuelve: rax = 1 si está vacío, 0 si no
; Se usa la raíz como indicador: la raíz y el contador se mueven juntos.
; ============================================================
binary_tree_is_empty:
    xor eax, eax
    cmp qword [rdi + BinaryTree.root], ABSENT
    sete al
    ret

; ============================================================
; binary_tree_size
; Argumentos: rdi = const BinaryTree *
; Devuelve: rax = número de valores distintos del árbol
; ============================================================
binary_tree_size:
    mov rax, [rdi + BinaryTree.count]
    ret

; ============================================================
; graph_node_init: vértice con adyacencia y enlace de registro ausentes.
; Argumentos: rdi = GraphNode *, rsi = etiqueta
; Devuelve: nada
; Es interno al grafo: el cliente no crea vértices a mano, los registra con
; `graph_add_vertex`. El `next_vertex` a ABSENT se deja escrito aunque
; `graph_add_vertex` lo reescriba después: documenta el estado del vértice
; recién creado y mantiene este inicializador coherente por sí solo.
; ============================================================
graph_node_init:
    mov [rdi + GraphNode.value], rsi
    mov qword [rdi + GraphNode.neighbours], ABSENT
    mov qword [rdi + GraphNode.next_vertex], ABSENT
    ret

; ============================================================
; graph_init: grafo vacío utilizable.
; Argumentos: rdi = Graph *
; Devuelve: nada
; Registro ausente y ambos contadores a cero. «Vacío» significa sin
; vértices; un grafo con un vértice aislado no está vacío.
; ============================================================
graph_init:
    mov qword [rdi + Graph.vertices], ABSENT
    mov qword [rdi + Graph.vertex_total], 0
    mov qword [rdi + Graph.edges], 0
    ret

; ============================================================
; find_vertex: búsqueda manual por etiqueta en el registro enlazado.
; Argumentos: rdi = const Graph *, rsi = etiqueta
; Devuelve: rax = GraphNode * o ABSENT si no está
; Recorrido O(V) sobre `next_vertex`, sin índices ni tablas: la
; especificación prohíbe delegar el registro en una colección.
; Es interno (no se exporta) y no usa registros salvados.
; ============================================================
find_vertex:
    mov rax, [rdi + Graph.vertices]
.scan:
    test rax, rax
    jz .done                    ; fin del registro: no está
    cmp [rax + GraphNode.value], rsi
    je .done
    mov rax, [rax + GraphNode.next_vertex]
    jmp .scan
.done:
    ret

; ============================================================
; graph_add_vertex: registra una etiqueta, incluidos los vértices aislados.
; Argumentos: rdi = Graph *, rsi = etiqueta
; Devuelve: rax = SUCCESS, o FAILURE si el montículo no puede crecer
; Es idempotente: si la etiqueta ya está registrada devuelve SUCCESS sin
; crear nodo ni tocar los contadores, así que repetir el alta no pierde la
; adyacencia que ese vértice ya tuviera. El vértice nuevo entra en la CABEZA
; del registro, que no tiene orden contractual.
;
; r14 guarda el nodo nuevo porque rdi es volátil y `graph_node_init` podría
; dejar de preservarlo. Con sus tres `push` la pila queda alineada a 16.
; ============================================================
graph_add_vertex:
    push rbx                    ; rbx = grafo
    push r12                    ; r12 = etiqueta
    push r14                    ; r14 = nodo nuevo del registro
    mov rbx, rdi
    mov r12, rsi
    call find_vertex
    test rax, rax
    jnz .success                ; ya registrado: alta idempotente
    mov rdi, GraphNode_size
    call alloc_bytes
    test rax, rax
    jz .failure
    mov r14, rax
    mov rdi, r14
    mov rsi, r12
    call graph_node_init
    mov rax, [rbx + Graph.vertices]
    mov [r14 + GraphNode.next_vertex], rax   ; cabecera anterior
    mov [rbx + Graph.vertices], r14          ; cabecera nueva
    inc qword [rbx + Graph.vertex_total]
.success:
    mov eax, SUCCESS
    jmp .done
.failure:
    mov rax, FAILURE
.done:
    pop r14
    pop r12
    pop rbx
    ret

; ============================================================
; graph_add_edge: arista dirigida entre dos vértices registrados.
; Argumentos: rdi = Graph *, rsi = u, rdx = v
; Devuelve: rax = SUCCESS, o FAILURE si falta algún extremo
;
; Reglas de la especificación que se ven en el código:
;   * ambos extremos deben existir; si falta uno, FAILURE y CERO mutaciones
;     (contadores y adyacencia quedan como estaban);
;   * la adyacencia se mantiene ORDENADA por etiqueta: se avanza mientras la
;     etiqueta actual sea menor y el nodo nuevo se inserta delante del primero
;     que ya no lo es, con r14 llevando la dirección del enlace;
;   * un duplicado se detecta en el mismo recorrido y devuelve SUCCESS sin
;     crear nodo ni contar arista;
;   * los bucles están permitidos: u = v es una arista normal.
;
; La pila se alinea con `sub rsp, 8` porque hay cuatro `push`.
; ============================================================
graph_add_edge:
    push rbx                    ; rbx = grafo (contador de aristas)
    push r12                    ; r12 = v (etiqueta destino)
    push r13                    ; r13 = vértice origen
    push r14                    ; r14 = dirección del enlace de adyacencia
    sub rsp, 8                  ; alineación a 16 antes de los `call`
    mov rbx, rdi
    mov r12, rdx
    call find_vertex            ; rdi = grafo, rsi = u: sin tocar
    test rax, rax
    jz .failure                 ; origen inexistente: no se muta nada
    mov r13, rax
    mov rdi, rbx                ; rdi es volátil: se restaura desde rbx
    mov rsi, r12
    call find_vertex            ; destino
    test rax, rax
    jz .failure                 ; destino inexistente: no se muta nada
    lea r14, [r13 + GraphNode.neighbours]
.scan:
    mov rax, [r14]
    test rax, rax
    jz .attach                  ; final de la lista: se añade al final
    mov rcx, [rax + NeighborNode.label]
    cmp rcx, r12
    je .success                 ; arista repetida: idempotente
    jg .attach                  ; la etiqueta actual es mayor: va delante
    lea r14, [rax + NeighborNode.next]
    jmp .scan
.attach:
    mov rdi, NeighborNode_size
    call alloc_bytes
    test rax, rax
    jz .failure
    mov [rax + NeighborNode.label], r12
    mov rcx, [r14]              ; el resto de la lista queda detrás
    mov [rax + NeighborNode.next], rcx
    mov [r14], rax              ; enlace anterior -> nodo nuevo
    inc qword [rbx + Graph.edges]
.success:
    mov eax, SUCCESS
    jmp .done
.failure:
    mov rax, FAILURE
.done:
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; ============================================================
; graph_has_edge: consulta de arista dirigida.
; Argumentos: rdi = const Graph *, rsi = u, rdx = v
; Devuelve: rax = SUCCESS si existe, FAILURE si no o si falta un extremo
; Recorre la adyacencia del origen, que está ordenada: en cuanto la etiqueta
; actual supera a `v`, la arista no existe y se corta el recorrido.
; El vértice origen se guarda en un hueco de pila ([rsp]) para no depender de
; rdi entre los dos `call`.
; ============================================================
graph_has_edge:
    push rbx                    ; rbx = grafo
    push r12                    ; r12 = v
    sub rsp, 24                 ; hueco del origen + alineación a 16
    mov rbx, rdi
    mov r12, rdx
    call find_vertex            ; origen
    test rax, rax
    jz .failure
    mov [rsp], rax
    mov rdi, rbx                ; rdi es volátil: se restaura desde rbx
    mov rsi, r12
    call find_vertex            ; destino
    test rax, rax
    jz .failure
    mov rcx, [rsp]              ; rcx = vértice origen
    mov rax, [rcx + GraphNode.neighbours]
.scan:
    test rax, rax
    jz .failure                 ; fin de la adyacencia: no está
    mov rcx, [rax + NeighborNode.label]
    cmp rcx, r12
    je .found
    jg .failure                 ; ordenada: si ya es mayor, no está
    mov rax, [rax + NeighborNode.next]
    jmp .scan
.found:
    mov eax, SUCCESS
    jmp .done
.failure:
    mov rax, FAILURE
.done:
    add rsp, 24
    pop r12
    pop rbx
    ret

; ============================================================
; graph_get_neighbors: copia independiente y ordenada de la adyacencia.
; Argumentos: rdi = const Graph *, rsi = u
; Devuelve: rax = NeighborNode * (lista copiada)
;           rax = ABSENT  si `u` existe pero no tiene vecinos
;           rax = FAILURE si `u` no existe o el montículo no puede crecer
;
; ABSENT y FAILURE son distintos a propósito: el contrato exige que un
; vértice aislado (secuencia vacía) no se confunda con un vértice
; inexistente (fallo). Comprueba FAILURE antes de recorrer rax.
;
; La copia se construye nodo a nodo y conserva el orden de la adyacencia. El
; grafo no se modifica: cambiar la copia, o añadir aristas después, no altera
; ni al grafo ni a una copia ya entregada.
;
; Si el montículo falla a mitad de copia, los nodos ya copiados quedan
; huérfanos: es una fuga ACOTADA y consciente, porque este contrato no tiene
; operación de liberación (una copia completa tampoco se liberaría nunca).
; Lo que sí se garantiza es que el fallo no muta el grafo.
; ============================================================
graph_get_neighbors:
    push rbx
    push r12                    ; r12 = cursor sobre la adyacencia original
    push r13                    ; r13 = dirección del enlace de la copia
    sub rsp, 16                 ; [rsp] = cabeza de la copia; alinea a 16
    call find_vertex
    test rax, rax
    jz .failure                 ; vértice inexistente
    mov r12, [rax + GraphNode.neighbours]
    mov qword [rsp], ABSENT     ; copia vacía
    mov r13, rsp
.copy:
    test r12, r12
    jz .complete                ; adyacencia original agotada
    mov rdi, NeighborNode_size
    call alloc_bytes
    test rax, rax
    jz .failure                 ; fuga acotada: ver la cabecera
    mov rcx, [r12 + NeighborNode.label]
    mov [rax + NeighborNode.label], rcx
    mov qword [rax + NeighborNode.next], ABSENT
    mov [r13], rax              ; enlaza la copia por la cola
    lea r13, [rax + NeighborNode.next]
    mov r12, [r12 + NeighborNode.next]
    jmp .copy
.complete:
    mov rax, [rsp]              ; ABSENT si no hubo ningún vecino
    jmp .done
.failure:
    mov rax, FAILURE
.done:
    add rsp, 16
    pop r13
    pop r12
    pop rbx
    ret

; ============================================================
; graph_is_empty: vacío significa SIN VÉRTICES.
; Argumentos: rdi = const Graph *
; Devuelve: rax = 1 si no hay vértices, 0 si hay alguno
; Un grafo con vértices aislados no está vacío; sus vecinos sí lo están.
; ============================================================
graph_is_empty:
    xor eax, eax
    cmp qword [rdi + Graph.vertex_total], 0
    sete al
    ret

; ============================================================
; graph_vertex_count
; Argumentos: rdi = const Graph *
; Devuelve: rax = número de vértices registrados
; ============================================================
graph_vertex_count:
    mov rax, [rdi + Graph.vertex_total]
    ret

; ============================================================
; graph_edge_count
; Argumentos: rdi = const Graph *
; Devuelve: rax = número de aristas distintas (un bucle cuenta una)
; ============================================================
graph_edge_count:
    mov rax, [rdi + Graph.edges]
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
