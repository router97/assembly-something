%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1
%define STDERR 2

%define INPUT_SIZE 1

%macro MACRO_EXIT 0
        mov rax, SYS_EXIT
        syscall
%endmacro

%macro MACRO_GET_ELEMENT 1
        lea rdi, array
        add rdi, %1
        movzx rax, byte [rdi]
%endmacro

section .data

        array db "abcdefghij"
        array_len EQU $-array

        index_error db 10, "only 0-9", 0
        index_error_len EQU $-index_error

section .bss

        input resb INPUT_SIZE


section .text

global _start

_start:
        call get_user_input

        lea rax, input
        movzx rdi, byte [rax]
        cmp rdi, 0x30
        jl INDEX_ERROR_DEST
        cmp rdi, 0x39
        jg INDEX_ERROR_DEST

        lea rax, input
        push rax
        call ascii_to_binary
        add rsp, 8

        MACRO_GET_ELEMENT rax

        push rax
        call print_char
        add rsp, 8

        MACRO_EXIT

get_user_input:
        mov rax,SYS_READ
        mov rsi, input
        mov rdi, STDIN
        mov rdx, INPUT_SIZE
        syscall
        ret

ascii_to_binary:
        push rbp
        mov rbp, rsp

        mov rdi, [rbp+16]
        movzx rax, byte [rdi]
        sub rax, 0x30

        pop rbp
        ret

print_char:
        push rbp
        mov rbp, rsp

        mov rax,SYS_WRITE
        mov rdi,STDOUT
        mov rsi, rbp
        add rsi, 16
        mov rdx, 1
        syscall

        pop rbp
        ret

INDEX_ERROR_DEST:
        mov rax,SYS_WRITE
        mov rdi,STDERR
        mov rsi, index_error
        mov rdx, index_error_len
        syscall
        MACRO_EXIT
