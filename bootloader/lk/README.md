LK (APPSBL)
========================================

lk就是Little Kernel，android lk也是appsboot是Qualcomm平台的bootloader.
它是类似OS一样的小操作系统.其通常由更底层的模块(secure boot)加载到内存
运行. 例如我们实验的平台MSM8960是如下方式来加载LK的:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/README.md

实验平台
----------------------------------------

* CPU - MSM8960
* SDRAM - 2GB, 映射地址为(0x8000000 ~ 0xffffff00)


目录结构
----------------------------------------

* app            // 应用相关
* arch           // arm 体系
* dev            // 设备相关
* include        // 头文件
* kernel         // lk系统相关
* platform       // 相关驱动
* project        // makefile文件
* scripts        // Jtag 脚本
* target         // 具体板子相关

Code Flow
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/lk_code_flow.md

Memory map
----------------------------------------

在经过secure boot加载完Appsbl(lk), 又由lk将HLOS(Linux kernel)加载
到DDR内存之后，我们得到如下存储空间布局:

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/memory_map.md
