include "emu8086.inc"

data segment
    input_buffer db 16, 0, 16 dup(0) ; used to store input
    big_number_buffer db 20 dup(0) ; every byte is a num, after each mutiply, you should make sure value in each byte is less than 10
data ends

stack segment
    dw   512  dup(0)
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
    printn ""
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx ; current number
    mov cl, input_buffer[1]
    scan:
        mov al, input_buffer[bx+2]
        cmp al, '0'
        jb error
        cmp al, '9'
        ja error
        
        sub al,'0'
        
        push ax
        push bx
        mov ax, dx
        mov bx, 10
        mul bx
        mov dx, ax
        pop bx
        pop ax
        add dx, ax
        
        inc bx
        loop scan
    

    mov ax, dx
    call print_num
    print "!= "
    
    mov bx, dx
    call fact ; calc (bx)! and save to big_number_buffer
    
    mov dx, 20
    call print_big_number ; print big_number_buffer, dx saves its length

    jmp no_error
    error:
        print "Input wrong!"
    no_error:
    mov ax, 4c00h ; exit to operating system.
    int 21h
    main endp
    
    
    fact proc near ; calc (bx)! and save to big_number_buffer
        cmp bx, 0
        jne recurrence
        mov cx, 20
        clear_a_bit:
            mov bx, cx
            mov big_number_buffer[bx-1], 0
            loop clear_a_bit
        mov big_number_buffer[0], 1
        ret
        recurrence:
            push bx
            dec bx
            call fact
            pop bx 
            
            ; multiply big_number_buffer with bx
            push dx
            mov dx, 20
            call multiply_big_number_with_small_number
            pop dx

            ret
    fact endp
    
    multiply_big_number_with_small_number proc near ; dx saves big number's length, bx saves small number (less than 28)
    ; big number is decimal number in array form, each byte is each bit, multiply it with a number less than 28
    ; how 28 is calculated: 9*x<=255, so x<28
        pusha
            ;print "Now big_number is:"
            ;call print_big_number
            ;print " Multiply it with "
            ;print_dw_reg bx
            ;printn ""
            push dx
            mov cx, dx
            mov dx, bx; use dx to save the small number instead
            xor ax, ax
            multiply_a_bit:
                mov bx, cx
                mov al, big_number_buffer[bx-1]
                mul dl
                mov big_number_buffer[bx-1], al
                loop multiply_a_bit
                      
 
            pop cx
            dec cx ; reduce (big number's length - 1) times
            xor bx, bx ; bx now is index
            reduce_a_bit:
                xor ax, ax
                mov al, big_number_buffer[bx]
                push bx
                mov bl, 10
                div bl

                pop bx
                add big_number_buffer[bx+1], al
                mov big_number_buffer[bx], ah
            
                inc bx
                loop reduce_a_bit
            

        popa
        ret
    multiply_big_number_with_small_number endp

    print_big_number proc near ; print big_number_buffer, dx saves its length
        pusha
        mov cx, dx
        xor ax, ax
        mov dx, 0 ; 0 means havenot found first bit not zero
        print_a_byte:
            mov bx, cx
            mov al, big_number_buffer[bx-1]
    
            ; if al = 0 and dx = 0 and cx != 1, then skip print this byte
            cmp al, 0
            jne judge_fail
            cmp dx, 0
            jne judge_fail
            cmp cx, 1
            je judge_fail
            jmp skip_print_this_byte
            judge_fail:
    
            cmp al, 0
            je skip_set_dx
            mov dx, 1
            skip_set_dx:
    
            call print_num
            skip_print_this_byte:
    
            loop print_a_byte
        popa
        ret
    print_big_number endp
    
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
