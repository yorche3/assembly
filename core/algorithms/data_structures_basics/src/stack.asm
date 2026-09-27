; stack.asm
; Stack: LIFO over the shared Node using a single top pointer.

%include "data_structures_basics.inc"

section .text
    global stack_init, stack_push, stack_pop, stack_peek, stack_is_empty
    global stack_size
    extern node_create

; ============================================================
; stack_init: empty stack
; Arguments: rdi = Stack *
; ============================================================
stack_init:
    mov qword [rdi + Stack.top], ABSENT
    mov qword [rdi + Stack.count], 0
    ret

; ============================================================
; stack_is_empty
; Arguments: rdi = const Stack *
; Returns: rax = 1 when empty, 0 otherwise
; ============================================================
stack_is_empty:
    xor eax, eax
    cmp qword [rdi + Stack.count], 0
    sete al
    ret

; ============================================================
; stack_size
; Arguments: rdi = const Stack *
; Returns: rax = element count
; ============================================================
stack_size:
    mov rax, [rdi + Stack.count]
    ret

; ============================================================
; stack_push: place the value on top
; Arguments: rdi = Stack *, rsi = value
; ============================================================
stack_push:
    push rbx
    mov rbx, rdi
    mov rdi, rsi
    call node_create
    test rax, rax
    jz .done
    mov rdx, [rbx + Stack.top]
    mov [rax + Node.next], rdx
    mov [rbx + Stack.top], rax
    inc qword [rbx + Stack.count]
.done:
    pop rbx
    ret

; ============================================================
; stack_peek: observe the top value without removing it
; Arguments: rdi = const Stack *
; Returns: rax = value, or FAILURE when the stack is empty
; ============================================================
stack_peek:
    mov rdx, [rdi + Stack.top]
    test rdx, rdx
    jz .empty
    mov rax, [rdx + Node.value]
    ret
.empty:
    mov rax, FAILURE
    ret

; ============================================================
; stack_pop: remove and return the top value
; Arguments: rdi = Stack *
; Returns: rax = value, or FAILURE when the stack is empty
; ============================================================
stack_pop:
    mov rdx, [rdi + Stack.top]
    test rdx, rdx
    jz .empty
    mov rax, [rdx + Node.value]
    mov rcx, [rdx + Node.next]
    mov [rdi + Stack.top], rcx
    dec qword [rdi + Stack.count]
    ret
.empty:
    mov rax, FAILURE
    ret
