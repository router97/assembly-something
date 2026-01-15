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
%define scale 2
%macro push3 3
        push %1
        push %2
        push %3
%endmacro

%define WIDTH 150
%define HEIGHT 40
%define LENGTH 255

section .data
        row TIMES WIDTH db 0x2E
        newline db 0x0A
        carriage db 0x0D
        red db `\033[31m`, 0
        red_len EQU $-red
        reset db `\033[0m`, 0
        reset_len EQU $-reset
        home db `\033[H`,0
        home_len EQU $-home

        point db 0x40

        one_line_up db `\033[1A`, 0
        one_line_up_len EQU $-one_line_up
        one_line_down db `\033[1B`, 0
        one_line_down_len EQU $-one_line_down
        one_col_right db `\033[1C`, 0
        one_col_right_len EQU $-one_col_right
        one_col_left db `\033[1D`, 0
        one_col_left_len EQU $-one_col_left

        ; ESC[2J - clear screen
        backspace db 0x08

        delay dq 1, 0


section .text
global _start

_start:
        call go_home
        call make_red
        call fill_background
        call ansi_reset
        
        
        wait_start:
                mov rax, 35
                mov rdi, delay
                xor rsi, rsi
                syscall
                jmp draw_points
        

        draw_points:
                ; Z, Y, X
                push3 1, 10, 10
                call draw_point
                sub rsp, 8*3

                push3 1, 10, 0
                call draw_point
                sub rsp, 8*3

                push3 1, 0, 10
                call draw_point
                sub rsp, 8*3

                push3 1, 0, 0
                call draw_point
                sub rsp, 8*3

                jmp wait_start
        

fill_background:
        mov r15, 0

        loop_row:
        
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, row
        mov rdx, WIDTH
        syscall

        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, newline
        mov rdx, 1
        syscall

        inc r15
        cmp r15, HEIGHT

        jl loop_row

        ret

make_red:
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, red
        mov rdx, red_len
        syscall
        ret

go_home:
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, home
        mov rdx, home_len
        syscall
        ret

ansi_reset:
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, reset
        mov rdx, reset_len
        syscall
        ret

%define x rbp + 24
%define y rbp + 16

move_cursor:
        push rbp
        mov rbp, rsp
        call go_home

        mov r14, [x]
        mov r15, [y]

        line_loop:
                cmp r15, 0
                je row_loop
                mov rax, SYS_WRITE
                mov rdi, STDOUT
                mov rsi, one_line_down
                mov rdx, one_line_down_len
                syscall
                dec r15
                jmp line_loop
        row_loop:
                cmp r14, 0
                je end
                mov rax, SYS_WRITE
                mov rdi, STDOUT
                mov rsi, one_col_right
                mov rdx, one_col_right_len
                syscall
                dec r14
                jmp row_loop
        end:
                pop rbp
                ret

%undef y
%undef x

%define z rbp + 32
%define y rbp + 24
%define x rbp + 16

draw_point:
        push rbp
        mov rbp, rsp

        mov r14, [x]
        push r14
        mov r14, [y]
        push r14
        call move_cursor
        add rsp, 16
        
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, backspace
        mov rdx, 1
        syscall

        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, point
        mov rdx, 1
        syscall

        pop rbp
        ret


%undef z
%undef y
%undef x
