.equ UART_BASE, 0x400000  
.equ DPRAM_BASE, 0x450000  

.equ IO_LEDS, 4
.equ IO_UART_DAT, 8
.equ IO_UART_CNTL, 16

.equ ENCODER_BASE, 0x410000  
.equ SAMPLER_INIT,0x04
.equ MODULE_INIT, 0x08
.equ SAMPLER_DONE, 0x0C
.equ ANGLE_OUT, 0x10
.equ SPEED_OUT, 0x14

.section .text
.globl start 
.globl blinker
.globl put_hello

Encoder:
#   li   gp,UART_BASE
#   li   gp, DPRAM_BASE
#   li   sp,0x10040
   li   sp,0x1000
   mv a1, zero
   mv a2, zero
   la   a0, initial
   call putstring
   li   gp, ENCODER_BASE 
   li   t1, 1
   sw   t1, MODULE_INIT(gp)	
Start_sampling:
	li   t1, 1
	li   gp, ENCODER_BASE 
	sw   t1, SAMPLER_INIT(gp)    

Wait_done:
	lw   t2, SAMPLER_DONE(gp)
	# beqz t2, Wait_done            

	lw   a1, ANGLE_OUT(gp)
	lw   a2, SPEED_OUT(gp)

	sw   zero, SAMPLER_INIT(gp)   

Wait_idle:
	lw   t2, SAMPLER_DONE(gp)
	# bnez t2, Wait_idle             

UART_WRITE:
	la   a0, Angle
	call putstring
	mv a0, a1
	call print_angle
	la   a0, Speed
	call putstring
	mv a0, a2
	call print_speed
	j Start_sampling

putstring:
	addi sp,sp,-4 # save ra on the stack
	sw ra,0(sp)   # (need to do that for functions that call functions)
	mv t2,a0	
.L1:    lbu a0,0(t2)
	beqz a0,.L2
	call putchar
	addi t2,t2,1	
	j .L1
.L2:    lw ra,0(sp)  # restore ra
	addi sp,sp,4 # restore sp
	ret	

.section .data
initial:
	.asciz "\n\r --- UART ACTIVA --- \n\r"
Angle:
	.asciz "\n\r Angulo: "
Speed:
	.asciz "\n\r Velocidad: "
