#!/bin/bash

qemu-system-i386 -L pc-bios -hda linux-0.11-devel-060625.qcow2 -no-reboot -m 16 -k en-us
