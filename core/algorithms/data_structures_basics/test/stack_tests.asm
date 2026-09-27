section .data
    header db "=== Stack Tests ===", 10, 0
    test_passed_message db "  PASSED: ", 0
    test_failed_message db "  FAILED: ", 0
    newline db 10, 0

    empty_state_name db "empty state and failed removal", 0
    lifo_peek_name db "LIFO and non-mutating peek", 0
    removal_reuse_name db "removal and reuse", 0
    empty_after_removal_name db "empty after removal", 0

    ten_input dq 10
    twenty_input dq 20
    thirty_input dq 30
    forty_input dq 40
    empty_output dq 1
    zero_output dq 0
    size_three_output dq 3
    ten_output dq 10
    twenty_output dq 20
    thirty_output dq 30
    forty_output dq 40
    failure_output dq -1

section .bss
    stack_fixture resq 2

section .text
    extern stack_init, stack_push, stack_pop, stack_peek, stack_is_empty, stack_size
    extern print_string, assert, tests_total, tests_passed, tests_failed
    %include "test_macros.inc"
    global run_stack_tests

run_stack_tests:
    print_str header
    run_test empty_state_name, test_empty_state
    run_test lifo_peek_name, test_lifo_peek
    run_test removal_reuse_name, test_removal_reuse
    run_test empty_after_removal_name, test_empty_after_removal
    print_str newline
    ret

test_empty_state:
    mov rdi, stack_fixture
    call stack_init
    mov rdi, stack_fixture
    call stack_is_empty
    assert_result empty_output, .fail
    mov rdi, stack_fixture
    call stack_size
    assert_result zero_output, .fail
    mov rdi, stack_fixture
    call stack_peek
    assert_result failure_output, .fail
    mov rdi, stack_fixture
    call stack_pop
    assert_result failure_output, .fail
    mov rax, 1
    ret
.fail:
    xor rax, rax
    ret

test_lifo_peek:
    mov rdi, stack_fixture
    mov rsi, [ten_input]
    call stack_push
    mov rdi, stack_fixture
    mov rsi, [twenty_input]
    call stack_push
    mov rdi, stack_fixture
    mov rsi, [thirty_input]
    call stack_push
    mov rdi, stack_fixture
    call stack_peek
    assert_result thirty_output, .fail
    mov rdi, stack_fixture
    call stack_size
    assert_result size_three_output, .fail
    mov rax, 1
    ret
.fail:
    xor rax, rax
    ret

test_removal_reuse:
    mov rdi, stack_fixture
    call stack_pop
    assert_result thirty_output, .fail
    mov rdi, stack_fixture
    mov rsi, [forty_input]
    call stack_push
    mov rdi, stack_fixture
    call stack_pop
    assert_result forty_output, .fail
    mov rdi, stack_fixture
    call stack_pop
    assert_result twenty_output, .fail
    mov rdi, stack_fixture
    call stack_pop
    assert_result ten_output, .fail
    mov rdi, stack_fixture
    call stack_is_empty
    assert_result empty_output, .fail
    mov rdi, stack_fixture
    call stack_size
    assert_result zero_output, .fail
    mov rax, 1
    ret
.fail:
    xor rax, rax
    ret

test_empty_after_removal:
    mov rdi, stack_fixture
    call stack_pop
    assert_result failure_output, .fail
    mov rdi, stack_fixture
    call stack_is_empty
    assert_result empty_output, .fail
    mov rax, 1
    ret
.fail:
    xor rax, rax
    ret
