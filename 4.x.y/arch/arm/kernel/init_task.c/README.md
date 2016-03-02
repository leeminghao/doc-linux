进程0
========================================

系统启动的时候，内核为进程0首先分配了一个thread_union --> init_thread_union;
然后将内核栈指针sp指向了init_thread_union + THREAD_START_SP.

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/kernel/head-common.S/__mmap_switched.md

初始化init_thread_union
----------------------------------------

path: arch/arm/kernel/init_task.c
```
struct task_struct init_task = INIT_TASK(init_task);
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

#### union thread_union

path: include/linux/sched.h
```
union thread_union {
    struct thread_info thread_info;
    unsigned long stack[THREAD_SIZE/sizeof(long)];
};
```

#### __init_task_data

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

#### INIT_THREAD_INFO

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

path: arch/arm/include/asm/thread_info.h
```
#define THREAD_SIZE             8192
#define THREAD_START_SP         (THREAD_SIZE - 8)

/*
 * low level task data that entry.S needs immediate access to.
 * __switch_to() assumes cpu_context follows immediately after cpu_domain.
 */
struct thread_info {
    unsigned long       flags;        /* low level flags */
    int                 preempt_count;    /* 0 => preemptable, <0 => bug */
    mm_segment_t        addr_limit;    /* address limit */
    struct task_struct  *task;        /* main task structure */
    struct exec_domain  *exec_domain;    /* execution domain */
    __u32               cpu;        /* cpu */
    __u32               cpu_domain;    /* cpu domain */
    struct cpu_context_save    cpu_context;    /* cpu context */
    __u32               syscall;    /* syscall number */
    __u8                used_cp[16];    /* thread used copro */
    unsigned long       tp_value;
    struct crunch_state crunchstate;
    union fp_state      fpstate __attribute__((aligned(8)));
    union vfp_state     vfpstate;
#ifdef CONFIG_ARM_THUMBEE
    unsigned long        thumbee_state;    /* ThumbEE Handler Base register */
#endif
    struct restart_block    restart_block;
};
```

#### struct cpu_context_save

path: arch/arm/include/asm/thread_info.h
```
struct cpu_context_save {
	__u32	r4;
	__u32	r5;
	__u32	r6;
	__u32	r7;
	__u32	r8;
	__u32	r9;
	__u32	sl;
	__u32	fp;
	__u32	sp;
	__u32	pc;
	__u32	extra[2];		/* Xscale 'acc' register, etc */
};
```

#### init_task

init_task是由宏INIT_TASK来初始化的，具体实现如下所示:

path: include/linux/init_task.h
```
/*
 *  INIT_TASK is used to set up the first task table, touch at
 * your own risk!. Base=0, limit=0x1fffff (=2MB)
 */
#define INIT_TASK(tsk)	\
{									\
	.state		= 0,						\
	.stack		= &init_thread_info,				\
	.usage		= ATOMIC_INIT(2),				\
	.flags		= PF_KTHREAD,					\
	.prio		= MAX_PRIO-20,					\
	.static_prio	= MAX_PRIO-20,					\
	.normal_prio	= MAX_PRIO-20,					\
	.policy		= SCHED_NORMAL,					\
	.cpus_allowed	= CPU_MASK_ALL,					\
	.mm		= NULL,						\
	.active_mm	= &init_mm,					\
	.se		= {						\
		.group_node 	= LIST_HEAD_INIT(tsk.se.group_node),	\
	},								\
	.rt		= {						\
		.run_list	= LIST_HEAD_INIT(tsk.rt.run_list),	\
		.time_slice	= RR_TIMESLICE,				\
		.nr_cpus_allowed = NR_CPUS,				\
	},								\
	.tasks		= LIST_HEAD_INIT(tsk.tasks),			\
	INIT_PUSHABLE_TASKS(tsk)					\
	.ptraced	= LIST_HEAD_INIT(tsk.ptraced),			\
	.ptrace_entry	= LIST_HEAD_INIT(tsk.ptrace_entry),		\
	.real_parent	= &tsk,						\
	.parent		= &tsk,						\
	.children	= LIST_HEAD_INIT(tsk.children),			\
	.sibling	= LIST_HEAD_INIT(tsk.sibling),			\
	.group_leader	= &tsk,						\
	RCU_INIT_POINTER(.real_cred, &init_cred),			\
	RCU_INIT_POINTER(.cred, &init_cred),				\
	.comm		= INIT_TASK_COMM,				\
	.thread		= INIT_THREAD,					\
	.fs		= &init_fs,					\
	.files		= &init_files,					\
	.signal		= &init_signals,				\
	.sighand	= &init_sighand,				\
	.nsproxy	= &init_nsproxy,				\
	.pending	= {						\
		.list = LIST_HEAD_INIT(tsk.pending.list),		\
		.signal = {{0}}},					\
	.blocked	= {{0}},					\
	.alloc_lock	= __SPIN_LOCK_UNLOCKED(tsk.alloc_lock),		\
	.journal_info	= NULL,						\
	.cpu_timers	= INIT_CPU_TIMERS(tsk.cpu_timers),		\
	.pi_lock	= __RAW_SPIN_LOCK_UNLOCKED(tsk.pi_lock),	\
	.timer_slack_ns = 50000, /* 50 usec default slack */		\
	.pids = {							\
		[PIDTYPE_PID]  = INIT_PID_LINK(PIDTYPE_PID),		\
		[PIDTYPE_PGID] = INIT_PID_LINK(PIDTYPE_PGID),		\
		[PIDTYPE_SID]  = INIT_PID_LINK(PIDTYPE_SID),		\
	},								\
	.thread_group	= LIST_HEAD_INIT(tsk.thread_group),		\
	INIT_IDS							\
	INIT_PERF_EVENTS(tsk)						\
	INIT_TRACE_IRQFLAGS						\
	INIT_LOCKDEP							\
	INIT_FTRACE_GRAPH						\
	INIT_TRACE_RECURSION						\
	INIT_TASK_RCU_PREEMPT(tsk)					\
	INIT_CPUSET_SEQ							\
}
```