HLOS (Linux kernel)
========================================

HLOS(Linux kernel)是由APPSBL(lk)加载到DDR

架构
----------------------------------------

* Krait

加载
----------------------------------------

* 载体: eMMC

执行
----------------------------------------

* 载体: DDR
* 起始地址: 0x80208000

ELF Header
----------------------------------------

```
$ arm-eabi-readelf -h vmlinux
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           ARM
  Version:                           0x1
  Entry point address:               0x0
  Start of program headers:          52 (bytes into file)
  Start of section headers:          3505884 (bytes into file)
  Flags:                             0x5000200, Version5 EABI, soft-float ABI
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         1
  Size of section headers:           40 (bytes)
  Number of section headers:         22
  Section header string table index: 19
```

Program Header
----------------------------------------

```
$ arm-eabi-readelf -l vmlinux

Elf file type is EXEC (Executable file)
Entry point 0x0
There are 1 program headers, starting at offset 52

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  LOAD           0x008000 0x00000000 0x00000000 0x34a288 0x34b2a8 RWE 0x8000

 Section to Segment mapping:
  Segment Sections...
   00     .text .rodata .piggydata .got.plt .got .pad .bss .stack
```