ENTRY(_start)
KERNEL_VMA = 0x400000;
SECTIONS
{
    . = KERNEL_VMA;
    .text : AT(ADDR(.text) - KERNEL_VMA)
    {
        . = ALIGN(4);
        LONG(0x1BADB002)
        LONG(0x00000003)
        LONG(0xE4524FFB)
        *(.text)
        . = ALIGN(4096);
    }
  
    /* Read-only data. */
	.rodata : AT(ADDR(.rodata) - KERNEL_VMA)
	{
		*(.rodata)
        . = ALIGN(4096);
	}


   .data : AT(ADDR(.data) - KERNEL_VMA)
   {
        *(.data)
        . = ALIGN(4096);
   }

   .eh_frame : AT(ADDR(.eh_frame) - KERNEL_VMA)

   {
       *(.eh_frame)
       . = ALIGN(4096);
   }

   .bss : AT(ADDR(.bss) - KERNEL_VMA)
   {
        *(COMMON)
        *(.bss)
        . = ALIGN(4096);
   }

   _end = .;

   /DISCARD/ :
   {
        *(.comment)
   }
}
