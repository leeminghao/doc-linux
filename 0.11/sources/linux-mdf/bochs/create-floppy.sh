#!/bin/bash

# $1 - floppy image, $2 - boot image, $3 - rootfs image
dd if=/dev/zero of=$1 bs=1024 count=1440  # 1.44MB
dd if=$2 of=$1
dd if=$3 of=$1 seek=256 obs=1024
