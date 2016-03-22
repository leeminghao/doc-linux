init_post
========================================

path: init/main.c
```
/* This is a non __init function. Force it to be noinline otherwise gcc
 * makes it inline to init() and it becomes part of init.text section
 */
static noinline int init_post(void)
{
    /* need to finish all async __init code before freeing the memory */
    /* 在释放内存前，必须完成所有的异步 __init 代码 */
    async_synchronize_full();
    // 释放所有init.* 段中的内存。
    free_initmem();
    // 通过修改页表，保证只读数据段为只读属性。大部分构架为空函数
    mark_rodata_ro();
    // 设置系统状态为运行状态
    system_state = SYSTEM_RUNNING;
    // 设定NUMA系统的内存访问策略为默认
    numa_default_policy();

    // 设置当前进程(init)为不可以杀进程(忽略致命的信号)
    current->signal->flags |= SIGNAL_UNKILLABLE;

    // 如果ramdisk_execute_command有指定的init程序，就执行它
    if (ramdisk_execute_command) {
        run_init_process(ramdisk_execute_command);
        printk(KERN_WARNING "Failed to execute %s\n",
                ramdisk_execute_command);
    }

    /*
     * We try each of these until one succeeds.
     *
     * The Bourne shell can be used instead of init if we are
     * trying to recover a really broken machine.
     */
    if (execute_command) {
        run_init_process(execute_command);
        printk(KERN_WARNING "Failed to execute %s.  Attempting "
                    "defaults...\n", execute_command);
    }
    run_init_process("/sbin/init");
    run_init_process("/etc/init");
    run_init_process("/bin/init");
    run_init_process("/bin/sh");

    panic("No init found.  Try passing init= option to kernel. "
          "See Linux Documentation/init.txt for guidance.");
}
```

run_init_process
----------------------------------------

```
static void run_init_process(const char *init_filename)
{
    argv_init[0] = init_filename;
    kernel_execve(init_filename, argv_init, envp_init);
}
```

### kernel_execve

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/kernel/sys_arm.c/kernel_execve.md
