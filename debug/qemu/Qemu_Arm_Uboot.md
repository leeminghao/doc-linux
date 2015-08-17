Qemu Arm U-boot
================================================================================

使用Qemu模拟Cortex-A9运行U-boot和Linux
--------------------------------------------------------------------------------


1. 安装GNU工具链
--------------------------------------------------------------------------------

```
    sudo apt-get insatll gcc-arm-linux-gnueabi
    sudo apt-get insatll g++-arm-linux-gnueabi
````

安装完成后会在 /usr/arm-linux-gnueabi/ 目录下生成库文件、头文件等。 我安装的GCC版本为：

```
    arm-linux-gnueabi-gcc (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3
    Copyright (C) 2011 Free Software Foundation, Inc.
```

2. 安装Qemu模拟器
--------------------------------------------------------------------------------

```
    sudo apt-get install qemu qemu-system qemu-utils
```

这时应该已经可以运行qemu-system-arm命令了, 其版本为：

```
    qemu-system-arm --version
    QEMU emulator version 1.0.50 (Debian 1.0.50-2012.03-0ubuntu2), Copyright (c) 2003-2008 Fabrice Bellard
```

3. 编译和运行U-boot：
--------------------------------------------------------------------------------

到 ftp://ftp.denx.de/pub/u-boot/ 下载最新版本的U-Boot源代码， 我用的目前最新版本 u-boot-2012.04.tar.bz2
解压后进入源代码目录，在Makefile里面增加两行：

```
    ARCH ?= arm
    CROSS_COMPILE ?= arm-linux-gnueabi-
```

其实就是告诉它使用ARM编译器来编译。

```
    make ca9x4_ct_vxp_config
    make
```

这里配置目标板为 Cortex-A9x4 vexpress. 之所以选这个配置可以从 boards.cfg文件里看到， vexpress是ARM公司使用Cortext-A9的一个开发板，相关的代码在 board/armltd/vexpress/ 目录，配置文件为include/configs/ca9x4_ct_vxp.h。  而且关键的是Qemu里面已经支持这个板卡。

编译完成后会生成u-boot文件
运行：

```
    qemu-system-arm -M vexpress-a9 -m 256M -nographic -kernel u-boot
```

或者

```
    qemu-system-arm -M vexpress-a9 -m 256M -serial stdio -kernel u-boot
```

发现，如果没有指定-nographics, 则必须要加-serial stdio才会有打印。

参数-m 256M为指定内存大小。-M 指定板卡的名称， 支持的板卡可以用-M ?查看， 如下：

```
    #qemu-system-arm -M ?
    Supported machines are:
    beagle Beagle board (OMAP3530)
    beaglexm Beagle board XM (OMAP3630)
    ............
    versatilepb ARM Versatile/PB (ARM926EJ-S)
    versatileab ARM Versatile/AB (ARM926EJ-S)
    vexpress-a9 ARM Versatile Express for Cortex-A9
    vexpress-a15 ARM Versatile Express for Cortex-A15
```

正常运行的结果：

```
    qemu-system-arm -M vexpress-a9 -m 256M -nographic -kernel u-boot
    U-Boot 2012.04 (Jul 08 2012 - 00:14:08)
    DRAM: 256 MiB
    WARNING: Caches not enabled
    Flash: ## Unknown flash on Bank 1 - Size = 0x00000000 = 0 MB
    ## Unknown flash on Bank 2 - Size = 0x00000000 = 0 MB
    *** failed ***
    MMC: MMC: 0
    *** Warning - bad CRC, using default environment
    In: serial
    Out: serial
    Err: serial
    Net: smc911x-0
    Hit any key to stop autoboot: 0
    VExpress#
    VExpress# printenv
    baudrate=38400
    bootcmd=run bootflash;
    bootdelay=2
    bootflash=run flashargs; cp ${ramdisk_addr} ${ramdisk_addr_r} ${maxramdisk}; bootm ${kernel_addr} ${ramdisk_addr_r}
    console=ttyAMA0,38400n8
    。。。。。
```

注意：如果在检测Flash failed后停止运行，是因为在 arch/arm/lib/board.c里面 board_init_r()函数里检测Flash失败后调用了hang(), 暂时先把hang()去掉就可以运行下去了。


4.  编译和运行Linux内核:
--------------------------------------------------------------------------------

到http://www.kernel.org/下载最新的Linux内核源码，我下载的是linux-3.4.4.tar.bz2. 解压后修改Makefile, ARCH = arm， CROSS_COMPILE=arm-linux-gnueabi-

```
    make vexpress_defconfig
```

（可以到 arch/arm/configs/ 目录看到所有自带的配置文件， 我们使用vexpress板卡默认的配置文件）
然后 make menuconfig --> System Type  把 Enable the L2x0 outer cache controller 取消， 否则Qemu会起不来， 暂时还不知道为什么。
然后就可以make了。 最后会生成 arch/arm/boot/zImage 文件， 这就是我们需要的内核映像。


5. 制作根文件系统：
--------------------------------------------------------------------------------

这部分网上有非常多的介绍，就不细说了。 大概流程是：先创建标准的Linux目录结构， 到http://www.busybox.net/上下载最新的Busybox源代码编译安装到刚才创建的目录，
拷贝ARM的库文件到相应目录，在etc/目录创建若干必须的启动脚本和配置文件。 下面说一下怎么生成一个ext3格式的文件系统映像：

```
    dd if=/dev/zero of=a9rootfs.ext3 bs=1M count=32 //创建一个32M的空文件
    mkfs.ext3 a9rootfs.ext3 //格式化为EXT3
    sudo mount -t ext3 a9rootfs.ext3 a9rootdir/ -o loop //挂载到a9rootdir目录
    cp path/to/your/rootfs/* a9rootdir/ -Rf //拷贝文件到该目录，相对于放到a9rootfs.ext3里面
    sudo umount a9rootdir/
```

至此a9rootfs.ex3 就包含了我们创建的根文件系统内容， 并且是ext3格式。


6. 使用Qemu运行Linux：
--------------------------------------------------------------------------------

```
    qemu-system-arm -kernel zImage -serial stdio -M vexpress-a9 -append "root=/dev/mmcblk0 console=ttyAMA0 console=tty0" -sd a9rootfs.ext3
```

Qemu可以模拟SD卡， 我们把a9rootfs.ext3作为一个SD设备，对应的设备文件即为 /dev/mmcblk0， 以它作为根文件系统启动。 ttyAMA0:  Serial console;  tty0: Framebuffer Console. 最后放一张启动后的图片：