#!/bin/sh

TARGET="x64"

QEMU="qemu-system-x86_64"
QEMU_ARGS="--no-reboot --no-shutdown -m 256M" #-s -S

ISO="build/tupai.iso"

sh "build-x64.sh"

$QEMU $QEMU_ARGS -cdrom $ISO || \
{ echo "QEMU failed"; exit 1; }
