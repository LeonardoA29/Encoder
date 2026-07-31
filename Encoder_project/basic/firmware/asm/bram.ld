MEMORY {
   BRAM (RWX) : ORIGIN = 0x0000, LENGTH = 0x4000  /* 16kB RAM */
}
SECTIONS
{
    everything :
    {
        . = ALIGN(4);
        main_terminal_tst.o(.text)
        *(.*)
    } >BRAM
}
