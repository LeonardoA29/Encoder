.section .text
.globl print_angle
.globl print_speed
.globl print_amplitude
.globl print_dec
.globl udiv32

# =================================================================
# udiv32: division SIN SIGNO de 32 bits usando solo RV32I base
#         (division binaria por desplazamientos, sin extension M).
#   entrada:  a0 = dividendo,  a1 = divisor
#   salida:   a0 = cociente,   a1 = resto
# No usa pila (no llama a otras funciones), pero SI modifica
# t0-t4 ademas de a0/a1: es una funcion "divmod" con 2 resultados.
# =================================================================
udiv32:
    mv   t0, a0        # t0 = dividendo (se desplaza bit a bit)
    mv   t1, a1        # t1 = divisor
    li   a0, 0         # a0 = cociente (resultado)
    li   t2, 0         # t2 = resto parcial
    li   t3, 32        # t3 = contador de bits restantes

.Ludiv_loop:
    slli t2, t2, 1
    srli t4, t0, 31    # t4 = bit mas significativo de t0
    or   t2, t2, t4
    slli t0, t0, 1
    slli a0, a0, 1
    bltu t2, t1, .Ludiv_skip
    sub  t2, t2, t1
    ori  a0, a0, 1
.Ludiv_skip:
    addi t3, t3, -1
    bnez t3, .Ludiv_loop

    mv   a1, t2        # a1 = resto final
    ret


# =================================================================
# print_dec: imprime en decimal, con signo, el entero de 32 bits
#            que llega en a0. No imprime salto de linea.
# =================================================================
print_dec:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)
    sw   s2, 12(sp)

    mv   s0, a0          # s0 = valor a convertir
    li   s1, 0           # s1 = 1 si es negativo

    bgez s0, .Ldec_pos
    li   s1, 1
    sub  s0, x0, s0      # valor absoluto
.Ldec_pos:

    addi sp, sp, -12     # buffer en pila (hasta 12 digitos, sobra para 32 bits)
    li   s2, 0           # s2 = cantidad de digitos generados

    bnez s0, .Ldec_loop
    li   t0, 0x30
    sb   t0, 0(sp)
    li   s2, 1
    j    .Ldec_signo

.Ldec_loop:
    beqz s0, .Ldec_signo
    mv   a0, s0
    li   a1, 10
    call udiv32          # a0 = s0/10 , a1 = s0%10
    mv   s0, a0
    addi t0, a1, 0x30
    add  t1, sp, s2
    sb   t0, 0(t1)
    addi s2, s2, 1
    j    .Ldec_loop

.Ldec_signo:
    beqz s1, .Ldec_print
    li   a0, 0x2D        # '-'
    call putchar

.Ldec_print:
    addi s2, s2, -1      # indice del digito mas significativo (quedaron invertidos)
.Ldec_print_loop:
    add  t1, sp, s2
    lbu  a0, 0(t1)
    call putchar
    addi s2, s2, -1
    bgez s2, .Ldec_print_loop

    addi sp, sp, 12

    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    lw   s2, 12(sp)
    addi sp, sp, 16
    ret


# =================================================================
# print_angle: imprime por UART un angulo con signo en formato
#              Q9.3 (13 bits utiles, 1 LSB = 0.125).
# a0 = valor crudo (13 bits significativos, se sign-extiende aqui).
# Salida: [-]D...D.FFF\n\r   (FFF = milesimos, 000..875)
# =================================================================
print_angle:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)
    sw   s2, 12(sp)

    slli a0, a0, 19      # sign-extend: 32 - 13 = 19
    srai a0, a0, 19
    mv   s0, a0          # s0 = valor con signo, en octavos

    li   s1, 0
    bgez s0, .Langle_pos
    li   s1, 1
    sub  s0, x0, s0      # valor absoluto en octavos
.Langle_pos:

    srli s2, s0, 3       # parte entera = octavos / 8 (shift puro, sin M)
    andi s0, s0, 0x7      # parte fraccionaria: 0..7 octavos

    beqz s1, .Langle_int
    li   a0, 0x2D         # '-'
    call putchar
.Langle_int:
    mv   a0, s2
    call print_dec         # imprime la parte entera

    li   a0, 0x2E          # '.'
    call putchar

    # octavos (0..7) -> milesimos (0,125,...,875) via tabla,
    # evitando multiplicar
    la   t0, frac_table
    slli t1, s0, 2         # indice * 4 bytes
    add  t0, t0, t1
    lw   s0, 0(t0)         # s0 = fraccion en milesimos (0..875)

    li   a1, 100
    mv   a0, s0
    call udiv32            # a0 = centenas, a1 = resto (0..99)
    mv   s1, a1            # guardar resto ANTES de llamar putchar (a1 no esta garantizado tras la llamada)
    addi a0, a0, 0x30
    call putchar

    li   a1, 10
    mv   a0, s1
    call udiv32            # a0 = decenas, a1 = unidades
    mv   s0, a1            # guardar unidades ANTES de llamar putchar
    addi a0, a0, 0x30
    call putchar

    addi a0, s0, 0x30
    call putchar

    li   a0, 0xA
    call putchar
    li   a0, 0x0D
    call putchar

    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    lw   s2, 12(sp)
    addi sp, sp, 16
    ret


# =================================================================
# print_speed: imprime por UART la velocidad angular con signo,
#              formato entero de 16 bits (sin parte fraccionaria).
# a0 = valor crudo de 16 bits (se sign-extiende aqui).
# Salida: [-]D...D\n\r
# =================================================================
print_speed:  

    addi sp, sp, -4
    sw   ra, 0(sp)

    slli a0, a0, 16      # sign-extend: 32 - 16 = 16
    srai a0, a0, 16
    call print_dec

    li   a0, 0xA
    call putchar
    li   a0, 0x0D
    call putchar

    lw   ra, 0(sp)
    addi sp, sp, 4
    ret


# =================================================================
# print_amplitude: imprime por UART un valor de 12 bits CON SIGNO
#                  en decimal, sin parte fraccionaria.
# a0 = valor crudo de 12 bits (se sign-extiende aqui).
# Salida: [-]D...D\n\r
# =================================================================
print_amplitude:
    addi sp, sp, -4
    sw   ra, 0(sp)

    slli a0, a0, 20      # sign-extend: 32 - 12 = 20
    srai a0, a0, 20
    call print_dec

    li   a0, 0xA
    call putchar
    li   a0, 0x0D
    call putchar

    lw   ra, 0(sp)
    addi sp, sp, 4
    ret


.section .rodata
.align 2
frac_table:
    .word 0
    .word 125
    .word 250
    .word 375
    .word 500
    .word 625
    .word 750
    .word 875
