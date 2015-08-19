linker header
========================================

elf header
----------------------------------------

```
$ arm-linux-androideabi-readelf -h linker
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              DYN (Shared object file)
  Machine:                           ARM
  Version:                           0x1
  Entry point address:               0xa18
  Start of program headers:          52 (bytes into file)
  Start of section headers:          54004 (bytes into file)
  Flags:                             0x5000000, Version5 EABI
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         9
  Size of section headers:           40 (bytes)
  Number of section headers:         26
  Section header string table index: 23
```

program header
----------------------------------------

```
$ arm-linux-androideabi-readelf -l linker

Elf file type is DYN (Shared object file)
Entry point 0xa18
There are 9 program headers, starting at offset 52

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  PHDR           0x000034 0x00000034 0x00000034 0x00120 0x00120 R   0x4
  INTERP         0x000154 0x00000154 0x00000154 0x00013 0x00013 R   0x1
      [Requesting program interpreter: /system/bin/linker]
  LOAD           0x000000 0x00000000 0x00000000 0x0c1f0 0x0c1f0 R E 0x1000
  LOAD           0x00ca5c 0x0000da5c 0x0000da5c 0x00734 0x01ca0 RW  0x1000
  DYNAMIC        0x00cef8 0x0000def8 0x0000def8 0x000c0 0x000c0 RW  0x4
  GNU_EH_FRAME   0x00c0a4 0x0000c0a4 0x0000c0a4 0x0014c 0x0014c R   0x4
  GNU_STACK      0x000000 0x00000000 0x00000000 0x00000 0x00000 RW  0
  EXIDX          0x008e4c 0x00008e4c 0x00008e4c 0x00650 0x00650 R   0x4
  GNU_RELRO      0x00ca5c 0x0000da5c 0x0000da5c 0x005a4 0x005a4 RW  0x4

 Section to Segment mapping:
  Segment Sections...
   00
   01     .interp
   02     .interp .dynsym .dynstr .hash .rel.dyn .rel.plt .plt .text .ARM.exidx .rodata .ARM.extab .eh_frame .eh_frame_hdr
   03     .data.rel.ro.local .init_array .dynamic .got .data .bss
   04     .dynamic
   05     .eh_frame_hdr
   06
   07     .ARM.exidx
   08     .data.rel.ro.local .init_array .dynamic .got
```