boot_cpu_init
========================================

当前系统的所有CPU均通过一些被声明为全局变量的掩码来进行记录，处于不同状态的CPU将对应不同的掩码。
boot_cpu_init函数设置当前CPU到online，active, present和possible掩码中。
具体行为请参考Documentation/cpu-hotplug.txt。

path: init/main.c
```
/*
 *    Activate the first processor.
 */

static void __init boot_cpu_init(void)
{
    int cpu = smp_processor_id();
    /* Mark the boot cpu "present", "online" etc for SMP and UP case */
    set_cpu_online(cpu, true);
    set_cpu_active(cpu, true);
    set_cpu_present(cpu, true);
    set_cpu_possible(cpu, true);
}
```

set_cpu_online
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/kernel/cpu.c/setup_cpu_online.md
