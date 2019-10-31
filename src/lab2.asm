include "emu8086.inc"

data segment
    buffer db 128 dup(0)
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
    ; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; input number
    print "Input a number (1~9):"
    mov ah, 01h
    int 21h
    sub al, '0'
    xor ah, ah
    push ax
    
    
    ; save numbers to buffer
    mul al
    mov cx, ax
    save:
        mov bx, cx
        mov buffer[bx-1], cl
        loop save

    ; print numbers in buffer
    xor bx, bx ; number count
    xor dh, dh ; line count
    pop ax
    mov cx,ax
    print_line:
        printn ""
        push cx
            mov cx,ax
            inc dh
            xor dl, dl
            print_in_a_line:
                cmp dl,dh
                jge skip_print_num
                
                ; print num in buffer[bx]
                push ax
                xor ax, ax
                mov al, buffer[bx]
                call print_num_uns
                pop ax
                inc dl
                print " "
                    
                skip_print_num:      
                      
                inc bx
                loop print_in_a_line
        pop cx
        loop print_line

    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends
DEFINE_PRINT_NUM_UNS
end start ; set entry point and stop the assembler.
