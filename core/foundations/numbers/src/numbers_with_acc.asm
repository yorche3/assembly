section .text
global sum_of_first_n_acc, factorial_acc, fibonacci_acc, greatest_common_divisor_acc, least_common_multiple_acc

;; sum_of_first_n(n) -> returns the sum of the first n natural numbers (n*(n+1))/2
;; Arguments: rdi = n
;; Returns: rax = sum of the first n natural numbers
sum_of_first_n_acc:
    mov rsi, 0       ; initialize accumulator to 0
    jmp sum_of_first_n_acc_help

;; sum_of_first_n_acc_help(n, acc) -> returns the sum of the first n natural numbers using accumulator
;; Arguments: rdi = n, rsi = accumulator
;; Returns: rax = sum of the first n natural numbers
sum_of_first_n_acc_help:
    ;; check if n is less than or equal to 0
    cmp rdi, 0       ; compare n with 0
    jle .base_zero   ; if n <= 0, return accumulator
    ;; add n to accumulator
    add rsi, rdi     ; rax = accumulator + n
    ;; decrement n by 1
    dec rdi          ; decrement n by 1
    ;; jump to the loop
    jmp sum_of_first_n_acc_help
.base_zero:
    mov rax, rsi     ; return accumulator
    ret              ; return from the function

;; factorial_acc(n) -> returns the factorial of n using accumulator
;; Arguments: rdi = n
;; Returns: rax = factorial of n
factorial_acc:
    mov rsi, 1       ; initialize accumulator to 1
    jmp factorial_acc_help

;; factorial_acc_help(n, accumulator) -> returns the factorial of n using accumulator
;; Arguments: rdi = n, rsi = accumulator
;; Returns: rax = factorial of n
factorial_acc_help:
    ;; check if n is less than or equal to 1
    cmp rdi, 1       ; compare n with 1
    jle .base_one    ; if n <= 1, return accumulator
    ;; multiply accumulator by n
    imul rsi, rdi    ; rax = accumulator * n
    ;; decrement n by 1
    dec rdi          ; decrement n by 1
    ;; jump to the loop
    jmp factorial_acc_help
.base_one:
    mov rax, rsi     ; return accumulator
    ret              ; return from the function

;; fibonacci_acc(n) -> returns the nth number in the Fibonacci sequence using accumulator
;; Arguments: rdi = n
;; Returns: rax = nth number in the Fibonacci sequence
;; Pseudocode:
;;   fibonacci_acc_help(n, acc2=0, acc1=1)
;;     if n <= 0: return acc2
;;     if n <= 2: return acc1 + acc2
;;     return fibonacci_acc_help(n-1, acc1, acc1 + acc2)
fibonacci_acc:
    mov rsi, 0       ; acc2 = fib(0) = 0
    mov rdx, 1       ; acc1 = fib(1) = 1
    jmp fibonacci_acc_help

;; fibonacci_acc_help(n, acc2, acc1) -> returns the nth Fibonacci number
;; Arguments: rdi = n, rsi = acc2 (fib(k)), rdx = acc1 (fib(k+1))
;; Returns: rax = nth number in the Fibonacci sequence
fibonacci_acc_help:
    ;; check if n is less than or equal to 0
    cmp rdi, 0       ; compare n with 0
    jle .base_zero   ; if n <= 0, return acc2
    ;; check if n is less than or equal to 2
    cmp rdi, 2       ; compare n with 2
    jle .base_one_two ; if n <= 2, return acc1 + acc2
    ;; recursive step: shift accumulators
    mov rax, rdx     ; rax = acc1
    add rax, rsi     ; rax = acc1 + acc2 (new acc1)
    mov rsi, rdx     ; acc2 = old acc1
    mov rdx, rax     ; acc1 = old acc1 + old acc2
    dec rdi          ; decrement n by 1
    jmp fibonacci_acc_help
.base_zero:
    mov rax, rsi     ; return acc2
    ret
.base_one_two:
    mov rax, rdx
    add rax, rsi     ; return acc1 + acc2
    ret

;; greatest_common_divisor_acc(a, b) -> returns the greatest common divisor of a and b using accumulator
;; Arguments: rdi = a, rsi = b
;; Returns: rax = greatest common divisor of a and b
greatest_common_divisor_acc:
    jmp greatest_common_divisor_acc_help

;; greatest_common_divisor_acc_help(a, b, acc) -> returns the greatest common divisor of a and b using accumulator
;; Arguments: rdi = a, rsi = b, rcx = acc
;; Returns: rax = greatest common divisor of a and b using accumulator
greatest_common_divisor_acc_help:
    ;; check if b is zero
    cmp rsi, 0       ; compare b with 0
    jle .base         ; if b <= 0, return accumulator
    ;; compute a % b and call gcd(b, a%b)
    mov rax, rdi     ; rax = a (dividend)
    xor rdx, rdx     ; clear high part of dividend
    div rsi          ; rdx = a % b (remainder)
    mov rdi, rsi     ; rdi = b (new first argument)
    mov rsi, rdx     ; rsi = a % b (new second argument)
    ;; recursive call: greatest_common_divisor_acc_help(b, a%b, a%b)
    jmp greatest_common_divisor_acc_help
.base:
    mov rax, rdi     ; return a
    ret              ; return from the function

;; least_common_multiple(a, b) -> returns the least common multiple of a and b
;; Arguments: rdi = a, rsi = b
;; Returns: rax = least common multiple of a and b
least_common_multiple_acc:
    push rdi         ; save a on the stack
    push rsi         ; save b on the stack
    call greatest_common_divisor_acc
    pop rsi          ; restore b
    pop rdi          ; restore a
    ;; calculate lcm using the formula: (a / gcd) * b
    mov rbx, rax     ; rbx = gcd(a, b)
    mov rax, rdi     ; rax = a
    xor rdx, rdx     ; clear high part of dividend
    div rbx          ; rax = a / gcd
    imul rax, rsi    ; rax = (a / gcd) * b
    ret              ; return from the function