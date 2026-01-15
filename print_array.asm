.data:
        array db 0x31, 0x32, 0x33, 0x34, 0x35, 0x36
        global _start

_start:
        lea r14, array
        push r14
        push qword 6
        call array_sum

        mov eax, 1
        mov edx, 0
        int 0x80

array_sum:
        push rbp
        mov rbp, rsp

        mov rax,1
        mov rdi,1
        mov rsi, rsp
        add rsi, 16
        add [rsi], byte 0x30
        mov rdx,1
        syscall
        sub [rsi], byte 0x30

        mov r15, [rsi]
        mov rsi, rbp
        add rsi, 16
        add rsi, 8
        mov r14, [rsi]

loop_start:
        mov rsi, r14
        syscall
        inc r14

        dec r15
        cmp r15, 0
        je loop_end
        jmp loop_start

loop_end:
        pop rbp
        ret
