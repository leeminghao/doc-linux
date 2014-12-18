Start Linux 0.11 from floppy.
================================================================================

Note: Linus comment to floppy.c: Also, I'm not certain this works on more than 1 floppy. Bugs may abund.
So, if you want to boot linux 0.11 from two floppy need you fix these bugs.

Create two floppy image:
--------------------------------------------------------------------------------

```
$ dd if=/dev/zero of=boot.img bs=1024 count=1440    # 1.44MB
$ dd if=/dev/zero of=rootfs.img bs=1024 count=1440  # 1.44MB
```

Write kernel image to boot.img:
--------------------------------------------------------------------------------

```
$ dd if=bootimage of=boot.img bs=4096
$ file boot.img rootfs.img
boot.img:   x86 boot sector
rootfs.img: data
```

Put bootimage and rootimage into a floppy:
--------------------------------------------------------------------------------

```
$ dd if=/dev/zero of=boot.img bs=1024 count=1440    # 1.44MB
$ dd if=bootimage of=floppy.img
$ dd if=rootimage-small of=floppy.img seek=256 obs=1024
```
