.data
data1:.word 0x04000000
pattern1:.word 0x0000000f
pattern2:.word 0x0000001e
pattern3:.word 0x0000003c
pattern4:.word 0x00000078
pattern5:.word 0x000000f0
pattern6:.word 0x000000e1
pattern7:.word 0x000000c3
pattern8:.word 0x00000087
.text
addi x6,x0,4#offset
addi x7,x0,31#max offset
addi x4,x0,3
addi x5,x0,0
lw x1,4(x0)#pattern
lw x2,0(x0)#loop time
loop:
addi x3,x0,0#cnt
#addi x5,x0,0
sw x1, 0x400(x0)#led out
addi x6,x6,4#offset increment
lw x1,(x6)
bge x7,x6,loop2
addi x6,x0,0#offset reset
loop2:
addi x3,x3,1
bge x2,x3,loop2
jal x8,loop