Little Kernel
========================================

lk就是Little Kernel，android lk也是appsboot是Qualcomm平台的bootloader.它是类似OS一样的小操作系统.
其通常由更底层的模块加载到内存运行.

实验平台
----------------------------------------

* CPU - MSM8960
* SDRAM - 2GB, 映射地址为(0x8000000 ~ 0xffffff00)

lk
----------------------------------------

binary目录下的lk是一个编译为elf格式的二进制可执行文件.从其elf header如下所示:

```
readelf -h lk
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           ARM
  Version:                           0x1
  Entry point address:               0x88f00000
  Start of program headers:          52 (bytes into file)
  Start of section headers:          2542408 (bytes into file)
  Flags:                             0x5000002, has entry point, Version5 EABI
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         2
  Size of section headers:           40 (bytes)
  Number of section headers:         19
  Section header string table index: 16
```

从其文件入口点地址为0x88f00000, 推测其极有可能是被更底层模块加载到内存地址0x88f00000处开始运行.
在后面我们有验证该入口地址就是lk执行第一条指令的物理地址.

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

_start
----------------------------------------

lk入口在crt0.s中_start函数开始. 在链接接文件system_onesegment.ld中指定.

path: lk/arch/arm/system-onesegment.ld
```
ENTRY(_start)
SECTIONS
{
    . = %MEMBASE%;
    ...
}
...
```

path: lk/arch/arm/crt0.s

* 1. 设置向量表
* 2. 初始化BSS
* 3. 跳到C函数(bl kmain)

kmain
----------------------------------------

kmain主要做两件事：

* 1.lk系统模块的初始化;
* 2.boot的启动初始化动作。

path: lk/kernel/main.c
```
void kmain(void)
{
    // get us into some sort of thread context
    // 初始化线程(lk中的简单线程)相关结构体。
    thread_init_early();

    // early arch stuff
    // 做一些如关闭cache，使能mmu的arm相关工作。
    arch_early_init();

    // do any super early platform initialization
    // 相关平台的早期初始化
    platform_early_init();

    // do any super early target initialization
    // 现在就一个函数跳转，初始化UART（板子相关）
    target_early_init();

    dprintf(INFO, "welcome to lk\n\n");

    // deal with any static constructors
    dprintf(SPEW, "calling constructors\n");
    // 构造函数相关初始化
    call_constructors();

    // bring up the kernel heap
    dprintf(SPEW, "initializing heap\n");
    // lk系统相关的堆初始化
    heap_init();

    // initialize the threading system
    dprintf(SPEW, "initializing threads\n");
    // 初始化线程.
    thread_init();

    // initialize the dpc system
    dprintf(SPEW, "initializing dpc\n");
    // lk系统控制器初始化(相关事件初始化)
    dpc_init();

    // initialize kernel timers
    dprintf(SPEW, "initializing timers\n");
    // 初始化lk中的定时器
    timer_init();

    ...
    // create a thread to complete system initialization
    dprintf(SPEW, "creating bootstrap completion thread\n");
    // 新建线程入口函数 bootstrap2 用于boot 工作
    thread_resume(thread_create("bootstrap2", &bootstrap2, NULL, DEFAULT_PRIORITY, DEFAULT_STACK_SIZE));

    // enable interrupts
    exit_critical_section();

    // become the idle thread
    thread_become_idle();
    ...
}
```

arch_early_init
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/arch_early_init.md

bootstrap2
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/bootstrap2.md
