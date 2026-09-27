; run_tests.asm
; Entry point that runs all test suites for the Data Structures Basics module
; Executes: node, linked list, stack and queue test suites

section .data
    header db "=== Data Structures Basics Module Tests ===", 10, 0
    newline db 10, 0

section .text
    global _start
    extern run_node_tests, run_linked_list_tests, run_stack_tests, run_queue_tests
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

    ; Run the four ADT suites, in the order the specification presents them
    call run_node_tests
    call run_linked_list_tests
    call run_stack_tests
    call run_queue_tests

    ; Print final summary (tests run, passed, failed)
    call print_summary

    ; Exit with the failure count as the status code
    mov rax, 60         ; sys_exit
    mov rdi, [tests_failed]
    syscall
