; node.asm
; Node: the module's single linked-cell type.
; The three structures share this node and its four contract operations.

%include "data_structures_basics.inc"

section .text
    global node_init, node_get_value, node_get_next, node_set_next
    global node_create
    extern alloc_bytes

; ============================================================
; node_init: store the value and leave the link absent
; Arguments: rdi = Node *, rsi = value
; ============================================================
node_init:
    mov [rdi + Node.value], rsi
    mov qword [rdi + Node.next], ABSENT
    ret

; ============================================================
; node_get_value: read the stored value
; Arguments: rdi = const Node *
; Returns: rax = value
; ============================================================
node_get_value:
    mov rax, [rdi + Node.value]
    ret

; ============================================================
; node_get_next: read the link
; Arguments: rdi = const Node *
; Returns: rax = Node * (0 when absent)
; ============================================================
node_get_next:
    mov rax, [rdi + Node.next]
    ret

; ============================================================
; node_set_next: replace the link
; Arguments: rdi = Node *, rsi = Node *
; ============================================================
node_set_next:
    mov [rdi + Node.next], rsi
    ret

; ============================================================
; node_create: allocate a node on the heap and initialise it
; Arguments: rdi = value
; Returns: rax = Node * (0 when the heap cannot grow)
; Not part of the contract: it is the allocation step shared by the
; inserting operations of LinkedList, Stack and Queue.
; ============================================================
node_create:
    push rbx
    mov rbx, rdi
    mov rdi, Node_size
    call alloc_bytes
    test rax, rax
    jz .done
    mov [rax + Node.value], rbx
    mov qword [rax + Node.next], ABSENT
.done:
    pop rbx
    ret
