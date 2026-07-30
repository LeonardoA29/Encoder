.equ LED_BASE, 0x470000  
.equ LED_IN_BCD,0x04
.equ LED_INIT, 0x08
.equ LED_DONE, 0x0C

.section .text
.globl print_led

print_led:
  li   gp, LED_BASE 
  sw   a0, LED_IN_BCD(gp) 
  li   t1, 1
  sw   t1, LED_INIT(gp) 
  sw   zero, LED_INIT(gp)  
.L0:
   li   t1, 1  
   lw   t2, LED_DONE(gp)
   and  t2, t2, t1
   beqz t2, .L0  
  ret

