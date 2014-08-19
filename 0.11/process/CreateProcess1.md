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

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/kernel_stack.jpg

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
3:  popl %eax
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
并将申请到的页面清零,用于进程1的task_struct及内核栈,执行代码如下所示:

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

path: kernel/fork.c
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

这两行代码为第二次执行fork()中的if (__res >= 0) 埋下伏笔,这个伏笔比较隐讳.

### copy_mem

接下来我们要在copy_process函数中设置进程1的分页管理，代码如下所示：

path: kernel/fork.c
```
int copy_process(int nr,long ebp,long edi,long esi,long gs,long none,
      long ebx,long ecx,long edx,
      long fs,long es,long ds,
      long eip,long cs,long eflags,long esp,long ss)
{
    ...
    if (last_task_used_math== current)
         __asm__("clts;fnsave %0"::"m" (p->tss.i387));
    if (copy_mem(nr,p)) {  // 设置子进程的代码段、数据段及创建、复制子进程的第一个页表
         task[nr]= NULL;   // 现在不会出现这种情况
         free_page((long) p);
         return -EAGAIN;
    }
    ...
｝
```

Intel 80x86体系结构分页机制是基于保护模式的，先打开pe，才能打开pg，不存在没有pe的pg。
保护模式是基于段的，换句话说，设置进程1的分页管理，就要先设置进程1的分段。

一般来讲，每个进程都要加载属于自己的代码、数据。这些代码、数据的寻址都是用: "段+偏移"的形式，也就是逻辑地址形式表示的。
CPU硬件自动将逻辑地址计算为CPU可寻址的线性地址，再根据操作系统对页目录表、页表的设置，自动将线性地址转换为分页的物理地址。
操作系统正是沿着这个技术路线，先在进程1的64 MB线性地址空间中设置代码段、数据段，然后设置页表、页目录。

##### 在进程1的线性地址空间中设置代码段、数据段

在Linux 0.11中，每个进程所属的程序代码执行时，都要根据其线性地址来进行寻址，并最终映射到物理内存上。

线性地址有32位，CPU将这个线性地址解析成“页目录项”, “页表项”和“页内偏移”:

* 页目录项存在于页目录表中，用以管理页表；
* 页表项存在于页表中，用以管理页面，最终在物理内存上找到指定的地址。

Linux 0.11中仅有一个页目录表，通过线性地址中提供的“页目录项”数据就可以找到页目录表中对应的页目录项:

* 通过这个页目录项就可以找到对应的页表；
* 之后，通过线性地址中提供的“页表项”数据，就可以在该页表中找到对应的页表项；
* 通过此页表项可以进一步找到对应的物理页面；
* 最后，通过线性地址中提供的“页内偏移”落实到实际的物理地址值。

整个过程如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/task_page.jpg

调用copy_mem()函数，先设置进程1的代码段、数据段的段基址、段限长，提取当前进程（进程0）的代码段、数据段以及段限长的信息，
并设置进程1的代码段和数据段的基地址。这个基地址就是它的进程号nr*64 MB。设置新进程LDT中段描述符中的基地址，如下所示:

path: kernel/fork.c
```
int copy_mem(int nr,struct task_struct * p)
{
    unsigned long old_data_base,new_data_base,data_limit;
    unsigned long old_code_base,new_code_base,code_limit;

    // 取子进程的代码、数据段限长
    code_limit=get_limit(0x0f); // 0x0f即1111: 代码段、LDT、3特权级
    data_limit=get_limit(0x17); // 0x17即10111: 数据段、LDT、3特权级

    // 获取父进程（现在是进程0）的代码段、数据段基址
    old_code_base = get_base(current->ldt[1]);
    old_data_base = get_base(current->ldt[2]);

    if (old_data_base != old_code_base)
        panic("We don't support separate I&D");
    if (data_limit < code_limit)
        panic("Bad data_limit");

    new_data_base = new_code_base = nr * 0x4000000; // 现在nr是1，0x4000000是64 MB
    p->start_code = new_code_base;
    /* set_base是设置进程的ldt,用于分段管理，用于逻辑地址映射到线性地址 */
    set_base(p->ldt[1],new_code_base); // 设置子进程代码段基址
    set_base(p->ldt[2],new_data_base); // 设置子进程数据段基址

    // 为进程1创建第一个页表、复制进程0的页表，设置进程1的页目录项
    if (copy_page_tables(old_data_base,new_data_base,data_limit)) {
        printk("free_page_tables: from copy_mem\n");
        free_page_tables(new_data_base,data_limit);
        return -ENOMEM;
    }

    return 0;
}
```

path: include/linux/sched.h
```
#define _set_base(addr,base)  \
__asm__ ("push %%edx\n\t" \
    "movw %%dx,%0\n\t" \
    "rorl $16,%%edx\n\t" \
    "movb %%dl,%1\n\t" \
    "movb %%dh,%2\n\t" \
    "pop %%edx" \
    ::"m" (*((addr)+2)), \
     "m" (*((addr)+4)), \
     "m" (*((addr)+7)), \
     "d" (base) \
    )

#define _set_limit(addr,limit) \
__asm__ ("push %%edx\n\t" \
    "movw %%dx,%0\n\t" \
    "rorl $16,%%edx\n\t" \
    "movb %1,%%dh\n\t" \
    "andb $0xf0,%%dh\n\t" \
    "orb %%dh,%%dl\n\t" \
    "movb %%dl,%1\n\t" \
    "pop %%edx" \
    ::"m" (*(addr)), \
     "m" (*((addr)+6)), \
     "d" (limit) \
    )

#define set_base(ldt,base) _set_base( ((char *)&(ldt)) , (base) )
#define set_limit(ldt,limit) _set_limit( ((char *)&(ldt)) , (limit-1)>>12 )
...
static inline unsigned long _get_base(char * addr)
{
         unsigned long __base;
         __asm__("movb %3,%%dh\n\t"
                 "movb %2,%%dl\n\t"
                 "shll $16,%%edx\n\t"
                 "movw %1,%%dx"
                 :"=&d" (__base)
                 :"m" (*((addr)+2)),
                  "m" (*((addr)+4)),
                  "m" (*((addr)+7)));
         return __base;
}

#define get_base(ldt) _get_base( ((char *)&(ldt)) )

// 取segment的段限长, 给__limit
#define get_limit(segment) ({ \
unsigned long __limit; \
__asm__("lsll %1,%0\n\tincl %0":"=r" (__limit):"r" (segment)); \
__limit;})
...
```

进入copy_page_tables()函数后，先为新的页表申请一个空闲页面，并把进程0中第一个页表里面前160个页表项复制
到这个页面中（1个页表项控制一个页面4 KB内存空间，160个页表项可以控制640 KB内存空间）。进程0和进程1的
页表暂时都指向了相同的页面，意味着进程1也可以操作进程0的页面。之后对进程1的页目录表进行设置。
最后，用重置CR3的方法刷新页变换高速缓存。进程1的页表和页目录表设置完毕。

执行代码如下:
path: mm/memory.c
```
...
#define invalidate()\
    __asm__("movl %%eax,%%cr3"::"a" (0))    // 重置CR3为0
...

/* from 是进程0的线性地址空间的基地址: 0x00000000.
 * to 是进程1的线性地址空间的基地址: 1 * 0x40000000
 */
int copy_page_tables(unsigned long from,unsigned long to,long size)
{
        unsigned long * from_page_table;
        unsigned long * to_page_table;
        unsigned long this_page;
        unsigned long * from_dir, * to_dir;
        unsigned long nr;

        /* 0x3fffff是4MB,是一个页表的管辖范围,二进制是22个1, "||"的两边必须同为0,所以,
         * from和to后22位必须都为0, 即4MB的整数倍, 意思是一个页表对应4MB连续的线性地址空间
         * 必须是从0x000000开始的4 MB的整数倍的线性地址,不能是任意地址开始的4MB,才符合分页的要求
         */
        if ((from&0x3fffff) || (to&0x3fffff))
             panic("copy_page_tables called with wrong alignment");

       /* 一个页目录项的管理范围是4 MB, 一项是4字节, 项的地址就是: 项数 * 4, 也就是项管理的线性地址起始地址的M数,
        * 比如: 0项的地址是0,管理范围是0～4 MB; 1项的地址是4,管理范围是4～8 MB; 2项的地址是8,管理范围是8～12MB...
        * >>20 就是地址的MB数, & 0xffc就是&111111111100b，就是4 MB以下部分清零的地址的MB数，也就是页目录项的地址
        * 也就是取得源地址和目的地址的目录项地址(from_dir 和 to_dir) */
        from_dir= (unsigned long *) ((from>>20) & 0xffc);   /* _pg_dir= 0 */
        to_dir= (unsigned long *) ((to>>20) & 0xffc);
        /* 计算要复制的内存块占用的页表数(也即目录项数) */
        size= ((unsigned) (size + 0x3fffff)) >> 22;         // >> 22是4 MB数
        /* 下面开始对每个占用的页表依次进行复制操作。*/
        for(; size-- > 0; from_dir++,to_dir++) {
             // 如果目的目录项指定的页表已经存在(P=1),则出错,死机。
             if (1 & *to_dir)
                   panic("copy_page_tables: already exist");
             // 如果此源目录项未被使用,则不用复制对应页表,跳过。
             if (!(1 & *from_dir))
                   continue;

             // *from_dir是页目录项中的地址，0xfffff000&是将低12位清零，高20位是页表的地址
             // 取当前源目录项中页表的地址 --> from_page_table。
             from_page_table= (unsigned long *) (0xfffff000 & *from_dir);
             // 为目的页表取一页空闲内存,如果返回是0则说明没有申请到空闲内存页面.返回值=-1,退出.
             if (!(to_page_table= (unsigned long *) get_free_page()))
                   return -1;   /* Out of memory, see freeing */
             // 设置目的目录项信息。7 是标志信息,表示(Usr, R/W, Present)
             *to_dir= ((unsigned long) to_page_table)|7;  // 7即111
             // 针对当前处理的页表,设置需复制的页面数. 如果是在内核空间,则仅需复制头160页(640KB),
             // 否则需要复制一个页表中的所有 1024 页面。
             // 现在仅仅需要复制160页
             nr= (from==0)?0xA0:1024;                     // 0xA0 即160，复制页表的项数，
             // 对于当前页表,开始复制指定数目 nr 个内存页面。
             for (;nr-- > 0;from_page_table++,to_page_table++){ // 复制父进程页表
                   this_page= *from_page_table; // 取源页表项内容。
                   if (!(1 & this_page)) // 如果当前源页面没有使用,则不用复制。
                         continue;
                    // 复位页表项中 R/W 标志(置 0)。(如果 U/S 位是 0,则 R/W 就没有作用。
                    // 如果 U/S 是 1,而 R/W 是 0,那么运行在用户层的代码就只能读页面。
                    // 如果 U/S 和 R/W 都置位,则就有写的权限。)
                   this_page &= ～2;   // 设置页表项属性，2是010，～2是101，代表用户、只读、存在
                   *to_page_table= this_page; // 将该页表项复制到目的页表中。
                   // 如果该页表项所指页面的地址在 1MB 以上,则需要设置内存页面映射数组mem_map[],
                   // 于是计算页面号,并以它为索引在页面映射数组相应项中增加引用次数。而对于位于
                   // 1MB 以下的页面,说明是内核页面,因此不需要对 mem_map[]进行设置。因为mem_map[]
                   // 仅用于管理主内存区中的页面使用情况。因此,对于内核移动到任务0中并且调用
                   // fork()创建任务 1 时(用于运行 init()),由于此时复制的页面还仍然都在内核
                   // 代码区域,因此以下判断中的语句不会执行。只有当调用fork()的父进程代码处于
                   // 主内存区(页面位置大于 1MB)时才会执行。这种情况需要在进程调用了execve(),
                   // 装载并执行了新程序代码时才会出现。
                   if (this_page > LOW_MEM) {   // 1 MB以内的内核区不参与用户分页管理
                         // 下面这句的含义是令源页表项所指内存页也为只读。因为现在开始有两个进程
                         // 共用内存区了。若其中一个内存需要进行写操作,则可以通过页异常的写保护
                         // 处理,为执行写操作的进程分配一页新的空闲页面,也即进行写时复制的操作。
                         *from_page_table= this_page;
                         this_page -= LOW_MEM;
                         this_page >>= 12;
                         mem_map[this_page]++;  // 增加引用计数，参看mem_init
                   }
             }
        }
        invalidate();  // 重置CR3为0，刷新"页变换高速缓存"
        return 0;
}
```

进程1此时是一个空架子，还没有对应的程序，它的页表又是从进程0的页表复制过来的，它们管理的页面
完全一致，也就是它暂时和进程0共享一套内存页面管理结构，等将来它有了自己的程序，再把关系解除，
并重新组织自己的内存管理结构。如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/task0_task1_page_table.jpg

总结：
--------------------------------------------------------------------------------
**为进程1创建task_struct，将进程0的task_struct的内容复制给进程1** -->
**为进程1的task_struct、tss做个性化设置。** -->
**为进程1创建第一个页表，将进程0的页表项内容赋给这个页表。** -->
**进程1共享进程0的文件。** -->
**设置进程1的GDT项。** -->
**最后将进程1设置为就绪态，使其可以参与进程间的轮转。**
