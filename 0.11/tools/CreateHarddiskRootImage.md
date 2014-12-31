在硬盘上制作根文件系统
================================================================================

在linux系统下使用dd命令创建hdc-0.11.new.img，步骤如下：

```
$ dd if=/dev/zero of=hdc-0.11.new.img bs=512 count=524160
```

读入了524160+0个块输出了524160+0个块[524160=520*16*63]

柱面数520，磁头数16，每磁道扇区数63，上面的bs表示每扇区的字节数，所以我们建立的磁盘容量为：
512*524160=268369920 bytes，近似为268MB

使用losetup命令将映像文件与loop0设备关联，以便对映像文件进行操作

```
$ sudo losetup /dev/loop0 hdrootfs.img
```

使用fdisk格式化设备

```
$ sudo fdisk /dev/loop0
Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel with disk identifier 0x24551eec.
Changes will remain in memory only, until you decide to write them.
After that, of course, the previous content won't be recoverable.

Warning: invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1):
Using default value 1
First sector (2048-124639, default 2048):
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-124639, default 124639):
Using default value 124639

Command (m for help): t
Selected partition 1
Hex code (type L to list codes): l

 0  Empty           24  NEC DOS         81  Minix / old Lin bf  Solaris
 1  FAT12           27  Hidden NTFS Win 82  Linux swap / So c1  DRDOS/sec (FAT-
 2  XENIX root      39  Plan 9          83  Linux           c4  DRDOS/sec (FAT-
 3  XENIX usr       3c  PartitionMagic  84  OS/2 hidden C:  c6  DRDOS/sec (FAT-
 4  FAT16 <32M      40  Venix 80286     85  Linux extended  c7  Syrinx
 5  Extended        41  PPC PReP Boot   86  NTFS volume set da  Non-FS data
 6  FAT16           42  SFS             87  NTFS volume set db  CP/M / CTOS / .
 7  HPFS/NTFS/exFAT 4d  QNX4.x          88  Linux plaintext de  Dell Utility
 8  AIX             4e  QNX4.x 2nd part 8e  Linux LVM       df  BootIt
 9  AIX bootable    4f  QNX4.x 3rd part 93  Amoeba          e1  DOS access
 a  OS/2 Boot Manag 50  OnTrack DM      94  Amoeba BBT      e3  DOS R/O
 b  W95 FAT32       51  OnTrack DM6 Aux 9f  BSD/OS          e4  SpeedStor
 c  W95 FAT32 (LBA) 52  CP/M            a0  IBM Thinkpad hi eb  BeOS fs
 e  W95 FAT16 (LBA) 53  OnTrack DM6 Aux a5  FreeBSD         ee  GPT
 f  W95 Ext'd (LBA) 54  OnTrackDM6      a6  OpenBSD         ef  EFI (FAT-12/16/
10  OPUS            55  EZ-Drive        a7  NeXTSTEP        f0  Linux/PA-RISC b
11  Hidden FAT12    56  Golden Bow      a8  Darwin UFS      f1  SpeedStor
12  Compaq diagnost 5c  Priam Edisk     a9  NetBSD          f4  SpeedStor
14  Hidden FAT16 <3 61  SpeedStor       ab  Darwin boot     f2  DOS secondary
16  Hidden FAT16    63  GNU HURD or Sys af  HFS / HFS+      fb  VMware VMFS
17  Hidden HPFS/NTF 64  Novell Netware  b7  BSDI fs         fc  VMware VMKCORE
18  AST SmartSleep  65  Novell Netware  b8  BSDI swap       fd  Linux raid auto
1b  Hidden W95 FAT3 70  DiskSecure Mult bb  Boot Wizard hid fe  LANstep
1c  Hidden W95 FAT3 75  PC/IX           be  Solaris boot    ff  BBT
1e  Hidden W95 FAT1 80  Old Minix
Hex code (type L to list codes): 80
Changed system type of partition 1 to 80 (Old Minix)

Command (m for help): p

Disk /dev/loop0: 63 MB, 63815680 bytes
255 heads, 63 sectors/track, 7 cylinders, total 124640 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x24551eec

      Device Boot      Start         End      Blocks   Id  System
/dev/loop0p1            2048      124639       61296   80  Old Minix

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.

WARNING: Re-reading the partition table failed with error 22: Invalid argument.
The kernel still uses the old table. The new table will be used at
the next reboot or after you run partprobe(8) or kpartx(8)
Syncing disks.
```

在Bochs环境中，在上面的镜像文件的第一个分区中建立minix文件系统，并将rootimage-0.11中的内容复制
到上面的分区中，步骤如下：

* 在Bochs中运行Linux0.11模拟系统时，其配置文件bochsrc.bxrc中通常需要以下这些内容:

```
#gdbstub: enabled=1, port=1234, text_base=0, data_base=0, bss_base=0
romimage: file=/usr/local/share/bochs/BIOS-bochs-latest
megs: 16
#vgaromimage: file=/usr/local/share/bochs/VGABIOS-lgpl-latest
vgaromimage: file=/usr/local/share/bochs/VGABIOS-elpin-2.40
vga: extension=vbe
#floppya: 1_44=floppy.img, status=inserted
#floppya: 1_44=bootimage-0.11, status=inserted
floppya: 1_44="bootimage-0.11-hd", status=inserted
#floppya: 1_44="../bootimage", status=inserted

#floppyb: 1_44=rootimage-0.11, status=inserted
#floppyb: 1_44=rootimage-small, status=inserted
#floppyb: 1_44=diskb.img, status=inserted

ata0-master: type=disk, path="hdc-0.11-new.img", mode=flat, cylinders=410, heads=16, spt=38
ata0-slave: type=disk, mode=flat, path="hdrootfs.img", cylinders=60, heads=16, spt=63
#ata0-master: type=disk, mode=flat, path="hdrootfs.img", cylinders=60, heads=16, spt=63

boot: a
log: bochsout.txt
#parport1: enable=0
#vga_update_interval: 300000
#keyboard_serial_delay: 200
#floppy_command_delay: 50000
#ips: 4000000
mouse: enabled=0
private_colormap: enabled=0
fullscreen: enabled=0
screenmode: name="sample"
```

* 使用mkfs命令在刚建立的第1个分区上创建MINIX文件系统。命令与信息如下所示。

https://github.com/leeminghao/doc-linux/tree/master/0.11/tools/step1.png

然后执行下列命令，把新的文件系统加载到/mnt目录上, 在加载了硬盘分区上的文件系统之后，
我们就可以把软盘上的根文件系统复制到硬盘上去了, 请执行以下命令：

https://github.com/leeminghao/doc-linux/tree/master/0.11/tools/step2.png
