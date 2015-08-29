TZ
========================================

TZ是被SBL2从eMMC加载到System IMEM(0x2A000000 ~ 0x2C000000)中的.

架构
----------------------------------------

* Krait

加载
----------------------------------------

* 载体: eMMC

执行
----------------------------------------

* 载体: System IMEM (0x2A000000 ~ 0x2C000000, 32MB)
* 起始地址: 0x2A000000

功能
----------------------------------------

* 安装安全环境(xPU)
* 提供安全模式支持ROT

ELF Header
----------------------------------------

```
$ arm-eabi-readelf -h tz.elf
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
  Entry point address:               0x2a000000
  Start of program headers:          1714672 (bytes into file)
  Start of section headers:          1714704 (bytes into file)
  Flags:                             0x5000002, has entry point, Version5 EABI
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         1
  Size of section headers:           40 (bytes)
  Number of section headers:         20
  Section header string table index: 19
```

Programe Header
----------------------------------------

```
$ arm-eabi-readelf -l tz.elf

Elf file type is EXEC (Executable file)
Entry point 0x2a000000
There are 1 program headers, starting at offset 1714672

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  LOAD           0x000034 0x2a000000 0x2a000000 0x31188 0x3cdd8 RWE 0x4000

 Section to Segment mapping:
  Segment Sections...
   00     TZBSP_VEC_TBL TZBSP_CODE TZBSP_RO_DATA TZBSP_RAM_RW TZBSP_RAM_ZI TZBSP_RAM_ZI TZBSP_MMU_L2_PT TZBSP_DAL_HEAP TZBSP_MMU_L1_PT TZBSP_UNCACHED_ZI
```

Disassembler
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/tz/tzbsp/build/AAAAANAZ/tz.S
