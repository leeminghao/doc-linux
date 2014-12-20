#!/bin/bash

# $1 - kernel image
# $2 - rootfs image
# -boot [order=drives][,once=drives][,menu=on|off][,splash=sp_name][,splash-time=sp_time][,reboot-timeout=rb_timeout][,strict=on|off]
#   Specify boot order drives as a string of drive letters. Valid drive letters depend on the target achitecture.
#   The x86 PC uses: a, b (floppy 1 and 2), c (first hard disk), d (first CD-ROM), n-p
#   (Etherboot from network adapter 1-4), hard disk boot is the default.
#   To apply a particular boot order only on the first startup, specify it via once.
#
#   Interactive boot menus/prompts can be enabled via menu=on as far as firmware/BIOS supports them. The default is non-interactive boot.
#
#   A splash picture could be passed to bios, enabling user to show it as logo, when option splash=sp_name is given and menu=on, If firmware/BIOS supports them.
#   Currently Seabios for X86 system support it.
#   limitation: The splash file could be a jpeg file or a BMP file in 24 BPP format(true color).
#               The resolution should be supported by the SVGA mode, so the recommended is 320x240, 640x480, 800x640.
#
#    A timeout could be passed to bios, guest will pause for rb_timeout ms when boot failed, then reboot.
#    If rb_timeout is '-1', guest will not reboot, qemu passes '-1' to bios by default.
#    Currently Seabios for X86 system support it.
#
# Do strict boot via strict=on as far as firmware/BIOS supports it.
# This only effects when boot priority is changed by bootindex options.
# The default is non-strict boot.
#
# try to boot from network first, then from hard disk
#        qemu-system-i386 -boot order=nc
# boot from CD-ROM first, switch back to default order after reboot
#         qemu-system-i386 -boot once=d
# boot with a splash picture for 5 seconds.
#         qemu-system-i386 -boot menu=on,splash=/root/boot.bmp,splash-time=5000
#
# Note: The legacy format '-boot drives' is still supported but its use is discouraged as it may be removed from future versions.

qemu-system-i386 -L pc-bios -m 16 -boot a -fda $1

# bochs -f bochsrc.bxrc
