Start Linux 0.11 from floppy.
================================================================================

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
