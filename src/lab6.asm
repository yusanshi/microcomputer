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

input_float_number_and_saved_to_fpu_top macro
    pusha
    mov di, offset input_buffer
    gets
    atof
    mov di, offset general_tbyte_temp
    sefpa
    fld general_tbyte_temp
    popa
endm

.data 
    x tbyte 0
    a1 tbyte 0
    a2 tbyte 0
    a3 tbyte 0
    factor_6 tbyte 1000000.0
    input_buffer db 36 dup(0)
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
    fstp x

    printf
	db	"Input a1: ",0
    input_float_number_and_saved_to_fpu_top
    fstp a1

    printf
	db	"Input a2: ",0
    input_float_number_and_saved_to_fpu_top
    fstp a2

    printf
	db	"Input a3: ",0
    input_float_number_and_saved_to_fpu_top
    fstp a3

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
	db	"The result is: ", 0

    print_fpu_top

    jmp no_error
    error:
    printf
    db "Error: x<0!",0

    no_error:
    mov ax, 4c00h ; exit to operating system.
    int 21h
end start