; naive_sort_cases.asm
; Shared test engine for the Naive_Sort algorithms (selection, bubble,
; insertion). Each algorithm's thin test file just supplies its own
; function pointer and header, then delegates here, avoiding
; duplicating the 8 shared cases per algorithm.
;
; Cases mirror 05_Naive_Sort.md's test table plus one extra case:
; in Assembly, unlike Ada's value-typed arrays, the array argument
; is a raw pointer, so a null pointer IS representable and must be
; checked (see the "null" case below).

section .data
    passed_prefix db "  PASSED: ", 0
    failed_prefix db "  FAILED: ", 0
    nl            db 10, 0

    case_standard db "sorts a standard unsorted array", 0
    case_sorted   db "preserves an already sorted array", 0
    case_reverse  db "sorts a reverse-order array", 0
    case_equal    db "preserves equal elements", 0
    case_negative db "sorts negative values", 0
    case_single   db "preserves a single-element array", 0
    case_empty    db "preserves an empty array", 0
    case_null     db "returns the null failure indicator for a null pointer", 0

section .text
    extern print_string, assert, assert_array, copy_qwords
    extern tests_total, tests_passed, tests_failed
    extern standard_input, standard_output, standard_len
    extern sorted_input, sorted_len
    extern reverse_input, reverse_output, reverse_len
    extern equal_input, equal_len
    extern negative_input, negative_output, negative_len
    extern single_input, single_len
    extern scratch_buffer
    %include "test_macros.inc"
    global run_naive_sort_cases

; ============================================================
; report_case: print PASSED/FAILED for one case and tally counters
; Arguments: rdi = case description ptr, rsi = verdict (1 pass / 0 fail)
; ============================================================
report_case:
    push r12
    push rbx
    mov r12, rdi
    mov rbx, rsi
    inc qword [tests_total]
    cmp rbx, 1
    je .pass
    print_str failed_prefix
    print_str r12
    print_str nl
    inc qword [tests_failed]
    jmp .done
.pass:
    print_str passed_prefix
    print_str r12
    print_str nl
    inc qword [tests_passed]
.done:
    pop rbx
    pop r12
    ret

; ============================================================
; run_naive_sort_cases: run the 8 shared cases against one sort
;   function under test.
; Arguments: rdi = pointer to the sort function to test
;            rsi = pointer to the algorithm header string
; The sort function's contract:
;   rdi = array ptr, rsi = element count
;   rax = same ptr, sorted ascending in place
;   rax = 0 if rdi is null (failure indicator)
;   if rsi = 0, returns rdi unchanged (same empty array)
; ============================================================
run_naive_sort_cases:
    push rbp
    mov rbp, rsp
    sub rsp, 8
    mov [rbp - 8], rdi   ; sort function ptr, kept on the stack so it
                         ; survives regardless of what the callee clobbers

    print_str rsi
    print_str nl

    ; -- standard --
    mov rdi, scratch_buffer
    mov rsi, standard_input
    mov rdx, [standard_len]
    call copy_qwords
    mov rdi, scratch_buffer
    mov rsi, [standard_len]
    call qword [rbp - 8]
    mov rdi, rax
    mov rsi, standard_output
    mov rdx, [standard_len]
    call assert_array
    mov rdi, case_standard
    mov rsi, rax
    call report_case

    ; -- already sorted --
    mov rdi, scratch_buffer
    mov rsi, sorted_input
    mov rdx, [sorted_len]
    call copy_qwords
    mov rdi, scratch_buffer
    mov rsi, [sorted_len]
    call qword [rbp - 8]
    mov rdi, rax
    mov rsi, sorted_input
    mov rdx, [sorted_len]
    call assert_array
    mov rdi, case_sorted
    mov rsi, rax
    call report_case

    ; -- reverse order --
    mov rdi, scratch_buffer
    mov rsi, reverse_input
    mov rdx, [reverse_len]
    call copy_qwords
    mov rdi, scratch_buffer
    mov rsi, [reverse_len]
    call qword [rbp - 8]
    mov rdi, rax
    mov rsi, reverse_output
    mov rdx, [reverse_len]
    call assert_array
    mov rdi, case_reverse
    mov rsi, rax
    call report_case

    ; -- equal elements --
    mov rdi, scratch_buffer
    mov rsi, equal_input
    mov rdx, [equal_len]
    call copy_qwords
    mov rdi, scratch_buffer
    mov rsi, [equal_len]
    call qword [rbp - 8]
    mov rdi, rax
    mov rsi, equal_input
    mov rdx, [equal_len]
    call assert_array
    mov rdi, case_equal
    mov rsi, rax
    call report_case

    ; -- negative values --
    mov rdi, scratch_buffer
    mov rsi, negative_input
    mov rdx, [negative_len]
    call copy_qwords
    mov rdi, scratch_buffer
    mov rsi, [negative_len]
    call qword [rbp - 8]
    mov rdi, rax
    mov rsi, negative_output
    mov rdx, [negative_len]
    call assert_array
    mov rdi, case_negative
    mov rsi, rax
    call report_case

    ; -- single element --
    mov rdi, scratch_buffer
    mov rsi, single_input
    mov rdx, [single_len]
    call copy_qwords
    mov rdi, scratch_buffer
    mov rsi, [single_len]
    call qword [rbp - 8]
    mov rdi, rax
    mov rsi, single_input
    mov rdx, [single_len]
    call assert_array
    mov rdi, case_single
    mov rsi, rax
    call report_case

    ; -- empty array: same pointer returned, untouched --
    mov rdi, scratch_buffer
    xor rsi, rsi
    call qword [rbp - 8]
    mov rdi, rax
    mov rsi, scratch_buffer
    call assert
    mov rdi, case_empty
    mov rsi, rax
    call report_case

    ; -- null pointer: failure indicator (rax = 0) --
    xor rdi, rdi
    mov rsi, 5
    call qword [rbp - 8]
    mov rdi, rax
    xor rsi, rsi
    call assert
    mov rdi, case_null
    mov rsi, rax
    call report_case

    print_str nl
    leave
    ret
