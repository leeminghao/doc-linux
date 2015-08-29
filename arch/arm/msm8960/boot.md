MSM8960 boot
========================================

MSM8960上电开机启动流程如下所示：

### Code Flow

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/secure_boot_code_flow.png

### Call Stack

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/secure_boot_call_stack.png

### Function

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/secure_boot_call_stack_functions.png

ARM是上电之后是从0x0地址开始执行代码的, 最先执行的程序是PBL.

PBL(RPM PBL)
----------------------------------------

当系统上电后，RPM CODE ROM(0x00000000 ~ 0x00018000)中预置的PBL程序被加载并执行.

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/pbl/README.md

SBL1
----------------------------------------

SBL1是被RPM PBL从eMMC上加载到SYSTEM IMEM(0x2A000000 ~ 0x2C000000)中执行的代码.

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/sbl1/README.md

SBL1复位Krait后跳转到SBL2中执行.

SBL2
----------------------------------------

SBL2是被SBL1从eMMC上加载到MIMEM/GMEM(0x2E000000 ~ 0x30000000)中执行.
**GMEM**: 是GPU的一块缓存.

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/sbl2/README.md

SBL2在完成指定功能后跳转到SBL3中去执行.

SBL3
----------------------------------------

SBL3是被SBL2从eMMC上加载到DDR(0x40000000 ~ 0xFFFFFFFF)中执行的.

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/sbl3/README.md

完成上述功能之后跳转到APPSBL中去执行:

APPSBL
----------------------------------------

APPSBL是被SBL3从eMMC上加载到DDR(0x40000000 ~ 0xFFFFFFFF)中执行的.

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/appsbl/README.md

完成上述功能之后跳转到HLOS中去执行:

HLOS
----------------------------------------

HLOS是被APPSBL从eMMC上加载到DDR(0x40000000 ~ 0xFFFFFFFF)中执行的.

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/hlos/README.md

Memory Layout
----------------------------------------

在完成HLOS的加载之后，各模块的的内存布局如下所示:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/memory_layout.md
