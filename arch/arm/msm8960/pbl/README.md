PBL
========================================

当系统上电后，RPM CODE ROM(0x00000000 ~ 0x00018000)中预置的PBL程序被加载并执行.

架构
----------------------------------------

* ARM7

加载
----------------------------------------

* 载体: RPM CODE ROM

执行
----------------------------------------

* 载体: RPM CODE ROM (0x00000000 ~ 0x00018000, 96KB)
* 起始地址: 0x00000000

功能
----------------------------------------

* 检测外部存储器(EMMC);
* 加载并认证SBL1;
* 低电量检测.

### 过程

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/pbl.png

完成上述功能之后跳转到SBL1中去执行.

### SBL1

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/sbl1/README.md