.section .text
    global _start

; Selection sort function
; Input: RDI - pointer to the array
;        RSI - length of the array
; Output: RAX - 0 if the array is null, otherwise undefined
; clobbers: rax, rbx -> temp, rcx -> min_index, rdx, r8 -> i, r9 -> j
selection_sort:
    test    rdi, rdi    ; Check if the array pointer is null
    jz      .array_null

    cmp     rsi, 2      ; Check if the array length is less than 2
    jl      .done

    xor     r8, r8      ; i = 0 -- for i = 0 to n-2
    mov     rcx, rsi
    sub     rcx, 2      ; n - 2
.outer_loop:
    cmp     r8, rcx
    jg      .done       ; if i > n - 2, we are done with sorting

    mov     r9, r8      ; j = i + 1
    inc     r9
    mov     rdx, r8     ; min_index = i
.inner_loop:
    cmp     r9, rsi
    jge     .swap_min
    mov     rax, [rdi + r9*8]
    mov     rbx, [rdi + rdx*8]
    cmp     rax, rbx
    jge     .no_update_min
    mov     rdx, r9
.no_update_min:
    inc     r9
    jmp     .inner_loop
.swap_min:
    cmp     rdx, r8
    je      .outer_loop_continue
    mov     rax, [rdi + r8*8]
    mov     rbx, [rdi + rdx*8]
    mov     [rdi + r8*8], rbx
    mov     [rdi + rdx*8], rax
.outer_loop_continue:
    inc     r8
    jmp     .outer_loop

.array_null:
    xor     rax, rax    ; return 0 if the array is null
.done:
    ret