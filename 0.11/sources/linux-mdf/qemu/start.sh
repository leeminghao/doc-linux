#!/bin/bash

# $1 - kernel image
# $2 - rootfs image
qemu-system-i386 -m 16 -boot a -fda $1 -fdb $2

# bochs -f bochsrc.bxrc
