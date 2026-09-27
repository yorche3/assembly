%macro print_str 1
    mov rdi, %1
    call print_string
%endmacro

%macro run_test 2
    inc qword [tests_total]
    call %2
    test rax, rax
    jnz %%passed
    print_str test_failed_message
    print_str %1
    print_str newline
    inc qword [tests_failed]
    jmp %%done
%%passed:
    print_str test_passed_message
    print_str %1
    print_str newline
    inc qword [tests_passed]
%%done:
%endmacro

%macro assert_result 2
    mov rdi, rax
    mov rsi, [%1]
    call assert
    test rax, rax
    jz %2
%endmacro
