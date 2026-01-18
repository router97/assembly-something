%define SYS_READ 0
%define SYS_WRITE 1
%define NANOSLEEP 35
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1
%define STDERR 2

%macro MACRO_EXIT 0
        mov rax, SYS_EXIT
        mov rdi, 0
        syscall
%endmacro


; %macro MACRO_CUBE 4
;         %4:
;                 dd %1 - 0.25, %2 - 0.25, %3 + 0.25, 0
;                 dd %1 - 0.25, %2 + 0.25, %3 + 0.25, 0
;                 dd %1 + 0.25, %2 - 0.25, %3 + 0.25, 0
;                 dd %1 + 0.25, %2 + 0.25, %3 + 0.25, 0

;                 dd %1 - 0.25, %2 - 0.25, %3 - 0.25, 0
;                 dd %1 - 0.25, %2 + 0.25, %3 - 0.25, 0
;                 dd %1 + 0.25, %2 - 0.25, %3 - 0.25, 0
;                 dd %1 + 0.25, %2 + 0.25, %3 - 0.25, 0
; %endmacro


%define WIDTH 155
%define HEIGHT 40
%define LENGTH 30

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

struc box
        .pl1: resb plane_size
        .pl2: resb plane_size
endstruc


section .data
        ; ==== ASCII ==== ;
        newline db 0x0A
        carriage db 0x0D
        backspace db 0x08
        ; ==== ^^^^^ ==== ;

        ; ==== COLORS ==== ;
        black db `\033[30m`, 0
        black_len EQU $-black
        black_bg db `\033[40m`, 0
        black_bg_len EQU $-black_bg

        red db `\033[31m`, 0
        red_len EQU $-red
        red_bg db `\033[41m`, 0
        red_bg_len EQU $-red_bg

        green db `\033[32m`, 0
        green_len EQU $-green
        green_bg db `\033[42m`, 0
        green_bg_len EQU $-green_bg

        yellow db `\033[33m`, 0
        yellow_len EQU $-yellow
        yellow_bg db `\033[43m`, 0
        yellow_bg_len EQU $-yellow_bg

        blue db `\033[34m`, 0
        blue_len EQU $-blue
        blue_bg db `\033[44m`, 0
        blue_bg_len EQU $-blue_bg

        magenta db `\033[35m`, 0
        magenta_len EQU $-magenta
        magenta_bg db `\033[45m`, 0
        magenta_bg_len EQU $-magenta_bg

        cyan db `\033[36m`, 0
        cyan_len EQU $-cyan
        cyan_bg db `\033[46m`, 0
        cyan_bg_len EQU $-cyan_bg

        white db `\033[37m`, 0
        white_len EQU $-white
        white_bg db `\033[47m`, 0
        white_bg_len EQU $-white_bg

        default_color db `\033[39m`, 0
        default_color_len EQU $-default_color
        default_color_bg db `\033[49m`, 0
        default_color_bg_len EQU $-default_color_bg
        ; ==== ^^^^^^ ==== ;

        ; ==== CURSOR CONTROLS ==== ;
        reset db `\033[0m`, 0
        reset_len EQU $-reset

        home db `\033[H`,0
        home_len EQU $-home

        one_col_right db `\033[1C`, 0
        one_col_right_len EQU $-one_col_right
        one_col_left db `\033[1D`, 0
        one_col_left_len EQU $-one_col_left

        one_line_up db `\033[1A`, 0
        one_line_up_len EQU $-one_line_up
        one_line_down db `\033[1B`, 0
        one_line_down_len EQU $-one_line_down
        ; ==== ^^^^^^^^^^^^^^^ ==== ;
        
        


        ; ==== BOX SETUPS ==== ;
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

        ; ----<

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

        ; ----<

        point1 dd -0.5, -1.0, 3.0, 0
        point2 dd -0.5, 1.0, 3.0, 0
        point3 dd 0.5, -1.0, 3.0, 0
        point4 dd 0.5, 1.0, 3.0, 0

        plane1_z_high dd 4.0
        plane1_z_low dd 0.001

        point5 dd -0.5, -1.0, 4.0, 0
        point6 dd -0.5, 1.0, 4.0, 0
        point7 dd 0.5, -1.0, 4.0, 0
        point8 dd 0.5, 1.0, 4.0, 0

        point_center dd 0.0, 0.0, 3.5, 0


        cube0:
        dd -0.51, 0.9, 3.25, 0.0
        dd -0.51, 0.4, 3.25, 0.0
        dd -1.01, 0.9, 3.25, 0.0
        dd -1.01, 0.4, 3.25, 0.0

        dd -0.51, 0.9, 3.75, 0.0
        dd -0.51, 0.4, 3.75, 0.0
        dd -1.01, 0.9, 3.75, 0.0
        dd -1.01, 0.4, 3.75, 0.0
cube1:
        dd 0.404, -0.738, 3.25, 0.0
        dd 0.404, -1.238, 3.25, 0.0
        dd -0.096, -0.738, 3.25, 0.0
        dd -0.096, -1.238, 3.25, 0.0

        dd 0.404, -0.738, 3.75, 0.0
        dd 0.404, -1.238, 3.75, 0.0
        dd -0.096, -0.738, 3.75, 0.0
        dd -0.096, -1.238, 3.75, 0.0
cube2:
        dd 0.775, 1.101, 3.25, 0.0
        dd 0.775, 0.601, 3.25, 0.0
        dd 0.275, 1.101, 3.25, 0.0
        dd 0.275, 0.601, 3.25, 0.0

        dd 0.775, 1.101, 3.75, 0.0
        dd 0.775, 0.601, 3.75, 0.0
        dd 0.275, 1.101, 3.75, 0.0
        dd 0.275, 0.601, 3.75, 0.0
cube3:
        dd -0.702, -0.055, 3.25, 0.0
        dd -0.702, -0.555, 3.25, 0.0
        dd -1.202, -0.055, 3.25, 0.0
        dd -1.202, -0.555, 3.25, 0.0

        dd -0.702, -0.055, 3.75, 0.0
        dd -0.702, -0.555, 3.75, 0.0
        dd -1.202, -0.055, 3.75, 0.0
        dd -1.202, -0.555, 3.75, 0.0
cube4:
        dd 1.172, -0.138, 3.25, 0.0
        dd 1.172, -0.638, 3.25, 0.0
        dd 0.672, -0.138, 3.25, 0.0
        dd 0.672, -0.638, 3.25, 0.0

        dd 1.172, -0.138, 3.75, 0.0
        dd 1.172, -0.638, 3.75, 0.0
        dd 0.672, -0.138, 3.75, 0.0
        dd 0.672, -0.638, 3.75, 0.0
cube5:
        dd -0.198, 1.144, 3.25, 0.0
        dd -0.198, 0.644, 3.25, 0.0
        dd -0.698, 1.144, 3.25, 0.0
        dd -0.698, 0.644, 3.25, 0.0

        dd -0.198, 1.144, 3.75, 0.0
        dd -0.198, 0.644, 3.75, 0.0
        dd -0.698, 1.144, 3.75, 0.0
        dd -0.698, 0.644, 3.75, 0.0
cube6:
        dd 0.009, -0.721, 3.25, 0.0
        dd 0.009, -1.221, 3.25, 0.0
        dd -0.491, -0.721, 3.25, 0.0
        dd -0.491, -1.221, 3.25, 0.0

        dd 0.009, -0.721, 3.75, 0.0
        dd 0.009, -1.221, 3.75, 0.0
        dd -0.491, -0.721, 3.75, 0.0
        dd -0.491, -1.221, 3.75, 0.0
cube7:
        dd 1.064, 0.831, 3.25, 0.0
        dd 1.064, 0.331, 3.25, 0.0
        dd 0.564, 0.831, 3.25, 0.0
        dd 0.564, 0.331, 3.25, 0.0

        dd 1.064, 0.831, 3.75, 0.0
        dd 1.064, 0.331, 3.75, 0.0
        dd 0.564, 0.831, 3.75, 0.0
        dd 0.564, 0.331, 3.75, 0.0
cube8:
        dd -0.746, 0.338, 3.25, 0.0
        dd -0.746, -0.162, 3.25, 0.0
        dd -1.246, 0.338, 3.25, 0.0
        dd -1.246, -0.162, 3.25, 0.0

        dd -0.746, 0.338, 3.75, 0.0
        dd -0.746, -0.162, 3.75, 0.0
        dd -1.246, 0.338, 3.75, 0.0
        dd -1.246, -0.162, 3.75, 0.0
cube9:
        dd 0.949, -0.465, 3.25, 0.0
        dd 0.949, -0.965, 3.25, 0.0
        dd 0.449, -0.465, 3.25, 0.0
        dd 0.449, -0.965, 3.25, 0.0

        dd 0.949, -0.465, 3.75, 0.0
        dd 0.949, -0.965, 3.75, 0.0
        dd 0.449, -0.465, 3.75, 0.0
        dd 0.449, -0.965, 3.75, 0.0
cube10:
        dd 0.184, 1.248, 3.25, 0.0
        dd 0.184, 0.748, 3.25, 0.0
        dd -0.316, 1.248, 3.25, 0.0
        dd -0.316, 0.748, 3.25, 0.0

        dd 0.184, 1.248, 3.75, 0.0
        dd 0.184, 0.748, 3.75, 0.0
        dd -0.316, 1.248, 3.75, 0.0
        dd -0.316, 0.748, 3.75, 0.0
cube11:
        dd -0.348, -0.551, 3.25, 0.0
        dd -0.348, -1.051, 3.25, 0.0
        dd -0.848, -0.551, 3.25, 0.0
        dd -0.848, -1.051, 3.25, 0.0

        dd -0.348, -0.551, 3.75, 0.0
        dd -0.348, -1.051, 3.75, 0.0
        dd -0.848, -0.551, 3.75, 0.0
        dd -0.848, -1.051, 3.75, 0.0
cube12:
        dd 1.226, 0.469, 3.25, 0.0
        dd 1.226, -0.031, 3.25, 0.0
        dd 0.726, 0.469, 3.25, 0.0
        dd 0.726, -0.031, 3.25, 0.0

        dd 1.226, 0.469, 3.75, 0.0
        dd 1.226, -0.031, 3.75, 0.0
        dd 0.726, 0.469, 3.75, 0.0
        dd 0.726, -0.031, 3.75, 0.0
cube13:
        dd -0.634, 0.718, 3.25, 0.0
        dd -0.634, 0.218, 3.25, 0.0
        dd -1.134, 0.718, 3.25, 0.0
        dd -1.134, 0.218, 3.25, 0.0

        dd -0.634, 0.718, 3.75, 0.0
        dd -0.634, 0.218, 3.75, 0.0
        dd -1.134, 0.718, 3.75, 0.0
        dd -1.134, 0.218, 3.75, 0.0
cube14:
        dd 0.617, -0.68, 3.25, 0.0
        dd 0.617, -1.18, 3.25, 0.0
        dd 0.117, -0.68, 3.25, 0.0
        dd 0.117, -1.18, 3.25, 0.0

        dd 0.617, -0.68, 3.75, 0.0
        dd 0.617, -1.18, 3.75, 0.0
        dd 0.117, -0.68, 3.75, 0.0
        dd 0.117, -1.18, 3.75, 0.0
cube15:
        dd 0.576, 1.195, 3.25, 0.0
        dd 0.576, 0.695, 3.25, 0.0
        dd 0.076, 1.195, 3.25, 0.0
        dd 0.076, 0.695, 3.25, 0.0

        dd 0.576, 1.195, 3.75, 0.0
        dd 0.576, 0.695, 3.75, 0.0
        dd 0.076, 1.195, 3.75, 0.0
        dd 0.076, 0.695, 3.75, 0.0
cube16:
        dd -0.612, -0.256, 3.25, 0.0
        dd -0.612, -0.756, 3.25, 0.0
        dd -1.112, -0.256, 3.25, 0.0
        dd -1.112, -0.756, 3.25, 0.0

        dd -0.612, -0.256, 3.75, 0.0
        dd -0.612, -0.756, 3.75, 0.0
        dd -1.112, -0.256, 3.75, 0.0
        dd -1.112, -0.756, 3.75, 0.0
cube17:
        dd 1.234, 0.074, 3.25, 0.0
        dd 1.234, -0.426, 3.25, 0.0
        dd 0.734, 0.074, 3.25, 0.0
        dd 0.734, -0.426, 3.25, 0.0

        dd 1.234, 0.074, 3.75, 0.0
        dd 1.234, -0.426, 3.75, 0.0
        dd 0.734, 0.074, 3.75, 0.0
        dd 0.734, -0.426, 3.75, 0.0
cube18:
        dd -0.383, 1.024, 3.25, 0.0
        dd -0.383, 0.524, 3.25, 0.0
        dd -0.883, 1.024, 3.25, 0.0
        dd -0.883, 0.524, 3.25, 0.0

        dd -0.383, 1.024, 3.75, 0.0
        dd -0.383, 0.524, 3.75, 0.0
        dd -0.883, 1.024, 3.75, 0.0
        dd -0.883, 0.524, 3.75, 0.0
cube19:
        dd 0.228, -0.75, 3.25, 0.0
        dd 0.228, -1.25, 3.25, 0.0
        dd -0.272, -0.75, 3.25, 0.0
        dd -0.272, -1.25, 3.25, 0.0

        dd 0.228, -0.75, 3.75, 0.0
        dd 0.228, -1.25, 3.75, 0.0
        dd -0.272, -0.75, 3.75, 0.0
        dd -0.272, -1.25, 3.75, 0.0
cube20:
        dd 0.917, 0.995, 3.25, 0.0
        dd 0.917, 0.495, 3.25, 0.0
        dd 0.417, 0.995, 3.25, 0.0
        dd 0.417, 0.495, 3.25, 0.0

        dd 0.917, 0.995, 3.75, 0.0
        dd 0.917, 0.495, 3.75, 0.0
        dd 0.417, 0.995, 3.75, 0.0
        dd 0.417, 0.495, 3.75, 0.0
cube21:
        dd -0.741, 0.118, 3.25, 0.0
        dd -0.741, -0.382, 3.25, 0.0
        dd -1.241, 0.118, 3.25, 0.0
        dd -1.241, -0.382, 3.25, 0.0

        dd -0.741, 0.118, 3.75, 0.0
        dd -0.741, -0.382, 3.75, 0.0
        dd -1.241, 0.118, 3.75, 0.0
        dd -1.241, -0.382, 3.75, 0.0
cube22:
        dd 1.089, -0.294, 3.25, 0.0
        dd 1.089, -0.794, 3.25, 0.0
        dd 0.589, -0.294, 3.25, 0.0
        dd 0.589, -0.794, 3.25, 0.0

        dd 1.089, -0.294, 3.75, 0.0
        dd 1.089, -0.794, 3.75, 0.0
        dd 0.589, -0.294, 3.75, 0.0
        dd 0.589, -0.794, 3.75, 0.0
cube23:
        dd -0.034, 1.209, 3.25, 0.0
        dd -0.034, 0.709, 3.25, 0.0
        dd -0.534, 1.209, 3.25, 0.0
        dd -0.534, 0.709, 3.25, 0.0

        dd -0.034, 1.209, 3.75, 0.0
        dd -0.034, 0.709, 3.75, 0.0
        dd -0.534, 1.209, 3.75, 0.0
        dd -0.534, 0.709, 3.75, 0.0

        ; ==== ^^^^^^^^^^ ==== ;

        ; ==== FLOAT CONSTANTS ==== ;
        float_ten dd 10.0
        float_five dd 5.0
        float_four dd 4.0
        float_three dd 3.0
        float_two_p_five dd 2.5
        float_two dd 2.0
        float_one_p_five dd 1.5
        float_one dd 1.0
        float_p_five dd 0.5
        float_zero dd 0.0
        float_minus_one dd -1.0
        float_minus_two dd -2.0

        float_height dd 40.0
        float_height_m1 dd 39.0
        
        float_width dd 155.0
        float_width_m1 dd 154.0

        deviation dd 0.0001
        float_negative_z_limit dd -5.85
        ; ==== ^^^^^^^^^^^^^^^ ==== ;

        ; ==== ANIMATION PARAMS ==== ;
        step dd 0.005
        smallstep dd 0.05
        rotate_step dd 0.1

        max_x dd 1.0
        min_x dd -1.0

        delay dq 0, 5000

        ; ---- ---- ASCII <
        pointchar db 0x30

        row TIMES WIDTH db 0x20
        row_len EQU $-row
        ; ---- <

        ; ==== ^^^^^^^^^^^^^^^^ ==== ;   


section .bss
        box1 resb box_size


section .text
global _start

_start:

        ;box plane1
        mov rax, [point1]
        mov [box1 + box.pl1 + plane.p1], rax
        mov rax, [point1+8]
        mov[box1 + box.pl1 + plane.p1 + 8], rax

        mov rax, [point2]
        mov [box1 + box.pl1 + plane.p2], rax
        mov rax, [point2+8]
        mov[box1 + box.pl1 + plane.p2 + 8], rax

        mov rax, [point3]
        mov [box1 + box.pl1 + plane.p3], rax
        mov rax, [point3+8]
        mov[box1 + box.pl1 + plane.p3 + 8], rax

        mov rax, [point4]
        mov [box1 + box.pl1 + plane.p4], rax
        mov rax, [point4+8]
        mov[box1 + box.pl1 + plane.p4 + 8], rax

        
        ;box plane2
        mov rax, [point5]
        mov [box1 + box.pl2 + plane.p1], rax
        mov rax, [point5+8]
        mov[box1 + box.pl2 + plane.p1 + 8], rax

        mov rax, [point6]
        mov [box1 + box.pl2 + plane.p2], rax
        mov rax, [point6+8]
        mov[box1 + box.pl2 + plane.p2 + 8], rax

        mov rax, [point7]
        mov [box1 + box.pl2 + plane.p3], rax
        mov rax, [point7+8]
        mov[box1 + box.pl2 + plane.p3 + 8], rax

        mov rax, [point8]
        mov [box1 + box.pl2 + plane.p4], rax
        mov rax, [point8+8]
        mov[box1 + box.pl2 + plane.p4 + 8], rax
        

        call go_home
        
        %macro MACRO_ANIMATE_CUBE 1
                mov rax, %1
                push rax
                call draw_box
                add rsp, 8
                

                lea rax, [%1 + box.pl1]
                push rax
                call move_plane_forward
                add rsp, 8
                lea rax, [%1 + box.pl2]
                push rax
                call move_plane_forward
                add rsp, 8

                push %1
                push point_center
                call rotate_box
                add rsp, 16
        %endmacro

        
        ; r10 - z dir
        mov r10, 1
        mov r12, 1
        
        .wait_start:
                ; mov rax, NANOSLEEP
                ; mov rdi, delay
                ; xor rsi, rsi
                ; syscall

                ; mov rax, point_center
                ; movss xmm0, [rax + point.x]
                ; movss xmm1, [float_p_five]
                ; addss xmm0, xmm1
                ; movss [rax + point.x], xmm0
                ; cmp r10, 1
                ; je .z_1
                ; jmp .z_0
                ; .z_1:
                ;         lea rax, [box1 + box.pl1]
                ;         push rax
                ;         call move_plane_forward
                ;         add rsp, 8

                ;         lea rax, [box1 + box.pl2]
                ;         push rax
                ;         call move_plane_forward
                ;         add rsp, 8

                ;         lea rax, [box1 + box.pl1]
                ;         push rax
                ;         call plane1_z_limit_check
                ;         add rsp, 8

                ;         cmp rax, 1
                        
                ;         je .z_set_0
                        
                ;         jmp .z_over
                ; .z_0:
                ;         lea rax, [box1 + box.pl1]
                ;         push rax
                ;         call move_plane_back
                ;         add rsp, 8

                ;         lea rax, [box1 + box.pl2]
                ;         push rax
                ;         call move_plane_back
                ;         add rsp, 8

                ;         lea rax, [box1 + box.pl1]
                ;         push rax
                ;         call plane1_z_limit_check
                ;         add rsp, 8

                ;         cmp rax, 1
                        
                ;         je .z_set_1
                        
                ;         jmp .z_over
                ; .z_set_0:
                ;         mov r10, 0
                ;         jmp .z_over
                ; .z_set_1:
                ;         mov r10, 1
                ;         jmp .z_over
                ; .z_over:


                ; cmp r12, 1
                ; je .x_1
                ; jmp .x_0
                ; .x_1:
                ;         lea rax, [box1 + box.pl1]
                ;         push rax
                ;         call move_plane_right
                ;         add rsp, 8

                ;         lea rax, [box1 + box.pl2]
                ;         push rax
                ;         call move_plane_right
                ;         add rsp, 8

                ;         lea rax, [box1 + box.pl2]
                ;         push rax
                ;         call plane_touching_wall_x
                ;         add rsp, 8
                        
                ;         cmp rax, 1

                ;         je .x_set_0
                ;         jmp .x_over
                ; .x_0:
                ;         lea rax, [box1 + box.pl1]
                ;         push rax
                ;         call move_plane_left
                ;         add rsp, 8

                ;         lea rax, [box1 + box.pl2]
                ;         push rax
                ;         call move_plane_left
                ;         add rsp, 8

                ;         lea rax, [box1 + box.pl2]
                ;         push rax
                ;         call plane_touching_wall_x
                ;         add rsp, 8
                ;         cmp rax, 1
                ;         je .x_set_1
                ;         jmp .x_over
                ; .x_set_0:
                ;         lea rax, [box1 + box.pl1]
                ;         push rax
                ;         call move_plane_left
                ;         add rsp, 8

                ;         lea rax, [box1 + box.pl2]
                ;         push rax
                ;         call move_plane_left
                ;         add rsp, 8

                ;         mov r12, 0
                ;         jmp .x_over
                ; .x_set_1:
                ;         lea rax, [box1 + box.pl1]
                ;         push rax
                ;         call move_plane_right
                ;         add rsp, 8

                ;         lea rax, [box1 + box.pl2]
                ;         push rax
                ;         call move_plane_right
                ;         add rsp, 8

                ;         mov r12, 1
                ;         jmp .x_over
                ; .x_over:
                
                jmp .draw
                
        

        .draw:
                call ansi_reset

                mov rax, point_center
                movss xmm0, [rax + point.z]
                movss xmm1, [smallstep]
                subss xmm0, xmm1
                movss [rax + point.z], xmm0
                movss xmm1, [float_negative_z_limit]
                ucomiss xmm0, xmm1
                jbe .over
                jmp .fine

                .over:
                        
                        MACRO_EXIT
                .fine:

                call go_home
                call fill_background

                

                MACRO_ANIMATE_CUBE cube0
                MACRO_ANIMATE_CUBE cube1
                MACRO_ANIMATE_CUBE cube2
                MACRO_ANIMATE_CUBE cube3
                MACRO_ANIMATE_CUBE cube4
                MACRO_ANIMATE_CUBE cube5
                MACRO_ANIMATE_CUBE cube6
                MACRO_ANIMATE_CUBE cube7
                MACRO_ANIMATE_CUBE cube8
                MACRO_ANIMATE_CUBE cube9
                MACRO_ANIMATE_CUBE cube10
                MACRO_ANIMATE_CUBE cube11
                MACRO_ANIMATE_CUBE cube12
                MACRO_ANIMATE_CUBE cube13
                MACRO_ANIMATE_CUBE cube14
                MACRO_ANIMATE_CUBE cube15
                MACRO_ANIMATE_CUBE cube16
                MACRO_ANIMATE_CUBE cube17
                MACRO_ANIMATE_CUBE cube18
                MACRO_ANIMATE_CUBE cube19
                MACRO_ANIMATE_CUBE cube20
                MACRO_ANIMATE_CUBE cube21
                MACRO_ANIMATE_CUBE cube22
                MACRO_ANIMATE_CUBE cube23
                

                ; movss xmm0, dword [point_center + point.x]
                ; movss xmm1, dword [point_center + point.y]
                ; movss xmm2, dword [point_center + point.z]
                ; sub rsp, 8
                ; mov [rsp], 0
                ; movss dword [rsp], xmm2
                ; sub rsp, 8
                ; mov [rsp], 0
                ; movss dword [rsp], xmm1
                ; sub rsp, 8
                ; mov [rsp], 0
                ; movss dword [rsp], xmm0
                ; call draw_point
                ; add rsp, 8*3

                mov rax, NANOSLEEP
                mov rdi, delay
                xor rsi, rsi
                syscall
                jmp .wait_start
        
        

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

make_black:
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, black
        mov rdx, black_len
        syscall
        ret

make_red:
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, red
        mov rdx, red_len
        syscall
        ret

make_green:
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, green
        mov rdx, green_len
        syscall
        ret

make_yellow:
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, yellow
        mov rdx, yellow_len
        syscall
        ret

make_blue:
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, blue
        mov rdx, blue_len
        syscall
        ret

make_magenta:
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, magenta
        mov rdx, magenta_len
        syscall
        ret

make_cyan:
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, cyan
        mov rdx, cyan_len
        syscall
        ret

make_white:
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, white
        mov rdx, white_len
        syscall
        ret

make_default_color:
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, default_color
        mov rdx, default_color_len
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

        .line_loop:
                cmp r15, 0
                je .row_loop
                mov rax, SYS_WRITE
                mov rdi, STDOUT
                mov rsi, one_line_down
                mov rdx, one_line_down_len
                syscall
                dec r15
                jmp .line_loop
        .row_loop:
                cmp r14, 0
                je .end
                mov rax, SYS_WRITE
                mov rdi, STDOUT
                mov rsi, one_col_right
                mov rdx, one_col_right_len
                syscall
                dec r14
                jmp .row_loop
        .end:
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
        divss xmm0, [float_two]
        mulss xmm0, [float_width]
        cvtss2si eax, xmm0
        cmp eax, 0
        jl .end
        cmp eax, WIDTH
        jg .end
        push rax

        movss xmm0, dword [y]
        divss xmm0, [z]
        addss xmm0, [float_one]
        divss xmm0, [float_two]
        mulss xmm0, [float_height]
        cvtss2si eax, xmm0
        cmp eax, 0
        jl .skip1
        cmp eax, HEIGHT
        jge .skip1
        push rax

        call move_cursor
        add rsp, 16

        jmp .skipover
        .skip1:
                add rsp, 8
                jmp .end
        .skipover:
                
        
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, backspace
        mov rdx, 1
        syscall

        movss xmm0, dword [z]
        ucomiss xmm0, [float_p_five]
        jb .p5
        ucomiss xmm0, [float_one]
        jb .one
        ucomiss xmm0, [float_one_p_five]
        jb .onep5
        ucomiss xmm0, [float_two]
        jb .two
        ucomiss xmm0, [float_two_p_five]
        jb .two
        ucomiss xmm0, [float_three]
        jb .three
        ucomiss xmm0, [float_four]
        jb .four
        ucomiss xmm0, [float_five]
        jb .five
        ucomiss xmm0, [float_ten]
        jb .ten
        jmp .end

        .p5:
                call make_white
                jmp .over
        .one:
                call make_cyan
                jmp .over
        .onep5:
                call make_magenta
                jmp .over
        .two:
                call make_blue
                jmp .over
        .three:
                call make_yellow
                jmp .over
        .four:
                call make_green
                jmp .over
        .five:
                call make_red
                jmp .over
        .ten:
                call make_black
                jmp .over
        .over:
                mov rax, SYS_WRITE
                mov rdi, STDOUT
                mov rsi, pointchar
                mov rdx, 1
                syscall

        
        .end:
                call ansi_reset
                pop rbp
                ret
%undef z
%undef y
%undef x


%define arg1 rbp + 16
move_plane_right:
        push rbp
        mov rbp, rsp

        movss xmm1, [step]

        mov rax, [arg1]
        movss xmm0, [rax + plane.p1 + point.x]
        addss xmm0, xmm1
        movss [rax + plane.p1 + point.x], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p2 + point.x]
        addss xmm0, xmm1
        movss [rax + plane.p2 + point.x], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p3 + point.x]
        addss xmm0, xmm1
        movss [rax + plane.p3 + point.x], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p4 + point.x]
        addss xmm0, xmm1
        movss [rax + plane.p4 + point.x], xmm0

        pop rbp
        ret
%undef arg1


%define arg1 rbp + 16
move_plane_left:
        push rbp
        mov rbp, rsp

        movss xmm1, [step]

        mov rax, [arg1]
        movss xmm0, [rax + plane.p1 + point.x]
        subss xmm0, xmm1
        movss [rax + plane.p1 + point.x], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p2 + point.x]
        subss xmm0, xmm1
        movss [rax + plane.p2 + point.x], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p3 + point.x]
        subss xmm0, xmm1
        movss [rax + plane.p3 + point.x], xmm0

        mov rax, [arg1]
        movss xmm0, [rax + plane.p4 + point.x]
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
        movss xmm1, [min_x]
        movss xmm2, [max_x]

        mov rax, [arg1]
        movss xmm0, [rax + plane.p1 + point.x]
        ucomiss xmm0, xmm1
        jb .yes
        ucomiss xmm0, xmm2
        ja .yes

        mov rax, [arg1]
        movss xmm0, [rax + plane.p2 + point.x]
        ucomiss xmm0, xmm1
        jb .yes
        ucomiss xmm0, xmm2
        ja .yes

        mov rax, [arg1]
        movss xmm0, [rax + plane.p3 + point.x]
        ucomiss xmm0, xmm1
        jb .yes
        ucomiss xmm0, xmm2
        ja .yes

        mov rax, [arg1]
        movss xmm0, [rax + plane.p4 + point.x]
        ucomiss xmm0, xmm1
        jb .yes
        ucomiss xmm0, xmm2
        ja .yes

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
        movss xmm1, [float_minus_two]
        movss xmm2, [float_two]

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
%define _dz xmm13

%define slope xmm7

%define curpx xmm8
%define curpy xmm9
%define curpz xmm14

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

        movss _dy, p2_y
        subss _dy, p1_y

        movss _dz, p2_z
        subss _dz, p1_z

        movss slope, _dy
        divss slope, _dx

        movss curpx, p1_x
        movss curpy, p1_y
        movss curpz, p1_z
        .decide:
                movss temp, _dx
                mulss temp, temp
                sqrtss temp, temp
                ucomiss temp, [deviation]
                jb .vertical

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

                movss temp, curpx
                subss temp, p1_x
                divss temp, _dx
                mulss temp, _dz
                movss curpz, p1_z
                addss curpz, temp

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

                movss temp, curpx
                subss temp, p1_x
                divss temp, _dx
                mulss temp, _dz
                movss curpz, p1_z
                addss curpz, temp

                ucomiss curpx, p2_x
                jbe .end
                jmp .loop_shared
        
        .vertical:
                movss temp, _dy
                mulss temp, temp
                sqrtss temp, temp
                ucomiss temp, [deviation]
                jb .z

                ucomiss _dy, [float_zero]
                jae .vertical_up
                jbe .vertical_down
                jmp .end
        
        .vertical_up:
                addss curpy, [smallstep]
                
                movss temp, curpy
                subss temp, p1_y
                divss temp, _dy
                mulss temp, _dz
                movss curpz, p1_z
                addss curpz, temp

                ucomiss curpy, p2_y
                jae .end
                jmp .loop_shared
        .vertical_down:
                subss curpy, [smallstep]

                movss temp, curpy
                subss temp, p1_y
                divss temp, _dy
                mulss temp, _dz
                movss curpz, p1_z
                addss curpz, temp

                ucomiss curpy, p2_y
                jbe .end
                jmp .loop_shared
        
        .z:
                ucomiss _dz, [float_zero]
                jae .z_up
                jbe .z_down
                jmp .end
        .z_up:
                addss curpz, [smallstep]
                ucomiss curpz, p2_z
                jae .end
                jmp .loop_shared

        .z_down:
                subss curpz, [smallstep]
                ucomiss curpz, p2_z
                jbe .end
                jmp .loop_shared

        .loop_shared:
                sub rsp, 8
                mov [rsp], 0
                movss dword [rsp], curpz
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
%undef arg1
%undef arg2

%undef p1_x
%undef p1_y
%undef p1_z

%undef p2_x
%undef p2_y
%undef p2_z

%undef _dx
%undef _dy
%undef _dz

%undef slope

%undef curpx
%undef curpy
%undef curpz

%undef temp


%define arg1 rbp + 16
draw_box:
        push rbp
        mov rbp, rsp

        mov r9, [arg1]
        lea rax, [r9 + box.pl1]
        push rax
        call draw_plane
        add rsp, 8

        mov r9, [arg1]
        lea rax, [r9 + box.pl2]
        push rax
        call draw_plane
        add rsp, 8

        mov r9, [arg1]
        lea rax, [r9 + box.pl1 + plane.p1]
        push rax
        lea rax, [r9 + box.pl2 + plane.p1]
        push rax
        call draw_line
        add rsp, 8*2

        mov r9, [arg1]
        lea rax, [r9 + box.pl1 + plane.p2]
        push rax
        lea rax, [r9 + box.pl2 + plane.p2]
        push rax
        call draw_line
        add rsp, 8*2

        mov r9, [arg1]
        lea rax, [r9 + box.pl1 + plane.p3]
        push rax
        lea rax, [r9 + box.pl2 + plane.p3]
        push rax
        call draw_line
        add rsp, 8*2

        mov r9, [arg1]
        lea rax, [r9 + box.pl1 + plane.p4]
        push rax
        lea rax, [r9 + box.pl2 + plane.p4]
        push rax
        call draw_line
        add rsp, 8*2

        .end:
                pop rbp
                ret
%undef arg1


%define ang_arg rbp + 16
%define _po rbp + 24
%define _p rbp + 32

%define resx xmm5
%define resy xmm6
%define resz xmm7

%define p_x xmm1
%define p_y xmm2
%define p_z xmm11

%define po_x xmm3
%define po_y xmm4
%define po_z xmm12

%define temp xmm8
%define temp2 xmm9
%define temp3 xmm13
%define sine xmm14
%define cosine xmm15
%define angle xmm10
rotate_point:
        push rbp
        mov rbp, rsp

        mov rax, [_p]
        movss p_x, [rax + point.x]
        movss p_y, [rax + point.y]
        movss p_z, [rax + point.z]

        mov rax, [_po]
        movss po_x, [rax + point.x]
        movss po_y, [rax + point.y]
        movss po_z, [rax + point.z]

        movss angle, [ang_arg]

        sub rsp, 8
        movss [rsp], angle
        fld dword [rsp]
        fsin
        fstp dword [rsp]
        movss sine, [rsp]

        movss [rsp], angle
        fld dword [rsp]
        fcos
        fstp dword [rsp]
        movss cosine, [rsp]
        add rsp, 8

        subss p_x, po_x
        subss p_y, po_y

        movss temp, cosine
        movss temp3, p_x
        mulss temp, temp3

        movss temp2, sine
        movss temp3, p_y
        mulss temp2, temp3

        movss resx, temp
        subss resx, temp2

        movss temp, cosine
        movss temp3, p_y
        mulss temp, temp3

        movss temp2, sine
        movss temp3, p_x
        mulss temp2, temp3

        movss resy, temp
        addss resy, temp2
        movss resz, p_z

        addss resy, po_y
        addss resx, po_x

        mov rax, [_p]
        movss [rax + point.x], resx
        movss [rax + point.y], resy
        movss [rax + point.z], resz

        pop rbp
        ret
%undef ang_arg
%undef _po
%undef _p

%undef resx
%undef resy
%undef resz

%undef p_x
%undef p_y
%undef p_z

%undef po_x
%undef po_y
%undef po_z

%undef temp
%undef temp2
%undef temp3
%undef sine
%undef cosine
%undef angle



%define ang_arg rbp + 16
%define _po rbp + 24
%define _p rbp + 32

%define resx xmm5
%define resy xmm6
%define resz xmm7

%define p_x xmm1
%define p_y xmm2
%define p_z xmm11

%define po_x xmm3
%define po_y xmm4
%define po_z xmm12

%define temp xmm8
%define temp2 xmm9
%define temp3 xmm13
%define sine xmm14
%define cosine xmm15
%define angle xmm10
rotate_point_z:
        push rbp
        mov rbp, rsp

        mov rax, [_p]
        movss p_x, [rax + point.x]
        movss p_y, [rax + point.y]
        movss p_z, [rax + point.z]

        mov rax, [_po]
        movss po_x, [rax + point.x]
        movss po_y, [rax + point.y]
        movss po_z, [rax + point.z]

        movss angle, [ang_arg]

        sub rsp, 8
        movss [rsp], angle
        fld dword [rsp]
        fsin
        fstp dword [rsp]
        movss sine, [rsp]

        movss [rsp], angle
        fld dword [rsp]
        fcos
        fstp dword [rsp]
        movss cosine, [rsp]
        add rsp, 8

        subss p_x, po_x
        subss p_y, po_y
        subss p_z, po_z

        movss temp, cosine
        movss temp3, p_x
        mulss temp, temp3

        movss temp2, sine
        movss temp3, p_z
        mulss temp2, temp3

        movss resx, temp
        addss resx, temp2

        movss temp, sine
        movss temp3, p_x
        mulss temp, temp3
        mulss temp, [float_minus_one]

        movss temp2, cosine
        movss temp3, p_z
        mulss temp2, temp3

        movss resz, temp
        addss resz, temp2
        
        movss resy, p_y

        addss resy, po_y
        addss resx, po_x
        addss resz, po_z

        mov rax, [_p]
        movss [rax + point.x], resx
        movss [rax + point.y], resy
        movss [rax + point.z], resz

        pop rbp
        ret
%undef ang_arg
%undef _po
%undef _p

%undef resx
%undef resy
%undef resz

%undef p_x
%undef p_y
%undef p_z

%undef po_x
%undef po_y
%undef po_z

%undef temp
%undef temp2
%undef temp3
%undef sine
%undef cosine
%undef angle


%define box_addr rbp + 24
%define po rbp + 16
rotate_box:
        push rbp
        mov rbp, rsp

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl1 + plane.p1]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point_z
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl1 + plane.p2]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point_z
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl1 + plane.p3]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point_z
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl1 + plane.p4]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point_z
        add rsp, 24



        mov rdi, [box_addr]
        lea rax, [rdi + box.pl2 + plane.p1]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point_z
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl2 + plane.p2]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point_z
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl2 + plane.p3]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point_z
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl2 + plane.p4]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point_z
        add rsp, 24




        mov rdi, [box_addr]
        lea rax, [rdi + box.pl1 + plane.p1]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl1 + plane.p2]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl1 + plane.p3]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl1 + plane.p4]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24



        mov rdi, [box_addr]
        lea rax, [rdi + box.pl2 + plane.p1]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl2 + plane.p2]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl2 + plane.p3]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl2 + plane.p4]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24

        pop rbp
        ret
%undef box_addr
%undef po

%define box_addr rbp + 24
%define po rbp + 16
rotate_box_xy:
        push rbp
        mov rbp, rsp



        mov rdi, [box_addr]
        lea rax, [rdi + box.pl1 + plane.p1]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl1 + plane.p2]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl1 + plane.p3]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl1 + plane.p4]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24



        mov rdi, [box_addr]
        lea rax, [rdi + box.pl2 + plane.p1]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl2 + plane.p2]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl2 + plane.p3]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24

        mov rdi, [box_addr]
        lea rax, [rdi + box.pl2 + plane.p4]
        push rax
        push [po]
        sub rsp, 8
        mov [rsp], 0
        movss xmm0, [rotate_step]
        movss dword [rsp], xmm0
        call rotate_point
        add rsp, 24

        pop rbp
        ret
%undef box_addr
%undef po