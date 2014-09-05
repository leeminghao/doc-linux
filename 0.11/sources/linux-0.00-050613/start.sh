#!/bin/bash

qemu-system-i386 -m 16 -boot a -fda Image -hdc a.img
