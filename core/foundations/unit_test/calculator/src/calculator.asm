section .text
global addition_function, subtraction_function, multiplication_function, division_function, modulus_function

; addition(a, b) -> returns a + b
; Arguments: rdi = a, rsi = b
; Returns: rax = a + b
addition_function:
    mov rax, rdi        ; Move first argument (a) into rax
    add rax, rsi        ; Add second argument (b) to rax
    ret

; subtraction(a, b) -> returns a - b
; Arguments: rdi = a, rsi = b
; Returns: rax = a - b
subtraction_function:
    mov rax, rdi        ; Move first argument (a) into rax
    sub rax, rsi        ; Subtract second argument (b) from rax
    ret

; multiplication(a, b) -> returns a * b (implemented as repeated addition)
; Arguments: rdi = a, rsi = b
; Returns: rax = a * b
multiplication_function:
    xor rax, rax        ; Initialize result to 0
    mov rcx, rsi        ; Use rsi (b) as loop counter
    cmp rcx, 0          ; Check if counter is zero
    je .done            ; If b == 0, result is already 0
.loop:
    add rax, rdi        ; Add a to result
    dec rcx             ; Decrement counter
    jnz .loop           ; Continue loop if counter is not zero
.done:
    ret

; division(a, b) -> returns a // b (implemented as repeated subtraction)
; Arguments: rdi = a, rsi = b
; Returns: rax = quotient (a // b)
division_function:
    xor rax, rax        ; Initialize quotient to 0
    cmp rsi, 0          ; Check for division by zero
    je .error           ; If b == 0, error (return -1 as sentinel)
.loop:
    cmp rdi, rsi        ; Compare a with b
    jl .done            ; If a < b, we're done
    sub rdi, rsi        ; a = a - b
    inc rax             ; quotient++
    jmp .loop           ; Repeat
.error:
    mov rax, -1         ; Return -1 to indicate division by zero
.done:
    ret

; modulus(a, b) -> returns a % b (implemented using division and multiplication)
; Arguments: rdi = a, rsi = b
; Returns: rax = a % b
modulus_function:
    ; Save original a and b (division will modify rdi)
    push rdi            ; Save a
    push rsi            ; Save b

    ; q = division(a, b) -> rax = q
    call division_function
    mov rcx, rax        ; rcx = q (quotient)

    ; Check if division returned -1 (error)
    cmp rcx, -1
    je .error_restore

    ; Restore original a and b (for use in multiplication and final subtraction)
    pop rsi             ; Restore b
    pop rdi             ; Restore a

    ; Save a again for the final subtraction
    push rdi            ; Save a

    ; p = multiplication(q, b)
    ; rdi = q, rsi = b
    push rsi            ; Save b (again)
    mov rdi, rcx        ; rdi = q
    call multiplication_function  ; rax = p = q * b
    mov rcx, rax        ; rcx = p
    pop rsi             ; Clean stack (b no longer needed)

    ; Restore original a
    pop rdi             ; rdi = original a

    ; return a - p
    sub rdi, rcx        ; rdi = a - p
    mov rax, rdi        ; rax = a - p
    ret

.error_restore:
    ; Clean up stack on error
    pop rsi
    pop rdi
    mov rax, -1         ; Return -1 to indicate error
    ret
