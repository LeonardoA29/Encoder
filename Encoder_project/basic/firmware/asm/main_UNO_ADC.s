.equ UART_BASE, 0x400000 
.equ UART1_BASE, 0x430000  
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
.equ X_in_test, 0x18
.equ y_in_test, 0x1C


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

Get_x_axis:	
	li 	t3, 10
	la   a0, X_dat
	call putstring

	addi a1, x0, 0
	li t0, 6

Get_Frame:
    # 1. Esperar Header 0xAA
    call getchar1
    li   t0, 0xAA
    bne  a0, t0, Get_Frame   # Si no es 0xAA, seguir esperando

    # 2. Leer X MSB
    call getchar1
    slli t1, a0, 8           # Shift a la izquierda (bits 15..8)

    # 3. Leer X LSB
    call getchar1
    or   t1, t1, a0          # Unir LSB -> t1 tiene el valor de 14/16 bits de X

    # 4. Leer Y MSB
    call getchar1
    slli t2, a0, 8

    # 5. Leer Y LSB
    call getchar1
    or   t2, t2, a0          # t2 tiene el valor de Y

    # 6. Esperar Footer 0x55 (Validación)
    call getchar1
    li   t0, 0x55
    bne  a0, t0, Get_Frame   # Si la trama es corrupta, descartar

    # 7. Guardar en los registros del hardware ENCODER
    li   gp, ENCODER_BASE
    sw   t1, X_in_test(gp)   # Escribir X en la FPGA
    sw   t2, y_in_test(gp)   # Escribir Y en la FPGA

    j Get_Frame              # Volver a esperar la siguiente trama
end_A:
	addi a0, a0, 0x30
	srli a1, a1, 4
bcd2bin_A:
	mv a3, a0
	mv a0, a1   
	call RDD_hw
	mv a1, a0
Get_Y_axis:
	addi a2, x0, 0
	li t0, 6 
	la   a0, Y_dat
	call putstring

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
load_x_y:
	li   gp, ENCODER_BASE 
	sw   a1, X_in_test(gp)
	sw	 a2, y_in_test(gp)

Start_sampling:
	li   t1, 1
	li   gp, ENCODER_BASE 
	sw   t1, SAMPLER_INIT(gp)    

Wait_done:       
	li a0, 16
	call wait
	lw   a1, ANGLE_OUT(gp)
	lw   a2, SPEED_OUT(gp)

	sw   zero, SAMPLER_INIT(gp)              

UART_WRITE:
	la   a0, Angle
	call putstring
	mv a0, a1
	call print_angle
	la   a0, Speed
	call putstring
	mv a0, a2
	call print_speed
	j Get_x_axis

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
X_dat:
	.asciz "\n\r Cordenada X:"
Y_dat:
	.asciz "\n\r Cordenada Y:"
Angle:
	.asciz "\n\r Angulo: "
Speed:
	.asciz "\n\r Velocidad: "
