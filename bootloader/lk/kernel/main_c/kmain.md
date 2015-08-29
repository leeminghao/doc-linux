kmain
========================================

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

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/arch/arm/arch_c/arch_early_init.md

bootstrap2
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/kernel/main_c/bootstrap2.md
