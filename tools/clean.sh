#!/bin/sh
set -e
. ./config.sh

for PROJECT in $PROJECTS; do
  (cd $ROOT_DIR/$PROJECT && $MAKE clean)
done

rm -rf $ROOT_DIR/sysroot
rm -rf $ROOT_DIR/isodir
rm -rf $ROOT_DIR/myos.iso
