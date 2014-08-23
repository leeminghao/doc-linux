Linux 0.11 进程1切换到进程0
================================================================================

在进程1为安装硬盘文件系统作准备：

https://github.com/leeminghao/doc-linux/blob/master/0.11/filesystem/InstallDiskFs.md

在这个过程中，需要等待硬盘将引导块从硬盘上读取到块高速缓存中，这时候硬盘正在继续读引导块。
如果程序继续执行，则需要对引导块中的数据进行操作。但这些数据还没有从硬盘中读完，所以调用
wait_on_buffer()函数，挂起等待,执行代码如下所示:

path: fs/buffer.c
```
static inline void wait_on_buffer(struct buffer_head * bh)
{
    cli();
    /* 判断刚才申请到的缓冲块是否被加锁,现在,缓冲块确实加锁了,调用sleep_on函数. */
    while (bh->b_lock)
        sleep_on(&bh->b_wait);
    sti();
}
```

path: kernel/sched.c
```
void sleep_on(struct task_struct **p)
{
    struct task_struct *tmp;

    if (!p)
        return;
    if (current == &(init_task.task))
        panic("task[0] trying to sleep");
    /* 将进程1设置为不可中断等待状态,进程1挂起，然后调用shedule()函数 */
    tmp = *p;
    *p = current;
    current->state = TASK_UNINTERRUPTIBLE; // 将进程1设置为不可中断等待状态
    schedule();
    if (tmp)
        tmp->state=0;
}
```

在等待硬盘读数据时,进程调度切换到进程0执行, 从进程1调度到进程0过程如下所示:

path: kernel/sched.c
```
void schedule(void)
{
    int i,next,c;
    struct task_struct ** p;

    /* check alarm, wake up any interruptible tasks that have got a signal */
    /* 首先依据task[64]这个结构，第一次遍历所有进程，只要地址指针不为空，就要针对它们的
     * “报警定时值alarm”以及“信号位图signal”进行处理。在当前的情况下，这些处理还不会产生
     * 具体的效果，尤其是进程1此时并没有收到任何信号，它的状态是“不可中断等待状态”，不可能
     * 转变为“就绪态”。
     */
    for(p = &LAST_TASK ; p > &FIRST_TASK ; --p)
        if (*p) {
            if ((*p)->alarm && (*p)->alarm < jiffies) { // 如果设置了定时或定时已过
                    (*p)->signal |= (1<<(SIGALRM-1));   // 设置SIGALRM
                    (*p)->alarm = 0; // alarm清零
            }
            if (((*p)->signal & ~(_BLOCKABLE & (*p)->blocked)) &&
                (*p)->state==TASK_INTERRUPTIBLE)
                (*p)->state=TASK_RUNNING;
        }

    /* this is the scheduler proper: */
    /* 第二次遍历task[64]的时候，此时只有两个进程，进程0的状态是可中断等待状态，
     * 进程1的状态也已经刚刚被设置成了不可中断等待状态。常规的进程切换条件是，
     * 剩余时间片最多且必须是就绪态，即代码“if ((*p)->state == TASK_RUNNING && (*p)->counter > c)”给出的条件。
     * 现在两个进程都不是就绪态，按照常规的条件无法切换进程，没有进程可以执行。
     * 这是一个非常尴尬的状态。
     * 操作系统的设计者对这种状态的解决方案是: 强行切换到进程0!
     * 注意: c的值将仍然是-1，所以next 仍然是0，这个next就是要切换到进程的进程号。可以看出，如果没有合适的进程，
     * next的数值将永远是0，就会切换到进程0去执行！
      */
    while (1) {
        c = -1;
        next = 0;
        i = NR_TASKS;
        p = &task[NR_TASKS];
        while (--i) {
            if (!*--p)
                continue;
            // 找出就绪态中counter最大的进程
            if ((*p)->state == TASK_RUNNING && (*p)->counter > c)
                c = (*p)->counter, next = i;
        }
        if (c) break;
        for(p = &LAST_TASK ; p > &FIRST_TASK ; --p)
            if (*p)
                (*p)->counter = ((*p)->counter >> 1) +
                        (*p)->priority;
    }
    switch_to(next);
}
```

接下来将要调用switch_to宏函数来执行进程切换操作:

path: include/linux/sched.h
```
#define FIRST_TSS_ENTRY 4
#define FIRST_LDT_ENTRY (FIRST_TSS_ENTRY+1)
// 宏定义,计算在全局表中第n个任务的 TSS 描述符的索引号(选择符)。
// FIRST_TSS_ENTRY<<3是100000，((unsigned long) n)<<4，对进程1是10000
// _TSS(1)就是110 0 00，最后2位特权级，右起第3位GDT，110是6即GDT中tss0的下标
#define _TSS(n) ((((unsigned long) n)<<4)+(FIRST_TSS_ENTRY<<3))
#define _LDT(n) ((((unsigned long) n)<<4)+(FIRST_LDT_ENTRY<<3))
...
/*
 * switch_to(n) should switch tasks to task nr n, first
 * checking that n isn't the current task, in which case it does nothing.
 * This also clears the TS-flag if the task we switched to has used
 * tha math co-processor latest.
 */
/*
 * switch_to(n)将切换当前任务到任务nr即n。首先检测任务 n 不是当前任务,
 * 如果是则什么也不做退出。如果我们切换到的任务最近(上次运行)使用过数学
 * 协处理器的话,则还需复位控制寄存器 cr0 中的 TS 标志。
 */
#define switch_to(n) {\
struct {long a,b;} __tmp; \         // 为ljmp的CS、EIP准备的数据结构
__asm__("cmpl %%ecx,current\n\t" \  // 任务n是当前任务吗?(current ==task[n]?)
    "je 1f\n\t" \                   // 是,则什么都不做,退出。
    "movw %%dx,%1\n\t" \            // 将新任务16位选择符存入__tmp.b中。
    "xchgl %%ecx,current\n\t" \     // current = task[n];ecx = 被切换出的任务。
    // ljmp到__tmp，__tmp中有偏移、段选择符， 但任务门忽略偏移
    "ljmp *%0\n\t" \                // 执行长跳转至*&__tmp,造成任务切换。
                                    // 在任务切换回来后才会继续执行下面的语句。
    "cmpl %%ecx,last_task_used_math\n\t" \ // 新任务上次使用过协处理器吗?
    "jne 1f\n\t" \   // 没有则跳转,退出。
    "clts\n" \       // 新任务上次使用过协处理器,则清cr0的TS标志。
    "1:" \
    ::"m" (*&__tmp.a),"m" (*&__tmp.b), \ // .a对应EIP（忽略），.b对应CS
    "d" (_TSS(n)),"c" ((long) task[n])); \ // EDX是TSS n的索引号，ECX即task[n]
}
```

switch_to (0)执行完后，已经切换到进程0去执行, 当时进程0切换到进程1时:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/ProcessSchedule1to0.md

是从switch_to (1)的"ljmp %0\n\t"这一行切换走的，TSS中保存当时的CPU所有寄存器的值，
其中CS:EIP指向的就是它的下一行，所以，现在进程0要从
```
"cmpl %%ecx,_last_task_used_math\n\t"
```
这行代码开始执行，如下所示:

当时进程0切换到进程1是从:

**pause()** --> **sys_pause()** --> **schedule()** --> **switch_to(1)**

这个调用路线执行过来的, 现在，switch_to（1）后半部分执行完毕后，就应该返回sys_pause(), for(;;) pause() 中执行了。
pause这个函数将在for（;;）这个循环里面被反复调用，所以，会继续调用schedule函数进行进程切换。而再次切换的时候，
由于两个进程还都不是就绪态，按照前面讲述过的理由，当所有进程都挂起的时候，内核会执行switch_to强行切换到进程0。
现在，switch_to中情况有些变化，"cmpl %%ecx,_current\n\t” “je 1f\n\t"的意思是：
如果切换到的进程就是当前进程，就跳转到下面的"1:"处直接返回。此时当前进程正是进程0，要切换到的进程也是进程0，正好符合这个条件。

所以，又回到进程0(注意：不是切换到进程0), 循环执行这个动作.

从这里可以看出操作系统的设计者为进程0设计的特殊职能:

**当所有进程都挂起或没有任何进程执行的时候，进程0就会出来维持操作系统的基本运转，等待挂起的进程具备可执行的条件。
业内人士也称进程0为怠速进程，很像维持汽车等待驾驶员踩油门的怠速状态那样维护计算机的怠速状态。**

注意: 硬盘的读写速度远低于CPU执行指令的速度(2～3个量级), 现在，硬盘仍在忙着把指定的数据读到它的缓存中...

硬盘在某一时刻把一个扇区的数据读出来了，产生硬盘中断。CPU接到中断指令后，终止正在执行的程序，
终止的位置肯定是在pause(), sys_pause(), schedule(), switch_to (n)循环里面的某行指令处.
然后转去执行硬盘中断服务程序:

https://github.com/leeminghao/doc-linux/blob/master/0.11/filesystem/InstallDiskFs.md