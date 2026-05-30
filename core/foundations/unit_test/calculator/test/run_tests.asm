; run_tests.asm
; Entry point that runs all unit tests for the Calculator module
; Uses shared print utilities from print_utils.asm

section .data
    header db "=== Calculator Unit Tests ===", 10, 0
    newline db 10, 0

section .text
    global _start
    extern run_all_tests, print_string

; ============================================================
; _start: Entry point
; ============================================================
_start:
    ; Print header
    mov rdi, header
    call print_string

    ; Run all tests
    call run_all_tests
    mov r12, rax        ; Save exit code

    ; Print final newline
    mov rdi, newline
    call print_string

    ; Exit with status code
    mov rax, 60         ; sys_exit
    mov rdi, r12        ; exit code
    syscall
