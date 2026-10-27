; alloc.asm
; Montículo del módulo: asignador de avance sobre la llamada al sistema `brk`.
; No hay liberación: el contrato no tiene operación de destrucción, así que un
; nodo que sale de una estructura nunca se reutiliza y el montículo solo crece.
; Consecuencia para los tests: cada módulo de prueba gasta memoria del proceso
; y no la devuelve; es el precio de no tener `free` en este contrato.

section .bss
    alloc_next resq 1       ; next free byte (0 until the first allocation)
    alloc_end  resq 1       ; current program break

section .text
    global alloc_bytes

; ============================================================
; alloc_bytes: reserva `size` bytes alineados a 16
; Argumentos: rdi = tamaño en bytes
; Devuelve: rax = puntero, o 0 cuando el núcleo no concede más montículo
; ============================================================
alloc_bytes:
    push rbx
    add rdi, 15
    and rdi, -16            ; redondea la petición a un múltiplo de 16
    mov rbx, rdi

    cmp qword [alloc_next], 0
    jne .have_room
    call .read_break

.have_room:
    mov rax, [alloc_next]
    lea rdx, [rax + rbx]
    cmp rdx, [alloc_end]
    jbe .take

    ; El bloque no cabe: se mueve el final del montículo más allá, con un
    ; margen, para que no cada asignación cueste una llamada al sistema.
    mov rdi, rdx
    add rdi, 65536          ; margen para amortizar las llamadas siguientes
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
; read_break: lee el final actual del montículo (brk(0) no lo mueve)
; ============================================================
.read_break:
    mov rax, 12             ; sys_brk
    xor rdi, rdi
    syscall
    mov [alloc_next], rax
    mov [alloc_end], rax
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
