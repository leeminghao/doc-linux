sbl3
========================================

SBL3是被SBL2从eMMC上加载到DDR(0x40000000 ~ 0xFFFFFFFF)中执行的.

架构
----------------------------------------

* Krait

加载
----------------------------------------

* 载体: eMMC

执行
----------------------------------------

* 载体: DDR (0x40000000 ~ 0xFFFFFFFF, 3GB)
* 起始地址: 0x8ff00000

**注意**: 虽然Krait架构将近3GB的内存空间分配给了DDR,但是不是说系统
就真实存在3GB的DDR内存，也可能小于3GB. 例如在我们的系统里就将真实的
2GB物理内存映射到了0x80000000 ~ 0xFFFFFF00这个地址段.

功能
----------------------------------------

* 复位检查;
* 提高系统时钟频率到最高;
* 检查下载模式/大容量存储模式;
* 加载并认证HLOS APPSBL(lk);

完成上述功能之后跳转到HLOS APPSBL中去执行:

https://github.com/leeminghao/doc-linux/blob/master/bootloader/lk/README.md

ELF Header
----------------------------------------

```
$ arm-eabi-readelf -h SBL3_AAAAANAZA.elf
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
  Entry point address:               0x8ff00000
  Start of program headers:          5443764 (bytes into file)
  Start of section headers:          5443796 (bytes into file)
  Flags:                             0x5000002, has entry point, Version5 EABI
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         1
  Size of section headers:           40 (bytes)
  Number of section headers:         28
  Section header string table index: 27
```

Program Header
----------------------------------------

```
$ arm-eabi-readelf -l SBL3_AAAAANAZA.elf

Elf file type is EXEC (Executable file)
Entry point 0x8ff00000
There are 1 program headers, starting at offset 5443764

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  LOAD           0x000034 0x8ff00000 0x8ff00000 0x4a15c 0xb8d08 RWE 0x4000

 Section to Segment mapping:
  Segment Sections...
   00     SBL3_CODE SBL3_RAM_RW SBL3_RAM_ZI SBL3_RAMDUMP_DATA SBL3_ERR_DATA
```

Disassemble
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/sbl3/build/AAAAANAZ/SBL3_AAAAANAZA.S
