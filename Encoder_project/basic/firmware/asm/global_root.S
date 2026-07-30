.equ SQRT_BASE, 0x450000  
.equ SQRT_OP,   0x04
.equ SQRT_INIT, 0x08
.equ SQRT_ROOT, 0x0C
.equ SQRT_RES,  0x10
.equ SQRT_DONE, 0X14

.section .text
.globl sqrt_hw

sqrt_hw:
  li   gp, SQRT_BASE 
  sw   a0, SQRT_OP(gp) 
  li   a0, 1
  sw   a0, SQRT_INIT(gp) 
  sw   zero, SQRT_INIT(gp)  
.L0:
   li   t0, 1  
   lw   t1, SQRT_DONE(gp)
   and  t1, t1, t0
   beqz t1, .L0  
   lw   a0, SQRT_ROOT(gp)
   lw   a1, SQRT_RES(gp)
  ret
  