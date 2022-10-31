PROJECTS=libc kernel

CURRENT_DIR=$(shell pwd)

HOST=i686-elf
HOSTARCH=$(shell tools/target-triplet-to-arch.sh $(HOST))

MAKE="make"

# Configure the cross-compiler to use the desired system root.
export SYSROOT="$(shell pwd)/sysroot"

export AR=${HOST}-ar
export AS=${HOST}-as

export PREFIX=/usr
export EXEC_PREFIX=$(PREFIX)
export BOOTDIR=/boot
export LIBDIR=$(EXEC_PREFIX)/lib
export INCLUDEDIR="$(PREFIX)/include"

export CC=${HOST}-gcc --sysroot=$(SYSROOT) -isystem=$(INCLUDEDIR)
export HOST
export HOSTARCH
export CFLAGS=-O2 -g
export CPPFLAGS=

all: aeon

run: iso
	qemu-system-$(HOSTARCH) -cdrom $(CURRENT_DIR)/aeon.iso

iso: aeon
	mkdir -p $(CURRENT_DIR)/isodir
	mkdir -p $(CURRENT_DIR)/isodir/boot
	mkdir -p $(CURRENT_DIR)/isodir/boot/grub
	cp $(CURRENT_DIR)/sysroot/boot/aeon.kernel $(CURRENT_DIR)/isodir/boot/aeon.kernel

	@echo "menuentry \"aeon\" {multiboot /boot/aeon.kernel}" > $(CURRENT_DIR)/isodir/boot/grub/grub.cfg

	grub2-mkrescue -o $(CURRENT_DIR)/aeon.iso $(CURRENT_DIR)/isodir

aeon: headers
	for p in $(PROJECTS); do (cd $(CURRENT_DIR)/$$p && DESTDIR=$(SYSROOT) $(MAKE_ARGS) $(MAKE) install); done

headers: $(PROJECTS)
	mkdir -p $(SYSROOT)
	for p in $(PROJECTS); do (cd $(CURRENT_DIR)/$$p && DESTDIR=$(SYSROOT) $(MAKE_ARGS) $(MAKE) install-headers); done

clean:
	for p in $(PROJECTS); do (cd $(CURRENT_DIR)/$$p && $(MAKE_ARGS) $(MAKE) clean); done

	rm -rf sysroot
	rm -rf isodir
	rm -rf aeon.iso
