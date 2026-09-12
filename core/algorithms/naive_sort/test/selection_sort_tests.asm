; selection_sort_tests.asm
; Runs the shared Naive_Sort cases against Selection_Sort

section .data
    header_msg db "=== Selection Sort Tests ===", 0

section .text
    extern selection_sort, run_naive_sort_cases
    global run_selection_sort_tests

run_selection_sort_tests:
    push rbp
    mov rbp, rsp
    mov rdi, selection_sort
    mov rsi, header_msg
    call run_naive_sort_cases
    pop rbp
    ret
