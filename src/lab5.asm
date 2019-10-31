include "emu8086.inc"

data segment
    buffer db 1024, 0, 1024 dup(0) ; used to store input
    stack_backup dw 2048 dup(0) 
    ; remember to shi bx! low address: stack top, high address: stack base
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
    xor bx, bx
    xor dx, dx ; dx: number count
    xor cx, cx ; current number
    scan:
        mov al, input_buffer[bx+2]
        inc bx

        cmp al, '0'
        jb not_a_num
        cmp al, '9'
        ja not_a_num

        ; assemble the number

        jmp temp_location
        not_a_num:
        ;finish assembling
        ;push assembled number to opnd stack
        ;reset to prepare for assembling
        temp_location:

        cmp al, 0
        je end_scan




        cmp al, '('
        jne not_left_parenthesis
        ; optr.push(char)
        not_left_parenthesis:

        cmp al, ')'
        jne not_right_parenthesis
            ;if temp == '(':
            ;    optr.pop(anywhere)
            ;else:
            ;    optr.pop(temp) (temp is an operator)
            ;    opnd.pop(b)
            ;    opnd.pop(a)
            ;    opnd.push((a temp b))
            ;    index - 1 
        not_right_parenthesis:

        cmp al, '+'
        je is_add_or_minus
        cmp al, '-'
        je is_add_or_minus
        jmp not_add_or_minus
        is_add_or_minus:
            ;if temp == '(':
            ;    optr.push(char)
            ;else:
            ;    optr.pop(temp) (temp is an operator)
            ;    opnd.pop(b)
            ;    opnd.pop(a)
            ;    opnd.push((a temp b))
            ;    index - 1

        not_add_or_minus:
        jmp error
    



    end_scan:

            
    jmp no_error
    error:
        print "Input wrong!"
    no_error:

    mov ax, 4c00h ; exit to operating system.
    int 21h
    main endp

    ; when push an optr, first push the ascii of the optr, then push 32767 (efffh).
    ; when push an opnd, first push the number, then push -32768 (8000h).

    optr_push proc near

    optr_push endp


    optr_pop proc near

    optr_pop endp


    opnd_push proc near

    opnd_push endp


    opnd_pop proc near

    opnd_pop endp



    opnd_top proc near

    opnd_top endp


    clear_stack_backup proc near
        TODO
        mov stack_backup[0], al
        or
        mov stack_backup[0], ax
    clear_stack_backup endp

code ends
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS
print_dw_reg macro  p ; p is dw regester to print
            push ax
            mov ax, p
            call print_num
            print " "
            pop ax
endm
print_db_reg macro  p ; p is db regester to print
            push ax
            mov al, p
            xor ah, ah
            call print_num
            print " "
            pop ax
endm
end start ; set entry point and stop the assembler.
