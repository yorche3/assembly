.section .text
    global _start

; Bubble sort function
; Input: RDI - pointer to the array
;        RSI - length of the array
; Output: RAX - 0 if the array is null, otherwise undefined
; clobbers: rax, r8 -> i, r9 -> j, esi -> swapped, rcx -> n - 2, rdx -> n - 1 - i
bubble_sort:
    test    rdi, rdi    ; Check if the array pointer is null
    jz      .array_null

    cmp     rsi, 2      ; Check if the array length is less than 2
    jl      .done

    ; Bubble sort implementation
    xor     r8, r8      ; i = 0 -- for i = 0 to n-2

    mov     rcx, rsi
    sub     rcx, 2      ; n - 2
.outer_loop:
    cmp     r8, rcx
    jg      .done       ; if i > n - 2, we are done with sorting
    
    xor     esi, esi    ; swapped = false

    xor     r9, r9      ; j = 0 -- for j = 0 to n - 1 - i
.inner_loop:
    mov     rdx, rsi
    sub     rdx, 1
    sub     rdx, r8     ; n - 1 - i
    cmp     r9, rdx
    jg      .outer_loop_continue

    ; Compare array[j] and array[j+1]
    mov     rax, [rdi + r9*8]
    mov     rbx, [rdi + r9*8 + 8]
    cmp     rax, rbx
    jle     .no_swap
    ; Swap array[j] and array[j+1]
    mov     [rdi + r9*8], rbx
    mov     [rdi + r9*8 + 8], rax
    mov     esi, 1  ; swapped = true
.no_swap:
    inc     r9
    jmp     .inner_loop
.outer_loop_continue:
    inc     r8
    jmp     .outer_loop
.array_null:
    xor     rax, rax    ; return 0 if the array is null
.done:
    ret

