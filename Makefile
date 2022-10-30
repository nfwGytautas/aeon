PROJECTS=libc kernel

CURRENT_DIR=$(shell pwd)

HOST=i686-elf
HOSTARCH=$(shell tools/target-triplet-to-arch.sh $(HOST))

export HOST
export HOSTARCH

MAKE="make"

# Configure the cross-compiler to use the desired system root.
SYSROOT="$(shell pwd)/sysroot"
CC="$CC --sysroot=$SYSROOT"

all: aeon

run: iso
	tools/qemu.sh

iso:
	tools/iso.sh

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
