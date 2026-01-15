global _start

_start:
        push qword 3
        call print_digit

        mov eax,1
        mov ebx,0
        int 0x80

print_digit:
        push rbp
        mov rbp,rsp

        mov rax,1
        mov rdi,1
        mov rsi, rbp
        add rsi, 16

        add [rsi], byte 0x30
        mov rdx,1
        syscall

        pop rbp
        ret
