%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1
%define STDERR 2

%macro MACRO_EXIT 0
        mov rax, SYS_EXIT
        syscall
%endmacro

section .data:
        message db "1-2-3-4-5-6-7-8-9-1-2-3-4-5-6-7-8-9"
        carriage_return db 0x0D
        message_len EQU $-message
        delay dq 0, 300000000

section .text

global _start

_start:
        jmp restart

print_message:
        mov rax, 35
        mov rdi, delay
        xor rsi, rsi
        syscall
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, r15
        mov rdx, 17
        syscall
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, carriage_return
        mov rdx, 1
        syscall
        inc r15
        inc r14
        jmp loop_entry



loop_entry:
        cmp r14,18
        jge restart
        jmp print_message
        MACRO_EXIT

restart:
        mov r15,message
        mov r14, 0
        jmp loop_entry
