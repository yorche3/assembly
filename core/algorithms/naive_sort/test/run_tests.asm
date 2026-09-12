; run_tests.asm
; Entry point that runs all test suites for the Naive_Sort module
; Executes: selection, bubble, and insertion sort test suites

section .data
    header db "=== Naive Sort Module Tests ===", 10, 0
    newline db 10, 0

section .text
    global _start
    extern run_selection_sort_tests, run_bubble_sort_tests, run_insertion_sort_tests
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

    ; Run all three algorithm test suites
    call run_selection_sort_tests
    call run_bubble_sort_tests
    call run_insertion_sort_tests

    ; Print final summary (tests runned, passed, failed)
    call print_summary

    ; Exit with failure count as status code
    mov rax, 60         ; sys_exit
    mov rdi, [tests_failed]
    syscall
