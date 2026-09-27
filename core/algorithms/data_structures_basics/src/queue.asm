; queue.asm
; Queue: FIFO over the shared Node using front and rear pointers.

%include "data_structures_basics.inc"

section .text
    global queue_init, queue_enqueue, queue_dequeue, queue_peek, queue_is_empty
    global queue_size
    extern node_create

; ============================================================
; queue_init: empty queue
; Arguments: rdi = Queue *
; ============================================================
queue_init:
    mov qword [rdi + Queue.front], ABSENT
    mov qword [rdi + Queue.rear], ABSENT
    mov qword [rdi + Queue.count], 0
    ret

; ============================================================
; queue_is_empty
; Arguments: rdi = const Queue *
; Returns: rax = 1 when empty, 0 otherwise
; ============================================================
queue_is_empty:
    xor eax, eax
    cmp qword [rdi + Queue.count], 0
    sete al
    ret

; ============================================================
; queue_size
; Arguments: rdi = const Queue *
; Returns: rax = element count
; ============================================================
queue_size:
    mov rax, [rdi + Queue.count]
    ret

; ============================================================
; queue_enqueue: add the value after rear
; Arguments: rdi = Queue *, rsi = value
; ============================================================
queue_enqueue:
    push rbx
    mov rbx, rdi
    mov rdi, rsi
    call node_create
    test rax, rax
    jz .done
    mov rdx, [rbx + Queue.rear]
    test rdx, rdx
    jnz .append
    mov [rbx + Queue.front], rax
    jmp .rear
.append:
    mov [rdx + Node.next], rax
.rear:
    mov [rbx + Queue.rear], rax
    inc qword [rbx + Queue.count]
.done:
    pop rbx
    ret

; ============================================================
; queue_peek: observe the front value without removing it
; Arguments: rdi = const Queue *
; Returns: rax = value, or FAILURE when the queue is empty
; ============================================================
queue_peek:
    mov rdx, [rdi + Queue.front]
    test rdx, rdx
    jz .empty
    mov rax, [rdx + Node.value]
    ret
.empty:
    mov rax, FAILURE
    ret

; ============================================================
; queue_dequeue: remove and return the front value
; Arguments: rdi = Queue *
; Returns: rax = value, or FAILURE when the queue is empty
; ============================================================
queue_dequeue:
    mov rdx, [rdi + Queue.front]
    test rdx, rdx
    jz .empty
    mov rax, [rdx + Node.value]
    mov rcx, [rdx + Node.next]
    mov [rdi + Queue.front], rcx
    test rcx, rcx
    jnz .count
    mov qword [rdi + Queue.rear], ABSENT  ; the queue became empty
.count:
    dec qword [rdi + Queue.count]
    ret
.empty:
    mov rax, FAILURE
    ret
