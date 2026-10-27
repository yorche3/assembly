section .bss
    number_buffer resb 21

section .data
    global tests_total, tests_passed, tests_failed
    tests_total dq 0
    tests_passed dq 0
    tests_failed dq 0
    total_message db "tests run ", 0
    passed_message db "passed ", 0
    failed_message db "failed ", 0
    newline db 10, 0

section .text
    global print_string, print_number, assert, print_summary

print_string:
    mov rsi, rdi
    xor edx, edx
.length:
    cmp byte [rsi + rdx], 0
    je .write
    inc rdx
    jmp .length
.write:
    mov eax, 1
    mov edi, 1
    syscall
    ret

print_number:
    lea rsi, [number_buffer + 20]
    mov byte [rsi], 0
    mov rax, rdi
    xor r9d, r9d
    mov r8d, 10
    test rax, rax
    jns .convert
    neg rax
    mov r9d, 1
.convert:
    dec rsi
    xor edx, edx
    div r8
    add dl, '0'
    mov [rsi], dl
    test rax, rax
    jnz .convert
    test r9, r9
    jz .print
    dec rsi
    mov byte [rsi], '-'
.print:
    mov rdi, rsi
    jmp print_string

assert:
    cmp rdi, rsi
    sete al
    movzx eax, al
    ret

print_summary:
    sub rsp, 8
    mov rdi, total_message
    call print_string
    mov rdi, [tests_total]
    call print_number
    mov rdi, newline
    call print_string
    mov rdi, passed_message
    call print_string
    mov rdi, [tests_passed]
    call print_number
    mov rdi, newline
    call print_string
    mov rdi, failed_message
    call print_string
    mov rdi, [tests_failed]
    call print_number
    mov rdi, newline
    call print_string
    add rsp, 8
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
