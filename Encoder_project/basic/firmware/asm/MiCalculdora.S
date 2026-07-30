.equ UART_BASE, 0x400000  
.equ DPRAM_BASE, 0x450000  

.equ IO_LEDS, 4
.equ IO_UART_DAT, 8
.equ IO_UART_CNTL, 16
.section .text
.globl start 
.globl blinker
.globl put_hello

calculator:
#   li   gp,UART_BASE
#   li   gp, DPRAM_BASE
#   li   sp,0x10040
   li   sp,0x1000
   li 	t3, 10
   li   t4, '*'
   li	t5, '/'
   li	t6, 35
loopM:	
	la   a0, command
	call putstring

	addi a1, x0, 0
	li t0, 6

Op_A:
	slli a1, a1, 4
	call getchar    
	call putchar    
	addi a0, a0, -0x30
	bge a0,t3, end_A
	bgt x0,a0, end_A
	add a1, a0, a1   
	addi t0, t0, -1
	beqz t0, bcd2bin_A
	j Op_A
end_A:
	addi a0, a0, 0x30
	srli a1, a1, 4
bcd2bin_A:
	mv a3, a0
	mv a0, a1   
	call RDD_hw
	mv a1, a0
Operador:
	beq  t4, a3, Ld_operador
	beq  t5, a3, Ld_operador
	beq  t6, a3, Ld_operador
	j loopM
Ld_operador:
	addi a2, x0, 0
	li t0, 6 

Op_B:
	slli a2, a2, 4
	call getchar    
	call putchar 
	addi a0, a0, -0x30
	bge a0,t3, end_B
	bgt x0,a0, end_B
	add a2, a0, a2   
	addi t0, t0, -1
	beqz t0, bcd2bin_B
	j Op_B
end_B:
	srli a2, a2, 4
bcd2bin_B:
	mv a0, a2
	call RDD_hw
	mv a2, a0	

	la   a0, result
	call putstring

	mv   a0,a1
	mv   a1,a2
	
Selector:
	beq a3, t5, divide
	beq a3, t6, root 
	call mult_hw
	j    print_res
divide:
	call div_hw
	j	print_res
root:
	mv a0,a1
	call sqrt_hw
print_res:		
	call DD_hw
	call print_led
	call print
	
	j    loopM
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
command:
	.asciz "\n\r - Enter two operands - \n\r"
operator:
	.asciz "\n\rEnter operator \n\r"
result:
	.asciz "\n\rResult = "

