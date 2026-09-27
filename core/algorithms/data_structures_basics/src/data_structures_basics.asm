; Data Structures Basics contract for the System V AMD64 ABI.
; Pointers use 0 for absence. Value-returning failed operations use -1.

%define FAILURE -1
%define ABSENT  0

struc Node
    .value: resq 1
    .next:  resq 1
endstruc

struc LinkedList
    .head:  resq 1
    .tail:  resq 1
    .count: resq 1
endstruc

struc Stack
    .top:   resq 1
    .count: resq 1
endstruc

struc Queue
    .front: resq 1
    .rear:  resq 1
    .count: resq 1
endstruc

section .text

; node_init(Node *node, int64_t value)
; node_get_value(const Node *node) -> int64_t
; node_get_next(const Node *node) -> Node * (0 when absent)
; node_set_next(Node *node, Node *next)
global node_init, node_get_value, node_get_next, node_set_next

; linked_list_init(LinkedList *list)
; linked_list_get_head(const LinkedList *list) -> int64_t (-1 when empty)
; linked_list_insert_head(LinkedList *list, int64_t value)
; linked_list_insert_tail(LinkedList *list, int64_t value)
; linked_list_delete(LinkedList *list, int64_t value) -> int64_t (1 or -1)
; linked_list_is_empty(const LinkedList *list) -> int64_t (0 or 1)
; linked_list_size(const LinkedList *list) -> int64_t
global linked_list_init, linked_list_get_head, linked_list_insert_head
global linked_list_insert_tail, linked_list_delete, linked_list_is_empty
global linked_list_size

; stack_init(Stack *stack)
; stack_push(Stack *stack, int64_t value)
; stack_pop(Stack *stack) -> int64_t (-1 when empty)
; stack_peek(const Stack *stack) -> int64_t (-1 when empty)
; stack_is_empty(const Stack *stack) -> int64_t (0 or 1)
; stack_size(const Stack *stack) -> int64_t
global stack_init, stack_push, stack_pop, stack_peek, stack_is_empty, stack_size

; queue_init(Queue *queue)
; queue_enqueue(Queue *queue, int64_t value)
; queue_dequeue(Queue *queue) -> int64_t (-1 when empty)
; queue_peek(const Queue *queue) -> int64_t (-1 when empty)
; queue_is_empty(const Queue *queue) -> int64_t (0 or 1)
; queue_size(const Queue *queue) -> int64_t
global queue_init, queue_enqueue, queue_dequeue, queue_peek, queue_is_empty, queue_size
