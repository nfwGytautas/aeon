BITS 32
ALIGN 4

mboot:
    ; Page allign loaded modules
    MBOOT_PAGE_ALIGN    equ     1<<0
    ; Provide memory information
    MBOOT_MEMORY_INFO   equ     1<<1

    ; Multiboot magic number
    MBOOT_MAGIC         equ     0x1BADB002

    ; Joint header flags
    MBOOT_HEADER_FLAGS  equ     MBOOT_PAGE_ALIGN | MBOOT_MEMORY_INFO

    ; Checksum
    MBOOT_CHECKSUM      equ     -(MBOOT_MAGIC + MBOOT_HEADER_FLAGS)

    ; Create memory are
    dd MBOOT_MAGIC
    dd MBOOT_HEADER_FLAGS
    dd MBOOT_CHECKSUM

; Entry point into kernel from bootloader
global _start
_start:
    ; Setup stack for C++ kernel
	mov esp, 0x7FFFF
    push esp

    ; Multiboot headers
    push eax ; Header magic number
    push ebx ; Header pointer

    ; Disable interrupts
    cli

	; Initialize process state for the kernel, initialize C++ features here
    extern _init
	call _init

	; Enter the C++ kernel
	; NOTE: Entering the kernel requires the stack to be 16 byte alligned
    extern aeonMain
  	call aeonMain

  	; Kernel exit enter infinite loop
    jmp $



global __gdt_flush
extern __gdt_ptr
__gdt_flush:
    ; Load __gdt_ptr into the register
    lgdt [__gdt_ptr]
    ; Reload data segment values
    JMP 0x08:.reload_CS
    ret

.reload_CS:
    mov ax, 0x10
    mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
    ret


; BSS
SECTION .bss
    resb 8192 ; 8KB memory
