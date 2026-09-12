.section .text
    global _start

; Insertion sort function
; Input: RDI - pointer to the array
;        RSI - length of the array
; Output: RAX - 0 if the array is null, otherwise undefined
; clobbers: rax, rbx -> temp, rcx -> key, rdx , r8 -> i, r9 -> j
insertion_sort:
    test    rdi, rdi    ; Check if the array pointer is null
    jz      .array_null

    cmp     rsi, 2      ; Check if the array length is less than 2
    jl      .done

    xor     r8, r8      ; i = 1 -- for i = 1 to n-1
    inc     r8

.outer_loop:
    cmp     r8, rsi
    jge     .done       ; if i >= n, we are done with sorting

    mov     rcx, [rdi + r8*8]   ; key = array[i]
    mov     r9, r8
    dec     r9
.inner_loop:
    cmp     r9, -1
    jle     .insert_key
    mov     rax, [rdi + r9*8]
    cmp     rax, rcx
    jle     .insert_key
    mov     [rdi + (r9+1)*8], rax
    dec     r9
    jmp     .inner_loop
.insert_key:
    mov     [rdi + (r9+1)*8], rcx
    inc     r8
    jmp     .outer_loop

.array_null:
    xor     rax, rax    ; return 0 if the array is null
.done:
    ret