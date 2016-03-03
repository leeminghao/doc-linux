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

```
    cgroup_init_early();
```

5.local_irq_disable
----------------------------------------

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

```
    page_address_init();
```

10.setup_arch
----------------------------------------

```
    printk(KERN_NOTICE "%s", linux_banner);
    setup_arch(&command_line);
```

11.boot_init_stack_canary
----------------------------------------

```
    /*
     * Set up the the initial canary ASAP:
     */
    boot_init_stack_canary();
```

12.mm_init_owner
----------------------------------------

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

```
    setup_command_line(command_line);
```

15.setup_nr_cpu_ids
----------------------------------------

```
    setup_nr_cpu_ids();
```

16.setup_per_cpu_areas
----------------------------------------

```
    setup_per_cpu_areas();
```

17.smp_prepare_boot_cpu
----------------------------------------

```
    smp_prepare_boot_cpu();    /* arch-specific boot-cpu hooks */
```

18.build_all_zonelists
----------------------------------------

```
    build_all_zonelists(NULL);
```

19.page_alloc_init
----------------------------------------

```
    page_alloc_init();
```

20.parse_early_param
----------------------------------------

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

```
    pidhash_init();
```

24.vfs_caches_init_early
----------------------------------------

```
    vfs_caches_init_early();
```

25.sort_main_extable
----------------------------------------

```
    sort_main_extable();
```

26.trap_init
----------------------------------------

```
    trap_init();
```

27.mm_init
----------------------------------------

```
    mm_init();
```

28.sched_init
----------------------------------------

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

```
    /*
     * Disable preemption - early bootup scheduling is extremely
     * fragile until we cpu_idle() for the first time.
     */
    preempt_disable();
```

30.local_irq_disable
----------------------------------------

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

```
    rcu_init();
```

34.radix_tree_init
----------------------------------------

```
    radix_tree_init();
```

35.early_irq_init
----------------------------------------

```
    /* init some links before init_ISA_irqs() */
    early_irq_init();
```

36.init_IRQ
----------------------------------------

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

```
    init_timers();
```

39.hrtimers_init
----------------------------------------

```
    hrtimers_init();
```

40.softirq_init
----------------------------------------

```
    softirq_init();
```

50.timekeeping_init
----------------------------------------

```
    timekeeping_init();
```

51.time_init
----------------------------------------

```
    time_init();
```

52.profile_init
----------------------------------------

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

```
    kmem_cache_init_late();
```

57.console_init
----------------------------------------

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