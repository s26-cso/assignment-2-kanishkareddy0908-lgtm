.section .data
filename: 
         .string "input.txt"
mode:     
     .string "r"
yes:  
    .string "Yes\n"
no:   .
   string "No\n"

.section .text
.globl main
.extern fopen,fseek,fread,ftell,printf

main:
      addi x2,x2,-16     #allocate space for stack
      la x10,filename
      la x11,mode
      call fopen         #fopen("input.txt","r")
      addi x8,x10,0      #x8=x10
      addi x10,x8        #save file pointer
      addi x10,x8,0      
      addi x11,x0,0
      addi x12,x0,2
      call fseek          #fseek(fp,0,seekend)
      addi x10,x8,0
      call ftell
      mv x9,x10          # size
      addi x19,x9,-1     # right = size - 1
      addi x19, x19, -1
      li x18,0           # left = 0
loop:
    bge x18, x19, is_palindrome
    mv x10, x8
    mv x11, x18
    li x12, 0
    call fseek           #fseek(fp,left,SEEK_SET)
    addi x10, x2, 0     # address of c1 (stack)
    li x11, 1
    li x12, 1
    mv x13, x8
    call fread           # fread(&c1,1,1,fp)
    # fseek(fp, right, SEEK_SET)
    mv x10, x8
    mv x11, x19
    li x12, 0
    call fseek
    addi x10, x2, 1     # address of c2 (stack)
    li x11, 1
    li x12, 1
    mv x13, x8
    call fread           #fread(&c2,1,1,fp)
    lb x5, 0(x2)
    lb x6, 1(x2)
    bne x5,x6,not_palindrome
    addi x18,x18,1
    addi x19,x19,-1
    jal x0,loop

is_palindrome:
    la x10, yes_str
    call printf
    jal x0,exit    
not_palindrome:
    la x10,no
    call printf
exit:
    addi x2,x2,16        #deallocate stack
    addi x10,x0,0      
    jalr x0,0(x1)