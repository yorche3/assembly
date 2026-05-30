section .text
global sum_of_first_n_rec, factorial_rec, fibonacci_rec, greatest_common_divisor_rec, least_common_multiple_rec

;; sum_of_first_n(n) -> returns the sum of the first n natural numbers (n*(n+1))/2
;; Arguments: rdi = n
;; Returns: rax = sum of the first n natural numbers
sum_of_first_n_rec:
    push rbp         ; save base pointer
    mov rbp, rdi     ; set base pointer to n
    cmp rdi, 0       ; check if n is less than or equal to 0
    jle .base_zero   ; if n <= 0, return 0
    ;; recursive call: sum_of_first_n(n-1)
    push rdi         ; save n on the stack
    dec rdi          ; decrement n by
    call sum_of_first_n_rec
    pop rdi          ; restore n from the stack
    add rax, rdi     ; add the result of the recursive call to rax
    jmp .done        ; jump to .done
.base_zero:
    mov rax, 0       ; if n <= 0, return 0
.done:
    pop rbp          ; restore base pointer
    ret              ; return from the function

;; factorial(n) -> returns the factorial of n
;; Arguments: rdi = n
;; Returns: rax = factorial of n
factorial_rec:
    push rbp         ; save base pointer
    mov rbp, rdi     ; set base pointer to n
    cmp rdi, 1       ; check if n is less than or equal to 1
    jle .base_one    ; if n <= 1, return 1
    ;; recursive call: factorial(n-1)
    push rdi         ; save n on the stack
    dec rdi          ; decrement n by
    call factorial_rec
    pop rdi          ; restore n from the stack
    imul rax, rdi     ; multiply the result of the recursive call to rax
    jmp .done        ; jump to .done
.base_one:
    mov rax, 1       ; if n <= 1, return 1
.done:
    pop rbp          ; restore base pointer
    ret              ; return from the function

;; fibonacci(n) -> returns the nth number in the Fibonacci sequence
;; Arguments: rdi = n
;; Returns: rax = nth number in the Fibonacci sequence
fibonacci_rec:
    push rbp         ; save base pointer
    mov rbp, rdi     ; set base pointer to n
    cmp rdi, 0       ; check if n is less than or equal to 0
    jle .base_zero   ; if n <= 0, return 0
    cmp rdi, 1
    je .base_one    ; if n == 1, return 1
    ;; recursive call: fibonacci(n-1)
    push rdi         ; save n on the stack
    dec rdi          ; decrement n by 1
    call fibonacci_rec
    pop rdi          ; restore n from the stack
    mov rbx, rax     ; save fib(n-1) in rbx
    ;; recursive call: fibonacci(n-2)
    push rdi         ; save n on the stack again
    dec rdi          ; decrement n by 1
    dec rdi          ; decrement n by 1 again (n-2)
    push rbx         ; preserve rbx across the recursive call
    call fibonacci_rec
    pop rbx          ; restore rbx = fib(n-1)
    pop rdi          ; clean up stack
    add rax, rbx     ; fib(n-2) + fib(n-1)
    jmp .done        ; jump to .done
.base_zero:
    mov rax, 0       ; if n <= 0, return 0
    jmp .done        ; jump to done (avoid fall-through)
.base_one:
    mov rax, 1       ; if n == 1, return 1
.done:
    pop rbp          ; restore base pointer
    ret              ; return from the function

;; greatest_common_divisor(a, b) -> returns the greatest common divisor of a and b
;; Arguments: rdi = a, rsi = b
;; Returns: rax = greatest common divisor of a and b
greatest_common_divisor_rec:
    push rbp         ; save base pointer
    mov rbp, rsp     ; set base pointer to stack pointer
    ;; check if b is zero
    cmp rsi, 0       ; compare b with 0
    jle .base         ; if b <= 0, return a
    ;; compute a % b and call gcd(b, a%%b)
    mov rax, rdi     ; rax = a (dividend)
    xor rdx, rdx     ; clear high part of dividend
    div rsi          ; rdx = a % b (remainder)
    mov rdi, rsi     ; rdi = b (new first argument)
    mov rsi, rdx     ; rsi = a % b (new second argument)
    call greatest_common_divisor_rec
    jmp .done        ; jump to done
.base:
    mov rax, rdi     ; return a
.done:
    pop rbp          ; restore base pointer
    ret              ; return from the function

;; least_common_multiple(a, b) -> returns the least common multiple of a and b
;; Arguments: rdi = a, rsi = b
;; Returns: rax = least common multiple of a and b
least_common_multiple_rec:
    push rbp         ; save base pointer
    mov rbp, rsp     ; set base pointer to stack pointer
    ;; save a and b on the stack
    push rdi         ; save a
    push rsi         ; save b
    call greatest_common_divisor_rec
    pop rsi          ; restore b
    pop rdi          ; restore a
    ;; calculate lcm using the formula: (a / gcd) * b
    mov rbx, rax     ; rbx = gcd(a, b)
    mov rax, rdi     ; rax = a
    xor rdx, rdx     ; clear high part of dividend
    div rbx          ; rax = a / gcd
    imul rax, rsi    ; rax = (a / gcd) * b
    pop rbp          ; restore base pointer
    ret              ; return from the function
    
