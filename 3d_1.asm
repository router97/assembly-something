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
%macro push3 3
        push %1
        push %2
        push %3
%endmacro

%define WIDTH 155
%define HEIGHT 40
%define LENGTH 255

%define scale 10

struc point
        .x: resd 1
        .y: resd 1
        .z: resd 1
        .color: resd 1
endstruc

struc plane
        .p1: resb point_size
        .p2: resb point_size
        .p3: resb point_size
        .p4: resb point_size
endstruc


section .data
        ; row TIMES WIDTH db 0x2E
        row TIMES WIDTH db 0x20
        newline db 0x0A
        carriage db 0x0D
        red db `\033[41m`, 0
        red_len EQU $-red
        blue db `\033[44m`, 0
        blue_len EQU $-blue
        reset db `\033[0m`, 0
        reset_len EQU $-reset
        home db `\033[H`,0
        home_len EQU $-home

        pointchar db 0x20

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

        delay dq 0, 50000000


        ; --------------------------
        ; point1 dd -0.25, -0.25, 1.4, 0
        ; point2 dd -0.25, 0.25, 1.4, 0
        ; point3 dd 0.25, -0.25, 1.4, 0
        ; point4 dd 0.25, 0.25, 1.4, 0

        ; plane1_z_high dd 3.0
        ; plane1_z_low dd 0.4

        ; point5 dd -0.25, -0.25, 1.65, 0
        ; point6 dd -0.25, 0.25, 1.65, 0
        ; point7 dd 0.25, -0.25, 1.65, 0
        ; point8 dd 0.25, 0.25, 1.65, 0

        ; =====<

        ; point1 dd -0.25, -0.25, 1.4, 0
        ; point2 dd -0.25, 0.25, 1.4, 0
        ; point3 dd 0.25, -0.25, 1.4, 0
        ; point4 dd 0.25, 0.25, 1.4, 0

        ; plane1_z_high dd 3.0
        ; plane1_z_low dd 0.4

        ; point5 dd -0.8, -0.8, 2.65, 0
        ; point6 dd -0.8, 0.8, 2.65, 0
        ; point7 dd 0.8, -0.8, 2.65, 0
        ; point8 dd 0.8, 0.8, 2.65, 0

        ; =====<

        point1 dd -0.5, -1.0, 2.0, 0
        point2 dd -0.5, 1.0, 2.0, 0
        point3 dd 0.5, -1.0, 2.0, 0
        point4 dd 0.5, 1.0, 2.0, 0

        plane1_z_high dd 2.99
        plane1_z_low dd 1.99

        point5 dd -0.5, -1.0, 3.0, 0
        point6 dd -0.5, 1.0, 3.0, 0
        point7 dd 0.5, -1.0, 3.0, 0
        point8 dd 0.5, 1.0, 3.0, 0

        ; --------------------------

        step dd 0.1
        smallstep dd 0.05
        float_zero dd 0.0
        float_height_m1 dd 39.0
        float_height dd 40.0
        float_width_m1 dd 154.0
        float_width dd 155.0
        two_float dd 2.0
        float_one dd 1.0
        minus_two_float dd -2.0

        deviation dd 0.001


        

section .bss
        plane1 resb plane_size
        plane2 resb plane_size


section .text
global _start

_start:
        ;plane1
        mov rax, [point1]
        mov [plane1 + plane.p1], rax
        mov rax, [point1+8]
        mov[plane1 + plane.p1 + 8], rax

        mov rax, [point2]
        mov [plane1 + plane.p2], rax
        mov rax, [point2+8]
        mov[plane1 + plane.p2 + 8], rax

        mov rax, [point3]
        mov [plane1 + plane.p3], rax
        mov rax, [point3+8]
        mov[plane1 + plane.p3 + 8], rax

        mov rax, [point4]
        mov [plane1 + plane.p4], rax
        mov rax, [point4+8]
        mov[plane1 + plane.p4 + 8], rax

        
        ;plane2
        mov rax, [point5]
        mov [plane2 + plane.p1], rax
        mov rax, [point5+8]
        mov[plane2 + plane.p1 + 8], rax

        mov rax, [point6]
        mov [plane2 + plane.p2], rax
        mov rax, [point6+8]
        mov[plane2 + plane.p2 + 8], rax

        mov rax, [point7]
        mov [plane2 + plane.p3], rax
        mov rax, [point7+8]
        mov[plane2 + plane.p3 + 8], rax

        mov rax, [point8]
        mov [plane2 + plane.p4], rax
        mov rax, [point8+8]
        mov[plane2 + plane.p4 + 8], rax
        

        call go_home
        

        ; r10 - z dir
        mov r10, 1
        mov r12, 1
        
        wait_start:
                mov rax, 35
                mov rdi, delay
                xor rsi, rsi
                syscall

                

                cmp r10, 1
                je z_1
                jmp z_0
                z_1:
                        mov rax, plane1
                        push rax
                        call move_plane_forward
                        add rsp, 8

                        mov rax, plane2
                        push rax
                        call move_plane_forward
                        add rsp, 8

                        mov rax, plane1
                        push rax
                        call plane1_z_limit_check
                        add rsp, 8

                        cmp rax, 1
                        
                        je z_set_0
                        

                        ; mov rax, plane2
                        ; push rax
                        ; call plane1_z_limit_check
                        ; add rsp, 8
                        
                        ; cmp rax, 1

                        ; je z_set_0
                        jmp z_over
                z_0:
                        mov rax, plane1
                        push rax
                        call move_plane_back
                        add rsp, 8

                        mov rax, plane2
                        push rax
                        call move_plane_back
                        add rsp, 8

                        mov rax, plane1
                        push rax
                        call plane1_z_limit_check
                        add rsp, 8

                        cmp rax, 1
                        
                        je z_set_1
                        

                        ; mov rax, plane2
                        ; push rax
                        ; call plane1_z_limit_check
                        ; add rsp, 8

                        ; cmp rax, 1
                        
                        ; je z_set_1
                        jmp z_over
                z_set_0:
                        mov r10, 0
                        jmp z_over
                z_set_1:
                        mov r10, 1
                        jmp z_over
                z_over:


                cmp r12, 1
                je x_1
                jmp x_0
                x_1:
                        mov rax, plane1
                        push rax
                        call move_plane_right
                        add rsp, 8

                        mov rax, plane2
                        push rax
                        call move_plane_right
                        add rsp, 8

                        mov rax, plane1
                        push rax
                        call plane_touching_wall_x
                        add rsp, 8
                        
                        cmp rax, 1

                        je x_set_0

                        mov rax, plane2
                        push rax
                        call plane_touching_wall_x
                        add rsp, 8
                        
                        cmp rax, 1

                        je x_set_0
                        jmp x_over
                x_0:
                        mov rax, plane1
                        push rax
                        call move_plane_left
                        add rsp, 8

                        mov rax, plane2
                        push rax
                        call move_plane_left
                        add rsp, 8

                        mov rax, plane1
                        push rax
                        call plane_touching_wall_x
                        add rsp, 8

                        cmp rax, 1
                        
                        je x_set_1

                        mov rax, plane2
                        push rax
                        call plane_touching_wall_x
                        add rsp, 8
                        je x_set_1
                        jmp x_over
                x_set_0:
                        mov r12, 0
                        jmp x_over
                x_set_1:
                        mov r12, 1
                        jmp x_over
                x_over:

                ; cmp r12, 1
                ; je y_1
                ; jmp y_0
                ; y_1:
                ;         mov rax, plane1
                ;         push rax
                ;         call move_plane_up
                ;         add rsp, 8

                ;         mov rax, plane1
                ;         push rax
                ;         call plane_touching_wall_y
                ;         add rsp, 8
                        
                ;         cmp rax, 1

                ;         je y_set_0
                ;         jmp y_over
                ; y_0:
                ;         mov rax, plane1
                ;         push rax
                ;         call move_plane_down
                ;         add rsp, 8

                ;         mov rax, plane1
                ;         push rax
                ;         call plane_touching_wall_y
                ;         add rsp, 8

                ;         cmp rax, 1
                        
                ;         je y_set_1
                ;         jmp y_over
                ; y_set_0:
                ;         mov r12, 0
                ;         jmp y_over
                ; y_set_1:
                ;         mov r12, 1
                ;         jmp y_over
                ; y_over:
                

                jmp draw_points
                
        

        draw_points:
                call go_home
                call fill_background
                call make_red

                mov rax, plane1
                push rax
                call draw_plane
                add rsp, 8

                mov rax, point1
                push rax
                mov rax, point5
                push rax
                call draw_line
                add rsp, 8*2

                call ansi_reset
                call make_blue
                mov rax, plane2
                push rax
                call draw_plane
                add rsp, 8

                call ansi_reset
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

make_blue:
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, blue
        mov rdx, blue_len
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
        mov rax, 0

        movss xmm0, dword [x]
        divss xmm0, [z]
        addss xmm0, [float_one]
        divss xmm0, [two_float]
        mulss xmm0, [float_width]
        cvtss2si eax, xmm0
        push rax

        movss xmm0, dword [y]
        divss xmm0, [z]
        addss xmm0, [float_one]
        divss xmm0, [two_float]
        mulss xmm0, [float_height]
        cvtss2si eax, xmm0
        push rax

        call move_cursor
        add rsp, 16
        
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, backspace
        mov rdx, 1
        syscall

        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, pointchar
        mov rdx, 1
        syscall

        pop rbp
        ret


%undef z
%undef y
%undef x


%define arg1 rbp + 16
move_plane_right:
        push rbp
        mov rbp, rsp

        mov rax, [arg1]
        movss xmm0, [rax + plane.p1 + point.x]
        movss xmm1, [step]
        addss xmm0, xmm1
        movss [rax + plane.p1 + point.x], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p2 + point.x]
        movss xmm1, [step]
        addss xmm0, xmm1
        movss [rax + plane.p2 + point.x], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p3 + point.x]
        movss xmm1, [step]
        addss xmm0, xmm1
        movss [rax + plane.p3 + point.x], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p4 + point.x]
        movss xmm1, [step]
        addss xmm0, xmm1
        movss [rax + plane.p4 + point.x], xmm0

        pop rbp
        ret
%undef arg1

%define arg1 rbp + 16
move_plane_left:
        push rbp
        mov rbp, rsp

        mov rax, [arg1]
        movss xmm0, [rax + plane.p1 + point.x]
        movss xmm1, [step]
        subss xmm0, xmm1
        movss [rax + plane.p1 + point.x], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p2 + point.x]
        movss xmm1, [step]
        subss xmm0, xmm1
        movss [rax + plane.p2 + point.x], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p3 + point.x]
        movss xmm1, [step]
        subss xmm0, xmm1
        movss [rax + plane.p3 + point.x], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p4 + point.x]
        movss xmm1, [step]
        subss xmm0, xmm1
        movss [rax + plane.p4 + point.x], xmm0

        pop rbp
        ret
%undef arg1

%define arg1 rbp + 16
move_plane_up:
        push rbp
        mov rbp, rsp

        mov rax, [arg1]
        movss xmm0, [rax + plane.p1 + point.y]
        movss xmm1, [step]
        addss xmm0, xmm1
        movss [rax + plane.p1 + point.y], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p2 + point.y]
        movss xmm1, [step]
        addss xmm0, xmm1
        movss [rax + plane.p2 + point.y], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p3 + point.y]
        movss xmm1, [step]
        addss xmm0, xmm1
        movss [rax + plane.p3 + point.y], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p4 + point.y]
        movss xmm1, [step]
        addss xmm0, xmm1
        movss [rax + plane.p4 + point.y], xmm0

        pop rbp
        ret
%undef arg1


%define arg1 rbp + 16
move_plane_down:
        push rbp
        mov rbp, rsp

        mov rax, [arg1]
        movss xmm0, [rax + plane.p1 + point.y]
        movss xmm1, [step]
        subss xmm0, xmm1
        movss [rax + plane.p1 + point.y], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p2 + point.y]
        movss xmm1, [step]
        subss xmm0, xmm1
        movss [rax + plane.p2 + point.y], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p3 + point.y]
        movss xmm1, [step]
        subss xmm0, xmm1
        movss [rax + plane.p3 + point.y], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p4 + point.y]
        movss xmm1, [step]
        subss xmm0, xmm1
        movss [rax + plane.p4 + point.y], xmm0

        pop rbp
        ret
%undef arg1

%define arg1 rbp + 16
move_plane_back:
        push rbp
        mov rbp, rsp

        mov rax, [arg1]
        movss xmm0, [rax + plane.p1 + point.z]
        movss xmm1, [smallstep]
        addss xmm0, xmm1
        movss [rax + plane.p1 + point.z], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p2 + point.z]
        movss xmm1, [smallstep]
        addss xmm0, xmm1
        movss [rax + plane.p2 + point.z], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p3 + point.z]
        movss xmm1, [smallstep]
        addss xmm0, xmm1
        movss [rax + plane.p3 + point.z], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p4 + point.z]
        movss xmm1, [smallstep]
        addss xmm0, xmm1
        movss [rax + plane.p4 + point.z], xmm0

        pop rbp
        ret
%undef arg1

%define arg1 rbp + 16
move_plane_forward:
        push rbp
        mov rbp, rsp

        mov rax, [arg1]
        movss xmm0, [rax + plane.p1 + point.z]
        movss xmm1, [smallstep]
        subss xmm0, xmm1
        movss [rax + plane.p1 + point.z], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p2 + point.z]
        movss xmm1, [smallstep]
        subss xmm0, xmm1
        movss [rax + plane.p2 + point.z], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p3 + point.z]
        movss xmm1, [smallstep]
        subss xmm0, xmm1
        movss [rax + plane.p3 + point.z], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p4 + point.z]
        movss xmm1, [smallstep]
        subss xmm0, xmm1
        movss [rax + plane.p4 + point.z], xmm0

        pop rbp
        ret
%undef arg1


%define arg1 rbp + 16
plane_touching_wall_x:
        push rbp
        mov rbp, rsp
        movss xmm1, [minus_two_float]
        movss xmm2, [two_float]

        mov rax, [arg1]
        movss xmm0, [rax + plane.p1 + point.x]
        ucomiss xmm0, xmm1
        jbe .yes
        ucomiss xmm0, xmm2
        jae .yes
        movss [rax + plane.p1 + point.x], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p2 + point.x]
        ucomiss xmm0, xmm1
        jbe .yes
        ucomiss xmm0, xmm2
        jae .yes
        movss [rax + plane.p2 + point.x], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p3 + point.x]
        ucomiss xmm0, xmm1
        jbe .yes
        ucomiss xmm0, xmm2
        jae .yes
        movss [rax + plane.p3 + point.x], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p4 + point.x]
        ucomiss xmm0, xmm1
        jbe .yes
        ucomiss xmm0, xmm2
        jae .yes
        movss [rax + plane.p4 + point.x], xmm0

        jmp .no
        .yes:
                mov rax, 1
                jmp .end
        .no:
                mov rax, 0
                jmp .end
        .end:
                pop rbp
                ret
%undef arg1


%define arg1 rbp + 16
plane_touching_wall_y:
        push rbp
        mov rbp, rsp
        movss xmm1, [minus_two_float]
        movss xmm2, [two_float]

        mov rax, [arg1]
        movss xmm0, [rax + plane.p1 + point.y]
        ucomiss xmm0, xmm1
        jbe .yes
        ucomiss xmm0, xmm2
        jae .yes
        movss [rax + plane.p1 + point.y], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p2 + point.y]
        ucomiss xmm0, xmm1
        jbe .yes
        ucomiss xmm0, xmm2
        jae .yes
        movss [rax + plane.p2 + point.y], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p3 + point.y]
        ucomiss xmm0, xmm1
        jbe .yes
        ucomiss xmm0, xmm2
        jae .yes
        movss [rax + plane.p3 + point.y], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p4 + point.y]
        ucomiss xmm0, xmm1
        jbe .yes
        ucomiss xmm0, xmm2
        jae .yes
        movss [rax + plane.p4 + point.y], xmm0

        jmp .no
        .yes:
                mov rax, 1
                jmp .end
        .no:
                mov rax, 0
                jmp .end
        .end:
                pop rbp
                ret
%undef arg1


%define arg1 rbp + 16
plane1_z_limit_check:
        push rbp
        mov rbp, rsp
        movss xmm1, [plane1_z_low]
        movss xmm2, [plane1_z_high]

        mov rax, [arg1]
        movss xmm0, [rax + plane.p1 + point.z]
        ucomiss xmm0, xmm1
        jbe .yes
        ucomiss xmm0, xmm2
        jae .yes
        movss [rax + plane.p1 + point.z], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p2 + point.z]
        ucomiss xmm0, xmm1
        jbe .yes
        ucomiss xmm0, xmm2
        jae .yes
        movss [rax + plane.p2 + point.z], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p3 + point.z]
        ucomiss xmm0, xmm1
        jbe .yes
        ucomiss xmm0, xmm2
        jae .yes
        movss [rax + plane.p3 + point.z], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p4 + point.z]
        ucomiss xmm0, xmm1
        jbe .yes
        ucomiss xmm0, xmm2
        jae .yes
        movss [rax + plane.p4 + point.z], xmm0

        jmp .no
        .yes:
                mov rax, 1
                jmp .end
        .no:
                mov rax, 0
                jmp .end
        .end:
                pop rbp
                ret
%undef arg1


%define arg1 rbp + 16
draw_plane:
        push rbp
        mov rbp, rsp

        mov r8, [arg1]

        movss xmm0, dword [r8 + plane.p1 + point.x]
        movss xmm1, dword [r8 + plane.p1 + point.y]
        movss xmm2, dword [r8 + plane.p1 + point.z]
        sub rsp, 8
        mov [rsp], 0
        movss dword [rsp], xmm2
        sub rsp, 8
        mov [rsp], 0
        movss dword [rsp], xmm1
        sub rsp, 8
        mov [rsp], 0
        movss dword [rsp], xmm0

        call draw_point
        add rsp, 8*3

        movss xmm0, dword [r8 + plane.p2 + point.x]
        movss xmm1, dword [r8 + plane.p2 + point.y]
        movss xmm2, dword [r8 + plane.p2 + point.z]
        sub rsp, 8
        mov [rsp], 0
        movss dword [rsp], xmm2
        sub rsp, 8
        mov [rsp], 0
        movss dword [rsp], xmm1
        sub rsp, 8
        mov [rsp], 0
        movss dword [rsp], xmm0
        call draw_point
        add rsp, 8*3

        movss xmm0, dword [r8 + plane.p3 + point.x]
        movss xmm1, dword [r8 + plane.p3 + point.y]
        movss xmm2, dword [r8 + plane.p3 + point.z]
        sub rsp, 8
        mov [rsp], 0
        movss dword [rsp], xmm2
        sub rsp, 8
        mov [rsp], 0
        movss dword [rsp], xmm1
        sub rsp, 8
        mov [rsp], 0
        movss dword [rsp], xmm0
        call draw_point
        add rsp, 8*3

        movss xmm0, dword [r8 + plane.p4 + point.x]
        movss xmm1, dword [r8 + plane.p4 + point.y]
        movss xmm2, dword [r8 + plane.p4 + point.z]
        sub rsp, 8
        mov [rsp], 0
        movss dword [rsp], xmm2
        sub rsp, 8
        mov [rsp], 0
        movss dword [rsp], xmm1
        sub rsp, 8
        mov [rsp], 0
        movss dword [rsp], xmm0
        call draw_point
        add rsp, 8*3

        mov r8, [arg1]
        lea rax, [r8 + plane.p1]
        push rax
        lea rax, [r8 + plane.p2]
        push rax
        call draw_line
        add rsp, 8*2

        lea rax, [r8 + plane.p2]
        push rax
        lea rax, [r8 + plane.p4]
        push rax
        call draw_line
        add rsp, 8*2

        lea rax, [r8 + plane.p4]
        push rax
        lea rax, [r8 + plane.p3]
        push rax
        call draw_line
        add rsp, 8*2

        lea rax, [r8 + plane.p3]
        push rax
        lea rax, [r8 + plane.p1]
        push rax
        call draw_line
        add rsp, 8*2

        pop rbp
        ret
%undef arg1


%define arg1 rbp + 16
%define arg2 rbp + 24

%define p1_x xmm1
%define p1_y xmm2
%define p1_z xmm11

%define p2_x xmm3
%define p2_y xmm4
%define p2_z xmm12

%define _dx xmm5
%define _dy xmm6

%define slope xmm7

%define curpx xmm8
%define curpy xmm9

%define temp xmm10

draw_line:
        push rbp
        mov rbp, rsp

        mov rax, [arg1]
        movss p1_x, [rax + point.x]
        movss p1_y, [rax + point.y]
        movss p1_z, [rax + point.z]

        mov rax, [arg2]
        movss p2_x, [rax + point.x]
        movss p2_y, [rax + point.y]
        movss p2_z, [rax + point.z]

        movss _dx, p2_x
        subss _dx, p1_x
        ; mulss _dx, _dx
        ; sqrtss _dx, _dx

        movss _dy, p2_y
        subss _dy, p1_y
        ; mulss _dy, _dy
        ; sqrtss _dy, _dy

        movss slope, _dy
        divss slope, _dx

        movss curpx, p1_x
        movss curpy, p1_y
        .decide:
                movss temp, _dx
                mulss temp, temp
                sqrtss temp, temp
                ucomiss temp, [deviation]
                jb .vertical

                ; ucomiss slope, [float_zero]
                ucomiss p2_x, p1_x
                jae .loop_right
                jbe .loop_left
                jmp .end

        .loop_right:
                addss curpx, [smallstep]
                movss curpy, p1_y
                movss temp, curpx
                subss temp, p1_x
                mulss temp, slope
                addss curpy, temp

                ucomiss curpx, p2_x
                jae .end
                jmp .loop_shared

        .loop_left:
                subss curpx, [smallstep]
                movss curpy, p1_y
                movss temp, curpx
                subss temp, p1_x
                mulss temp, slope
                addss curpy, temp

                ucomiss curpx, p2_x
                jbe .end
                jmp .loop_shared
        
        .vertical:
                ucomiss _dy, [float_zero]
                jae .vertical_up
                jbe .vertical_down
                jmp .end
        
        .vertical_up:
                addss curpy, [smallstep]
                ucomiss curpy, p2_y
                jae .end
                jmp .loop_shared
        .vertical_down:
                subss curpy, [smallstep]
                ucomiss curpy, p2_y
                jbe .end
                jmp .loop_shared

        .loop_shared:
                sub rsp, 8
                mov [rsp], 0
                movss dword [rsp], p1_z
                sub rsp, 8
                mov [rsp], 0
                movss dword [rsp], curpy
                sub rsp, 8
                mov [rsp], 0
                movss dword [rsp], curpx
                call draw_point
                add rsp, 8*3

                jmp .decide

        .end:
                pop rbp
                ret
