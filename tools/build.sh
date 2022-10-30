#!/bin/sh
set -e
. ./headers.sh

for PROJECT in $PROJECTS; do
  (cd $ROOT_DIR/$PROJECT && DESTDIR="$SYSROOT" $MAKE install)
done
