#!/bin/bash

qemu-system-i386 -m 16 -boot a -fda bootimage -hdc hdc-0.11-new.img
