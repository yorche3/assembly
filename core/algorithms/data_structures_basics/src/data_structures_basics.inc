; Data Structures Basics contract for the System V AMD64 ABI.
; Shared header: the structures and the macros, included by every file of src/.
; Pointers use 0 for absence. Value-returning failed operations use -1.
;
; The list below is the module's public surface; each file of src/ declares in
; its own `global` the operations it implements.

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

; node_init(Node *node, int64_t value)
; node_get_value(const Node *node) -> int64_t
; node_get_next(const Node *node) -> Node * (0 when absent)
; node_set_next(Node *node, Node *next)
;   -> src/node.asm

; linked_list_init(LinkedList *list)
; linked_list_get_head(const LinkedList *list) -> int64_t (-1 when empty)
; linked_list_insert_head(LinkedList *list, int64_t value)
; linked_list_insert_tail(LinkedList *list, int64_t value)
; linked_list_delete(LinkedList *list, int64_t value) -> int64_t (1 or -1)
; linked_list_is_empty(const LinkedList *list) -> int64_t (0 or 1)
; linked_list_size(const LinkedList *list) -> int64_t
;   -> src/linked_list.asm

; stack_init(Stack *stack)
; stack_push(Stack *stack, int64_t value)
; stack_pop(Stack *stack) -> int64_t (-1 when empty)
; stack_peek(const Stack *stack) -> int64_t (-1 when empty)
; stack_is_empty(const Stack *stack) -> int64_t (0 or 1)
; stack_size(const Stack *stack) -> int64_t
;   -> src/stack.asm

; queue_init(Queue *queue)
; queue_enqueue(Queue *queue, int64_t value)
; queue_dequeue(Queue *queue) -> int64_t (-1 when empty)
; queue_peek(const Queue *queue) -> int64_t (-1 when empty)
; queue_is_empty(const Queue *queue) -> int64_t (0 or 1)
; queue_size(const Queue *queue) -> int64_t
;   -> src/queue.asm
