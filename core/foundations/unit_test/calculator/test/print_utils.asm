; print_utils.asm
; Shared utility functions for string and number output
; Used by: calculator_test.asm, run_tests.asm

section .bss
    num_str resb 20     ; Buffer for number-to-string conversion

section .text
    global print_string, print_number, calculate_string_length

; ============================================================
; print_string: Print a null-terminated string
; Arguments: rdi = pointer to string
; ============================================================
print_string:
    push rbp
    mov rbp, rsp
    push rsi
    push rdx
    push rcx

    call calculate_string_length
    mov rdx, rax        ; length
    mov rax, 1          ; sys_write
    mov rsi, rdi        ; buffer
    mov rdi, 1          ; stdout
    syscall

    pop rcx
    pop rdx
    pop rsi
    pop rbp
    ret

; ============================================================
; calculate_string_length: Get length of null-terminated string
; Arguments: rdi = pointer to string
; Returns: rax = length
; ============================================================
calculate_string_length:
    push rdi
    xor rax, rax
    mov rcx, -1
    repne scasb
    not rcx
    dec rcx
    mov rax, rcx
    pop rdi
    ret

; ============================================================
; print_number: Print an integer
; Arguments: rdi = integer to print
; ============================================================
print_number:
    push rbp
    mov rbp, rsp
    push rdi
    push rsi
    push rdx
    push rcx
    push r8

    ; Convert integer to string
    mov rax, [rbp - 8]  ; Get back the number (into rax for division)
    lea rsi, [num_str + 19]  ; Point to end of buffer
    mov byte [rsi], 0   ; Null terminator
    mov rcx, 10         ; Base 10
    xor r8, r8          ; Sign flag

    ; Handle negative numbers
    cmp rax, 0
    jge .convert_loop
    neg rax
    mov r8, 1           ; Remember it's negative

.convert_loop:
    dec rsi
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rsi], dl
    test rax, rax
    jnz .convert_loop

    ; Add negative sign if needed
    test r8, r8
    jz .print
    dec rsi
    mov byte [rsi], '-'

.print:
    ; Print the number
    push rsi
    mov rdi, rsi
    call print_string
    pop rsi

    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rbp
    ret
