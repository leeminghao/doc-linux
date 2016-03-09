进程0
========================================

系统启动的时候，内核为进程0首先分配了一个thread_union --> init_thread_union;
然后将内核栈指针sp指向了init_thread_union + THREAD_START_SP.

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/kernel/head-common.S/__mmap_switched.md

初始化init_thread_union
----------------------------------------

### init_task

path: arch/arm/kernel/init_task.c
```
struct task_struct init_task = INIT_TASK(init_task);
```

### init_thread_union

path: arch/arm/kernel/init_task.c
```
...
/*
 * Initial thread structure.
 *
 * We need to make sure that this is 8192-byte aligned due to the
 * way process stacks are handled. This is done by making sure
 * the linker maps this in the .text segment right after head.S,
 * and making head.S ensure the proper alignment.
 *
 * The things we do for performance..
 */
union thread_union init_thread_union __init_task_data =
      { INIT_THREAD_INFO(init_task) };
```

### union thread_union

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/include/linux/sched_h/thread_union.md

### __init_task_data

__init_task_data只是一个宏.

path: include/linux/init_task.h
```
/* Attach to the init_task data structure for proper alignment */
#define __init_task_data __attribute__((__section__(".data..init_task")))
```

init_thread_union的内容就展开成了：

// 数据放进指定的数据段.data..init_task
union thread_union init_thread_union __attribute__((__section__(".data..init_task"))) =
    { INIT_THREAD_INFO(init_task) };

#### .data..init_task

该section在vmlinux.lds.S中定义如下所示:

path: arch/arm/kernel/vmlinux.lds.S
```
    .data : AT(__data_loc) {
        _data = .;        /* address in memory */
        _sdata = .;

        /*
         * first, the init task union, aligned
         * to an 8192 byte boundary.
         */
        INIT_TASK_DATA(THREAD_SIZE)
     }
```

path: include/asm-generic/vmlinux.lds.h
```
#define INIT_TASK_DATA(align)                                           \
        . = ALIGN(align);                                               \
        *(.data..init_task)
```

### INIT_THREAD_INFO

INIT_THREAD_INFO宏是用来初始化一个struct thread_info结构体的.

path: arch/arm/include/asm/thread_info.h
```
#define INIT_THREAD_INFO(tsk)                     \
{                                                 \
   .task  = &tsk,                                 \
   .exec_domain        = &default_exec_domain,    \
   .flags                = 0,                     \
   .preempt_count        = INIT_PREEMPT_COUNT,    \
   .addr_limit           = KERNEL_DS,             \
   .cpu_domain           = domain_val(DOMAIN_USER, DOMAIN_MANAGER) | \
                           domain_val(DOMAIN_KERNEL, DOMAIN_MANAGER) | \
                           domain_val(DOMAIN_IO, DOMAIN_CLIENT),  \
   .restart_block        = {                   \
       .fn                   = do_no_restart_syscall,   \
   },                                                    \
}
```

#### struct thread_info

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/include/asm/thread_info.h/thread_info.md

### INIT_TASK

init_task是由宏INIT_TASK来初始化的，具体实现如下所示:

path: include/linux/init_task.h
```
/*
 *  INIT_TASK is used to set up the first task table, touch at
 * your own risk!. Base=0, limit=0x1fffff (=2MB)
 */
#define INIT_TASK(tsk)    \
{                                    \
    .state        = 0,                        \
    .stack        = &init_thread_info,                \
    .usage        = ATOMIC_INIT(2),                \
    .flags        = PF_KTHREAD,                    \
    .prio        = MAX_PRIO-20,                    \
    .static_prio    = MAX_PRIO-20,                    \
    .normal_prio    = MAX_PRIO-20,                    \
    .policy        = SCHED_NORMAL,                    \
    .cpus_allowed    = CPU_MASK_ALL,                    \
    .mm        = NULL,                        \
    .active_mm    = &init_mm,                    \
    .se        = {                        \
        .group_node     = LIST_HEAD_INIT(tsk.se.group_node),    \
    },                                \
    .rt        = {                        \
        .run_list    = LIST_HEAD_INIT(tsk.rt.run_list),    \
        .time_slice    = RR_TIMESLICE,                \
        .nr_cpus_allowed = NR_CPUS,                \
    },                                \
    .tasks        = LIST_HEAD_INIT(tsk.tasks),            \
    INIT_PUSHABLE_TASKS(tsk)                    \
    .ptraced    = LIST_HEAD_INIT(tsk.ptraced),            \
    .ptrace_entry    = LIST_HEAD_INIT(tsk.ptrace_entry),        \
    .real_parent    = &tsk,                        \
    .parent        = &tsk,                        \
    .children    = LIST_HEAD_INIT(tsk.children),            \
    .sibling    = LIST_HEAD_INIT(tsk.sibling),            \
    .group_leader    = &tsk,                        \
    RCU_INIT_POINTER(.real_cred, &init_cred),            \
    RCU_INIT_POINTER(.cred, &init_cred),                \
    .comm        = INIT_TASK_COMM,                \
    .thread        = INIT_THREAD,                    \
    .fs        = &init_fs,                    \
    .files        = &init_files,                    \
    .signal        = &init_signals,                \
    .sighand    = &init_sighand,                \
    .nsproxy    = &init_nsproxy,                \
    .pending    = {                        \
        .list = LIST_HEAD_INIT(tsk.pending.list),        \
        .signal = {{0}}},                    \
    .blocked    = {{0}},                    \
    .alloc_lock    = __SPIN_LOCK_UNLOCKED(tsk.alloc_lock),        \
    .journal_info    = NULL,                        \
    .cpu_timers    = INIT_CPU_TIMERS(tsk.cpu_timers),        \
    .pi_lock    = __RAW_SPIN_LOCK_UNLOCKED(tsk.pi_lock),    \
    .timer_slack_ns = 50000, /* 50 usec default slack */        \
    .pids = {                            \
        [PIDTYPE_PID]  = INIT_PID_LINK(PIDTYPE_PID),        \
        [PIDTYPE_PGID] = INIT_PID_LINK(PIDTYPE_PGID),        \
        [PIDTYPE_SID]  = INIT_PID_LINK(PIDTYPE_SID),        \
    },                                \
    .thread_group    = LIST_HEAD_INIT(tsk.thread_group),        \
    INIT_IDS                            \
    INIT_PERF_EVENTS(tsk)                        \
    INIT_TRACE_IRQFLAGS                        \
    INIT_LOCKDEP                            \
    INIT_FTRACE_GRAPH                        \
    INIT_TRACE_RECURSION                        \
    INIT_TASK_RCU_PREEMPT(tsk)                    \
    INIT_CPUSET_SEQ                            \
}
```

#### task_struct

对应的task_struct进程描述符如下:

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/include/linux/sched_h/task_struct.md

#### init_thread_info

path: arch/arm/include/asm/thread_info.h
```
#define init_thread_info    (init_thread_union.thread_info)
#define init_stack          (init_thread_union.stack)
```

task_struct, thread_info和内核栈之间关系
----------------------------------------

在内核的某个特定组件使用了过多栈空间时，内核栈会溢出到thread_info部分，这很可能会导致严重的故障。
此外在紧急情况下输出调用栈回溯时将会导致错误的信息出现，因此内核提供了kstack_end函数，用于判断
给出的地址是否位于栈的有效部分之内。

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/kernel/init_task.c/res/task_struct-thread_info-stack.jpg
