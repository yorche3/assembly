; run_tests.asm
; Entry point that runs all test suites for the Numbers module
; Executes: recursive, recursive_with_accumulator, and iterative test suites

section .data
    header db "=== Numbers Module Tests ===", 10, 0
    newline db 10, 0

section .text
    global _start
    extern run_recursive_tests, run_recursive_with_acc_tests, run_iterative_tests
    extern print_string, init_test_counters, print_summary, tests_failed

; ============================================================
; _start: Entry point
; ============================================================
_start:
    ; Initialize global test counters
    call init_test_counters

    ; Print header
    mov rdi, header
    call print_string
    mov rdi, newline
    call print_string

    ; Run all three test suites
    call run_recursive_tests
    call run_recursive_with_acc_tests
    call run_iterative_tests

    ; Print final summary (tests runned, passed, failed)
    call print_summary

    ; Exit with failure count as status code
    mov rax, 60         ; sys_exit
    mov rdi, [tests_failed]
    syscall
