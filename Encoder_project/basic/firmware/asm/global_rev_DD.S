.equ RDD_BASE,     0x420000  
.equ RDD_IN_BCD,   0x04
.equ RDD_INIT,     0x08
.equ RDD_OUT_BIN,  0x0C
.equ RDD_DONE,     0x10

.section .text
.globl RDD_hw


RDD_hw:
  li   gp, RDD_BASE 
  sw   a0, RDD_IN_BCD(gp)  
  li   a0, 1
  sw   a0, RDD_INIT(gp) 
  sw   zero, RDD_INIT(gp)  
.L0:
   li   t0, 1  
   lw   t1, RDD_DONE(gp)
   and  t1, t1, t0
   beqz t1, .L0  
   lw   a0, RDD_OUT_BIN(gp)
  ret
