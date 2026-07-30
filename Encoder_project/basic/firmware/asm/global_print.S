.section .text
.globl print

print:
  addi sp, sp, -12  
  sw   ra, 0(sp)
  sw   t0, 4(sp) 
  sw   t3, 8(sp)

  li   t3, 128 
  mv a1, a0      
.L5:
  srli t0, a1, 28   
  andi t0, t0, 0x0F    
  addi t0, t0, 0x30    
  mv   a0, t0
  call putchar       
  slli a1, a1, 4       
  srli t3, t3, 1
  bnez t3, .L5

.PC0:
  li   a0, 0xA         
  call putchar
  li   a0, 0x0D        
  call putchar
  
  lw   ra, 0(sp)
  lw   t0, 4(sp)
  lw   t3, 8(sp)
  addi sp, sp, 12
  ret

