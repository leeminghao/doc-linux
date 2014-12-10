#!/bin/bash

# -hdc hdc-0.11-new.img
# -fdb diskb.img
# -fdb rootimage-0.11
qemu-system-i386 -m 16 -boot a -fda bootimage -fdb qemu/diskb.img

# bochs -f bochsrc.bxrc
