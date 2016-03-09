do_fork - kernel/fork.c
========================================

参数
----------------------------------------

```
/*
 *  Ok, this is the main fork-routine.
 *
 * It copies the process, and if successful kick-starts
 * it and waits for it to finish using the VM if required.
 */
long do_fork(unsigned long clone_flags,
          unsigned long stack_start,
          struct pt_regs *regs,
          unsigned long stack_size,
          int __user *parent_tidptr,
          int __user *child_tidptr)
{
```

该函数需要下列参数:

* clone_flags是一个标志集合，用来指定控制复制过程的一些属性。最低字节指定了在子进程终止
  时被发给父进程的信号号码。其余的高位字节保存了各种常数。

* start_stack是用户状态下栈的起始地址。

* regs是一个指向寄存器集合的指针，其中以原始形式保存了调用参数。该参数使用的数据类型是
  特定于体系结构的struct pt_regs，其中按照系统调用执行时寄存器在内核栈上的存储顺序，
  保存了所有的寄存器.

* stack_size是用户状态下栈的大小。该参数通常是不必要的，设置为0。

* parent_tidptr和child_tidptr是指向用户空间中地址的两个指针，分别指向父子进程的TID。
  NPTL（Native PosixThreads Library）库的线程实现需要这两个参数。

```
    struct task_struct *p;
    int trace = 0;
    long nr;

    /*
     * Do some preliminary argument and permissions checking before we
     * actually start allocating stuff
     */
    if (clone_flags & CLONE_NEWUSER) {
        if (clone_flags & CLONE_THREAD)
            return -EINVAL;
        /* hopefully this check will go away when userns support is
         * complete
         */
        if (!capable(CAP_SYS_ADMIN) || !capable(CAP_SETUID) ||
                !capable(CAP_SETGID))
            return -EPERM;
    }

    /*
     * Determine whether and which event to report to ptracer.  When
     * called from kernel_thread or CLONE_UNTRACED is explicitly
     * requested, no event is reported; otherwise, report if the event
     * for the type of forking is enabled.
     */
    if (likely(user_mode(regs)) && !(clone_flags & CLONE_UNTRACED)) {
        if (clone_flags & CLONE_VFORK)
            trace = PTRACE_EVENT_VFORK;
        else if ((clone_flags & CSIGNAL) != SIGCHLD)
            trace = PTRACE_EVENT_CLONE;
        else
            trace = PTRACE_EVENT_FORK;

        if (likely(!ptrace_event_enabled(current, trace)))
            trace = 0;
    }

    p = copy_process(clone_flags, stack_start, regs, stack_size,
             child_tidptr, NULL, trace);
    /*
     * Do this prior waking up the new thread - the thread pointer
     * might get invalid after that point, if the thread exits quickly.
     */
    if (!IS_ERR(p)) {
        struct completion vfork;

        trace_sched_process_fork(current, p);

        nr = task_pid_vnr(p);

        if (clone_flags & CLONE_PARENT_SETTID)
            put_user(nr, parent_tidptr);

        if (clone_flags & CLONE_VFORK) {
            p->vfork_done = &vfork;
            init_completion(&vfork);
            get_task_struct(p);
        }

        wake_up_new_task(p);

        /* forking complete and child started to run, tell ptracer */
        if (unlikely(trace))
            ptrace_event(trace, nr);

        if (clone_flags & CLONE_VFORK) {
            if (!wait_for_vfork_done(p, &vfork))
                ptrace_event(PTRACE_EVENT_VFORK_DONE, nr);
        }
    } else {
        nr = PTR_ERR(p);
    }
    return nr;
}
```
