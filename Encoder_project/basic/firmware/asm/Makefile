# *************************************************
# IMPORTANTE PARA PODER COMPILAR ESTE EJEMPLO:
# En el archivo:litex/litex/soc/software/common.mak
# cambiar de:
# ifeq ($(LTO), 1)
# COMMONFLAGS += -flto
# endif
# a:
# COMMONFLAGS += -flto
# *************************************************

OBJECTS = main_UNO_ADC.o print_decimal.o putchar.o wait.o global_rev_DD.o getchar.o
OBJS    = main_UNO_ADC.o

CROSS   = riscv32-unknown-elf
CC      = $(CROSS)-gcc
AS      = $(CROSS)-as
LD      = $(CROSS)-ld
OBJCOPY = $(CROSS)-objcopy
OBJDUMP = $(CROSS)-objdump

# Banderas estrictas para arquitectura de 32-bit sin FPU (soft-float)
AFLAGS  = -march=rv32i -mabi=ilp32
CFLAGS  = -march=rv32i -mabi=ilp32

all: firmware.hex 

firmware.bin: firmware.elf
	$(OBJCOPY) -O verilog $< firmware_flash.hex
	$(OBJCOPY) -O ihex $< firmware_flash_intel.hex
	$(OBJCOPY) -O binary $< $@
	chmod -x $@

firmware.elf: $(OBJECTS) bram.ld
	$(LD) $(LDFLAGS) -T bram.ld -m elf32lriscv -nostdlib -Map firmware.map -N -o $@ $(OBJECTS)
	chmod -x $@
	
firmware.hex: firmware.elf firmware.lst firmware.bin
	../firmware_words_src/firmware_words firmware.elf -ram 16384 -max_addr 16384 -out firmware.hex
	cp firmware.hex ../../rtl
	cp firmware_flash.hex ../../rtl

firmware.lst: firmware.elf
	$(OBJDUMP) -h -S $< > $@

# Regla para archivos C
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Reglas para archivos ensamblador (.S en mayúscula y .s en minúscula)
%.o: %.S
	$(AS) $(AFLAGS) $< -o $@

%.o: %.s
	$(AS) $(AFLAGS) $< -o $@

clean:
	rm -rf $(OBJECTS) *.elf *.bin .*~ *~ *.map *.d *.hex *.o *.lst

.PHONY: clean bram.ld

# Generar bram.ld directamente desde Makefile
bram.ld:
	@echo "MEMORY {"                         >  bram.ld
	@echo "   BRAM (RWX) : ORIGIN = 0x0000, LENGTH = 0x4000  /* 16kB RAM */" >> bram.ld
	@echo "}"                                >> bram.ld
	@echo "SECTIONS"                         >> bram.ld
	@echo "{"                                >> bram.ld
	@echo "    everything :"                 >> bram.ld
	@echo "    {"                            >> bram.ld
	@echo "        . = ALIGN(4);"            >> bram.ld
	@echo "        $(OBJS)(.text)"           >> bram.ld
	@echo "        *(.*)"                    >> bram.ld
	@echo "    } >BRAM"                      >> bram.ld
	@echo "}"                                >> bram.ld