; Each named input is a sequence of operation, three arguments, output, mode.
; Modes: 0 = void, 1 = scalar, 2 = neighbours, 3 = saved neighbours.
%macro operation 2
    extern %1
    section .data
    %1_name db %2, 0
    section .text
test_%1:
    mov rax, %1
    mov r10, %1_name
    jmp execute_operation
%endmacro

%macro step 5-6 1
    dq test_%1, %2, %3, %4, %5, %6
%endmacro

%macro case_entry 2
    dq %1_name, %1_input, %1_output
    section .rodata
    %1_name db %2, 0
    section .data
%endmacro

%macro tree_start 0
    step tree_node_init, parent_fixture, 10, 0, 0, 0
%endmacro

%macro children_start 0
    tree_start
    step tree_node_init, left_fixture, 20, 0, 0, 0
    step tree_node_init, right_fixture, 30, 0, 0, 0
    step tree_node_set_left, parent_fixture, left_fixture, 0, 0, 0
    step tree_node_set_right, parent_fixture, right_fixture, 0, 0, 0
%endmacro

%macro tree_insert 1
    step binary_tree_insert, tree_fixture, %1, 0, success_output
%endmacro

%macro tree_contains 1
    step binary_tree_contains, tree_fixture, %1, 0, success_output
%endmacro

%macro vertex 1
    step graph_add_vertex, graph_fixture, %1, 0, success_output
%endmacro

%macro edge 2
    step graph_add_edge, graph_fixture, %1, %2, success_output
%endmacro

%macro graph_counts 2
    step graph_vertex_count, graph_fixture, 0, 0, %1
    step graph_edge_count, graph_fixture, 0, 0, %2
%endmacro

%macro neighbors 2
    step graph_get_neighbors, graph_fixture, %1, 0, %2, 2
%endmacro

%macro graph_pair 0
    step graph_init, graph_fixture, 0, 0, 0, 0
    vertex 10
    vertex 30
%endmacro
