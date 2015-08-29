sbl1
========================================

SBL1是被RPM PBL从eMMC上加载到SYSTEM IMEM(0x2A000000 ~ 0x2C000000)
中执行的代码.

架构
----------------------------------------

* ARM7

加载
----------------------------------------

* 载体: eMMC

执行
----------------------------------------

* 载体: System IMEM (0x2A000000 ~ 0x2C000000, 32MB)
* 起始地址: 0x2A000000

功能
----------------------------------------

* 初始化SSBI和PMIC总线;
* 加载并认证SBL2;
* 配置Krait时钟并且将Krait复位.

完成上述功能之后, 复位后跳转到SBL2中执行.

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/sbl2/README.md

ELF Header
----------------------------------------

```
$ arm-eabi-readelf -h SBL1_AAAAANAZA.elf
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
  Start of program headers:          1405104 (bytes into file)
  Start of section headers:          1405136 (bytes into file)
  Flags:                             0x5000002, has entry point, Version5 EABI
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         1
  Size of section headers:           40 (bytes)
  Number of section headers:         26
  Section header string table index: 25
```

Program Header
----------------------------------------

```
$ arm-eabi-readelf -l SBL1_AAAAANAZA.elf

Elf file type is EXEC (Executable file)
Entry point 0x2a000000
There are 1 program headers, starting at offset 1405104

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  LOAD           0x000034 0x2a000000 0x2a000000 0x147d4 0x1c734 RWE 0x800

 Section to Segment mapping:
  Segment Sections...
   00     SBL1_ROM SBL1_DATA_RW SBL1_DATA_ZI
```

Disassemble
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/sbl1/build/AAAAANAZ/SBL1_AAAAANAZA.S
