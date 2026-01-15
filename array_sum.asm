section .data
        array db 1, 2, 3, 4, 5
        array_length db 5
        result db 0


section .text

global _start

_start:
        lea r14, array
        push r14
        lea r15, array_length
        push r15
        call function

        mov rax, 1
        mov rdi, 1
        lea rsi, result
        mov rdx, 1

        ; rezyltat 15. 15 + 34 = 49. 49 v ascii eto 1
        add [rsi], byte 34
        syscall

        mov eax, 60
        mov edi, 0
        syscall


function:
        push rbp
        mov rbp, rsp

        mov rsi, [rbp + 16]
        movzx r15, byte [rsi]

        mov rsi, [rbp + 24]
        mov r14, rsi

        movzx eax, byte [r14]

        loop_start:

        dec r15
        jz loop_end

        inc r14
        add al, [r14]
        jmp loop_start

        loop_end:
        
        mov [result], al

        pop rbp
        ret
