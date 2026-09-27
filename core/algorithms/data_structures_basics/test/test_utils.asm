section .bss
    number_buffer resb 21

section .data
    global tests_total, tests_passed, tests_failed
    tests_total  dq 0
    tests_passed dq 0
    tests_failed dq 0

    tests_run_message db "tests run ", 0
    passed_message    db "passed ", 0
    failed_message    db "failed ", 0
    newline           db 10, 0

section .text
    global print_string, print_number, assert
    global init_test_counters, print_summary

print_string:
    push rdi
    xor rdx, rdx
.length:
    cmp byte [rdi + rdx], 0
    je .write
    inc rdx
    jmp .length
.write:
    mov rsi, rdi
    mov rax, 1
    mov rdi, 1
    syscall
    pop rdi
    ret

print_number:
    lea rsi, [number_buffer + 20]
    mov byte [rsi], 0
    mov rax, rdi
    xor rcx, rcx
    mov r8, 10
    test rax, rax
    jns .convert
    neg rax
    mov cl, 1
.convert:
    dec rsi
    xor rdx, rdx
    div r8
    add dl, '0'
    mov [rsi], dl
    test rax, rax
    jnz .convert
    test rcx, rcx
    jz .print
    dec rsi
    mov byte [rsi], '-'
.print:
    mov rdi, rsi
    call print_string
    ret

assert:
    cmp rdi, rsi
    sete al
    movzx rax, al
    ret

init_test_counters:
    mov qword [tests_total], 0
    mov qword [tests_passed], 0
    mov qword [tests_failed], 0
    ret

print_summary:
    mov rdi, tests_run_message
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
    ret
