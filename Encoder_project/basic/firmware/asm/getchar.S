.equ UART_BASE, 0x400000  
.equ UART1_BASE, 0x430000  
.equ IO_UART_DAT, 8
.equ IO_UART_CNTL, 16

.section .text

.global	getchar
.global	getchar1
.type	getchar, @function
getchar:

	addi sp,sp,-4      # save a3, a4, a5 on the stack
	sw   t0,0(sp)
	li   gp, UART_BASE 
.L0:	
    lw   a0,IO_UART_CNTL(gp)
	andi t0,a0,256 # bit 8 = data ready
   beqz  t0,.L0
	li   t0,0x02
	sw   t0,IO_UART_CNTL(gp)
	lw   a0,IO_UART_DAT(gp)        
	andi a0,a0, 255
#	li   t0,10                  # <enter> generates CR/LF, we ignore LF.
#	beq  a0,t0, getchar
	lw   t0,0(sp)
	addi sp,sp,4      # save a3, a4, a5 on the stack
        ret 

.global	getchar
.type	getchar, @function
getchar1:

	addi sp,sp,-4      # save a3, a4, a5 on the stack
	sw   t0,0(sp)
	li   gp, UART1_BASE 
.L1:	
    lw   a0,IO_UART_CNTL(gp)
	andi t0,a0,256 # bit 8 = data ready
   beqz  t0,.L1
	li   t0,0x02
	sw   t0,IO_UART_CNTL(gp)
	lw   a0,IO_UART_DAT(gp)        
	andi a0,a0, 255
#	li   t0,10                  # <enter> generates CR/LF, we ignore LF.
#	beq  a0,t0, getchar
	lw   t0,0(sp)
	addi sp,sp,4      # save a3, a4, a5 on the stack
        ret 


