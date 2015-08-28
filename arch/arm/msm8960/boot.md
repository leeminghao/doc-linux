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

PBL是存在MSM8960内部的IROM(也称为为RPM ROM)上的代码, 从MSM8960内存系统映射图:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/memory_map.md

我们知道IROM被映射到0x00000000 ~ 0x02000000这个32MB地址空间, 系统上电后，IROM中预置的PBL程序
加载执行被执行.

### 加载位置

* IROM

### 执行位置

* IROM

### 功能

* 检测外部存储器(EMMC);
* 加载并认证SBL1模块;
* 低电量检测.

SBL1
----------------------------------------

SBL1是被加载到地址0x2A000000处开始执行, SBL1下载SBL2到IMEM上，用加密算法认证SBL2,
SBL1将Krait复位, Krait在复位后，会跳到SBL2头.

SBL2
----------------------------------------

Krait在复位后，会跳到SBL2头:

* SBL2提高Krait的时钟
* SBL2下载TZ到IMEM上
* SBL2用加密算法认证TZ
* 执行TZ(设置安全环境，参数，等等)
* 下载RPM固件到RAM上
* SBL2设置DDR
* SBL2下载SBL3到DDR上，用加密算法认证SBL3
* 发送Scorpion信号(Ready)
* 跳到SBL3头

SBL3
----------------------------------------

* 提高系统时钟
* 下载APPSBL(lk), 认证APPSBL
* 等待RPM发送INTR信号
* 收到INTR信号，程序跳到APPSBL头
* 当收到INTR时，Krait会跳到APPSBL头.
* APPSBL下载HLOS，跳到HLOS

lk
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/bootloader/lk/README.md
