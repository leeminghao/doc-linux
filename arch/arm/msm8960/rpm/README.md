RPM firmware
========================================

RPM firmware是被SBL2从eMMC加载到RPM Code RAM(0x00020000 ~ 0x00048000, 160KB)中执行的.
如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/rpm_code_rom_ram.png

架构
----------------------------------------

* ARM7

加载
----------------------------------------

* 载体: eMMC

执行
----------------------------------------

* 载体: RPM Code RAM (0x00020000 ~ 0x00048000, 160KB)
* 起始地址: 0x00020000

功能
----------------------------------------

* 资源电源管理器

ELF HEADER
----------------------------------------

```
$ arm-eabi-readelf -h RPM.elf
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
  Entry point address:               0x20000
  Start of program headers:          4276480 (bytes into file)
  Start of section headers:          4276512 (bytes into file)
  Flags:                             0x5000002, has entry point, Version5 EABI
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         1
  Size of section headers:           40 (bytes)
  Number of section headers:         19
  Section header string table index: 18
```

Program Header
----------------------------------------

```
$ arm-eabi-readelf -l RPM.elf

Elf file type is EXEC (Executable file)
Entry point 0x20000
There are 1 program headers, starting at offset 4276480

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  LOAD           0x000034 0x00020000 0x00020000 0x22280 0x22780 RWE 0x8

 Section to Segment mapping:
  Segment Sections...
   00     RPM_ROM RPM_DATA_RW RPM_DATA_ZI DAL_HEAP DAL_HEAP
```

Disassembler
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/rpm//8064/build/RPM.S
