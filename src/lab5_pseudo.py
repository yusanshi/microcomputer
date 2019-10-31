for char in buffer:
    if char >= '0' and char <= '9':
        assemble the number
    else:
        finish assembling
        push assembled number to opnd stack
        reset to prepare for assembling
        
    if char == 0:
        break
    
    temp = opnd.top()
    if char == '(':
        optr.push(char)
    
    elif char == ')':
        if temp == '(':
            optr.pop(anywhere)
        else:
            optr.pop(temp) (temp is an operator)
            opnd.pop(b)
            opnd.pop(a)
            opnd.push((a temp b))
            index - 1 
    elif char =='+' or char == '-':
        if temp == '(':
            optr.push(char)
        else:
            optr.pop(temp) (temp is an operator)
            opnd.pop(b)
            opnd.pop(a)
            opnd.push((a temp b))
            index - 1
    else:
        jump to error

print value in opnd.top()