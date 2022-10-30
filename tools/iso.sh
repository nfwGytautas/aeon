#!/bin/sh
set -e
. ./build.sh

mkdir -p $ROOT_DIR/isodir
mkdir -p $ROOT_DIR/isodir/boot
mkdir -p $ROOT_DIR/isodir/boot/grub

cp $ROOT_DIR/sysroot/boot/aeon.kernel $ROOT_DIR/isodir/boot/aeon.kernel
cat > $ROOT_DIR/isodir/boot/grub/grub.cfg << EOF
menuentry "aeon" {
	multiboot /boot/aeon.kernel
}
EOF
grub2-mkrescue -o $ROOT_DIR/aeon.iso $ROOT_DIR/isodir
