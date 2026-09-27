section .data
    header db "=== LinkedList Tests ===", 10, 0
    test_passed_message db "  PASSED: ", 0
    test_failed_message db "  FAILED: ", 0
    newline db 10, 0

    empty_state_name db "empty state", 0
    insert_both_ends_name db "insert at both ends", 0
    delete_first_name db "delete first occurrence", 0
    absent_value_name db "absent value", 0
    empty_list_name db "empty the list", 0

    tail_ten_input dq 10
    tail_twenty_input dq 20
    head_five_input dq 5
    absent_value_input dq 99
    empty_output dq 1
    nonempty_output dq 0
    zero_output dq 0
    head_five_output dq 5
    head_twenty_output dq 20
    head_ten_output dq 10
    size_four_output dq 4
    size_three_output dq 3
    success_output dq 1
    failure_output dq -1

section .bss
    linked_list_fixture resq 3

section .text
    extern linked_list_init, linked_list_get_head, linked_list_insert_head
    extern linked_list_insert_tail, linked_list_delete, linked_list_is_empty, linked_list_size
    extern print_string, assert, tests_total, tests_passed, tests_failed
    %include "test_macros.inc"
    global run_linked_list_tests

run_linked_list_tests:
    print_str header
    run_test empty_state_name, test_empty_state
    run_test insert_both_ends_name, test_insert_both_ends
    run_test delete_first_name, test_delete_first_occurrence
    run_test absent_value_name, test_absent_value
    run_test empty_list_name, test_empty_list
    print_str newline
    ret

test_empty_state:
    mov rdi, linked_list_fixture
    call linked_list_init
    mov rdi, linked_list_fixture
    call linked_list_is_empty
    assert_result empty_output, .fail
    mov rdi, linked_list_fixture
    call linked_list_size
    assert_result zero_output, .fail
    mov rdi, linked_list_fixture
    call linked_list_get_head
    assert_result failure_output, .fail
    mov rax, 1
    ret
.fail:
    xor rax, rax
    ret

test_insert_both_ends:
    mov rdi, linked_list_fixture
    mov rsi, [tail_ten_input]
    call linked_list_insert_tail
    mov rdi, linked_list_fixture
    mov rsi, [tail_twenty_input]
    call linked_list_insert_tail
    mov rdi, linked_list_fixture
    mov rsi, [head_five_input]
    call linked_list_insert_head
    mov rdi, linked_list_fixture
    mov rsi, [tail_ten_input]
    call linked_list_insert_tail
    mov rdi, linked_list_fixture
    call linked_list_size
    assert_result size_four_output, .fail
    mov rdi, linked_list_fixture
    call linked_list_get_head
    assert_result head_five_output, .fail
    mov rax, 1
    ret
.fail:
    xor rax, rax
    ret

test_delete_first_occurrence:
    mov rdi, linked_list_fixture
    mov rsi, [tail_ten_input]
    call linked_list_delete
    assert_result success_output, .fail
    mov rdi, linked_list_fixture
    call linked_list_get_head
    assert_result head_five_output, .fail
    mov rdi, linked_list_fixture
    call linked_list_size
    assert_result size_three_output, .fail
    mov rax, 1
    ret
.fail:
    xor rax, rax
    ret

test_absent_value:
    mov rdi, linked_list_fixture
    mov rsi, [absent_value_input]
    call linked_list_delete
    assert_result failure_output, .fail
    mov rdi, linked_list_fixture
    call linked_list_get_head
    assert_result head_five_output, .fail
    mov rdi, linked_list_fixture
    call linked_list_size
    assert_result size_three_output, .fail
    mov rax, 1
    ret
.fail:
    xor rax, rax
    ret

test_empty_list:
    mov rdi, linked_list_fixture
    mov rsi, [head_five_input]
    call linked_list_delete
    assert_result success_output, .fail
    mov rdi, linked_list_fixture
    call linked_list_get_head
    assert_result head_twenty_output, .fail
    mov rdi, linked_list_fixture
    mov rsi, [tail_twenty_input]
    call linked_list_delete
    assert_result success_output, .fail
    mov rdi, linked_list_fixture
    call linked_list_get_head
    assert_result head_ten_output, .fail
    mov rdi, linked_list_fixture
    mov rsi, [tail_ten_input]
    call linked_list_delete
    assert_result success_output, .fail
    mov rdi, linked_list_fixture
    call linked_list_is_empty
    assert_result empty_output, .fail
    mov rdi, linked_list_fixture
    call linked_list_size
    assert_result zero_output, .fail
    mov rdi, linked_list_fixture
    call linked_list_get_head
    assert_result failure_output, .fail
    mov rax, 1
    ret
.fail:
    xor rax, rax
    ret
