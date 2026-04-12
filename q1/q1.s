.section .text
.globl make_node
make_node:
          addi x2,x2,-16 #sp-=16(allocate stack space)
          sd x1,0(x2)    #save ra on stack
          sd x10,8(x2)   #save val on stack
          li x10,24      #malloc size
          call malloc
          ld x5,8(x2)    #reload val from stack
          sw x5,0(x10)    #store val
          sd x0,8(x10)    #left=NULL
          sd x0,16(x10)   #right=NULL
          ld x1,0(x2)    #restore ra
          addi x2,x2,16  #empty the stack
          jalr x0,0(x1)  #ret



.globl insert
insert:
       addi x2,x2,-24    #sp-=24(allocate stack space)
       sd x1,0(x2)       #store ra
       sd x10,8(x2)      #save root pointer
       sd x11,16(x2)     #save value 
       beq x10,x0,i_base #if root==NULL create node(basecase)
       lw x5,0(x10)      #load root->val into x5
       blt x11,x5,insert_in_left #if val<root->val go to left subtree
       ld x6,16(x10)     #x6=root->right
       addi x10,x6,0     #move right child into x10
       ld x11,16(x2)     #restore val into x11
       call insert
       ld x7,8(x2)       #restore the original root
       sd x10,16(x7)     #root->right=returned subtree
       addi x10,x7,0
       jal x0,i_end
insert_in_left:
       ld x10,8(x2)      #reload root from stack
       ld x6,8(x10)      #x6=root->left
       addi x10,x6,0     #move left child into x10
       ld x11,16(x2)     #restore val
       call insert
       ld x7,8(x2)       #reload original root
       sd x10,8(x7)      #root->left=returned subtree
       addi x10,x7,0     #return root
       jal x0,i_end
i_base:
       ld x10,16(x2)     #load val into x10
       call make_node    #create new node(returns in x10)
i_end:
      ld x1,0(x2)        #restore return address
      addi x2,x2,24      #deallocate stack
      jalr x0,0(x1)      #return


.globl get
get:
     beq x10,x0,null     #if root==NULL return NULL
     lw x5,0(x10)        #x5=root->val
     beq x5,x11,found    #if root->val==target go to found
     blt x11,x5,left     #if target<root->val go to left subtree
     ld x10,16(x10)      #x10=root->right
     jal x0,get          #jump to get
left:
    ld x10,8(x10)        #x10=root->left
    jal x0,get           #jump to get
found:
      jalr x0,0(x1)      #return curr node
null:
     addi x10,x0,0       #return NULL
     jalr x0,0(x1)   


.globl getAtMost
getAtMost:
      addi x5,x0,-1      #ans=-1
loop:
     beq x11,x0,done     #if root==NULL return ans=-1
     lw x6,0(x11)        #x6=root->val
     beq x6,x10,dup      #root->val==target return val
     blt x6,x10,g_right  #if root->val<target go to right
     ld x11,8(x11)       #move to root->left
     jal x0,loop         #continue loop
g_right:
     addi x5,x6,0        #update ans to root->val
     ld x11,16(x11)      #move to root->right
     jal x0,loop         #continue loop
dup:
    addi x10,x6,0      #return the given val
    jalr x0,0(x1)
done:
     addi x10,x5,0       #return ans
     jalr x0,0(x1)       #return