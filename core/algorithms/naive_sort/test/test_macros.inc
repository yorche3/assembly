; test_macros.inc
; Shared test macro for the Naive_Sort test suites
; Include in each test file: %include "test_macros.inc"
;
; Requires: print_string (extern in the including file)

; ============================================================
; Macro: print_str string_or_reg
; Prints a null-terminated string (label or register operand)
; ============================================================
%macro print_str 1
    mov rdi, %1
    call print_string
%endmacro
