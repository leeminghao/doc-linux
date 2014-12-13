#!/bin/bash

# -hdc hdc-0.11-new.img
qemu-system-i386 -m 16 -boot a -fda $1 -fdb $2 -s -S
