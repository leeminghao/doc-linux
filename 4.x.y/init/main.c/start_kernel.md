start_kernel - init/main.c
========================================

__mmap_switched在为内核跳转到start_kernel C函数准备运行环境:

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/kernel/head-common.S/__mmap_switched.md

1.lockdep_init
----------------------------------------

lockdep是linux内核的一个调试模块，用来检查内核互斥机制尤其是自旋锁潜在的死锁问题。
自旋锁由于是查询方式等待，不释放处理器，比一般的互斥机制更容易死锁，故引入lockdep
检查以下几种情况可能的死锁:

* 同一个进程递归地加锁同一把锁；
* 一把锁既在中断（或中断下半部）使能的情况下执行过加锁操作，又在中断（或中断下半部）里
  执行过加锁操作。这样该锁有可能在锁定时由于中断发生又试图在同一处理器上加锁；
* 加锁后导致依赖图产生成闭环，这是典型的死锁现象。

```
asmlinkage void __init start_kernel(void)
{
    char * command_line;
    extern const struct kernel_param __start___param[], __stop___param[];
    /*
     * Need to run as early as possible, to initialize the
     * lockdep hash:
     */
    lockdep_init();
```

2.smp_setup_processor_id
----------------------------------------

```
    smp_setup_processor_id();
```

3.debug_objects_early_init
----------------------------------------

```
    debug_objects_early_init();
```

4.cgroup_init_early
----------------------------------------

cgroup: 它的全称为control group.即一组进程的行为控制.比如,我们限制进程/bin/sh的CPU使用为20%.
我们就可以建一个cpu占用为20%的cgroup. 然后将/bin/sh进程添加到这个cgroup中.当然,一个cgroup
可以有多个进程.

```
    cgroup_init_early();
```

5.local_irq_disable
----------------------------------------

关闭当前CUP中断

```
    local_irq_disable();
```

6.Disable interrupts
----------------------------------------

```
    early_boot_irqs_disabled = true;
   /*
    * Interrupts are still disabled. Do necessary setups, then
    * enable them
   */
```

7.tick_init
----------------------------------------

初始化time ticket，时钟

```
    tick_init();
```

8.boot_cpu_init
----------------------------------------

```
    boot_cpu_init();
```

9.page_address_init
----------------------------------------

初始化页地址

```
    page_address_init();
```

10.setup_arch
----------------------------------------

体系结构相关的内核初始化过程.

```
    printk(KERN_NOTICE "%s", linux_banner);
    setup_arch(&command_line);
```

11.boot_init_stack_canary
----------------------------------------

初始化stack_canary栈,stack_canary的是带防止栈溢出攻击保护的堆栈。当user space的程序通过
int 0x80进入内核空间的时候，CPU自动完成一次堆栈切换，从user space的stack切换到
kernel space的stack。在这个进程exit之前所发生的所有系统调用所使用的kernel stack都是同一个。
kernel stack的大小一般为8192 / sizeof (long);

```
    /*
     * Set up the the initial canary ASAP:
     */
    boot_init_stack_canary();
```

Linux 0.11 Stack:

https://github.com/leeminghao/doc-linux/blob/master/0.11/misc/Stack.md

12.mm_init_owner
----------------------------------------

初始化内存管理

```
    mm_init_owner(&init_mm, &init_task);
```

13.mm_init_cpumask
----------------------------------------

```
    mm_init_cpumask(&init_mm);
```

14.setup_command_line
----------------------------------------

处理启动命令，这里就是设置的command_line.

```
    setup_command_line(command_line);
```

15.setup_nr_cpu_ids
----------------------------------------

这个在定义了SMP的时候有作用.

```
    setup_nr_cpu_ids();
```

16.setup_per_cpu_areas
----------------------------------------

setup_per_cpu_areas()函数给每个CPU分配内存，并拷贝.data.percpu段的数据。为系统中的每个
CPU的per_cpu变量申请空间。

```
    setup_per_cpu_areas();
```

17.smp_prepare_boot_cpu
----------------------------------------

如果是SMP环境，则设置boot CPU的一些数据。在引导过程中使用的CPU称为boot CPU.

```
    smp_prepare_boot_cpu();    /* arch-specific boot-cpu hooks */
```

18.build_all_zonelists
----------------------------------------

设置node和zone数据结构

```
    build_all_zonelists(NULL);
```

19.page_alloc_init
----------------------------------------

初始化page allocation相关结构

```
    page_alloc_init();
```

20.parse_early_param
----------------------------------------

解析内核参数.

```
    printk(KERN_NOTICE "Kernel command line: %s\n", boot_command_line);
    parse_early_param();
    parse_args("Booting kernel", static_command_line, __start___param,
           __stop___param - __start___param,
           0, 0, &unknown_bootoption);
```

21.jump_label_init
----------------------------------------

```
    jump_label_init();
```

22.setup_log_buf
----------------------------------------

```
    /*
     * These use large bootmem allocations and must precede
     * kmem_cache_init()
     */
    setup_log_buf(0);
```

23.pidhash_init
----------------------------------------

初始化hash表，以便于从进程的PID获得对应的进程描述指针，按照实际的物理内存初始化pid hash表.

```
    pidhash_init();
```

24.vfs_caches_init_early
----------------------------------------

初始化VFS的两个重要数据结构dcache和inode的缓存。

```
    vfs_caches_init_early();
```

25.sort_main_extable
----------------------------------------

把编译期间,kbuild设置的异常表,也就是__start___ex_table和__stop___ex_table之中的所有元素进行排序

```
    sort_main_extable();
```

26.trap_init
----------------------------------------

初始化中断向量表

```
    trap_init();
```

27.mm_init
----------------------------------------

memory map初始化.

```
    mm_init();
```

28.sched_init
----------------------------------------

核心进程调度器初始化，调度器的初始化的优先级要高于任何中断的建立，并且初始化进程0，即idle进程，
但是并没有设置idle进程的NEED_RESCHED标志，所以还会继续完成内核初始化剩下的事情。这里仅仅为进程
调度程序的执行做准备。它所做的具体工作是调用init_bh函数(kernel/softirq.c)把timer,tqueue,
immediate三个人物队列加入下半部分的数组

```
    /*
     * Set up the scheduler prior starting any interrupts (such as the
     * timer interrupt). Full topology setup happens at smp_init()
     * time - but meanwhile we still have a functioning scheduler.
     */
    sched_init();
```

29.preempt_disable
----------------------------------------

抢占计数器加1

```
    /*
     * Disable preemption - early bootup scheduling is extremely
     * fragile until we cpu_idle() for the first time.
     */
    preempt_disable();
```

30.local_irq_disable
----------------------------------------

检查中断是否打开

```
    if (!irqs_disabled()) {
        printk(KERN_WARNING "start_kernel(): bug: interrupts were "
                "enabled *very* early, fixing it\n");
        local_irq_disable();
    }
```

31.idr_init_cache
----------------------------------------

```
    idr_init_cache();
```

32.perf_event_init
----------------------------------------

```
    perf_event_init();
```

33.rcu_init
----------------------------------------

Read-Copy-Update的初始化
RCU机制是Linux2.6之后提供的一种数据一致性访问的机制，从RCU（read-copy-update）的名称上看，
我们就能对他的实现机制有一个大概的了解，在修改数据的时候，首先需要读取数据，然后生成一个副本，
对副本进行修改，修改完成之后再将老数据update成新的数据，此所谓RCU.

```
    rcu_init();
```

34.radix_tree_init
----------------------------------------

Linux使用radix树来管理位于文件系统缓冲区中的磁盘块，radix树是trie树的一种.

```
    radix_tree_init();
```

35.early_irq_init
----------------------------------------

early_irq_init 则对数组中每个成员结构进行初始化,例如, 初始每个中断源的中断号.其他的函数基本为空.

```
    /* init some links before init_ISA_irqs() */
    early_irq_init();
```

36.init_IRQ
----------------------------------------

初始化IRQ中断和终端描述符.初始化系统中支持的最大可能的中断描述结构struct irqdesc
变量数组irq_desc[NR_IRQS],把每个结构变量irq_desc[n]都初始化为预先定义好的坏中断
描述结构变量bad_irq_desc,并初始化该中断的链表表头成员结构变量pend.

```
    init_IRQ();
```

37.prio_tree_init
----------------------------------------

```
    prio_tree_init();
```

38.init_timers
----------------------------------------

初始化定时器Timer相关的数据结构.

```
    init_timers();
```

39.hrtimers_init
----------------------------------------

对高精度时钟进行初始化.

```
    hrtimers_init();
```

40.softirq_init
----------------------------------------

软中断初始化.

```
    softirq_init();
```

50.timekeeping_init
----------------------------------------

初始化时钟源

```
    timekeeping_init();
```

51.time_init
----------------------------------------

初始化系统时间，检查系统定时器描述结构struct sys_timer全局变量system_timer是否为空，
如果为空将其指向dummy_gettimeoffset()函数。

```
    time_init();
```

52.profile_init
----------------------------------------

profile只是内核的一个调试性能的工具,这个可以通过menuconfig中的Instrumentation Support->profile.

```
    profile_init();
```

53.call_function_init
----------------------------------------

```
    call_function_init();
```

54.local_irq_enable
----------------------------------------

与local_irq_disbale相对应，开中断

```
    if (!irqs_disabled())
        printk(KERN_CRIT "start_kernel(): bug: interrupts were "
                 "enabled early\n");
    early_boot_irqs_disabled = false;
    local_irq_enable();
```

55.allow GFP
----------------------------------------


```
    /* Interrupts are enabled now so all GFP allocations are safe. */
    gfp_allowed_mask = __GFP_BITS_MASK;
```

56.kmem_cache_init_late
----------------------------------------

memory cache的初始化.

```
    kmem_cache_init_late();
```

57.console_init
----------------------------------------

初始化控制台以显示printk的内容，在此之前调用的printk，只是把数据存到缓冲区里，只有在这个函数调用
后，才会在控制台打印出内容该函数执行后可调用printk()函数将log_buf中符合打印级别要求的系统信息
打印到控制台上。

```
    /*
     * HACK ALERT! This is early. We're enabling the console before
     * we've done PCI setups etc, and console_init() must be aware of
     * this. But we do want output early, in case something goes wrong.
     */
    console_init();
    if (panic_later)
        panic(panic_later, panic_param);
```

58.lockdep_info
----------------------------------------

如果定义了CONFIG_LOCKDEP宏，那么就打印锁依赖信息，否则什么也不做

```
    lockdep_info();
```

59.locking_selftest
----------------------------------------

```
    /*
     * Need to run this when irqs are enabled, because it wants
     * to self-test [hard/soft]-irqs on/off lock inversion bugs
     * too:
     */
    locking_selftest();
```

60.CONFIG_BLK_DEV_INITRD
----------------------------------------

```
#ifdef CONFIG_BLK_DEV_INITRD
    if (initrd_start && !initrd_below_start_ok &&
        page_to_pfn(virt_to_page((void *)initrd_start)) < min_low_pfn) {
        printk(KERN_CRIT "initrd overwritten (0x%08lx < 0x%08lx) - "
            "disabling it.\n",
            page_to_pfn(virt_to_page((void *)initrd_start)),
            min_low_pfn);
        initrd_start = 0;
    }
#endif
```

61.page_cgroup_init
----------------------------------------

```
    page_cgroup_init();
```

62.debug_objects_mem_init
----------------------------------------

```
    debug_objects_mem_init();
```

63.kmemleak_init
----------------------------------------

```
    kmemleak_init();
```

64.setup_per_cpu_pageset
----------------------------------------

```
    setup_per_cpu_pageset();
```

65.numa_policy_init
----------------------------------------

```
    numa_policy_init();
```

66.late_time_init
----------------------------------------

```
    if (late_time_init)
        late_time_init();
```

67.sched_clock_init
----------------------------------------

```
    sched_clock_init();
```

68.calibrate_delay
----------------------------------------

```
    calibrate_delay();
```

69.pidmap_init
----------------------------------------

```
    pidmap_init();
```

70.anon_vma_init
----------------------------------------

```
    anon_vma_init();
```

71.CONFIG_X86
----------------------------------------

```
#ifdef CONFIG_X86
    if (efi_enabled)
        efi_enter_virtual_mode();
#endif
```

72.thread_info_cache_init
----------------------------------------

```
    thread_info_cache_init();
```

73.cred_init
----------------------------------------

```
    cred_init();
```

74.fork_init
----------------------------------------

```
    fork_init(totalram_pages);
```

75.proc_caches_init
----------------------------------------

```
    proc_caches_init();
```

76.buffer_init
----------------------------------------

```
    buffer_init();
```

77.key_init
----------------------------------------

```
    key_init();
```

78.security_init
----------------------------------------

```
    security_init();
```

79.dbg_late_init
----------------------------------------

```
    dbg_late_init();
```

80.vfs_caches_init
----------------------------------------

```
    vfs_caches_init(totalram_pages);
```

81.signals_init
----------------------------------------

```
    signals_init();
```

82.page_writeback_init
----------------------------------------

```
    /* rootfs populating might need page-writeback */
    page_writeback_init();
```

83.proc_root_init
----------------------------------------

```
#ifdef CONFIG_PROC_FS
    proc_root_init();
#endif
```

84.cgroup_init
----------------------------------------

```
    cgroup_init();
```

85.cpuset_init
----------------------------------------

```
    cpuset_init();
```

86.taskstats_init_early
----------------------------------------

```
    taskstats_init_early();
```

87.delayacct_init
----------------------------------------

```
    delayacct_init();
```

88.check_bugs
----------------------------------------

```
    check_bugs();
```

89.acpi_early_init
----------------------------------------

```
    acpi_early_init(); /* before LAPIC and SMP init */
```

90.sfi_init_late
----------------------------------------

```
    sfi_init_late();
```

91.ftrace_init
----------------------------------------

```
    ftrace_init();
```

92.rest_init
----------------------------------------

```
    /* Do the rest non-__init'ed, we're now alive */
    rest_init();
}
```