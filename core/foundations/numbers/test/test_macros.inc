;; test_macros.inc
;; Shared test macros for Numbers test suites
;; Include in each test file: %include "test_macros.inc"
;;
;; Requires these extern symbols:
;;   print_string, tests_total, tests_passed, tests_failed
;;
;; Requires these data strings in each test file:
;;   test_passed_msg, test_failed_msg, newline

; ============================================================
; Macro: print_str string_label
; Prints a null-terminated string
; ============================================================
%macro print_str 1
    mov rdi, %1
    call print_string
%endmacro

; ============================================================
; Macro: run_test test_name_str, test_function_label
; Runs a test function, prints PASSED/FAILED, updates counters
;
; The test function must return:
;   rax = 1 if passed (assert returned 1)
;   rax = 0 if failed
; ============================================================
%macro run_test 2
    inc qword [tests_total]
    call %2
    cmp rax, 1          ; assert returns 1 if passed
    je .pass_%2
    ; Failed
    print_str test_failed_msg
    print_str %1
    print_str newline
    inc qword [tests_failed]
    jmp .done_%2
.pass_%2:
    print_str test_passed_msg
    print_str %1
    print_str newline
    inc qword [tests_passed]
.done_%2:
%endmacro
