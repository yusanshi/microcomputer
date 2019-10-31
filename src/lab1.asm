include "emu8086.inc"

data segment
    buffer db 128,0, 128 dup(0)
    input_file db "Input1.txt", 0
    output_file db "Output1.txt", 0
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

    ; input string
    print "Input string:"
    mov dx, offset buffer
    mov ah, 0ah
    int 21h

    ; create Input1.txt
    mov cx, 0
    mov dx, offset input_file
    mov ah, 3ch
    int 21h
    push ax

    ; save input to Input1.txt
    mov bx, ax
    xor cx, cx
    mov cl, buffer[1]
    mov dx, offset buffer + 2
    mov ah, 40h
    int 21h

    ; close Input1.txt
    pop bx
    mov ah, 3eh
    int 21h


    ; transform character in buffer
    xor cx, cx
    mov cl, buffer[1]
    scan:
        mov bx, cx
        mov al, buffer[bx+1]
        cmp al, 'a'
        jb is_not_lowercase
        cmp al, 'z'
        ja is_not_lowercase
        mov bx, cx   
        sub al, 'a'
        add al, 'A'
        mov buffer[bx+1], al  
        is_not_lowercase:
        loop scan


    ; print string
    printn ""
    print "Output string:"
    xor bx, bx
    mov bl, buffer[1]
    mov buffer[bx+2],'$' 
    mov dx, offset buffer + 2
    mov ah, 09h
    int 21h

    ; create Output1.txt
    mov cx, 0
    mov dx, offset output_file
    mov ah, 3ch
    int 21h
    push ax

    ; save buffer to Output1.txt
    mov bx, ax
    xor cx, cx
    mov cl, buffer[1]
    mov dx, offset buffer + 2
    mov ah, 40h
    int 21h

    ; close Output1.txt
    pop bx
    mov ah, 3eh
    int 21h

    mov ax, 4c00h ; exit to operating system.
    int 21h

ends
DEFINE_PRINT_NUM_UNS
end start ; set entry point and stop the assembler.
