MSM8960 Memory Map
========================================

MSM 8960存储器映射如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/memory_map.md

32位地址总共4GB的地址空间.

0x40000000 ~ 0xFFFFFFFF
----------------------------------------

3GB空间分配给系统物理内存.

0x00000000 ~ 0x40000000
----------------------------------------

1GB分配CPU其它管理系统使用.

### 0x00000000 ~ 0x02000000

总共32MB空间分配给CPU内置IROM使用，该IROM用于CPU上电执行PBL启动程序和RPM(资源电源管理程序)使用.

### 0x2A000000 ~ 0x2C000000

总共32MB空间分配给CPU内置IMEM使用.
