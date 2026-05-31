section .bss
    name resb 64          ; reserve 64 bytes for name input

section .data
    prompt db 'Enter your name: ', 0xA
    prompt_len equ $ - prompt
    greeting db 'Hello, ', 0
    greeting_len equ $ - greeting
    newline db 0xA
    space   db ' ', 0

section .text
    global _start

_start:
    ; print prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; read input
    mov rax, 0
    mov rdi, 0
    mov rsi, name
    mov rdx, 64
    syscall
    mov rbx, rax        ; save number of bytes read in rbx

    ; remove trailing newline if present
    dec rbx             ; last byte index
    mov rsi, name
    add rsi, rbx
    mov al, byte [rsi]
    cmp al, 0xA
    jne skip_newline
    mov byte [rsi], 0

skip_newline:
    ; print greeting
    mov rax, 1
    mov rdi, 1
    mov rsi, greeting
    mov rdx, greeting_len
    syscall

    ; print name
    mov rax, 1
    mov rdi, 1
    mov rsi, name
    mov rdx, rbx        ; number of bytes to print
    syscall

    ; print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall