/* Instruct bootloader to start the execution at start_ in the boot.s */
ENTRY(_start)

/* Describe the memory sections for the kernel */
SECTIONS
{
	/* Start at 1MiB */
	. = 1M;

	/* Multiboot and text sections */
	.text BLOCK(4K) : ALIGN(4K)
	{
        . = ALIGN(8);
		KEEP(*(.multiboot))
		*(.text)
	}

	/* Read-only data. */
	.rodata BLOCK(4K) : ALIGN(4K)
	{
		*(.rodata)
	}

	/* Read-write data (initialized) */
	.data BLOCK(4K) : ALIGN(4K)
	{
		*(.data)
	}

	/* Read-write data (uninitialized) and stack */
	.bss BLOCK(4K) : ALIGN(4K)
	{
		*(COMMON)
		*(.bss)
	}

	/* Compiler segments goes under here */
}
