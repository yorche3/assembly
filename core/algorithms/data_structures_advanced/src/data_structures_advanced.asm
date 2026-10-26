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

; Void operations do nothing; other placeholders return failure or type defaults.
node_init:
    ret

node_get_value:
    xor eax, eax
    ret

tree_node_init:
    ret

tree_node_get_value:
    xor eax, eax
    ret

tree_node_get_left:
    mov rax, ABSENT
    ret

tree_node_get_right:
    mov rax, ABSENT
    ret

tree_node_set_left:
    ret

tree_node_set_right:
    ret

binary_tree_init:
    ret

binary_tree_insert:
    mov rax, FAILURE
    ret

binary_tree_contains:
    mov rax, FAILURE
    ret

binary_tree_is_empty:
    xor eax, eax
    ret

binary_tree_size:
    xor eax, eax
    ret

graph_node_init:
    ret

graph_init:
    ret

graph_add_vertex:
    mov rax, FAILURE
    ret

graph_add_edge:
    mov rax, FAILURE
    ret

graph_has_edge:
    mov rax, FAILURE
    ret

graph_get_neighbors:
    mov rax, FAILURE
    ret

graph_is_empty:
    xor eax, eax
    ret

graph_vertex_count:
    xor eax, eax
    ret

graph_edge_count:
    xor eax, eax
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
