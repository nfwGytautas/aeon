/* Multiboot header constants */
.set ALIGN,		1<<0 				/* align loaded modules on page boundaries */
.set MEMINFO,	1<<1 				/* provide memory map */
.set FLAGS,    	ALIGN | MEMINFO 	/* Multiboot 'flag' field */
.set MAGIC,		0x1BADB002			/* Magic number so that the bootloader can find the header */
.set CHECKSUM,	-(MAGIC + FLAGS)	/* Cheksum of above constants */


/* Mark program as a kernel */
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM


/* Create the stack for the kernel, the current stack size is 16KB (needs to be 16-byte aligned) */
.section .bss
.align 16
stack_bottom:
.skip 16384 # 16 KiB
stack_top:

/* Entry point into kernel from bootloader */
.section .text
.global _start
.type _start, @function
_start:
	/* 32-bit protected mode from now on
	 * Interrupts disabled 
	 * Paging disabled
	 */

	/* Setup stack for C++ kernel */
	mov $stack_top, %esp
	 
	/* Initialize process state for the kernel, initialize C++ features here */
	call _init /* Global constructors */

	/* Environment initialized
	 * GDT loaded
	 * Paging enabled
	 * NOTE: Entering the kernel requires the stack to be 16 byte alligned
	 */
  	call kernel_main

  	/* Kernel exit enter infinite loop */
  	cli /* Disable interrupts */

  	/* Wait for interrupt and loop if it happens */
1:	hlt
	jmp 1b

/* For debugging the _start symbol is set to the current location */
.size _start, . - _start
