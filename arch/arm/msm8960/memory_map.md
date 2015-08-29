MSM8960 Memory Map
========================================

MSM 8960存储器映射如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/memory_map.png

32位地址总共4GB的地址空间.

0x40000000 ~ 0xFFFFFFFF
----------------------------------------

3GB, 分配给系统物理内存(DDR).

0x00000000 ~ 0x40000000
----------------------------------------

1GB, 分配CPU其它管理系统使用.

### 0x00000000 ~ 0x02000000

RPM/SYSTEM FPB, 32MB, 其又被作如下映射:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/rpm_code_rom_ram.png

#### 0x00000000 ~ 0x00018000

96KB, RPM CODE ROM, 用于RPM Boot ROM Code.

#### 0x00018000 ~ 0x00020000

32KB, UNUSED AREA

#### 0x00020000 ~ 0x00048000

160KB, RPM CODE RAM, 用于加载RPM firmware

### 0x2A000000 ~ 0x2C000000

32MB， 分配给CPU内置System IMEM使用.

### 0x2E000000 ~ 0x30000000

32MB， 配给MIMEM/GMEM使用.
