.equ DIV_BASE, 0x440000  
.equ DIV_DIVD, 0x04
.equ DIV_DIVS, 0x08
.equ DIV_INIT, 0x0C
.equ DIV_COC,  0x10
.equ DIV_RES,  0X14
.equ DIV_DONE, 0X18


.section .text
.globl div_hw

#li a0, 122     #  colocar como comentario después de la prueba
#li a1, 4

div_hw:
  li   gp, DIV_BASE 
  sw   a0, DIV_DIVD(gp) 
  sw   a1, DIV_DIVS(gp) 
  li   a0, 1
  sw   a0, DIV_INIT(gp) 
  sw   zero, DIV_INIT(gp)  
.L0:
   li   t0, 1  
   lw   t1, DIV_DONE(gp)
   and  t1, t1, t0
   beqz t1, .L0  
   lw   a0, DIV_COC(gp)
   lw   a1, DIV_RES(gp)
  ret
  