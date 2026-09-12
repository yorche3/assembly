; bubble_sort_tests.asm
; Runs the shared Naive_Sort cases against Bubble_Sort

section .data
    header_msg db "=== Bubble Sort Tests ===", 0

section .text
    extern bubble_sort, run_naive_sort_cases
    global run_bubble_sort_tests

run_bubble_sort_tests:
    push rbp
    mov rbp, rsp
    mov rdi, bubble_sort
    mov rsi, header_msg
    call run_naive_sort_cases
    pop rbp
    ret
