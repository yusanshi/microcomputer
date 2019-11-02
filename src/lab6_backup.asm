.model 	small
.386
.xlist
include stdlib.a
includelib stdlib.lib
.list
.stack 128

print_fpu_top macro
	local skip_print_minus, print_a_bit_integer, skip_set_meet, will_putc, skip_putc, skip_set_meet2, will_putc2, skip_putc2, print_a_bit_fraction
    pusha
    fld st(0)
    fld factor_6
    fmul
    fbstp general_tbyte_temp
    mov al, byte ptr general_tbyte_temp[9]
    and al, 11110000b
    shr al, 4
    add al, 48
    cmp al, '8'
    jne skip_print_minus
    mov al, '-'
    putc
    skip_print_minus:

    mov cx, 6
    mov dx, 0; 0: not meet no zero 1: has meet
    print_a_bit_integer:
        mov bx, cx
        add bx, 2
        mov al, byte ptr general_tbyte_temp[bx]

        push ax
        and al, 11110000b
        shr al, 4
        add al, 48
        cmp al, '0'
        je skip_set_meet
        mov dx, 1
        skip_set_meet:
        ; not print if char == 0 and has meet == 0
        cmp al, '0'
        jne will_putc
        cmp dx, 0
        jne will_putc
        jmp skip_putc
        will_putc:
        putc
        skip_putc:
        pop ax
        

        and al, 00001111b
        add al, 48
        cmp al, '0'
        je skip_set_meet2
        mov dx, 1
        skip_set_meet2:

        ; not print if char == 0 and has meet = 0 and cx != 1
        cmp al, '0'
        jne will_putc2
        cmp dx, 0
        jne will_putc2
        cmp cx, 1
        je will_putc2
        jmp skip_putc2
        will_putc2:
        putc
        skip_putc2:

        loop print_a_bit_integer

    mov al, '.'
    putc

    mov cx, 3
    print_a_bit_fraction:
        mov bx, cx
        sub bx, 1
        mov al, byte ptr general_tbyte_temp[bx]
        push ax
        and al, 11110000b
        shr al, 4
        add al, 48
        putc
        pop ax
        and al, 00001111b
        add al, 48
        putc
        loop print_a_bit_fraction
    popa
endm

get_tbyte_value_from_string macro src, dest
    pusha

    popa
endm

input_float_number_and_saved_to_fpu_top macro
    local divide_one_time
    pusha

    ; input string containing entire number string to input_buffer
    mov di, offset input_buffer
    gets
    ; split them into integer_buffer, and fraction_buffer and push fraction width (if no dot, firstly insert '.0' at the end)

    ; parse integer_buffer into integer_tbyte_temp, fraction_buffer into fraction_tbyte_temp
    get_tbyte_value_from_string integer_buffer, integer_tbyte_temp
    get_tbyte_value_from_string fraction_buffer, fraction_tbyte_temp

    ; divide fraction_tbyte_temp with 10^(width poped)
    pop cx
    divide_one_time:
        fld fraction_tbyte_temp
        fld factor_1
        fdiv
        fstp fraction_tbyte_temp
        loop divide_one_time

    fld integer_tbyte_temp
    fld fraction_tbyte_temp
    fadd
    popa
endm

.data 
    x_error_msg db "Error: x<0!",0
    x tbyte 6.0
    a1 tbyte 7.0
    a2 tbyte 1.0
    a3 tbyte 2.0
    x_dd dd 6.0
    a1_dd dd 7.0
    a2_dd dd 1.0
    a3_dd dd 2.0
    factor_6 tbyte 1000000.0
    factor_1 tbyte 10.0
    result tbyte 0
    input_buffer db 36 dup(0)
    integer_buffer db 16 dup(0)
    fraction_buffer db 16 dup(0)
    integer_tbyte_temp tbyte 0
    fraction_tbyte_temp tbyte 0
    integer_dw_temp dw 0
    fraction_dw_temp dw 0
    general_tbyte_temp tbyte 0

.code
start:
    mov	ax, @data
	mov	ds, ax
    mov es, ax
    finit

    printf
	db	"Input x: ",0
    input_float_number_and_saved_to_fpu_top
    ;fstp x
    putcr

    printf
	db	"Input a1: ",0
    ;input_float_number_and_saved_to_fpu_top
    ;fstp a1
    putcr

    printf
	db	"Input a2: ",0
    ;input_float_number_and_saved_to_fpu_top
    ;fstp a2
    putcr

    printf
	db	"Input a3: ",0
    ;input_float_number_and_saved_to_fpu_top
    ;fstp a3
    putcr


    fld x ; x
    ftst ; compare with 0
    fstsw ax
    sahf
    jb error
    fsqrt ; sqrt(x)
    fld a1; a1, sqrt(x)
    fmul ; a1*sqrt(x)
    fld a2; a2, a1*sqrt(x)
    fld x ; x, a2, a1*sqrt(x)
    fyl2x ; a2*log2(x), a1*sqrt(x)
    fld x ; x, a2*log2(x), a1*sqrt(x)
    fsin  ; sin(x), a2*log2(x), a1*sqrt(x)
    fld a3; a3, sin(x), a2*log2(x), a1*sqrt(x)
    fmul  ; a3*sin(x), a2*log2(x), a1*sqrt(x)
    fadd  ; a3*sin(x) + a2*log2(x), a1*sqrt(x)
    fadd  ; a3*sin(x) + a2*log2(x) + a1*sqrt(x)

    printf
	db	"The result is: ",0

    print_fpu_top

    jmp no_error
    error:
    mov di, offset x_error_msg
    puts

    no_error:
    mov ax, 4c00h ; exit to operating system.
    int 21h
end start