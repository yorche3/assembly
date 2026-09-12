; test_utils.asm
; Shared utility functions for the Naive_Sort test suites
; Includes: print utilities, assert (int/pointer), assert_array,
;           copy_qwords (fixture protection), counters, summary

section .bss
    num_str resb 20     ; Buffer for number-to-string conversion

section .data
    global tests_total, tests_passed, tests_failed
    tests_total  dq 0
    tests_passed dq 0
    tests_failed dq 0

section .text
    global print_string, print_number, calculate_string_length
    global init_test_counters, print_summary, print_newline
    global assert, assert_array, copy_qwords

; ============================================================
; print_string: Print a null-terminated string
; Arguments: rdi = pointer to string
; ============================================================
print_string:
    push rbp
    mov rbp, rsp
    push rsi
    push rdx
    push rcx

    call calculate_string_length
    mov rdx, rax        ; length
    mov rax, 1          ; sys_write
    mov rsi, rdi        ; buffer
    mov rdi, 1          ; stdout
    syscall

    pop rcx
    pop rdx
    pop rsi
    pop rbp
    ret

; ============================================================
; calculate_string_length: Get length of null-terminated string
; Arguments: rdi = pointer to string
; Returns: rax = length
; ============================================================
calculate_string_length:
    push rdi
    xor rax, rax
    mov rcx, -1
    repne scasb
    not rcx
    dec rcx
    mov rax, rcx
    pop rdi
    ret

; ============================================================
; print_number: Print an integer
; Arguments: rdi = integer to print
; ============================================================
print_number:
    push rbp
    mov rbp, rsp
    push rdi
    push rsi
    push rdx
    push rcx
    push r8

    mov rax, [rbp - 8]  ; original rdi (the integer to print)
    lea rsi, [num_str + 19]
    mov byte [rsi], 0
    mov rcx, 10
    xor r8, r8

    cmp rax, 0
    jge .convert_loop
    neg rax
    mov r8, 1

.convert_loop:
    dec rsi
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rsi], dl
    test rax, rax
    jnz .convert_loop

    test r8, r8
    jz .print
    dec rsi
    mov byte [rsi], '-'

.print:
    push rsi
    mov rdi, rsi
    call print_string
    pop rsi

    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rbp
    ret

; ============================================================
; assert: Compare two integer/pointer values
; Arguments: rdi = actual, rsi = expected
; Returns: rax = 1 if equal (pass), 0 if different (fail)
; Used for the empty-array (pointer identity) and null-pointer
; failure-indicator cases, where there is nothing to compare
; element-wise.
; ============================================================
assert:
    push rbx
    mov rax, rdi
    mov rbx, rsi
    cmp rax, rbx
    sete al
    movzx rax, al
    pop rbx
    ret

; ============================================================
; assert_array: Compare two qword arrays element-wise
; Arguments: rdi = actual array ptr, rsi = expected array ptr,
;            rdx = element count
; Returns: rax = 1 if all elements are equal, 0 otherwise
; ============================================================
assert_array:
    push rbx
    push rcx
    xor rcx, rcx
.loop:
    cmp rcx, rdx
    jge .pass
    mov rax, [rdi + rcx*8]
    mov rbx, [rsi + rcx*8]
    cmp rax, rbx
    jne .fail
    inc rcx
    jmp .loop
.pass:
    mov rax, 1
    jmp .done
.fail:
    xor rax, rax
.done:
    pop rcx
    pop rbx
    ret

; ============================================================
; copy_qwords: Copy a fixture array into a scratch buffer, so
;   that in-place sort functions never mutate the shared
;   read-only fixtures used across the three algorithms.
; Arguments: rdi = destination ptr, rsi = source ptr, rdx = count
; ============================================================
copy_qwords:
    push rcx
    xor rcx, rcx
.loop:
    cmp rcx, rdx
    jge .done
    mov rax, [rsi + rcx*8]
    mov [rdi + rcx*8], rax
    inc rcx
    jmp .loop
.done:
    pop rcx
    ret

; ============================================================
; init_test_counters: Reset counters to zero
; ============================================================
init_test_counters:
    mov qword [tests_total], 0
    mov qword [tests_passed], 0
    mov qword [tests_failed], 0
    ret

; ============================================================
; print_summary: Print final test summary
; Format: "tests runned X\npassed Y\nfailed Z\n"
; ============================================================
print_summary:
    push rbp
    mov rbp, rsp
    push rdi

    mov rdi, summary_line1
    call print_string
    mov rdi, [tests_total]
    call print_number
    call print_newline

    mov rdi, summary_line2
    call print_string
    mov rdi, [tests_passed]
    call print_number
    call print_newline

    mov rdi, summary_line3
    call print_string
    mov rdi, [tests_failed]
    call print_number
    call print_newline

    pop rdi
    pop rbp
    ret

; ============================================================
; print_newline: Print a newline
; ============================================================
print_newline:
    push rdi
    mov rdi, newline_str
    call print_string
    pop rdi
    ret

section .data
    summary_line1 db "tests runned ", 0
    summary_line2 db "passed ", 0
    summary_line3 db "failed ", 0
    newline_str db 10, 0
