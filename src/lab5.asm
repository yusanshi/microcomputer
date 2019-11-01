include "emu8086.inc"

data segment
    buffer db 255, 0, 255 dup(0) ; used to store input
    buffer_temp db 256 dup(0) ; add '(' at start and ')' at end from buffer 
    optr dw 2048 dup(0)
    opnd dw 2048 dup(0)
    optr_sp dw 0 ; stack top
    opnd_sp dw 0 ; stack top
data ends

stack segment
    dw   2048  dup(0)
stack ends

code segment
    main proc
    start:
    ; set segment registers:
    mov ax, data
    mov ds, ax
    
    ; input arithmetic
    print "Input: "
    mov dx, offset buffer
    mov ah, 0ah
    int 21h
    
    xor bx, bx
    mov buffer_temp[0], '('
    transform:
        mov al, buffer[bx+2]
        inc bx
        
        cmp al, 13
        je end_transform
        
        mov buffer_temp[bx], al
        jmp transform
        
        
    end_transform:
    mov buffer_temp[bx], ')'
    mov buffer_temp[bx+1], 13
    
    
    ; scan string in buffer to stack
    xor bx, bx
    xor cx, cx ; current number
    xor dx, dx ; dx indicates whether is assembling number
    scan:
        mov al, buffer_temp[bx]
        inc bx       
        ;delete
        ;printn ""
        ;print_db_reg al
        
        cmp al, '0'
        jb not_a_num
        cmp al, '9'
        ja not_a_num

        ; assemble the number
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
        add al, '0'
        mov dx, 1
        jmp scan 
        
        not_a_num:
        ;if is_assembling == 1:
        ;    opnd.push(assembled_number)
        ;    reset to prepare for assembling
        ;    is_assembling = 0
        cmp dx, 0
        je skip_finish_assembling
        push ax
        mov ax, cx
        call opnd_push
        pop ax
        xor cx, cx
        mov dx, 0
        skip_finish_assembling:
        
        cmp al, 13
        je end_scan   
        
        cmp al, '('
        jne not_left_parenthesis
        ; optr.push(char)
        push ax
        xor ah, ah
        call optr_push
        pop ax
        jmp scan
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
            
            push dx
            
            ; dx is temp (optr.top())
            push ax
            call optr_top
            mov dx, ax
            pop ax
            cmp dl, '('
            jne temp_location
            push ax
            call optr_pop
            pop ax
            jmp temp_location1
            temp_location:
            block1
            temp_location1:
            
            pop dx
            jmp scan
             
        not_right_parenthesis:

        cmp al, '+'
        je is_add_or_minus
        cmp al, '-'
        je is_add_or_minus
        
        ;delete
        print "before error:"
        print_db_reg al
        jmp error
        is_add_or_minus:
            ;if temp == '(':
            ;    optr.push(char)
            ;else:
            ;    optr.pop(temp) (temp is an operator)
            ;    opnd.pop(b)
            ;    opnd.pop(a)
            ;    opnd.push((a temp b))
            ;    index - 1
            
            push dx
            
            ; dx is temp (optr.top())
            push ax
            call optr_top
            mov dx, ax
            pop ax
            cmp dl, '('
            jne temp_location2
            push ax
            xor ah, ah
            call optr_push
            pop ax
            jmp temp_location3
            temp_location2:
            block1
            temp_location3: 
            pop dx
            jmp scan
    
    end_scan:
    
    printn ""
    print "Result: "
    ; print result
    call opnd_pop
    call print_num
    
            
    jmp no_error
    error:
        print "Input wrong!"
    no_error:

    mov ax, 4c00h ; exit to operating system.
    int 21h
    main endp

    optr_push proc near ; push ax
    ;delete
    ;printn ''
    ;print 'optr push:'
    ;print_db_reg al
        
    push bx
    mov bx ,optr_sp
    mov optr[bx], ax
    add optr_sp, 2
    pop bx
    ret
    optr_push endp


    optr_pop proc near ; pop to ax
    push bx
    sub optr_sp, 2
    mov bx ,optr_sp
    mov ax, optr[bx] 
    pop bx
    ;delete
    ;printn ''
    ;print 'optr pop:'
    ;print_db_reg al
    
    
    ret
    optr_pop endp


    opnd_push proc near ; push ax
    push bx
    ;delete
    ;printn ''
    ;print 'opnd push:'
    ;print_db_reg al
    
    mov bx ,opnd_sp
    mov opnd[bx], ax
    add opnd_sp, 2    
    
    pop bx
    ret
    opnd_push endp


    opnd_pop proc near ; pop to ax
    push bx
    sub opnd_sp, 2
    mov bx ,opnd_sp
    mov ax, opnd[bx] 
    pop bx
    ;delete
    ;printn ''
    ;print 'opnd pop:'
    ;print_db_reg al    
    ret
    opnd_pop endp



    optr_top proc near ; get top to ax
    call optr_pop
    add optr_sp, 2
    ;delete
    ;print 'optr get top:'
    ;print_db_reg al    
    ret
    optr_top endp

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
block1 macro
    ; optr.pop(temp) (temp is an operator)
    ; opnd.pop(b)
    ; opnd.pop(a)
    ; opnd.push((a temp b))
    ; index - 1  
    pusha
    ; bx: temp 
    ; cx: b 
    ; dx: a
    call optr_pop
    mov bx, ax ; temp
    call opnd_pop
    mov cx, ax ; b
    call opnd_pop
    mov dx, ax  ; a
    cmp bl, '+'
    je is_add
    cmp bl, '-'
    je is_minus
    ;delete
    print 'before error (block):'
    print_db_reg bl
    jmp error
    local is_add
    is_add:
    add ax, cx
    jmp end_point
    local is_minus
    is_minus: 
    sub ax, cx
    local end_point    
    end_point:    
    call opnd_push      
    popa
    dec bx            
endm    
end start ; set entry point and stop the assembler.
