%include "data_structures_advanced.inc"
%include "test_macros.inc"

operation tree_node_init, "TreeNode.init"
operation tree_node_get_value, "TreeNode.get_value"
operation tree_node_get_left, "TreeNode.get_left"
operation tree_node_get_right, "TreeNode.get_right"
operation tree_node_set_left, "TreeNode.set_left"
operation tree_node_set_right, "TreeNode.set_right"
operation binary_tree_init, "BinaryTree.init"
operation binary_tree_insert, "BinaryTree.insert"
operation binary_tree_contains, "BinaryTree.contains"
operation binary_tree_is_empty, "BinaryTree.is_empty"
operation binary_tree_size, "BinaryTree.size"
operation graph_init, "Graph.init"
operation graph_add_vertex, "Graph.add_vertex"
operation graph_add_edge, "Graph.add_edge"
operation graph_has_edge, "Graph.has_edge"
operation graph_get_neighbors, "Graph.get_neighbors"
operation graph_is_empty, "Graph.is_empty"
operation graph_vertex_count, "Graph.vertex_count"
operation graph_edge_count, "Graph.edge_count"

section .data
    success_output dq SUCCESS
    failure_output dq FAILURE
    absent_output dq ABSENT
    true_output dq 1
    false_output dq 0
    zero_output dq 0
    one_output dq 1
    two_output dq 2
    three_output dq 3
    four_output dq 4
    five_output dq 5
    ten_output dq 10
    twenty_output dq 20
    thirty_output dq 30
    left_output dq left_fixture
    right_output dq right_fixture
    empty_neighbors_output dq 0
    thirty_neighbors_output dq 1, 30
    ten_neighbors_output dq 1, 10
    fifty_neighbors_output dq 1, 50
    sorted_neighbors_output dq 3, 30, 50, 70
    extended_neighbors_output dq 2, 30, 50

    passed_message db "  PASSED: ", 0
    failed_message db "  FAILED: ", 0
    assertion_message db "    Assertion_Error: ", 0
    scalar_message db " should equal ", 0
    neighbors_message db " should equal [", 0
    comma_message db ",", 0
    close_message db "]", 0
    actual_message db "; actual ", 0
    case_message db " in case ", 0
    newline db 10, 0

    ; One row per specification case; immutable adaptation is not applicable.
    cases:
    case_entry create_node, "TreeNode/create a tree node"
    case_entry initial_links, "TreeNode/absent initial links"
    case_entry link_children, "TreeNode/link two children"
    case_entry traverse_links, "TreeNode/traverse each link"
    case_entry unlink_children, "TreeNode/unlink children"
    case_entry empty_tree, "BinaryTree/create empty"
    case_entry root_tree, "BinaryTree/insert the root"
    case_entry branches_tree, "BinaryTree/insert lower and higher"
    case_entry multilevel_tree, "BinaryTree/multilevel branches"
    case_entry missing_tree, "BinaryTree/missing value in nonempty tree"
    case_entry duplicate_tree, "BinaryTree/idempotent duplicate"
    case_entry ordered_tree, "BinaryTree/ordered insertions"
    case_entry empty_graph, "Graph/create empty"
    case_entry isolated_graph, "Graph/isolated vertex"
    case_entry directed_graph, "Graph/nonconsecutive labels and directed edge"
    case_entry duplicate_vertex, "Graph/duplicate vertex preserves adjacency"
    case_entry duplicate_edge, "Graph/duplicate edge"
    case_entry missing_endpoint, "Graph/missing endpoint without mutation"
    case_entry sorted_graph, "Graph/sorted neighbours and counts"
    case_entry missing_edge, "Graph/missing-edge query"
    case_entry missing_neighbors, "Graph/neighbours of missing vertex"
    case_entry loop_graph, "Graph/self-loop and duplicate"
    case_entry isolated_result, "Graph/neighbour-result isolation"
    cases_end:

    create_node_input:
    tree_start
    step tree_node_get_value, parent_fixture, 0, 0, ten_output
    create_node_output:
    dq 0

    initial_links_input:
    tree_start
    step tree_node_get_left, parent_fixture, 0, 0, absent_output
    step tree_node_get_right, parent_fixture, 0, 0, absent_output
    initial_links_output:
    dq 0

    link_children_input:
    children_start
    step tree_node_get_left, parent_fixture, 0, 0, left_output
    step tree_node_get_value, -2, 0, 0, twenty_output
    step tree_node_get_right, parent_fixture, 0, 0, right_output
    step tree_node_get_value, -2, 0, 0, thirty_output
    link_children_output:
    dq 0

    traverse_links_input:
    children_start
    step tree_node_get_left, parent_fixture, 0, 0, left_output
    step tree_node_get_value, -2, 0, 0, twenty_output
    step tree_node_get_left, left_fixture, 0, 0, absent_output
    step tree_node_get_right, left_fixture, 0, 0, absent_output
    step tree_node_get_right, parent_fixture, 0, 0, right_output
    step tree_node_get_value, -2, 0, 0, thirty_output
    step tree_node_get_left, right_fixture, 0, 0, absent_output
    step tree_node_get_right, right_fixture, 0, 0, absent_output
    traverse_links_output:
    dq 0

    unlink_children_input:
    children_start
    step tree_node_set_left, parent_fixture, ABSENT, 0, 0, 0
    step tree_node_get_left, parent_fixture, 0, 0, absent_output
    step tree_node_get_value, parent_fixture, 0, 0, ten_output
    step tree_node_get_right, parent_fixture, 0, 0, right_output
    step tree_node_get_value, -2, 0, 0, thirty_output
    step tree_node_set_right, parent_fixture, ABSENT, 0, 0, 0
    step tree_node_get_left, parent_fixture, 0, 0, absent_output
    step tree_node_get_right, parent_fixture, 0, 0, absent_output
    step tree_node_get_value, parent_fixture, 0, 0, ten_output
    unlink_children_output:
    dq 0

    empty_tree_input:
    step binary_tree_init, tree_fixture, 0, 0, 0, 0
    step binary_tree_is_empty, tree_fixture, 0, 0, true_output
    step binary_tree_size, tree_fixture, 0, 0, zero_output
    step binary_tree_contains, tree_fixture, 50, 0, failure_output
    empty_tree_output:
    dq 0

    root_tree_input:
    step binary_tree_init, tree_fixture, 0, 0, 0, 0
    tree_insert 50
    step binary_tree_size, tree_fixture, 0, 0, one_output
    step binary_tree_is_empty, tree_fixture, 0, 0, false_output
    tree_contains 50
    root_tree_output:
    dq 0

    branches_tree_input:
    step binary_tree_init, tree_fixture, 0, 0, 0, 0
    tree_insert 50
    tree_insert 30
    tree_insert 70
    step binary_tree_size, tree_fixture, 0, 0, three_output
    tree_contains 50
    tree_contains 30
    tree_contains 70
    branches_tree_output:
    dq 0

    multilevel_tree_input:
    step binary_tree_init, tree_fixture, 0, 0, 0, 0
    tree_insert 50
    tree_insert 30
    tree_insert 70
    tree_insert 20
    tree_insert 40
    tree_contains 50
    tree_contains 30
    tree_contains 70
    tree_contains 20
    tree_contains 40
    step binary_tree_size, tree_fixture, 0, 0, five_output
    multilevel_tree_output:
    dq 0

    missing_tree_input:
    step binary_tree_init, tree_fixture, 0, 0, 0, 0
    tree_insert 50
    step binary_tree_contains, tree_fixture, 99, 0, failure_output
    step binary_tree_size, tree_fixture, 0, 0, one_output
    tree_contains 50
    missing_tree_output:
    dq 0

    duplicate_tree_input:
    step binary_tree_init, tree_fixture, 0, 0, 0, 0
    tree_insert 50
    tree_insert 30
    tree_insert 70
    tree_insert 30
    step binary_tree_size, tree_fixture, 0, 0, three_output
    tree_contains 50
    tree_contains 30
    tree_contains 70
    duplicate_tree_output:
    dq 0

    ordered_tree_input:
    step binary_tree_init, tree_fixture, 0, 0, 0, 0
    tree_insert 20
    tree_insert 30
    tree_insert 40
    tree_insert 50
    tree_insert 70
    step binary_tree_size, tree_fixture, 0, 0, five_output
    tree_contains 20
    tree_contains 30
    tree_contains 40
    tree_contains 50
    tree_contains 70
    step binary_tree_contains, tree_fixture, 99, 0, failure_output
    ordered_tree_output:
    dq 0

    empty_graph_input:
    step graph_init, graph_fixture, 0, 0, 0, 0
    step graph_is_empty, graph_fixture, 0, 0, true_output
    graph_counts zero_output, zero_output
    step graph_has_edge, graph_fixture, 10, 30, failure_output
    step graph_get_neighbors, graph_fixture, 10, 0, failure_output
    empty_graph_output:
    dq 0

    isolated_graph_input:
    step graph_init, graph_fixture, 0, 0, 0, 0
    vertex 10
    step graph_is_empty, graph_fixture, 0, 0, false_output
    graph_counts one_output, zero_output
    neighbors 10, empty_neighbors_output
    isolated_graph_output:
    dq 0

    directed_graph_input:
    step graph_init, graph_fixture, 0, 0, 0, 0
    vertex 10
    vertex 70
    edge 10, 70
    step graph_has_edge, graph_fixture, 10, 70, success_output
    step graph_has_edge, graph_fixture, 70, 10, failure_output
    graph_counts two_output, one_output
    directed_graph_output:
    dq 0

    duplicate_vertex_input:
    graph_pair
    edge 10, 30
    vertex 10
    graph_counts two_output, one_output
    neighbors 10, thirty_neighbors_output
    duplicate_vertex_output:
    dq 0

    duplicate_edge_input:
    graph_pair
    edge 10, 30
    edge 10, 30
    graph_counts two_output, one_output
    neighbors 10, thirty_neighbors_output
    duplicate_edge_output:
    dq 0

    missing_endpoint_input:
    graph_pair
    edge 10, 30
    step graph_add_edge, graph_fixture, 10, 99, failure_output
    step graph_add_edge, graph_fixture, 99, 10, failure_output
    step graph_add_edge, graph_fixture, 98, 99, failure_output
    step graph_add_edge, graph_fixture, 99, 99, failure_output
    graph_counts two_output, one_output
    neighbors 10, thirty_neighbors_output
    neighbors 30, empty_neighbors_output
    step graph_has_edge, graph_fixture, 10, 99, failure_output
    step graph_has_edge, graph_fixture, 99, 10, failure_output
    step graph_has_edge, graph_fixture, 98, 99, failure_output
    step graph_has_edge, graph_fixture, 99, 99, failure_output
    step graph_get_neighbors, graph_fixture, 98, 0, failure_output
    step graph_get_neighbors, graph_fixture, 99, 0, failure_output
    missing_endpoint_output:
    dq 0

    sorted_graph_input:
    graph_pair
    vertex 50
    vertex 70
    edge 10, 70
    edge 10, 30
    edge 10, 50
    edge 30, 50
    neighbors 10, sorted_neighbors_output
    neighbors 30, fifty_neighbors_output
    neighbors 50, empty_neighbors_output
    neighbors 70, empty_neighbors_output
    graph_counts four_output, four_output
    sorted_graph_output:
    dq 0

    missing_edge_input:
    graph_pair
    step graph_has_edge, graph_fixture, 10, 30, failure_output
    graph_counts two_output, zero_output
    step graph_is_empty, graph_fixture, 0, 0, false_output
    missing_edge_output:
    dq 0

    missing_neighbors_input:
    step graph_init, graph_fixture, 0, 0, 0, 0
    vertex 10
    step graph_get_neighbors, graph_fixture, 99, 0, failure_output
    neighbors 10, empty_neighbors_output
    graph_counts one_output, zero_output
    missing_neighbors_output:
    dq 0

    loop_graph_input:
    step graph_init, graph_fixture, 0, 0, 0, 0
    vertex 10
    edge 10, 10
    edge 10, 10
    step graph_has_edge, graph_fixture, 10, 10, success_output
    neighbors 10, ten_neighbors_output
    graph_counts one_output, one_output
    loop_graph_output:
    dq 0

    isolated_result_input:
    graph_pair
    vertex 50
    edge 10, 30
    step graph_get_neighbors, graph_fixture, 10, 0, thirty_neighbors_output, 3
    neighbors 10, thirty_neighbors_output
    dq mutate_copy, 0, 0, 0, 0, 0
    neighbors 10, thirty_neighbors_output
    edge 10, 50
    dq observe_saved, 0, 0, 0, thirty_neighbors_output, 2
    neighbors 10, extended_neighbors_output
    graph_counts three_output, two_output
    isolated_result_output:
    dq 0

section .bss
    fixtures_start:
    parent_fixture resb TreeNode_size
    left_fixture resb TreeNode_size
    right_fixture resb TreeNode_size
    tree_fixture resb BinaryTree_size
    graph_fixture resb Graph_size
    saved_neighbors resq 1
    last_result resq 1
    fixtures_end:
    actual_result resq 1
    operation_name resq 1

section .text
    global run_data_structures_advanced_tests
    extern print_string, print_number, assert
    extern tests_total, tests_passed, tests_failed

run_data_structures_advanced_tests:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov rbx, cases
.case:
    cmp rbx, cases_end
    jae .done
    ; Reset caller-owned storage, never the immutable input/expected tables.
    mov rdi, fixtures_start
    mov ecx, fixtures_end - fixtures_start
    xor eax, eax
    cld
    rep stosb
    inc qword [tests_total]
    mov r12, [rbx + 8]
    mov r13, [rbx + 16]
.step:
    cmp r12, r13
    jae .passed
    call [r12]
    test rax, rax
    jz .failed
    add r12, 48
    jmp .step
.passed:
    inc qword [tests_passed]
    mov rdi, passed_message
    jmp .report
.failed:
    inc qword [tests_failed]
    mov rdi, failed_message
.report:
    call print_string
    mov rdi, [rbx]
    call print_string
    mov rdi, newline
    call print_string
    add rbx, 24
    jmp .case
.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

execute_operation:
    sub rsp, 8
    mov [operation_name], r10
    mov rdi, [r12 + 8]
    cmp rdi, -2
    jne .arguments
    mov rdi, [last_result]
.arguments:
    mov rsi, [r12 + 16]
    mov rdx, [r12 + 24]
    call rax
    mov [last_result], rax
    mov [actual_result], rax
    cmp qword [r12 + 40], 0
    je .passed
    cmp qword [r12 + 40], 1
    jne .neighbors
    mov rdi, rax
    mov rsi, [r12 + 32]
    mov rsi, [rsi]
    call assert
    test rax, rax
    jz .failed
    jmp .passed
.neighbors:
    mov r14, [r12 + 32]
    mov r15, [r14]
    add r14, 8
    mov rbp, [actual_result]
.element:
    test r15, r15
    jz .end_neighbors
    ; Failure/absence must be checked before accessing a returned list.
    cmp rbp, FAILURE
    je .failed
    test rbp, rbp
    jz .failed
    mov rdi, [rbp + NeighborNode.label]
    mov rsi, [r14]
    call assert
    test rax, rax
    jz .failed
    mov rbp, [rbp + NeighborNode.next]
    add r14, 8
    dec r15
    jmp .element
.end_neighbors:
    mov rdi, rbp
    mov rsi, ABSENT
    call assert
    test rax, rax
    jz .failed
    cmp qword [r12 + 40], 3
    jne .passed
    mov rax, [actual_result]
    mov [saved_neighbors], rax
.passed:
    mov eax, 1
    add rsp, 8
    ret
.failed:
    mov rdi, assertion_message
    call print_string
    mov rdi, [operation_name]
    call print_string
    cmp qword [r12 + 40], 1
    jne .sequence_message
    mov rdi, scalar_message
    call print_string
    mov rdi, [r12 + 32]
    mov rdi, [rdi]
    call print_number
    mov rdi, actual_message
    call print_string
    mov rdi, [actual_result]
    call print_number
    jmp .case_message
.sequence_message:
    mov rdi, neighbors_message
    call print_string
    mov r14, [r12 + 32]
    mov r15, [r14]
    add r14, 8
.expected_element:
    test r15, r15
    jz .close_sequence
    mov rdi, [r14]
    call print_number
    add r14, 8
    dec r15
    jz .close_sequence
    mov rdi, comma_message
    call print_string
    jmp .expected_element
.close_sequence:
    mov rdi, close_message
    call print_string
.case_message:
    mov rdi, case_message
    call print_string
    mov rdi, [rbx]
    call print_string
    mov rdi, newline
    call print_string
    xor eax, eax
    add rsp, 8
    ret

mutate_copy:
    ; Only the independently returned, already validated copy is modified.
    mov rax, [last_result]
    mov qword [rax + NeighborNode.label], 99
    mov eax, 1
    ret

observe_saved:
    mov rax, saved_result
    mov r10, graph_get_neighbors_name
    jmp execute_operation

saved_result:
    mov rax, [saved_neighbors]
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
