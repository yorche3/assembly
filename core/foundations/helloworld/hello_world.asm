section .data
    msg db 'Hello, World! from Assembly', 0xA  ; message with newline
    len equ $ - msg              ; length of message

section .text
    global _start

_start:
    ; write syscall
    mov eax, 1        ; syscall number (sys_write)
    mov edi, 1        ; file descriptor (stdout)
    mov rsi, msg      ; message to write
    mov edx, len      ; message length
    syscall

    ; exit syscall
    mov eax, 60       ; syscall number (sys_exit)
    xor rdi, rdi      ; exit code 0
    syscall