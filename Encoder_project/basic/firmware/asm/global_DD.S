.equ DD_BASE,     0x460000  
.equ DD_IN_BIN,   0x04
.equ DD_INIT,     0x08
.equ DD_OUT_BCD,  0x0C
.equ DD_DONE,     0x10

.section .text
.globl DD_hw


DD_hw:
  li   gp, DD_BASE 
  sw   a0, DD_IN_BIN(gp)  
  li   a0, 1
  sw   a0, DD_INIT(gp) 
  sw   zero, DD_INIT(gp)  
.L0:
   li   t0, 1  
   lw   t1, DD_DONE(gp)
   and  t1, t1, t0
   beqz t1, .L0  
   lw   a0, DD_OUT_BCD(gp)
  ret
