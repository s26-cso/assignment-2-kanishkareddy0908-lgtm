.section .data
space:    
     .string " "
newline:  
      .string "\n"
fmt:      
      .string "%lld"
.section .text
.globl main
.extern printf,malloc,atoi

main:
    addi x2,x2,-80         #allocate stack
    sd x1,72(x2)           #save ra
    sd x8,64(x2)           #save argc
    sd x9,56(x2)           #save argv
    sd x18,48(x2)          
    sd x19,40(x2)
    sd x20,32(x2)
    sd x21,24(x2)
    sd x22,16(x2)
    sd x23,8(x2)
    addi x8,x10,0          #x8=argc
    addi x9,x11,0          #x9=argv
    addi x5,x0,1           
    ble x8,x5,exit         #if argc<=1,exit
    addi x18,x8,-1         # n=argc-1
    slli x10,x18,3         
    call malloc            #allocate array of each element 8 bytes
    addi x19,x10,0         #arr
    slli x10,x18,3         
    call malloc
    mv x20,x10             #result
    slli x10,x18,3         
    call malloc
    addi x21,x10,0         #stack
    addi x23,x0,0
convert_args:
    beq x23,x18,process_start
    slli x5,x23,3          
    addi x5,x5,8           
    add x5,x9,x5           
    ld x10,0(x5)           #argv[i]
    call atoi              #convert string → int
    slli x5,x23,3          
    add x5,x19,x5          
    sd x10,0(x5)           #store in arr
    addi x23,x23,1
    jal x0,convert_args
process_start:
    li x22,-1              #stack top=-1
    addi x23,x18,-1        #i=n-1

loop:
    blt x23,x0,print_start
    slli x5,x23,3
    add x5,x19,x5
    ld x6,0(x5)            #arr[i]

while_stack:
    blt x22,x0,end_while
    slli x7,x22,3
    add x7,x21,x7
    ld x28,0(x7)           #index from stack
    slli x29,x28,3
    add x29,x19,x29
    ld x30,0(x29)          #arr[stack[top]]
    bgt x30,x6,end_while   #stop if greater
    addi x22,x22,-1        #pop
    jal x0,while_stack

end_while:
    slli x5,x23,3
    add x5,x20,x5
    li x7,-1
    blt x22,x0,store_res
    slli x28,x22,3
    add x28,x21,x28
    ld x7,0(x28)           #next greater index

store_res:
    sd x7,0(x5)            #result[i]
    addi x22,x22,1         #push index
    slli x5,x22,3
    add x5,x21,x5
    sd x23,0(x5)
    addi x23,x23,-1
    jal x0,loop
print_start:
    li x23,0

print_loop:
    beq x23,x18,exit
    slli x5,x23,3
    add x5,x20,x5
    ld x11,0(x5)
    la x10,fmt
    call printf
    addi x24,x18,-1
    beq x23,x24,skip_space
    la x10,space
    call printf
skip_space:
    addi x23,x23,1
    jal x0,print_loop
exit:
    la x10,newline
    call printf
    ld x1,72(x2)
    ld x8,64(x2)
    ld x9,56(x2)
    ld x18,48(x2)
    ld x19,40(x2)
    ld x20,32(x2)
    ld x21,24(x2)
    ld x22,16(x2)
    ld x23,8(x2)
    addi x2,x2,80
    addi x10,x0,0
    jalr x0,0(x1)