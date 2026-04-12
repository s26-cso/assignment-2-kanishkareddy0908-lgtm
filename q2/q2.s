.section .data
space: .string " "
newline: .string "\n"
fmt: .string "%d"

.section .text
.globl main
.extern printf,malloc

string_to_int:
    addi x5,x0,0           #x5(res)=0
    addi x6,x0,0           #x6(negative flag)=0
    lb x7,0(x10)           #load 1st char
    li x28,45              #x28=45(ascii of '-')
    bne x7,x28,digit_loop  #if char is'-' go to digit_loop
    addi x6,x0,1           #else x6=1
    addi x10,x10,1         #move pointer to next char

digit_loop:
    lb x7,0(x10)           #load curr char
    beq x7,x0,end_str      #if char =='\0'- end of str
    li x28,48              #x28=48('0')
    blt x7,x28,end_str     #if char<'0' stop 
    li x29,57              #x29=57('9')
    bgt x7,x29,end_str     #if char>'9' -stop
    addi x7,x7,-48         #convert ascii to int
    li x28,10              #x28=10
    mul x5,x5,x28          #res=res*10
    add x5,x5,x7           #res=res+digit
    addi x10,x10,1         #string pointer++
    jal x0,digit_loop      #loop again

end_str:
    beq x6,x0,finish     #if negative==0,go to finish
    sub x5,x0,x5         #res=0-res

finish:
    addi x10,x5,0        #ret res
    jalr x0,0(x1)        #return caller

main:
    addi x2,x2,-80     #allocate space on stack
    sd x1,72(x2)       #save ra on stack  
    sd x8,64(x2)       #save argc
    sd x9,56(x2)       #save argv
    sd x18,48(x2)      
    sd x19,40(x2)
    sd x20,32(x2)
    sd x21,24(x2)
    sd x22,16(x2)
    sd x23,8(x2)
    addi x8,x10,0      #x8=argc
    addi x9,x11,0      #x9=argv pointer
    addi x5,x0,1       
    ble x8,x5,exit     #if argc<=1,exit
    addi x18,x8,-1     #num=argc-1
    slli x10,x18,2     #size=num*4
    call malloc
    mv x19, x10
    slli x10, x18, 2
    call malloc
    mv x20, x10
    slli x10, x18, 2
    call malloc
    mv x21, x10

    li x23, 0
convert_args:
    beq x23, x18, process_start
    slli x5, x23, 3
    addi x5, x5, 8
    add x5, x9, x5
    ld x10, 0(x5)
    call string_to_int
    slli x5, x23, 2
    add x5, x19, x5
    sw x10, 0(x5)
    addi x23, x23, 1
    jal x0, convert_args

process_start:
    li x22, -1
    addi x23, x18, -1

algo_loop:
    blt x23, x0, print_start
    slli x5, x23, 2
    add x5, x19, x5
    lw x6, 0(x5)

while_stack:
    blt x22, x0, end_while
    slli x7, x22, 2
    add x7, x21, x7
    lw x28, 0(x7)
    slli x29, x28, 2
    add x29, x19, x29
    lw x30, 0(x29)
    bgt x30, x6, end_while
    addi x22, x22, -1
    jal x0, while_stack

end_while:
    slli x5, x23, 2
    add x5, x20, x5
    li x7, -1
    blt x22, x0, store_res
    slli x28, x22, 2
    add x28, x21, x28
    lw x7, 0(x28)

store_res:
    sw x7, 0(x5)
    addi x22, x22, 1
    slli x5, x22, 2
    add x5, x21, x5
    sw x23, 0(x5)
    addi x23, x23, -1
    jal x0, algo_loop

print_start:
    li x23, 0

print_loop:
    beq x23, x18, exit
    slli x5, x23, 2
    add x5, x20, x5
    lw x11, 0(x5)
    la x10, fmt
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
    addi x10,x10,0
    jalr x0,0(x1)