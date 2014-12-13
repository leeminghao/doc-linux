Mounting raw and qcow2 VM disk images
================================================================================

Mounting a partition from raw image is pretty simple:
--------------------------------------------------------------------------------

```
losetup /dev/loop0 image.img
kpartx -a /dev/loop0
mount /dev/mapper/loop0p1 /mnt/image
```

If kernel parameter (as loop in compiled into Fedora’s kernel) like loop.max_part=63 added it is even simplier:
--------------------------------------------------------------------------------

```
losetup /dev/loop0 image.img
mount /dev/loop0p1 /mnt/image
```

Alternative way is to specify direct offset to partition:
--------------------------------------------------------------------------------

```
mount image.img /mnt/image -o loop,offset=32256
```

To mount qcow2 images there is (at least in F-11 qemu) very useful qemu-nbd util. It shares image through kernel network block device protocol and this allows to mount it:
--------------------------------------------------------------------------------

```
modprobe nbd max_part=63
qemu-nbd -c /dev/nbd0 image.img
mount /dev/nbd0p1 /mnt/image
```

If LVM is present on image it could be initialized with:
--------------------------------------------------------------------------------

```
vgscan
vgchange -ay
mount /dev/VolGroupName/LogVolName /mnt/image
```

Finishing is done with (depending on how it was initalized):
--------------------------------------------------------------------------------

```
umount /mnt/image
vgchange -an VolGroupName
killall qemu-nbd
kpartx -d /dev/loop0
losetup -d /dev/loop0
```

Mount a image file to a directory:
--------------------------------------------------------------------------------

sudo mount -r -o loop rootfs.img mnt/