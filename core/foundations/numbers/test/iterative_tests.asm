; iterative_tests.asm
; Tests for the Iterative Numbers module
; Uses: test_utils.asm (assert, print_string) + test_macros.inc

section .data
    header_msg      db "=== Iterative Tests ===", 10, 0
    test_passed_msg db "  PASSED: ", 0
    test_failed_msg db "  FAILED: ", 0
    newline         db 10, 0

    ; Test names
    test_sum_0      db "sum_of_first_n_ite(0)", 0
    test_sum_3      db "sum_of_first_n_ite(3)", 0
    test_fact_0     db "factorial_ite(0)", 0
    test_fact_4     db "factorial_ite(4)", 0
    test_fib_0      db "fibonacci_ite(0)", 0
    test_fib_1      db "fibonacci_ite(1)", 0
    test_fib_6      db "fibonacci_ite(6)", 0
    test_gcd_12_8   db "greatest_common_divisor_ite(12, 8)", 0
    test_gcd_7_5    db "greatest_common_divisor_ite(7, 5)", 0
    test_lcm_4_6    db "least_common_multiple_ite(4, 6)", 0
    test_lcm_6_8    db "least_common_multiple_ite(6, 8)", 0

section .text
    extern sum_of_first_n_ite, factorial_ite, fibonacci_ite
    extern greatest_common_divisor_ite, least_common_multiple_ite
    extern print_string, assert, tests_total, tests_passed, tests_failed
    %include "test_macros.inc"
    global run_iterative_tests

; ============================================================
; run_iterative_tests: Run all iterative tests
; ============================================================
run_iterative_tests:
    push rbp
    mov rbp, rsp
    print_str header_msg
    run_test test_sum_0,    test_sum_of_first_n_ite_0
    run_test test_sum_3,    test_sum_of_first_n_ite_3
    run_test test_fact_0,   test_factorial_ite_0
    run_test test_fact_4,   test_factorial_ite_4
    run_test test_fib_0,    test_fibonacci_ite_0
    run_test test_fib_1,    test_fibonacci_ite_1
    run_test test_fib_6,    test_fibonacci_ite_6
    run_test test_gcd_12_8, test_gcd_ite_12_8
    run_test test_gcd_7_5,  test_gcd_ite_7_5
    run_test test_lcm_4_6,  test_lcm_ite_4_6
    run_test test_lcm_6_8,  test_lcm_ite_6_8
    print_str newline
    pop rbp
    ret

; ============================================================
; Individual test functions
; Each calls function under test, then assert(result, expected)
; Returns: rax = 1 if pass, 0 if fail (from assert)
; ============================================================

test_sum_of_first_n_ite_0:
    mov rdi, 0
    call sum_of_first_n_ite
    mov rdi, rax
    mov rsi, 0
    call assert
    ret

test_sum_of_first_n_ite_3:
    mov rdi, 3
    call sum_of_first_n_ite
    mov rdi, rax
    mov rsi, 6
    call assert
    ret

test_factorial_ite_0:
    mov rdi, 0
    call factorial_ite
    mov rdi, rax
    mov rsi, 1
    call assert
    ret

test_factorial_ite_4:
    mov rdi, 4
    call factorial_ite
    mov rdi, rax
    mov rsi, 24
    call assert
    ret

test_fibonacci_ite_0:
    mov rdi, 0
    call fibonacci_ite
    mov rdi, rax
    mov rsi, 0
    call assert
    ret

test_fibonacci_ite_1:
    mov rdi, 1
    call fibonacci_ite
    mov rdi, rax
    mov rsi, 1
    call assert
    ret

test_fibonacci_ite_6:
    mov rdi, 6
    call fibonacci_ite
    mov rdi, rax
    mov rsi, 8
    call assert
    ret

test_gcd_ite_12_8:
    mov rdi, 12
    mov rsi, 8
    call greatest_common_divisor_ite
    mov rdi, rax
    mov rsi, 4
    call assert
    ret

test_gcd_ite_7_5:
    mov rdi, 7
    mov rsi, 5
    call greatest_common_divisor_ite
    mov rdi, rax
    mov rsi, 1
    call assert
    ret

test_lcm_ite_4_6:
    mov rdi, 4
    mov rsi, 6
    call least_common_multiple_ite
    mov rdi, rax
    mov rsi, 12
    call assert
    ret

test_lcm_ite_6_8:
    mov rdi, 6
    mov rsi, 8
    call least_common_multiple_ite
    mov rdi, rax
    mov rsi, 24
    call assert
    ret
