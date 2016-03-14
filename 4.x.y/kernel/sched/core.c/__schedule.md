__schedule - kernel/sched/core.c
========================================

在内核中的许多地方，如果要将CPU分配给与当前活动进程不同的另一个进程，都会直接调用主调度器函数
（schedule）。在从系统调用返回之后，内核也会检查当前进程是否设置了重调度标志TIF_NEED_RESCHED，
例如，前述的scheduler_tick就会设置该标志。如果是这样，则内核会调用schedule。该函数假定当前活动
进程一定会被另一个进程取代。

1.__sched前缀
----------------------------------------

该前缀用于可能调用schedule的函数，包括schedule自身。
该前缀目的在于: 将相关函数的代码编译之后，放到目标文件的一个特定的段中，即.sched.text中。
该信息使得内核在显示栈转储或类似信息时，忽略所有与调度有关的调用。由于调度器函数调用不是
普通代码流程的一部分，因此在这种情况下是没有意义的。

```
/*
 * __schedule() is the main scheduler function.
 */
static void __sched __schedule(void)
{
```

```
    struct task_struct *prev, *next;
    unsigned long *switch_count;
    struct rq *rq;
    int cpu;

need_resched:
    preempt_disable();
    cpu = smp_processor_id();
    rq = cpu_rq(cpu);
    rcu_note_context_switch(cpu);
    prev = rq->curr;

    schedule_debug(prev);

    if (sched_feat(HRTICK))
        hrtick_clear(rq);

    raw_spin_lock_irq(&rq->lock);

    switch_count = &prev->nivcsw;
    if (prev->state && !(preempt_count() & PREEMPT_ACTIVE)) {
        if (unlikely(signal_pending_state(prev->state, prev))) {
            prev->state = TASK_RUNNING;
        } else {
            deactivate_task(rq, prev, DEQUEUE_SLEEP);
            prev->on_rq = 0;

            /*
             * If a worker went to sleep, notify and ask workqueue
             * whether it wants to wake up a task to maintain
             * concurrency.
             */
            if (prev->flags & PF_WQ_WORKER) {
                struct task_struct *to_wakeup;

                to_wakeup = wq_worker_sleeping(prev, cpu);
                if (to_wakeup)
                    try_to_wake_up_local(to_wakeup);
            }
        }
        switch_count = &prev->nvcsw;
    }

    pre_schedule(rq, prev);

    if (unlikely(!rq->nr_running))
        idle_balance(cpu, rq);

    put_prev_task(rq, prev);
    next = pick_next_task(rq);
    clear_tsk_need_resched(prev);
    rq->skip_clock_update = 0;

    if (likely(prev != next)) {
        rq->nr_switches++;
        rq->curr = next;
        ++*switch_count;

        context_switch(rq, prev, next); /* unlocks the rq */
        /*
         * The context switch have flipped the stack from under us
         * and restored the local variables which were saved when
         * this task called schedule() in the past. prev == current
         * is still correct, but it can be moved to another cpu/rq.
         */
        cpu = smp_processor_id();
        rq = cpu_rq(cpu);
    } else
        raw_spin_unlock_irq(&rq->lock);

    post_schedule(rq);

    sched_preempt_enable_no_resched();
    if (need_resched())
        goto need_resched;
}
```