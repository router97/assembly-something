section .data
        message db "Hello, World!", 0x00
        messageLen EQU $-message

section .text

global _start

_start:
        mov rax, 1
        mov rdi, 1
        mov rsi, message
        mov rdx, messageLen
        syscall

        mov rax, 60
        syscall
