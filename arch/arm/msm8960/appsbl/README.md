APPSBL (lk)
----------------------------------------

APPSBL是被SBL3从eMMC上加载到DDR(0x40000000 ~ 0xFFFFFFFF)中执行的.

架构
----------------------------------------

* Krait

加载
----------------------------------------

* 载体: eMMC

执行
----------------------------------------

* 载体: DDR
* 起始地址: 0x88f00000

### 过程

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/appsbl_hlos.png

ELF Header
----------------------------------------

```
$ arm-eabi-readelf -h lk
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
  Entry point address:               0x88f00000
  Start of program headers:          52 (bytes into file)
  Start of section headers:          2505492 (bytes into file)
  Flags:                             0x5000002, has entry point, Version5 EABI
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         2
  Size of section headers:           40 (bytes)
  Number of section headers:         19
  Section header string table index: 16
```

Programe Header
----------------------------------------

```
$ arm-eabi-readelf -l lk

Elf file type is EXEC (Executable file)
Entry point 0x88f00000
There are 2 program headers, starting at offset 52

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  EXIDX          0x04de84 0x88f45e84 0x88f45e84 0x00020 0x00020 R   0x4
  LOAD           0x008000 0x88f00000 0x88f00000 0x1120e0 0x120878 RWE 0x8000

 Section to Segment mapping:
  Segment Sections...
   00     .ARM.exidx
   01     .text.boot .text .rodata .ARM.exidx .data .bss
```

Disassembler
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/appsbl/build-msm8960/lk.S

Code Flow
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/bootloader/lk/README.md
