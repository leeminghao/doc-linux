kernel_init
========================================

1.为SMP系统作准备
----------------------------------------

在SMP系统做准备，激活所有CPU，并开始SMP系统的调度

path: init/main.c
```
static int __init kernel_init(void * unused)
{
    /*
     * Wait until kthreadd is all set-up.
     */
    wait_for_completion(&kthreadd_done);
    /*
     * init can allocate pages on any node
     */
    set_mems_allowed(node_states[N_HIGH_MEMORY]);
    /*
     * init can run on any cpu.
     */
    set_cpus_allowed_ptr(current, cpu_all_mask);

    cad_pid = task_pid(current);

    smp_prepare_cpus(setup_max_cpus);

    do_pre_smp_initcalls();
    lockup_detector_init();

    smp_init();
    sched_init_smp();
```

2.do_basic_setup
----------------------------------------

do_basic_setup函数主要是初始化设备驱动，完成其他驱动程序（直接编译进内核的模块）的初始化。
内核中大部分的启动数据输出（都是各设备的驱动模块输出）都是这里产生的

```
    do_basic_setup();
```

3.打开控制台
----------------------------------------

```
    /* Open the /dev/console on the rootfs, this should never fail */
    if (sys_open((const char __user *) "/dev/console", O_RDWR, 0) < 0)
        printk(KERN_WARNING "Warning: unable to open an initial console.\n");
    /* 复制两次标准输入（0）的文件描述符(它是上面打开的/dev/console，也就是系统控制台):
     * 一个作为标准输出（1）
     * 一个作为标准出错（2）
     */
    (void) sys_dup(0);
    (void) sys_dup(0);
    /*
     * check if there is an early userspace init.  If yes, let it do all
     * the work
     */
    /* 检查是否有早期用户空间的init程序。如果有，让其执行*/
    if (!ramdisk_execute_command)
        ramdisk_execute_command = "/init";

    if (sys_access((const char __user *) ramdisk_execute_command, 0) != 0) {
        ramdisk_execute_command = NULL;
        prepare_namespace();
    }

    /*
     * Ok, we have completed the initial bootup, and
     * we're essentially up and running. Get rid of the
     * initmem segments and start the user-mode stuff..
     */
```

4.init_post
----------------------------------------

在内核init线程的最后执行了init_post函数，在这个函数中真正启动了用户空间进程init.

```
    init_post();
    return 0;
}
```
