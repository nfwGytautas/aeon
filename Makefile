# Helpers
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

# Variables
HOST=i686-elf
ARCH_TRIPLET=i386

CURRENT_DIR=$(shell pwd)
OUT_DIR=$(CURRENT_DIR)/out/
ARCH_DIR=arch/$(ARCH_TRIPLET)/

CC=${HOST}-gcc #--sysroot=$(SYSROOT) -isystem=$(INCLUDEDIR)
CFLAGS=-g -O2 -ffreestanding -Wall -Wextra
CPPFLAGS=-Ikernel/include -D__AEON_LIBK

LD=${HOST}-ld

# Source files
KERNEL_SOURCES=$(call rwildcard,kernel/,*.cpp)

ARCH_SOURCES=$(call rwildcard,$(ARCH_DIR),*.cpp)
ARCH_SOURCES:=$(ARCH_SOURCES) $(call rwildcard,$(ARCH_DIR),*.s)

# Create .o files from sources
KERNEL_OBJS=$(KERNEL_SOURCES:.cpp=.o)

ARCH_OBJS=$(ARCH_SOURCES:.cpp=.o)
ARCH_OBJS:=$(ARCH_OBJS) $(ARCH_SOURCES:.s=.o)

# Rules
.PHONY: all run iso aeon clean

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

aeon: $(KERNEL_OBJS) $(ARCH_OBJS) $(ARCH_DIR)/linker.ld
	$(CC) -T $(ARCH_DIR)linker.ld -o $(OUT_DIR)/$@.kernel $(CFLAGS) -nostdlib -lgcc $(call rwildcard,$(OUT_DIR),*.o)

clean:
	rm -rf $(OUT_DIR)

# Generic rule for code compilation
$(ARCH_DIR)/crtbegin.o $(ARCH_DIR)/crtend.o:
	OBJ=`$(CC) $(CFLAGS) $(LDFLAGS) -print-file-name=$(@F)` && cp "$$OBJ" $@

%.o: %.cpp
	mkdir -p $(dir $(OUT_DIR)$@)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $(OUT_DIR)$@

%.o: %.s
	mkdir -p $(dir $(OUT_DIR)$@)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $(OUT_DIR)$@
