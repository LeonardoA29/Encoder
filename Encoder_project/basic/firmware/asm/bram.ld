MEMORY {
   BRAM (RWX) : ORIGIN = 0x0000, LENGTH = 0x4000  /* 6kB RAM */
}
SECTIONS
{
    everything :
    {
        . = ALIGN(4);
        MiCalculdora_tcl.o (.text)
        *(.*)
    } >BRAM
}
