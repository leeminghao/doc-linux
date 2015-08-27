MSM8960 boot
========================================

MSM8960的启动过程和各个模块的加载地址如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/res/boot.jpg

PBL
----------------------------------------

ARM是上电之后从0地址开始执行代码, BL是存在MSM8960的IROM(芯片内部ROM)上,这个启动代码也称为SBL0。
这段IROM被映射到0地址,通电后，PBL被执行。其功能如下所示:

* PBL测试是通电启动还是重启;
* PBL提高RPM时钟到60MHz;
* PBL将SBL1从Flash device下载到IMEM

SBL1
----------------------------------------

SBL1下载SBL2，用加密算法认证SBL2, SBL1将Krait复位, Krait在复位后，会跳到SBL2头.

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
* 下载APPSBL；认证APPSBL
* 等待RPM发送INTR信号
* 收到INTR信号，程序跳到APPSBL头
* 当收到INTR时，Krait会跳到APPSBL头, 下载HLOS，跳到HLOS
* HLOS下载modem image, 调用PIL服务进入TZ
* 认证image, 复位modem
* 下载LPA Hexagon image，调用PIL服务进入TZ
* 认证image, 复位LPA Hexagon
* 下载SPS ARM7 image，调用PIL服务进入TZ
* 认证image, 复位SPS ARM7
* 下载RIVA image，调用PIL服务进入TZ
* 认证image, 复位RIVA
* HLOS APPSBL加载和校验HLOS内核lk.

lk
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/bootloader/lk/README.md
