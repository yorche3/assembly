; linked_list.asm
; LinkedList: singly linked sequence with head, tail and count.
; It shares Node with Stack and Queue; it does not wrap another structure.

%include "data_structures_basics.inc"

section .text
    global linked_list_init, linked_list_get_head, linked_list_insert_head
    global linked_list_insert_tail, linked_list_delete, linked_list_is_empty
    global linked_list_size
    extern node_create

; ============================================================
; linked_list_init: empty list
; Arguments: rdi = LinkedList *
; ============================================================
linked_list_init:
    mov qword [rdi + LinkedList.head], ABSENT
    mov qword [rdi + LinkedList.tail], ABSENT
    mov qword [rdi + LinkedList.count], 0
    ret

; ============================================================
; linked_list_is_empty
; Arguments: rdi = const LinkedList *
; Returns: rax = 1 when empty, 0 otherwise
; ============================================================
linked_list_is_empty:
    xor eax, eax
    cmp qword [rdi + LinkedList.count], 0
    sete al
    ret

; ============================================================
; linked_list_size
; Arguments: rdi = const LinkedList *
; Returns: rax = element count
; ============================================================
linked_list_size:
    mov rax, [rdi + LinkedList.count]
    ret

; ============================================================
; linked_list_get_head: value of the head node
; Arguments: rdi = const LinkedList *
; Returns: rax = value, or FAILURE when the list is empty
; ============================================================
linked_list_get_head:
    mov rdx, [rdi + LinkedList.head]
    test rdx, rdx
    jz .empty
    mov rax, [rdx + Node.value]
    ret
.empty:
    mov rax, FAILURE
    ret

; ============================================================
; linked_list_insert_head
; Arguments: rdi = LinkedList *, rsi = value
; ============================================================
linked_list_insert_head:
    push rbx
    mov rbx, rdi
    mov rdi, rsi
    call node_create
    test rax, rax
    jz .done
    mov rdx, [rbx + LinkedList.head]
    mov [rax + Node.next], rdx
    mov [rbx + LinkedList.head], rax
    cmp qword [rbx + LinkedList.tail], ABSENT
    jne .count
    mov [rbx + LinkedList.tail], rax
.count:
    inc qword [rbx + LinkedList.count]
.done:
    pop rbx
    ret

; ============================================================
; linked_list_insert_tail
; Arguments: rdi = LinkedList *, rsi = value
; ============================================================
linked_list_insert_tail:
    push rbx
    mov rbx, rdi
    mov rdi, rsi
    call node_create
    test rax, rax
    jz .done
    mov rdx, [rbx + LinkedList.tail]
    test rdx, rdx
    jnz .append
    mov [rbx + LinkedList.head], rax
    mov [rbx + LinkedList.tail], rax
    jmp .count
.append:
    mov [rdx + Node.next], rax
    mov [rbx + LinkedList.tail], rax
.count:
    inc qword [rbx + LinkedList.count]
.done:
    pop rbx
    ret

; ============================================================
; linked_list_delete: remove the first occurrence of value
; Arguments: rdi = LinkedList *, rsi = value
; Returns: rax = 1 on success, FAILURE when the value is not in the list
; ============================================================
linked_list_delete:
    mov rax, [rdi + LinkedList.head]    ; current
    xor rcx, rcx                        ; previous
.loop:
    test rax, rax
    jz .not_found
    cmp [rax + Node.value], rsi
    je .found
    mov rcx, rax
    mov rax, [rax + Node.next]
    jmp .loop
.found:
    mov rdx, [rax + Node.next]
    test rcx, rcx
    jnz .link_previous
    mov [rdi + LinkedList.head], rdx
    jmp .tail
.link_previous:
    mov [rcx + Node.next], rdx
.tail:
    cmp [rdi + LinkedList.tail], rax
    jne .count
    mov [rdi + LinkedList.tail], rcx
.count:
    dec qword [rdi + LinkedList.count]
    mov rax, 1
    ret
.not_found:
    mov rax, FAILURE
    ret
