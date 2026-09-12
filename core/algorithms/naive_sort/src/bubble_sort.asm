section .text

; Bubble sort function
; Input: RDI - pointer to the array
;        RSI - length of the array
; Output: RAX - same pointer as RDI, array sorted ascending in place.
;         RAX - 0 if the array is null (failure indicator).
; clobbers: rax, rbx (saved/restored), r8 -> i, r9 -> j, r10 -> swapped, rcx -> n - 2, rdx -> n - 1 - i
global bubble_sort
bubble_sort:
    test    rdi, rdi    ; Check if the array pointer is null
    jz      .array_null

    push    rbx

    cmp     rsi, 2      ; Check if the array length is less than 2
    jl      .done

    ; Bubble sort implementation
    xor     r8, r8      ; i = 0 -- for i = 0 to n-2

    mov     rcx, rsi
    sub     rcx, 2      ; n - 2
.outer_loop:
    cmp     r8, rcx
    jg      .done       ; if i > n - 2, we are done with sorting

    xor     r10, r10    ; swapped = false -- r10 used, not esi/rsi (rsi holds length)

    xor     r9, r9      ; j = 0 -- for j = 0 to n - 2 - i
.inner_loop:
    mov     rdx, rsi
    sub     rdx, 2
    sub     rdx, r8     ; n - 2 - i
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
    mov     r10, 1  ; swapped = true
.no_swap:
    inc     r9
    jmp     .inner_loop
.outer_loop_continue:
    test    r10, r10
    jz      .done       ; no swaps this pass, already sorted
    inc     r8
    jmp     .outer_loop
.done:
    pop     rbx
    mov     rax, rdi
    ret
.array_null:
    xor     rax, rax    ; return 0 if the array is null
    ret

