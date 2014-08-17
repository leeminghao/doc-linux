Linux 0.11 进程1
================================================================================

Linux 0.11跳转到main函数以后经过一系列初始化工作以后，创建了进程0：

初始化：

https://github.com/leeminghao/doc-linux/blob/master/0.11/init/StartMainInit.md

创建进程0：

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/CreateProcess0.md

现在Linux 0.11内核中的进程0现在处在3特权级状态，即进程状态。正式开始运行要做的第一件事就是
作为父进程调用fork函数创建第一个子进程——进程1，这是父子进程创建机制的第一次实际运用。
以后，所有进程都是基于父子进程创建机制由父进程创建出来的。

进程0创建进程1
--------------------------------------------------------------------------------

### fork

在Linux操作系统中创建新进程的时候，都是由父进程调用fork函数来实现的。
执行代码如下：

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

从上面main.c的代码中对fork()的声明，可知调用fork函数, 实际上是执行到unistd.h中的
宏函数syscall0中去，对应代码如下：

path: include/unistd.h
```
#define __NR_setup    0    /* used only by init, to get system going */
#define __NR_exit     1
#define __NR_fork     2
...
#define _syscall0(type,name) \
type name(void) \
{ \
long __res; \
__asm__ volatile ("int $0x80" \
    : "=a" (__res) \
    : "0" (__NR_##name)); \
if (__res >= 0) \
    return (type) __res; \
errno = -__res; \
return -1; \
}
...
int fork(void);
```

path: include/linux/sys.h
```
extern int sys_fork();
...
fn_ptr sys_call_table[] = { sys_setup, sys_exit, sys_fork, sys_read,
sys_write, sys_open, sys_close, sys_waitpid, sys_creat, sys_link,
sys_unlink, sys_execve, sys_chdir, sys_time, sys_mknod, sys_chmod,
sys_chown, sys_break, sys_stat, sys_lseek, sys_getpid, sys_mount,
sys_umount, sys_setuid, sys_getuid, sys_stime, sys_ptrace, sys_alarm,
sys_fstat, sys_pause, sys_utime, sys_stty, sys_gtty, sys_access,
sys_nice, sys_ftime, sys_sync, sys_kill, sys_rename, sys_mkdir,
sys_rmdir, sys_dup, sys_pipe, sys_times, sys_prof, sys_brk, sys_setgid,
sys_getgid, sys_signal, sys_geteuid, sys_getegid, sys_acct, sys_phys,
sys_lock, sys_ioctl, sys_fcntl, sys_mpx, sys_setpgid, sys_ulimit,
sys_uname, sys_umask, sys_chroot, sys_ustat, sys_dup2, sys_getppid,
sys_getpgrp, sys_setsid, sys_sigaction, sys_sgetmask, sys_ssetmask,
sys_setreuid,sys_setregid };
```
path: include/linux/sched.h
```
typedef int (*fn_ptr)();
```

syscall0展开后，看上去像下面的样子：

```
int fork(void)
{
    long __res;
    // int 0x80是所有系统调用函数的总入口，fork()是其中之一
    __asm__ volatile ("int $0x80"
        : "=a" (__res)       // 第一个冒号后是输出部分，将_res赋给eax
        : "0" (__NR_fork));  // 第二个冒号后是输入部分，"0"：同上寄存器，即eax，__NR_fork就是2，将2给eax
    if (__res >= 0)          // int 0x80中断返回后，将执行这一句
        return (int) __res;
    errno= -__res;
    return -1;
}
```

注意： 别忘了int 0x80导致CPU硬件自动将ss、esp、eflags、cs、eip的值压栈！
int 0x80的执行路线很长，下面我们来分析这个过程:

A. 先执行: "0" （__NR_ fork）这一行，意思是将fork 在sys_call_table[]中对应的函数编号
__NR_fork（也就是2）赋值给eax。这个编号即sys_fork()函数在sys_call_table中的偏移值。

B. 紧接着就执行"int $0x80"，产生一个软中断，CUP从3特权级的进程0代码跳到0特权级内核代码中执行。
中断使CPU硬件自动将SS、ESP、EFLAGS、CS、EIP这5个寄存器的数值按照这个顺序压入init_task(进程0)中的内核栈。

init_task的内核栈如下所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/task0.jpg

**注意**: 在跳转到main函数后的初始化过程，提到的move_to_user_mode这个函数中做的压栈动作就是模仿中断的硬件压栈，
这些压栈的数据将在后续的copy_process()函数中用来初始化进程1的TSS。值得注意，压栈的EIP指向当前指令"int $0x80"的下一行, 即:

```
if （__res >= 0）
    return (int) __res;
```

**这一行就是进程0从fork函数系统调用中断返回后第一条指令的位置。这一行也将是进程1开始执行的第一条指令位置。**

### system_call

在sched_init函数中set_system_gate（0x80,&system_call）的设置，CPU自动压栈完成后，跳转到system_call.s
中的_system_call处执行，执行过程如下所示:

path: kernel/system_call.s
```
bad_sys_call:
    movl $-1,%eax
    iret
.align 2
reschedule:
    pushl $ret_from_sys_call
    jmp schedule
.align 2
system_call:
    cmpl $nr_system_calls-1,%eax
    ja bad_sys_call
    # 继续将DS、ES、FS、EDX、ECX、EBX压栈
    # 以上一系列的压栈操作都是为了后面调用copy_process函数中初始化进程1中的TSS做准备.
    push %ds
    push %es
    push %fs
    pushl %edx
    pushl %ecx        # push %ebx,%ecx,%edx as parameters
    pushl %ebx        # to the system call
    movl $0x10,%edx        # set up ds,es to kernel space
    mov %dx,%ds
    mov %dx,%es
    movl $0x17,%edx        # fs points to local data space
    mov %dx,%f
    # 内核通过刚刚设置的eax的偏移值2查询 sys_call_table[]，得知本次系统调用对应的函数是sys_fork().
    # call _sys_call_table(,%eax,4)中的eax是2，这一行可以看成:
    # call _sys_call_table + 2×4(4的意思是_sys_call_table[]的每一项有4字节),相当于call _sys_call_table[2]，就是执行sys_fork.
    # 注意: call _sys_call_table（,%eax,4）指令本身也会压栈保护现场.
    call sys_call_table(,%eax,4)
    pushl %eax
    movl current,%eax
    cmpl $0,state(%eax)        # state
    jne reschedule
    cmpl $0,counter(%eax)        # counter
    je reschedule
ret_from_sys_call:
    movl current,%eax        # task[0] cannot have signals
    cmpl task,%eax
    je 3f
    cmpw $0x0f,CS(%esp)        # was old code segment supervisor ?
    jne 3f
    cmpw $0x17,OLDSS(%esp)        # was stack segment = 0x17 ?
    jne 3f
    movl signal(%eax),%ebx
    movl blocked(%eax),%ecx
    notl %ecx
    andl %ebx,%ecx
    bsfl %ecx,%ecx
    je 3f
    btrl %ecx,%ebx
    movl %ebx,signal(%eax)
    incl %ecx
    pushl %ecx
    call do_signal
    popl %eax
3:    popl %eax
    popl %ebx
    popl %ecx
    popl %edx
    pop %fs
    pop %es
    pop %ds
    iret
```

### sys_fork

因为汇编中对应C语言的函数名在前面多加一个下划线“_”（C语言的sys_fork()对应汇编的就是_sys_fork），所以跳转到 _sys_fork处执行.
执行代码如下所示:

path: kernel/system_call.s
```
.align 2
sys_fork:
    call find_empty_process
    ...
```

开始执行sys_fork():
在sched_init()函数中已经对task[64]除0项以外的所有项清空, 现在sys_fork调用find_empty_process()
函数为进程1获得一个可用的进程号和task[64]中的一个位置, find_empty_process的执行过程如下所示:

path: kernel/fork.c
```
// 内核用全局变量last_pid来存放系统自开机以来累计的进程数，也将此变量用作新建进程的进程号。
long last_pid=0;
...
// 为新创建的进程找到一个空闲的位置，NR_TASKS是64
int find_empty_process(void)
{
    int i;

repeat:
    if ((++last_pid)<0) last_pid=1;
    // 第一次遍历task[64], "&&"条件成立说明last_pid已被使用, 则++last_pid, 直到获得用于新进程的进程号.
    for(i=0 ; i<NR_TASKS ; i++)
        if (task[i] && task[i]->pid == last_pid) goto repeat;
    // 第二次遍历task[64], 获得第一个空闲的i, 俗称进程号.
    for(i=1 ; i<NR_TASKS ; i++)
        if (!task[i])
            return i;
    // 因为Linux 0.11的task[64]只有64项, 最多只能同时运行64个进程, 如果函数返回-EAGAIN,
    // 意味着当前已经有64个进程在运行, 当然这种情况现在还不会发生.
    return -EAGAIN;
}
```

现在，两次遍历的结果是新的进程号last_pid就是1，在task[64]中占据第二项, 接下来返回到sys_fork中继续执行:

path: kernel/system_call.s
```
.align 2
sys_fork:
    call find_empty_process
    testl %eax,%eax # eax保存find_empty_process函数返回的进程1的进程号
    js 1f
    # 进程1的进程号及在task[64]中的位置确定后, 正在创建的进程1就等于有了身份.
    # 接下来, 在进程0的内核栈中继续压栈, 将5个寄存器值进栈, 为调用copy_process()函数准备参数,
    # 这些数据也是用来初始化进程1的TSS.
    # 注意: 最后压栈的eax的值就是find_empty_process()函数返回的进程号, 也将是copy_process()函数的第一个参数int nr,
    push %gs
    pushl %esi
    pushl %edi
    pushl %ebp
    pushl %eax
    # 压栈结束后, 开始调用copy_process()函数.
    call copy_process
    addl $20,%esp
1:  ret
```

### copy_process

进程0已经成为一个可以创建子进程的父进程, 在内核中有“进程0的task_struct”和“进程0的页表项”等专属进程0的管理信息.
接下来, 进程0将在copy_process()函数中做非常重要的体现父子进程创建机制的工作:

path: kernel/fork.c
```
/*
 *  Ok, this is the main fork-routine. It copies the system process
 * information (task[nr]) and sets up the necessary registers. It
 * also copies the data segment in it's entirety.
 */
// 注意: 这些参数是int 0x80, system_call, sys_fork多次累积压栈的结果，顺序是完全一致的
int copy_process(int nr,long ebp,long edi,long esi,long gs,long none,
        long ebx,long ecx,long edx,
        long fs,long es,long ds,
        long eip,long cs,long eflags,long esp,long ss)
{
    struct task_struct *p;
    int i;
    struct file *f;

    p = (struct task_struct *) get_free_page();
    if (!p)
        return -EAGAIN;
    ...
    return last_pid;
}
```

进入copy_process()函数后, 调用get_free_page()函数, 在主内存申请一个空闲页面,
并将申请到的页面清零,用于进程1的task_struct及内核栈, 执行代码如下所示:

path: mm/memory.c
```
#define LOW_MEM 0x100000  // 内存低端(1MB)
#define PAGING_MEMORY (15*1024*1024)     // 分页内存 15MB, 主内存区最多 15M
#define PAGING_PAGES (PAGING_MEMORY>>12) // 分页后的物理内存页数
...
/*
* 获取首个(实际上是最后 1 个:-)空闲页面,并标记为已使用。如果没有空闲页面,
* 就返回 0。
*/
// 取空闲页面。如果已经没有可用内存了,则返回 0。
// 输入: %1(ax=0) - 0; %2 - (LOW_MEM); %3 - (cx=PAGING PAGES); %4 - (edi=mem_map+PAGING_PAGES-1).
// 输出: 返回%0(ax=页面起始地址)。
// 上面%4寄存器实际指向mem_map[]内存字节图的最后一个字节。本函数从mem_map末端开始向前扫描
// 所有页面标志(页面总数为 PAGING_PAGES),若有页面空闲(其内存映像字节为 0)则返回页面地址。
unsigned long get_free_page(void)
{
    register unsigned long __res asm( "ax" );

// 反向扫描串（mem map[]），al（0）与di不等则重复（找引用对数为0的项）
__asm__( "std ; repne ; scasb\n\t" // 方向位置位,将 al(0)与对应每个页面的(di)内容比较,
    "jne 1f\n\t"           // 如果没有等于0的字节,则跳转结束(返回 0).
    "movb $1,1(%%edi)\n\t" // 将对应页面的内存映像位 "置1"。
    "sall $12,%%ecx\n\t"   // 页面数 * 4K = 相对页面起始地址; ecx算数左移12位，页的相对地址
    "addl %2,%%ecx\n\t"    // 再加上低端内存地址,即获得页面实际物理起始地址; LOW MEN + ecx，页的物理地址
    "movl %%ecx,%%edx\n\t" // 将页面实际起始地址 --> edx 寄存器
    "movl $1024,%%ecx\n\t" // 寄存器 ecx 置计数值 1024。
    // 将4092+edx的位置 --> edi(该页面的末端); 将edx + 4 KB的有效地址赋给edi
    "leal 4092(%%edx),%%edi\n\t"
    "rep ; stosl\n\t"    // 将 edi 所指内存清零(反方向,也即将该页面清零)。
    "movl %%edx,%%eax\n" // 将页面起始地址 --> eax(返回值)。
    "1:"
    : "=a" (__res)
    : "" (0), "i" (LOW_MEM), "c" (PAGING_PAGES),
    "D" (mem_map+PAGING_PAGES-1)
    : "di" , "cx" , "dx" ); // 第三个冒号后是程序中改变过的量

    return __res;  // 返回空闲页面地址(如果无空闲也则返回 0)。
}
```

按照get_free_page()函数的算法，是从主内存的末端开始向低地址端递进，现在是开机以来,
操作系统内核第一次为进程在主内存申请空闲页面，申请到的空闲页面肯定在16 MB主内存的最末端.

**注意**: get_free_page函数只是指出在主内存区的一页空闲页面,但并没有映射到某个进程的线性地址去。
后面的put_page()函数就是用来作映射的。

接下来回到copy_process函数继续执行，如下所示：

path: mm/memory.c
```
int copy_process(int nr,long ebp,long edi,long esi,long gs,long none,
        long ebx,long ecx,long edx,
        long fs,long es,long ds,
        long eip,long cs,long eflags,long esp,long ss)
{
    struct task_struct *p;
    int i;
    struct file *f;

    p = (struct task_struct *) get_free_page();
    if (!p)
        return -EAGAIN;
    /* 将这个页面的指针强制类型转换为指向task_struct的指针类型, 并挂接在task[1]上,
     * 即task[nr] = p. nr就是第一个参数, 是find_empty_process函数返回的进程号.
     * 注意: 强制类型转换的意思是"认定"这个页面的低地址端就是进程1的task_struct的首地址，同时暗示了高地址部分是内核栈.
     * 了解了这一点，后面的p->tss.esp0 = PAGE_SIZE + (long)p就不奇怪了.
     */
    task[nr] = p;
    /* current指向当前进程的task_struct的指针，当前进程是进程0.
     * 下面这行的意思: 将父进程的task_struct赋给子进程, 这是父子进程创建机制的重要体现.
     * 这行代码执行后, 父子进程的task_struct将完全一样
     * 注意指针类型: 只复制task_struct，并未将4 KB都复制，即进程0的内核栈并未复制
     */
    *p = *current;    /* NOTE! this doesn't copy the supervisor stack */
    /* 只有内核代码中明确表示将该进程设置为就绪状态才能被唤醒, 除此之外，没有任何办法将其唤醒 */
    p->state= TASK_UNINTERRUPTIBLE;
    /* 进程1的task_struct的雏形此时已经形成了，进程0的task_struct中的信息并不一定全都适用于进程1，
     * 因此还需要针对具体情况进行调整。从p->开始的代码，都是为进程1所做的个性化调整设置，
     * 其中调整TSS所用到的数据都是前面程序累积压栈形成的参数。
     */
    p->pid = last_pid;
    p->father = current->pid;
    p->counter = p->priority;
    p->signal = 0;
    p->alarm = 0;
    p->leader = 0;        /* process leadership doesn't inherit */
    p->utime = p->stime = 0;
    p->cutime = p->cstime = 0;
    p->start_time = jiffies;
    // 开始设置子进程的TSS
    p->tss.back_link = 0;
    // esp0是内核栈指针
    p->tss.esp0 = PAGE_SIZE + (long) p;
    // 0x10就是10000，0特权级，GDT，数据段
    p->tss.ss0 = 0x10;
    // 重要！就是参数的EIP，是int 0x80压栈的，指向的是: if(__res >= 0)
    p->tss.eip = eip;
    p->tss.eflags = eflags;
    // 重要！决定main()函数中if (!fork())后面的分支走向
    p->tss.eax = 0;
    p->tss.ecx = ecx;
    p->tss.edx = edx;
    p->tss.ebx = ebx;
    p->tss.esp = esp;
    p->tss.ebp = ebp;
    p->tss.esi = esi;
    p->tss.edi = edi;
    p->tss.es = es & 0xffff;
    p->tss.cs = cs & 0xffff;
    p->tss.ss = ss & 0xffff;
    p->tss.ds = ds & 0xffff;
    p->tss.fs = fs & 0xffff;
    p->tss.gs = gs & 0xffff;
    // 挂接子进程的LDT
    p->tss.ldt = _LDT(nr);
    p->tss.trace_bitmap = 0x80000000;

    ...
    return last_pid;
}
```

**注意**:

A. task_union的设计颇具匠心, 前面是task_struct，后面是内核栈，增长的方向正好相反，正好占用一页，
顺应分页机制，分配内存非常方便。而且操作系统设计者肯定经过反复测试，保证内核代码所有可能的
调用导致压栈的最大长度都不会覆盖前面的task_struct。因为内核代码都是操作系统设计者设计的，
可以做到心中有数。相反，假如这个方法为用户进程提供栈空间，恐怕要出大问题了。

接下来的代码意义重大：

```
*p= *current;   /* NOTE! this doesn't copy the supervisor stack */
```

current是指向当前进程的指针；p是进程1的指针。当前进程是进程0，是进程1的父进程。
将父进程的task_struct复制给子进程，就是将父进程最重要的进程属性复制给了子进程，
子进程继承了父进程的绝大部分能力。这是父子进程创建机制的特点之一。

B. 下面这两行代码很关键:

```
    p->tss.eip= eip;
    p->tss.eax= 0;
```

这两行代码为第二次执行fork()中的if (__res >= 0) 埋下伏笔。这个伏笔比较隐讳.


1）为进程1创建task_struct，将进程0的task_struct的内容复制给进程1。
2）为进程1的task_struct、tss做个性化设置。
3）为进程1创建第一个页表，将进程0的页表项内容赋给这个页表。
4）进程1共享进程0的文件。
5）设置进程1的GDT项。
6）最后将进程1设置为就绪态，使其可以参与进程间的轮转。
