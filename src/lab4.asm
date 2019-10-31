include "emu8086.inc"

data segment
    buffer db 16 dup(0) ; used to store input
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
    
    ; input string and parse it as a number into dx (positive)
    print "Input a nubmer (0~20): "
    mov dx, offset buffer
    mov ah, 0ah
    int 21h
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx ; current number
    mov cl, buffer[1]
    scan:
        mov al, buffer[bx+2]
        cmp al, '0'
        ;jb error
        cmp al, '9'
        ;ja error
        
        sub al,'0'
        
        push ax
        push bx
        mov ax, dx
        mov bx, 10
        mul bx
        mov dx, ax
        pop bx
        pop ax
        
        inc bx
        loop scan
    
        

    mov ax, dx
    call print_num
    print "!= "



            
    jmp no_error
    error:
        print "Input wrong!"
    no_error:
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS
end start ; set entry point and stop the assembler.
