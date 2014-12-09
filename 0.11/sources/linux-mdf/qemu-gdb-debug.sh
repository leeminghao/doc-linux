#!/bin/bash

# -hdc hdc-0.11-new.img
qemu-system-i386 -m 16 -boot a -fda bootimage -fdb diskb.img -s -S
