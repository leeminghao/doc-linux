Linux 0.11 进程0切换到进程1
================================================================================

进程0创建完成进程1以后：

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/CreateProcess1.md

现在执行的是进程0的代码，从这里开始，进程0准备切换到进程1去执行。

Linux 0.11进程调度时机(调度策略)
--------------------------------------------------------------------------------

* 允许进程运行的时间结束:

进程在创建时，都被赋予了有限的时间片，以保证所有进程每次都只执行有限的时间。一旦进程的时间片
被削减为0，就说明这个进程此次执行的时间用完了，立即切换到其他进程去执行，实现多进程轮流执行。

* 进程的运行停止:

当一个进程需要等待外设提供的数据，或等待其他程序的运行结果...或进程已经执行完毕时，在这些情况下，
虽然还有剩余的时间片，但是进程不再具备进一步执行的“逻辑条件”了。如果还等着时钟中断产生后再切换到
别的进程去执行，就是在浪费时间，应立即切换到其他进程去执行。

这两种情况中任何一种情况出现，都会导致进程切换。

进程0第一次切换到进程1去执行
--------------------------------------------------------------------------------

在进程0创建完进程1以后，进程0接下来会调用执行pause函数，执行代码如下所示:

path: init/main.c
```
static inline _syscall0(int,fork)
static inline _syscall0(int,pause)
...
void main(void)
{
    ...
    move_to_user_mode();
    if (!fork()) {        /* we count on this going ok */
        init();
    }
   /*
    *   NOTE!!   For any other task 'pause()' would mean we have to get a
    * signal to awaken, but task0 is the sole exception (see 'schedule()')
    * as task 0 gets activated at every idle moment (when no other tasks
    * can run). For task0 'pause()' just means we go check if some other
    * task can run, and if not we return here.
    */
    for(;;) pause();
}
```

pause()函数的调用与fork()函数的调用一样，会执行到unistd.h中的syscall0，通过int 0x80中断，在
system_call.s中的call _sys_call_table（,%eax,4）映射到sys_pause()的系统调用函数去执行，具体步骤
与调用fork()函数步骤类似。略有差别的是，fork()函数是用汇编写的，而sys_pause()函数是用C语言写的。

进入sys_pause()函数后,将进程0设置为可中断等待状态,然后调用schedule()函数进行进程切换执行代码如下:

path: kernel/sched.c
```
int sys_pause(void)
{
    // 将进程0设置为可中断等待状态，如果产生某种中断，或其他进程给这个进程发送特定信号...
    // 才有可能将这个进程的状态改为就绪态
    current->state = TASK_INTERRUPTIBLE;
    schedule();
    return 0;
}
```

接下来进入schedule函数中去执行, 执行代码如下所示:
在schedule()函数中，先分析当前有没有必要进行进程切换，如果有必要，再进行具体的切换操作。

path: kernel/sched.c
```
/*
 *  'schedule()' is the scheduler function. This is GOOD CODE! There
 * probably won't be any reason to change this, as it should work well
 * in all circumstances (ie gives IO-bound processes good response etc).
 * The one thing you might take a look at is the signal-handler code here.
 *
 *   NOTE!!  Task 0 is the 'idle' task, which gets called when no other
 * tasks can run. It can not be killed, and it cannot sleep. The 'state'
 * information in task[0] is never used.
 */
void schedule(void)
{
    int i,next,c;
    struct task_struct ** p;

    /* check alarm, wake up any interruptible tasks that have got a signal */
    /* 首先依据task[64]这个结构，第一次遍历所有进程，只要地址指针不为空，就要针对它们的
     * “报警定时值alarm”以及“信号位图signal”进行处理。在当前的情况下，这些处理还不会产生
     * 具体的效果，尤其是进程0此时并没有收到任何信号，它的状态是“可中断等待状态”，不可能
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
    /* 第二次遍历所有进程，比较进程的状态和时间片，找出处在就绪态且counter最大的进程。
     * 现在只有进程0和进程1，且进程0是可中断等待状态，不是就绪态，只有进程1处于就绪态，
     * 所以，执行switch_to（next），切换到进程1去执行
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

程序将一直执行到

```
"ljmp *%0\n\t"
```

这一行, ljmp通过CPU的任务门机制并未实际使用任务门，将CPU的各个寄存器值保存在进程0的TSS中，
将进程1的TSS数据以及LDT的代码段、数据段描述符数据恢复给CPU的各个寄存器，实现从0特权级的内核代码
切换到3特权级的进程1代码执行.

首先是为什么要加*这是gas语法，表示绝对跳转(与C中的*是不同的)，若程序没有加*，则编译器会自己加上*，可以在linux中测试；

ljmp用法说明：

按AS手册，ljmp指令存在两种形式，即：

A. 直接操作数跳转，此时操作数即为目标逻辑地址(选择符，偏移)，即形如：
```
ljmp $seg_selector, $offset
```

B. 使用内存操作数，这时候，AS手册规定，内存操作数必须用“*”作前缀，即形如：ljmp *mem48，其中内存
位置mem48处存放目标逻辑地址: 高16bit存放的是seg_selector，低32bit存放的是offset。
注意：这条指令里的“*”只是表示间接跳转的意思，与C语言里的“*”作用完全不同。

回到源码上，ljmp %0用的ljmp的第二种用法，"ljmp *%0"这条语句展开后相当于"ljmp *__tmp.a"，
也就是跳转到地址&__tmp.a中包含的48bit逻辑地址处。而按struct _tmp的定义，这也就意味着__tmp.a
即为该逻辑地址的offset部分，__tmp.b的低16bit为seg_selector(高16bit无用)部分。由于在"ljmp %0"之前，
"movw %%dx,%1"这条语句已经把状态段选择符"__TSS(n)"的值赋给了__tmp.b的低16bit。

通过以上说明，可以知道了ljmp将跳转到选择子指定的地方，大致过程是，ljmp判断选择符为TSS类型，
于是就告诉硬件要切换任务，硬件首先它要将当前的pc,esp,eax等现场信息保存在当前自己的TSS段描述符中,
然后再将目标TSS段描述符中的pc,esp,eax的值拷贝至对应的寄存器中.当这些过程全部做完以后内核就实现了
内核的切换. 可以参考下图：

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/task_schedule.gif

接下来，轮到进程1执行，它将进一步构建环境，使进程能够以文件的形式与外设交互。

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/Process1Running.md

**需要提醒的是**:
**pause()函数的调用是通过int 0x80中断从3特权级的进程0代码翻转到0特权级的内核代码执行的，
在_system_call中的call _sys_call_table (,%eax,4) 中调用sys_pause()函数，并在sys_pause()中的
schedule()中调用switch_to()，在switch_to()中ljmp进程1的代码执行。
现在，switch_to( )中ljmp后面的代码还没有执行，call _sys_call_table (,%eax,4) 后续的代码也还
没有执行，int 0x80的中断没有返回。**
