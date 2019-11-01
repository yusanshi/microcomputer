is_assembling = 0
for char in buffer:
    if char >= '0' and char <= '9':
        assemble the number
        is_assembling = 1
        break
    else:
        if is_assembling == 1:
            opnd.push(assembled_number)
            reset to prepare for assembling
            is_assembling = 0
        
    if char == 13:
        break
    
    temp = optr.top()
    if char == '(':
        optr.push(char)
        break
    
    elif char == ')':
        if temp == '(':
            optr.pop(anywhere)
        else:
            optr.pop(temp) (temp is an operator)
            opnd.pop(b)
            opnd.pop(a)
            opnd.push((a temp b))
            index - 1
        break 
    elif char =='+' or char == '-':
        if temp == '(':
            optr.push(char)
        else:
            optr.pop(temp) (temp is an operator)
            opnd.pop(b)
            opnd.pop(a)
            opnd.push((a temp b))
            index - 1
        break
    else:
        jump to error

print value in opnd.top()