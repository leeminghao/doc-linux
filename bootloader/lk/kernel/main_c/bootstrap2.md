bootstrap2
========================================

它在kmain的最后被以新的简单线程的方式运行起来的。

path: lk/kernel/main.c
```
static int bootstrap2(void *arg)
{
    dprintf(SPEW, "top of bootstrap2()\n");

    arch_init();

    // XXX put this somewhere else
#if WITH_LIB_BIO
    bio_init();
#endif
#if WITH_LIB_FS
    fs_init();
#endif

    // initialize the rest of the platform
    dprintf(SPEW, "initializing platform\n");
    // 它就一个函数调用acpu_clock_init, 进行系统时钟设置，超频.
    platform_init();

    // initialize the target
    dprintf(SPEW, "initializing target\n");
    // 针对不同的硬件平台进行设置，有键盘设置，和系统分区表(partition table)的设置。
    target_init();

    dprintf(SPEW, "calling apps_init()\n");
    // 对LK中的所谓app初始化并运行起来，而aboot_init就在开始被运行. (aboot_init加载linux)
    apps_init();

    return 0;
}
```

apps_init
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/apps/app_c/apps_init.md
