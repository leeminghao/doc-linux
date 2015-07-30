Little Kernel
========================================

lk 就是 Little Kernel ，android lk 也是appsboot 是Qualcomm平台 arm11 端的 bootloader。
它是类似OS一样的小操作系统。

lk源码位置在android 系统下：

path: boottable/bootloader/lk

* app            // 应用相关
* arch           // arm 体系
* dev            // 设备相关
* include        // 头文件
* kernel         // lk系统相关
* platform       // 相关驱动
* projiect       // makefile文件
* scripts        // Jtag 脚本
* target         // 具体板子相关

LK 分析
----------------------------------------

### _start

lk入口在crt0.s中_start 函数开始（在连接文件 system_onesegment.ld 中 ENTRY（_start）指定）

path: lk/arch/arm/crt0.s

* 1. 设置向量表
* 2. 初始化BSS
* 3. 跳到C函数（bl kmain）

### kmain

path: lk/kernel/main.c

* 1. thread_init_early()       初始化lk系统进程相关
* 2. arch_early_init()         cpu相关的初始化, 如, 关闭cache使能mmu等
* 3. platform_early_init()     具体的平台相关初始化
* 4. target_early_init()       对平台的检测
* 5. call_constructors()       构造函数相关
* 6. heap_init();              lk系统堆栈的初始化
* 7. thread_init()             线程相关初始化
* 8. dpc_init();               lk相关控制系统初始化(涉及event事件机制)
* 9. timer_init()              lk定时器初始化
* 10. bootstrap2()             系统相关重点下面专门分析

### bootstrap2

它在kmain的最后被以新的简单线程的方式运行起来的。

path: lk/kernel/main.c

```
thread_resume(thread_create("bootstrap2", &bootstrap2, NULL, DEFAULT_PRIORITY, DEFAULT_STACK_SIZE));
```

bootstrap2 主要做了3件事：

* 1. platform_init() - 它就一个函数调用 acpu_clock_init ,对arm 11 进行系统时钟设置，超频。
* 2. target_init() - 针对不同的硬件平台进行设置，有键盘设置，和系统 分区表（partition table）的设置。
* 3. apps_init() - 对LK中的所谓app初始化并运行起来，而aboot_init 就在开始被运行。（aboot_init加载linux）

LK在硬件，平台和系统初始化后，运行起第一个进程bootstrap2，
而bootstrap2再把注册在系统中的app（即进程）逐个运行起来。
前面提到的aboot就是被运行起来的其中一个app。在aboot中
最终完成了linux kernel的加载运行动作。
