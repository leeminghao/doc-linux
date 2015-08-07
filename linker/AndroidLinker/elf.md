elf
========================================

greet
----------------------------------------

greet是由src/libgreet下面的main.c编译而成其elf header如下所示:

```
$ arm-linux-androideabi-readelf -e greet
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
  Entry point address:               0x2e8
  Start of program headers:          52 (bytes into file)
  Start of section headers:          4436 (bytes into file)
  Flags:                             0x5000000, Version5 EABI
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         8
  Size of section headers:           40 (bytes)
  Number of section headers:         23
  Section header string table index: 22

Section Headers:
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .interp           PROGBITS        00000134 000134 000013 00   A  0   0  1
  [ 2] .dynsym           DYNSYM          00000148 000148 000080 10   A  3   1  4
  [ 3] .dynstr           STRTAB          000001c8 0001c8 000079 00   A  0   0  1
  [ 4] .hash             HASH            00000244 000244 000034 04   A  2   0  4
  [ 5] .rel.dyn          REL             00000278 000278 000020 08   A  2   0  4
  [ 6] .rel.plt          REL             00000298 000298 000018 08   A  2   7  4
  [ 7] .plt              PROGBITS        000002b0 0002b0 000038 00  AX  0   0  4
  [ 8] .text             PROGBITS        000002e8 0002e8 0000be 00  AX  0   0  4
  [ 9] .note.android.ide PROGBITS        000003a8 0003a8 000018 00   A  0   0  4
  [10] .ARM.extab        PROGBITS        000003c0 0003c0 00000c 00   A  0   0  4
  [11] .ARM.exidx        ARM_EXIDX       000003cc 0003cc 000010 08  AL  8   0  4
  [12] .preinit_array    PREINIT_ARRAY   00001ec0 000ec0 000008 00  WA  0   0  4
  [13] .init_array       INIT_ARRAY      00001ec8 000ec8 000008 00  WA  0   0  4
  [14] .fini_array       FINI_ARRAY      00001ed0 000ed0 000008 00  WA  0   0  4
  [15] .dynamic          DYNAMIC         00001ed8 000ed8 000100 08  WA  3   0  4
  [16] .got              PROGBITS        00001fd8 000fd8 000028 00  WA  0   0  4
  [17] .bss              NOBITS          00002000 001000 000004 00  WA  0   0  4
  [18] .comment          PROGBITS        00000000 001000 000010 01  MS  0   0  1
  [19] .note.gnu.gold-ve NOTE            00000000 001010 00001c 00      0   0  4
  [20] .ARM.attributes   ARM_ATTRIBUTES  00000000 00102c 000036 00      0   0  1
  [21] .gnu_debuglink    PROGBITS        00000000 001062 00000c 00      0   0  1
  [22] .shstrtab         STRTAB          00000000 00106e 0000e4 00      0   0  1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings)
  I (info), L (link order), G (group), T (TLS), E (exclude), x (unknown)
  O (extra OS processing required) o (OS specific), p (processor specific)

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  PHDR           0x000034 0x00000034 0x00000034 0x00100 0x00100 R   0x4
  INTERP         0x000134 0x00000134 0x00000134 0x00013 0x00013 R   0x1
      [Requesting program interpreter: /system/bin/linker]
  LOAD           0x000000 0x00000000 0x00000000 0x003dc 0x003dc R E 0x1000
  LOAD           0x000ec0 0x00001ec0 0x00001ec0 0x00140 0x00144 RW  0x1000
  DYNAMIC        0x000ed8 0x00001ed8 0x00001ed8 0x00100 0x00100 RW  0x4
  GNU_STACK      0x000000 0x00000000 0x00000000 0x00000 0x00000 RW  0
  EXIDX          0x0003cc 0x000003cc 0x000003cc 0x00010 0x00010 R   0x4
  GNU_RELRO      0x000ec0 0x00001ec0 0x00001ec0 0x00140 0x00140 RW  0x4

 Section to Segment mapping:
  Segment Sections...
   00
   01     .interp
   02     .interp .dynsym .dynstr .hash .rel.dyn .rel.plt .plt .text .note.android.ident .ARM.extab .ARM.exidx
   03     .preinit_array .init_array .fini_array .dynamic .got .bss
   04     .dynamic
   05
   06     .ARM.exidx
   07     .preinit_array .init_array .fini_array .dynamic .got
```