include "emu8086.inc"

data segment
    buffer db 2048 dup(0)
    array dw 128 dup(0)
    input_file db "Input3.txt", 0
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

    ; open Input3.txt
    mov dx, offset input_file
    mov al, 0
    mov ah, 3dh
    int 21h
    
    ; read Input3.txt
    mov dx, offset buffer
    mov bx, ax
    mov cx, 1024
    mov ah, 3fh
    int 21h   
    
    ; scan string in buffer to array
    ; ascii: '\n':10, '-':45
    xor bx, bx
    xor dx, dx ;dh: number count  dl: is_negative
    xor cx, cx ; current number
    scan:
        mov al, buffer[bx]
        cmp al, 0    
        je end_scan
        
        cmp al, 45
        jne skip_set_neg
        mov dl, 1
        skip_set_neg:
        
        cmp al, 10
        jne skip_reset
            ; save current number and begin scanning new number
            cmp dl, 0
            je skip_neg
            neg cx
            skip_neg:
            push bx
            xor bx, bx
            mov bl, dh
            shl bx, 1
            mov array[bx], cx
            pop bx
            xor cx, cx
            inc dh
            xor dl, dl
        skip_reset:
        
        cmp al, '0'
        jb skip_process_bit
        cmp al, '9'
        ja skip_process_bit
        
        sub al,'0'
        push ax
        push dx
        mov ax, cx
        push bx
        mov bx, 10
        mul bx
        pop bx
        mov cx, ax
        pop dx
        pop ax
        xor ah, ah
        add cx, ax 

        skip_process_bit:
        
        inc bx
        jmp scan 
        
    end_scan:
 
    mov dl, dh
    xor dh, dh
    xor ax, ax
    mov ax, dx
    print "Number count: "
    call print_num
    printn ""
    print "Before sorting: "
    print_dw_array array, dx
    
    printn ""
    printn "Sorting..."
    push dx ; save number length to stack
    
    
    ; bubble sorting
    mov cx, dx
    dec cx
    first_layer:
        push cx
        xor bx, bx
        second_layer:
            mov ax, array[bx]
            cmp ax, array[bx+2]
            jle skip_exchange
            push array[bx]
            push array[bx+2]
            pop array[bx]
            pop array[bx+2]
            skip_exchange:
            add bx, 2
            loop second_layer
        pop cx
        loop first_layer


    pop dx
    print "After sorting: "
    print_dw_array array, dx
    
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    

ends
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS

print_dw_reg macro  p ; p is dw regester to print
            push ax
            mov ax, p
            call print_num
            print " "
            pop ax
endm

print_dw_array macro p, q ; p is dw array to print, q is register storing its length
pusha
xor bx, bx
local loop_print_num
loop_print_num:
    shl bx, 1
    mov ax, p[bx]
    shr bx, 1
    call print_num
    print " "
    inc bx
    cmp bx, q
    jne loop_print_num
popa   
endm

end start ; set entry point and stop the assembler.
