include "emu8086.inc"

data segment

data ends

stack segment
    dw   128  dup(0)
stack ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    



            

    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
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
