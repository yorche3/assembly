; insertion_sort_tests.asm
; Runs the shared Naive_Sort cases against Insertion_Sort

section .data
    header_msg db "=== Insertion Sort Tests ===", 0

section .text
    extern insertion_sort, run_naive_sort_cases
    global run_insertion_sort_tests

run_insertion_sort_tests:
    push rbp
    mov rbp, rsp
    mov rdi, insertion_sort
    mov rsi, header_msg
    call run_naive_sort_cases
    pop rbp
    ret
