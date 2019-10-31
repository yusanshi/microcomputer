include "emu8086.inc"

org 100h

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

; end
mov ax, 4c00h
int 21h

ret
buffer db 64,0, 64 dup(0)
input_file db "Input1.txt", 0
output_file db "Output1.txt", 0
end