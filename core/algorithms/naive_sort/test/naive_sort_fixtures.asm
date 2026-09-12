; naive_sort_fixtures.asm
; Shared, read-only test fixtures for the Naive_Sort test suites.
; One fixture set is reused by the three algorithms (selection,
; bubble, insertion) via 05_Naive_Sort.md's shared test cases.
;
; Lengths are stored as qword data (not NASM `equ`) because `equ`
; constants are local to the assembling file and cannot be
; imported with `extern` from another object file.

section .data
    global standard_input, standard_output, standard_len
    standard_input   dq 5, 2, 9, 1, 5, 6
    standard_output  dq 1, 2, 5, 5, 6, 9
    standard_len     dq 6

    global sorted_input, sorted_len
    sorted_input     dq 1, 2, 3, 4, 5
    sorted_len       dq 5

    global reverse_input, reverse_output, reverse_len
    reverse_input    dq 5, 4, 3, 2, 1
    reverse_output   dq 1, 2, 3, 4, 5
    reverse_len      dq 5

    global equal_input, equal_len
    equal_input      dq 7, 7, 7, 7
    equal_len        dq 4

    global negative_input, negative_output, negative_len
    negative_input   dq 3, -1, 4, -5, 0
    negative_output  dq -5, -1, 0, 3, 4
    negative_len     dq 5

    global single_input, single_len
    single_input     dq 42
    single_len       dq 1

section .bss
    ; Large enough for the biggest fixture (standard_input, 6 qwords);
    ; each case copies its fixture here before calling the in-place sort.
    global scratch_buffer
    scratch_buffer   resq 6
