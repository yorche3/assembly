; alloc.asm
; Heap for the module: a bump allocator on top of the brk syscall.
; There is no release: the contract has no destroy operation, so a node that
; leaves a structure is never reused and the heap only grows.

section .bss
    alloc_next resq 1       ; next free byte (0 until the first allocation)
    alloc_end  resq 1       ; current program break

section .text
    global alloc_bytes

; ============================================================
; alloc_bytes: reserve size bytes, aligned to 16
; Arguments: rdi = size in bytes
; Returns: rax = pointer, or 0 when the kernel refuses to grow the heap
; ============================================================
alloc_bytes:
    push rbx
    add rdi, 15
    and rdi, -16            ; round the request up to a 16-byte boundary
    mov rbx, rdi

    cmp qword [alloc_next], 0
    jne .have_room
    call .read_break

.have_room:
    mov rax, [alloc_next]
    lea rdx, [rax + rbx]
    cmp rdx, [alloc_end]
    jbe .take

    ; The block does not fit: move the break past it, with a margin so that
    ; every allocation does not cost a system call.
    mov rdi, rdx
    add rdi, 65536
    mov rax, 12             ; sys_brk
    syscall
    cmp rax, rdx
    jb .no_memory
    mov [alloc_end], rax
    mov rax, [alloc_next]

.take:
    mov [alloc_next], rdx
    pop rbx
    ret

.no_memory:
    xor eax, eax
    pop rbx
    ret

; ============================================================
; read_break: read the current program break (brk(0) does not move it)
; ============================================================
.read_break:
    mov rax, 12             ; sys_brk
    xor rdi, rdi
    syscall
    mov [alloc_next], rax
    mov [alloc_end], rax
    ret
