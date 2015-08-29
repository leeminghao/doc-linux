MSM8960 boot
========================================

MSM8960上电开机启动执行过程如下所示:

### 执行流程图

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/secure_boot_code_flow.png

### 执行调用栈图

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/secure_boot_call_stack.png

### 执行功能图

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/secure_boot_call_stack_functions.png

根据上述三个按照时间，空间和功能划分的执行流程图，我们详细介绍下各模块的执行位置，作用等.

ARM是上电之后是从0地址开始执行代码的.

PBL(RPM PBL)
----------------------------------------

PBL是存在MSM8960内部的IROM(也称为RPM ROM)上的代码, 从MSM8960内存系统映射:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/memory.md

我们知道IROM被映射到0x00000000 ~ 0x02000000这个32MB地址空间,
当系统上电后，IROM中预置的PBL程序被加载并执行.

### 架构

* ARM7

### 加载

* 载体: IROM

### 执行

* 载体: IROM (0x00000000 ~ 0x02000000, 32MB)
* 起始地址: 0x00000000

### 功能

* 检测外部存储器(EMMC);
* 加载并认证SBL1;
* 低电量检测.

完成上述功能之后跳转到SBL1中去执行.

SBL1
----------------------------------------

SBL1是被RPM PBL从eMMC上加载到SYSTEM IMEM(0x2A000000 ~ 0x2C000000)
中执行的代码. 其详细信息如下所示:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/sbl1/README.md

SBL1复位Krait后跳转到SBL2中执行.

SBL2
----------------------------------------

SBL2是被SBL1从eMMC上加载到MIMEM/GMEM(0x2E000000 ~ 0x30000000)中执行.

**GMEM**: 是GPU的一块缓存.

其详细信息如下所示:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/sbl2/README.md

SBL2在完成指定功能后跳转到SBL3中去执行.

SBL3
----------------------------------------

SBL3是被SBL2从eMMC上加载到DDR(0x40000000 ~ 0xFFFFFFFF)中执行的.
其详细信息如下所示:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/sbl3/README.md

完成上述功能之后跳转到HLOS APPSBL中去执行:

https://github.com/leeminghao/doc-linux/blob/master/bootloader/lk/README.md
