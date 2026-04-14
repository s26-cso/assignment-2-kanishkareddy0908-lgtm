.section .data
filename:  .string "input.txt"
mode:  .string "r"
yes: .string "Yes\n"
no: .string "No\n"

.section .text
.globl main
.extern fopen,fseek,fread,ftell,printf,fclose
main:
    addi x2,x2,-32    #allocate stack
    sw x1,28(x2)      #save ra
    sw x8,24(x2)      #save s0(fp)
    sw x9,20(x2)      #save s1(right)
    sw x18,16(x2)     #save s2(left)
    la x10,filename         
    la x11,mode             
    call fopen
    addi x8,x10,0           
    beq x8,x0,exit_err      #if fp==NULL,exit
    addi x10,x8,0           
    addi x11,x0,0           
    addi x12,x0,2           #SEEK_END
    call fseek
    addi x10,x8,0           
    call ftell              
    addi x9,x10,-1          #x9=right=size-1
    addi x18,x0,0           #x18=left= 0

loop:
    bge x18,x9,is_palindrome 
    addi x10,x8,0           
    addi x11,x18,0          
    addi x12,x0,0           #SEEK_SET
    call fseek
    addi x10,x2,0           #buffer at stack
    addi x11,x0,1           
    addi x12,x0,1           
    addi x13,x8,0           
    call fread              
    addi x10,x8,0           
    addi x11,x9,0           
    addi x12,x0,0           #SEEK_SET
    call fseek
    addi x10,x2,1           #buffer at stack+1
    addi x11,x0,1           
    addi x12,x0,1           
    addi x13,x8,0           
    call fread              
    lb x5,0(x2)            
    lb x6,1(x2)            
    bne x5,x6,not_palindrome
    addi x18,x18,1          #left++
    addi x9,x9,-1           #right--
    jal x0,loop             

is_palindrome:
    la x10,yes
    call printf
    jal x0,cleanup          

not_palindrome:
    la x10,no
    call printf
cleanup:
    addi x10,x8,0           
    call fclose
exit_err:
    lw x1,28(x2)            
    lw x8,24(x2)            
    lw x9,20(x2)
    lw x18,16(x2)
    addi x2,x2,32           
    addi x10,x0,0           
    jalr x0,0(x1)