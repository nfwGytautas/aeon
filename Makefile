# Helpers
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

# Variables
HOST=i686-elf
ARCH_TRIPLET=i386

CURRENT_DIR=$(shell pwd)
OUT_DIR=$(CURRENT_DIR)/out/

CC=${HOST}-gcc --sysroot=$(SYSROOT) -isystem=$(INCLUDEDIR)
ASM=yasm

CFLAGS=-g -O2 -ffreestanding -Wall -Wextra -fstack-protector-all
CPPFLAGS=-Ikernel/include -D__AEON_LIBK
ASMFLAGS=-f elf

LD=${HOST}-ld

# Source files
KERNEL_SOURCE_DIR=kernel/
ARCH_SOURCE_DIR=arch/$(ARCH_TRIPLET)/

# .cpp files
CPP_SOURCE_FILES=$(call rwildcard,$(KERNEL_SOURCE_DIR),*.cpp)
CPP_SOURCE_FILES:=$(CPP_SOURCE_FILES) $(call rwildcard,$(ARCH_SOURCE_DIR),*.cpp)

# .s files (no wildcard here we want to be specific for assembly files)
ASM_SOURCE_FILES:=$(ARCH_SOURCE_DIR)boot.s

# Create .o files from sources
OBJECTS=$(CPP_SOURCE_FILES:.cpp=.o) $(ASM_SOURCE_FILES:.s=.o)
OBJECTS:=$(addprefix $(OUT_DIR), $(OBJECTS))

OBJ_LINK_ORDER=$(OUT_DIR)crti.o $(OUT_DIR)crtbegin.o $(OBJECTS) $(OUT_DIR)crtend.o $(OUT_DIR)crtn.o

# Rules
.PHONY: all run iso aeon clean
.SILENT: clean

all: aeon

run: iso
	qemu-system-$(ARCH_TRIPLET) -cdrom $(OUT_DIR)/aeon.iso

iso: aeon
	mkdir -p $(OUT_DIR)/isodir
	mkdir -p $(OUT_DIR)/isodir/boot
	mkdir -p $(OUT_DIR)/isodir/boot/grub
	cp $(OUT_DIR)/aeon.kernel $(OUT_DIR)/isodir/boot/aeon.kernel

	@echo "menuentry \"aeon\" {multiboot /boot/aeon.kernel}" > $(OUT_DIR)/isodir/boot/grub/grub.cfg

	grub2-mkrescue -o $(OUT_DIR)/aeon.iso $(OUT_DIR)/isodir

aeon: crt $(OBJECTS) $(ARCH_SOURCE_DIR)linker.ld
	@echo "Linking aeon..."
	$(CC) -T $(ARCH_SOURCE_DIR)linker.ld -o $(OUT_DIR)$@.kernel $(CFLAGS) -nostdlib -lgcc $(OBJ_LINK_ORDER)
	@echo "Done"

crt:
	@mkdir -p $(OUT_DIR)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $(ARCH_SOURCE_DIR)crti.s -o $(OUT_DIR)crti.o
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $(ARCH_SOURCE_DIR)crtn.s -o $(OUT_DIR)crtn.o
	OBJ=`$(CC) $(CFLAGS) $(LDFLAGS) -print-file-name=crtbegin.o` && cp "$$OBJ" $(OUT_DIR)crtbegin.o
	OBJ=`$(CC) $(CFLAGS) $(LDFLAGS) -print-file-name=crtend.o` && cp "$$OBJ" $(OUT_DIR)crtend.o

clean:
	rm -rf $(OUT_DIR)

# Generic rules for code compilation
$(OUT_DIR)%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(OUT_DIR)%.o: %.s
	@mkdir -p $(dir $@)
	$(ASM) $(ASMFLAGS) -c $< -o $@
