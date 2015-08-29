sbl2
========================================

SBL2是被SBL1从eMMC上加载到MIMEM/GMEM(0x2E000000 ~ 0x30000000)中执行的.

架构
----------------------------------------

* Krait

加载
----------------------------------------

* 载体: eMMC

执行
----------------------------------------

* 载体: MIMEM/GMEM (0x2E000000 ~ 0x30000000, 32MB)
* 起始地址: 0x2E000000

功能
----------------------------------------

* 初始化Krait处理器;
* 使能data cache 和 MMU;
* 加载和认证TZ image和RPM firmware;
* 配置外部DDR存储器;
* 加载和认证SBL3;

### TZ

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/tz/README.md

### RPM firmware

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/rpm/README.md

### 过程

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/sbl2_A.png

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/sbl2_B.png

完成上述功能之后跳转到SBL3中去执行.

### SBL3

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/sbl3/README.md

ELF Header
----------------------------------------

```
$ arm-eabi-readelf -h SBL2_AAAAANAZA.elf
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
  Entry point address:               0x2e000000
  Start of program headers:          2023168 (bytes into file)
  Start of section headers:          2023200 (bytes into file)
  Flags:                             0x5000002, has entry point, Version5 EABI
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         1
  Size of section headers:           40 (bytes)
  Number of section headers:         31
  Section header string table index: 30
```

Programe Header
----------------------------------------

```
$ arm-eabi-readelf -l SBL2_AAAAANAZA.elf

Elf file type is EXEC (Executable file)
Entry point 0x2e000000
There are 1 program headers, starting at offset 2023168

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  LOAD           0x000034 0x2e000000 0x2e000000 0x1ffe0 0x2c6c0 RWE 0x4000

 Section to Segment mapping:
  Segment Sections...
   00     SBL2_VEC_TBL SBL2_IND_VEC_TBL SBL2_PTR_AREA1 SBL2_CODE SBL2_RAM_RW SBL2_RAM_ZI SBL2_ERR_DATA
```

Disassembler
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/sbl2/build/AAAAANAZ/SBL2_AAAAANAZA.S
