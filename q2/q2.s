.section .data
space:      .string " "         
newline:    .string "\n"         
fmt:        .string "%lld"        

.section .text
.globl main
.extern printf, malloc, atoi

main:
    addi x2,x2,-96        #allocate stack 
    sd x1,88(x2)          #save (ra)
    sd x8,80(x2)          #save argc
    sd x9,72(x2)          #save argv
    sd x18,64(x2)         #save n
    sd x19,56(x2)         #save arr pointer
    sd x20,48(x2)         #save result pointer
    sd x21,40(x2)         #save stack pointer
    sd x22,32(x2)         #save stack top
    sd x23,24(x2)         #save loop index
    addi x8,x10,0         #x8=argc
    addi x9,x11,0         #x9=argv
    addi x5,x0,1          #constant 1
    ble x8,x5,exit        #if argc<=1, exit
    addi x18,x8,-1        #n=argc-1(number of elements)
    slli x10,x18,3        #size=n*8
    call malloc
    addi x19,x10,0        #x19=arr base
    slli x10,x18,3        #result array
    call malloc
    addi x20,x10,0        #x20=result base
    slli x10,x18,3
    call malloc
    addi x21,x10,0        #x21=stack base
    li x23,0              #i=0
convert:
    beq x23,x18,start     #if i==n, go to processing
    slli x5,x23,3         #offset=i*8
    addi x5,x5,8          #skip argv[0]
    add x5,x9,x5          #address of argv[i+1]
    ld x10,0(x5)          #load string pointer
    call atoi             #convert string→int
    slli x5,x23,3
    add x5,x19,x5         #arr[i] address
    sd x10,0(x5)          #store value
    addi x23,x23,1        #i++
    jal x0,convert

start:
    addi x22,x0,-1        #stack top=-1
    addi x23,x18,-1       #i=n-1
loop:
    blt x23,x0,print      #if i<0, go to print
    slli x5,x23,3
    add x5,x19,x5
    ld x6,0(x5)           #arr[i]
while:
    blt x22,x0,endw       #if stack empty
    slli x7,x22,3
    add x7,x21,x7
    ld x28,0(x7)          #stack[top]
    slli x29,x28,3
    add x29,x19,x29
    ld x30,0(x29)         #arr[stack[top]]
    ble x30,x6,pop        #pop
    jal x0,endw
pop:
    addi x22,x22,-1       #top--
    jal x0,while
endw:
    slli x5,x23,3
    add x5,x20,x5         #result[i]
    addi x7,x0,-1         #default -1
    blt x22,x0,store
    slli x28,x22,3
    add x28,x21,x28
    ld x7,0(x28)          #next greater index
store:
    sd x7,0(x5)
    addi x22,x22,1        #push
    slli x5,x22,3
    add x5,x21,x5
    sd x23,0(x5)
    addi x23,x23,-1       #i--
    jal x0,loop
print:
    addi x23,x0,0        #i=0
print_loop:
    beq x23,x18,exit
    slli x5,x23,3
    add x5,x20,x5
    la x10,fmt
    ld x11,0(x5)
    call printf
    addi x24,x18,-1
    beq x23,x24,skip
    la x10,space
    call printf
skip:
    addi x23,x23,1
    jal x0,print_loop
exit:
    la x10,newline
    call printf
    ld x1,88(x2)
    ld x8,80(x2)
    ld x9,72(x2)
    ld x18,64(x2)
    ld x19,56(x2)
    ld x20,48(x2)
    ld x21,40(x2)
    ld x22,32(x2)
    ld x23,24(x2)
    addi x2,x2,96
    addi x10,x0,0
    jalr x0,0(x1)