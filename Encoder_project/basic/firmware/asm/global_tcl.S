.equ TCL_BASE, 0x410000  
.equ TCL_INIT,0x04
.equ TCL_DAT, 0x08
.equ TCL_DONE, 0x0C

.section .text
.globl TCL

TCL:
  li   gp, TCL_BASE 
  li   t1, 1
  sw   t1, TCL_INIT(gp) 
  sw   zero, TCL_INIT(gp)  
.L0:
   li   t1, 1  
   lw   t2, TCL_DONE(gp)
   and  t2, t2, t1
   beqz t2, .L0 
   lw   a0, TCL_DAT(gp)
  ret

