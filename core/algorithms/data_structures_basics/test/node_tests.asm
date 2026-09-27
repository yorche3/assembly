section .data
    header db "=== Node Tests ===", 10, 0
    test_passed_message db "  PASSED: ", 0
    test_failed_message db "  FAILED: ", 0
    newline db 10, 0

    initialize_observe_name db "initialize and observe value/link", 0
    link_traverse_name db "initialize another node, link and traverse", 0

    initialize_input dq 10
    link_input dq 20
    initialize_value_output dq 10
    link_value_output dq 20
    absent_next_output dq 0

section .bss
    initialize_node resq 2
    linked_node resq 2

section .text
    extern node_init, node_get_value, node_get_next, node_set_next
    extern print_string, assert, tests_total, tests_passed, tests_failed
    %include "test_macros.inc"
    global run_node_tests

run_node_tests:
    print_str header
    run_test initialize_observe_name, test_initialize_and_observe
    run_test link_traverse_name, test_link_and_traverse
    print_str newline
    ret

test_initialize_and_observe:
    mov rdi, initialize_node
    mov rsi, [initialize_input]
    call node_init

    mov rdi, initialize_node
    call node_get_value
    assert_result initialize_value_output, .fail

    mov rdi, initialize_node
    call node_get_next
    assert_result absent_next_output, .fail

    mov rax, 1
    ret
.fail:
    xor rax, rax
    ret

test_link_and_traverse:
    mov rdi, linked_node
    mov rsi, [link_input]
    call node_init

    mov rdi, initialize_node
    mov rsi, linked_node
    call node_set_next

    mov rdi, initialize_node
    call node_get_next
    mov rdi, rax
    call node_get_value
    assert_result link_value_output, .fail

    mov rdi, linked_node
    call node_get_next
    assert_result absent_next_output, .fail

    mov rax, 1
    ret
.fail:
    xor rax, rax
    ret
