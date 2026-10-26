; Data Structures Advanced contract for the System V AMD64 ABI.
; Arguments: rdi, rsi, rdx in signature order. Return value: rax.
; Callee-saved: rbx, rbp, r12-r15. Integers and pointers occupy 64 bits.
; Caller-owned storage is passed to initializers; no capacity is required.
; Bodies in data_structures_advanced.asm are placeholders, not implementations.

%ifndef DATA_STRUCTURES_ADVANCED_INC
%define DATA_STRUCTURES_ADVANCED_INC

%define FAILURE -1
%define ABSENT   0
%define SUCCESS  1

; Value-only base, not instantiated independently. Children embed its value.
struc Node
    .value: resq 1
endstruc

struc TreeNode
    .value: resq 1
    .left:  resq 1
    .right: resq 1
endstruc

struc BinaryTree
    .root:  resq 1
    .count: resq 1
endstruc

; Internal linked storage, also used for independent neighbour snapshots.
struc NeighborNode
    .label: resq 1
    .next:  resq 1
endstruc

struc GraphNode
    .value:       resq 1
    .neighbours:  resq 1
    .next_vertex: resq 1
endstruc

struc Graph
    .vertices:     resq 1
    .vertex_total: resq 1
    .edges:        resq 1
endstruc

; All operation bodies live in src/data_structures_advanced.asm.
; These signatures describe the eventual contract, not placeholder behaviour.

; node_init(Node *node, int64_t value) -> void (base initialization only)
; node_get_value(const Node *node) -> int64_t (no failure)

; tree_node_init(TreeNode *node, int64_t value) -> void
; tree_node_get_value(const TreeNode *node) -> int64_t (no failure)
; tree_node_get_left(const TreeNode *node) -> TreeNode * (ABSENT if unlinked)
; tree_node_get_right(const TreeNode *node) -> TreeNode * (ABSENT if unlinked)
; tree_node_set_left(TreeNode *node, TreeNode *left) -> void
; tree_node_set_right(TreeNode *node, TreeNode *right) -> void
; Setters accept ABSENT and do not change a containing tree's count.

; binary_tree_init(BinaryTree *tree) -> void
; binary_tree_insert(BinaryTree *tree, int64_t value) -> int64_t (SUCCESS)
; binary_tree_contains(const BinaryTree *tree, int64_t value)
;   -> int64_t (SUCCESS or FAILURE)
; binary_tree_is_empty(const BinaryTree *tree) -> int64_t (0 or 1)
; binary_tree_size(const BinaryTree *tree) -> int64_t
; Initialization leaves root absent and count zero. Duplicate insert succeeds
; without increasing count; there is no contractual capacity or full state.

; graph_node_init(GraphNode *node, int64_t label) -> void (internal to Graph)

; graph_init(Graph *graph) -> void
; graph_add_vertex(Graph *graph, int64_t label) -> int64_t (SUCCESS)
; graph_add_edge(Graph *graph, int64_t u, int64_t v)
;   -> int64_t (SUCCESS or FAILURE if either endpoint is missing)
; graph_has_edge(const Graph *graph, int64_t u, int64_t v)
;   -> int64_t (SUCCESS or FAILURE)
; graph_get_neighbors(const Graph *graph, int64_t u)
;   -> NeighborNode * in rax, or FAILURE if u is missing
; graph_is_empty(const Graph *graph) -> int64_t (0 or 1)
; graph_vertex_count(const Graph *graph) -> int64_t
; graph_edge_count(const Graph *graph) -> int64_t
; Initialization leaves vertices absent and both counters zero.
; Duplicate vertices/edges succeed without changing counts; self-loops are valid.
; Missing endpoints fail without mutation. Labels are values, not array indices.
; Neighbours are ascending, duplicate-free independent linked copies: ABSENT
; means an existing isolated vertex. Check FAILURE before dereferencing rax.
; Changing a returned copy or adding edges cannot change an earlier snapshot.
; Registry and adjacency are manually linked, with no contractual capacity.

%endif
