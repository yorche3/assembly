section .data
    header db "=== Data Structures Advanced Module Tests ===", 10, 0

section .text
    global _start
    extern print_string, print_summary, tests_failed
    extern run_data_structures_advanced_tests

_start:
    mov rdi, header
    call print_string
    call run_data_structures_advanced_tests
    call print_summary
    mov rdi, [tests_failed]
    mov eax, 60
    syscall

section .note.GNU-stack noalloc noexec nowrite progbits