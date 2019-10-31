include "emu8086.inc"

data segment
    buffer db 1024, 0, 1024 dup(0) ; used to store input
data ends

stack segment
    dw   2048  dup(0)
    ; when push an optr, first push the ascii of the optr, then push 32767 (efffh).
    ; when push an opnd, first push the number, then push -32768 (8000h).
stack ends

code segment
    main proc
    start:
    ; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    
    ; input string and parse it as a number into dx (positive)
    print "Input a nubmer (0~20): "
    mov dx, offset input_buffer
    mov ah, 0ah
    int 21h

    ; scan string in buffer to stack
    ; ascii: '(': 40 ')':41 '-':45
    xor bx, bx
    xor dx, dx ; dh: number count  dl: is_negative
    xor cx, cx ; current number

    scan:
        mov al, input_buffer[bx+2]
        inc bx
        cmp al, 0    
        je end_scan

        cmp al, '0'
        jb not_a_num
        cmp al, '9'
        ja not_a_num




        jmp scan
        not_a_num:

        cmp al, '-'
        jne not_minus

        jmp scan
        not_minus:

        cmp al, '('
        jne not_left_parenthesis
        push '('
        push efffh
        jmp scan
        not_left_parenthesis:

        cmp al, ')'
        jne not_right_parenthesis
        push ')'
        push efffh
        jmp scan
        not_right_parenthesis: 
    
        jmp error


    end_scan:

            
    jmp no_error
    error:
        print "Input wrong!"
    no_error:
    mov ax, 4c00h ; exit to operating system.
    int 21h
    main endp 
code ends
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS
end start ; set entry point and stop the assembler.
