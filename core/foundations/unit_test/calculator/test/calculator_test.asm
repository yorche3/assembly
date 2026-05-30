; calculator_test.asm
; Unit tests for the Calculator module
; Tests: addition, subtraction, multiplication, division, modulus

section .data
    test_passed_msg db "  PASSED: ", 0
    test_failed_msg db "  FAILED: ", 0
    test_addition_msg db "test_addition", 0
    test_subtraction_msg db "test_subtraction", 0
    test_multiplication_msg db "test_multiplication", 0
    test_division_msg db "test_division", 0
    test_modulus_msg db "test_modulus", 0
    newline db 10, 0

    ; Test results
    tests_total dq 0
    tests_passed dq 0
    tests_failed dq 0

section .text
extern addition_function, subtraction_function, multiplication_function, division_function, modulus_function
extern calculate_string_length, print_string, print_number
global run_all_tests, test_addition, test_subtraction, test_multiplication, test_division, test_modulus

; ============================================================
; Helper macro to print a string
; ============================================================
%macro print_str 1
    mov rdi, %1
    call print_string
%endmacro

; ============================================================
; Macro: run_test test_name, test_function
; ============================================================
%macro run_test 2
    inc qword [tests_total]
    call %2
    cmp rax, 0
    je .pass_%2
    ; Failed
    print_str test_failed_msg
    print_str %1
    print_str newline
    inc qword [tests_failed]
    jmp .done_%2
.pass_%2:
    print_str test_passed_msg
    print_str %1
    print_str newline
    inc qword [tests_passed]
.done_%2:
%endmacro

; ============================================================
; run_all_tests: Entry point to run all tests
; Returns: rax = 0 if all passed, 1 if any failed
; ============================================================
run_all_tests:
    push rbp
    mov rbp, rsp

    ; Initialize counters
    mov qword [tests_total], 0
    mov qword [tests_passed], 0
    mov qword [tests_failed], 0

    ; Run each test
    run_test test_addition_msg, test_addition
    run_test test_subtraction_msg, test_subtraction
    run_test test_multiplication_msg, test_multiplication
    run_test test_division_msg, test_division
    run_test test_modulus_msg, test_modulus

    ; Print summary
    print_str newline
    print_str test_passed_msg
    mov rdi, [tests_passed]
    call print_number
    print_str newline
    print_str test_failed_msg
    mov rdi, [tests_failed]
    call print_number
    print_str newline

    ; Return status
    mov rax, [tests_failed]
    cmp rax, 0
    je .all_pass
    mov rax, 1
    jmp .done
.all_pass:
    xor rax, rax
.done:
    pop rbp
    ret

; ============================================================
; test_addition: Tests addition(2, 3) == 5
; Returns: rax = 0 if pass, 1 if fail
; ============================================================
test_addition:
    push rbp
    mov rbp, rsp

    mov rdi, 2
    mov rsi, 3
    call addition_function
    cmp rax, 5
    jne .fail
    
    xor rax, rax
    jmp .done
.fail:
    mov rax, 1
.done:
    pop rbp
    ret

; ============================================================
; test_subtraction: Tests subtraction(5, 2) == 3
; Returns: rax = 0 if pass, 1 if fail
; ============================================================
test_subtraction:
    push rbp
    mov rbp, rsp

    mov rdi, 5
    mov rsi, 2
    call subtraction_function
    cmp rax, 3
    jne .fail
    
    xor rax, rax
    jmp .done
.fail:
    mov rax, 1
.done:
    pop rbp
    ret

; ============================================================
; test_multiplication: Tests multiplication(3, 4) == 12
; Returns: rax = 0 if pass, 1 if fail
; ============================================================
test_multiplication:
    push rbp
    mov rbp, rsp

    mov rdi, 3
    mov rsi, 4
    call multiplication_function
    cmp rax, 12
    jne .fail

    ; Also test multiplication by zero: multiplication(5, 0) == 0
    mov rdi, 5
    mov rsi, 0
    call multiplication_function
    cmp rax, 0
    jne .fail
    
    xor rax, rax
    jmp .done
.fail:
    mov rax, 1
.done:
    pop rbp
    ret

; ============================================================
; test_division: Tests division(10, 3) == 3
; Returns: rax = 0 if pass, 1 if fail
; ============================================================
test_division:
    push rbp
    mov rbp, rsp

    mov rdi, 10
    mov rsi, 3
    call division_function
    cmp rax, 3
    jne .fail
    
    xor rax, rax
    jmp .done
.fail:
    mov rax, 1
.done:
    pop rbp
    ret

; ============================================================
; test_modulus: Tests modulus(10, 3) == 1
; Returns: rax = 0 if pass, 1 if fail
; ============================================================
test_modulus:
    push rbp
    mov rbp, rsp

    mov rdi, 10
    mov rsi, 3
    call modulus_function
    cmp rax, 1
    jne .fail
    
    xor rax, rax
    jmp .done
.fail:
    mov rax, 1
.done:
    pop rbp
    ret
