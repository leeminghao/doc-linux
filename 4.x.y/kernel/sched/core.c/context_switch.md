context_switch
========================================

内核选择新进程之后，必须处理与多任务相关的技术细节.这些细节总称为上下文切换（context switching）。
辅助函数context_switch是个分配器，它会调用所需的特定于体系结构的方法。

1.prepare_task_switch
----------------------------------------

紧接着进程切换之前，prepare_task_switch会调用每个体系结构都必须定义的prepare_arch_switch挂钩。
这使得内核执行特定于体系结构的代码，为切换做事先准备。大多数支持的体系结构（Sparc64和Sparc除外）
都不需要该选项，因此并未使用。

```
/*
 * context_switch - switch to the new MM and the new
 * thread's register state.
 */
static inline void
context_switch(struct rq *rq, struct task_struct *prev,
           struct task_struct *next)
{
    struct mm_struct *mm, *oldmm;

    prepare_task_switch(rq, prev, next);

    mm = next->mm;
    oldmm = prev->active_mm;
```

```
    /*
     * For paravirt, this is coupled with an exit in switch_to to
     * combine the page table reload and the switch backend into
     * one hypercall.
     */
    arch_start_context_switch(prev);

    if (!mm) {
        next->active_mm = oldmm;
        atomic_inc(&oldmm->mm_count);
        enter_lazy_tlb(oldmm, next);
    } else
        switch_mm(oldmm, mm, next);

    if (!prev->mm) {
        prev->active_mm = NULL;
        rq->prev_mm = oldmm;
    }
    /*
     * Since the runqueue lock will be released by the next
     * task (which is an invalid locking op but in the case
     * of the scheduler it's an obvious special-case), so we
     * do an early lockdep release here:
     */
#ifndef __ARCH_WANT_UNLOCKED_CTXSW
    spin_release(&rq->lock.dep_map, 1, _THIS_IP_);
#endif

    /* Here we just switch the register state and the stack. */
    switch_to(prev, next, prev);

    barrier();
    /*
     * this_rq must be evaluated again because prev may have moved
     * CPUs since it called schedule(), thus the 'rq' on its stack
     * frame will be invalid.
     */
    finish_task_switch(this_rq(), prev);
}
```