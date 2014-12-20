#!/bin/bash

qemu-system-i386 -L pc-bios -m 16 -boot a -fda $1 -s -S
