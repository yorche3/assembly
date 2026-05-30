section .text
global sum_of_first_n_ite, factorial_ite, fibonacci_ite, greatest_common_divisor_ite, least_common_multiple_ite

;; sum_of_first_n(n) -> returns the sum of the first n natural numbers (n*(n+1))/2
;; Arguments: rdi = n
;; Returns: rax = sum of the first n natural numbers
sum_of_first_n_ite:
    mov rax, 0       ; initialize accumulator to 0
    cmp rdi, 0       ; check if n is less than or equal to 0
    jle .base_zero   ; if n <= 0, return 0
    ;; iterative loop: sum_of_first_n(n)
.loop:
    add rax, rdi     ; add n to accumulator
    dec rdi          ; decrement n by 1
    cmp rdi, 0       ; check if n is less than or equal to 0
    jg .loop         ; if n > 0, jump to .loop
.base_zero:
    ret              ; return from the function

;; factorial(n) -> returns the factorial of n
;; Arguments: rdi = n
;; Returns: rax = factorial of n
factorial_ite:
    mov rax, 1       ; initialize accumulator to 1
    cmp rdi, 1       ; check if n is less than or equal to 1
    jle .base_one    ; if n <= 1, return 1
    ;; iterative loop: factorial(n)
.loop:
    imul rax, rdi    ; multiply accumulator by n
    dec rdi          ; decrement n by 1
    cmp rdi, 1       ; check if n is less than or equal to 1
    jg .loop         ; if n > 1, jump to .loop
.base_one:
    ret              ; return from the function

;; fibonacci(n) -> returns the nth Fibonacci number
;; Arguments: rdi = n
;; Returns: rax = nth Fibonacci number
;; Pseudocode:
;;   if n <= 1: return n
;;   acc2 = 0; acc1 = 1
;;   for i = 2 to n:
;;     temp = acc1 + acc2
;;     acc2 = acc1
;;     acc1 = temp
;;   return acc1
fibonacci_ite:
    cmp rdi, 0       ; check if n <= 0
    jle .base_zero   ; if n <= 0, return 0
    cmp rdi, 1       ; check if n == 1
    je .base_one     ; if n == 1, return 1
    mov rsi, 0       ; acc2 = fib(0) = 0
    mov rdx, 1       ; acc1 = fib(1) = 1
.loop:
    mov rax, rdx     ; rax = acc1
    add rax, rsi     ; rax = acc1 + acc2 (temp)
    mov rsi, rdx     ; acc2 = old acc1
    mov rdx, rax     ; acc1 = temp
    dec rdi          ; n--
    cmp rdi, 1       ; compare n with 1
    jg .loop         ; if n > 1, continue loop
    mov rax, rdx     ; return acc1
    ret
.base_zero:
    mov rax, 0
    ret
.base_one:
    mov rax, 1
    ret


;; greatest_common_divisor(a, b) -> returns the greatest common divisor of a and b
;; Arguments: rdi = a, rsi = b
;; Returns: rax = greatest common divisor of a and b
greatest_common_divisor_ite:
    ;; check if b is equal to 0
    cmp rsi, 0       ; compare b with 0
    je .base          ; if b == 0, return a
.loop:
    mov rax, rdi     ; rax = a (dividend)  <- FIX: was missing!
    xor rdx, rdx     ; clear high part of dividend
    div rsi          ; rdx = a % b (remainder)
    mov rdi, rsi     ; rdi = b (new first argument)
    mov rsi, rdx     ; rsi = a % b (new second argument)
    cmp rsi, 0       ; check if b == 0
    jg .loop         ; if b > 0, continue loop
.base:
    mov rax, rdi     ; return a
    ret

;; least_common_multiple(a, b) -> returns the least common multiple of a and b
;; Arguments: rdi = a, rsi = b
;; Returns: rax = least common multiple of a and b
least_common_multiple_ite:
    push rdi         ; save a on the stack
    push rsi         ; save b on the stack
    call greatest_common_divisor_ite
    pop rsi          ; restore b
    pop rdi          ; restore a
    ;; calculate lcm using the formula: (a / gcd) * b
    mov rbx, rax     ; rbx = gcd(a, b)
    mov rax, rdi     ; rax = a
    xor rdx, rdx     ; clear high part of dividend
    div rbx          ; rax = a / gcd
    imul rax, rsi    ; rax = (a / gcd) * b
    ret              ; return from the function