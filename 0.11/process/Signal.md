信号量机制
================================================================================

实例
--------------------------------------------------------------------------------

path: samples/samples.h
```
#include <signal.h>

static inline void sig_usr(int signo)
{
    if (signo == SIGUSR1) {
        printf("received SIGUSR1\n");
    } else {
        printf("received %d\n", signo);
    }
}

static inline __attribute__((always_inline)) int test_signal(void)
{
    pid_t pid;

    if ((pid = fork()) < 0) {
        return -1;
    } else if (pid == 0) {
        signal(SIGUSR1, sig_usr);
        pause();
        return 0;
    } else {
        return kill(2, SIGUSR1);
    }
}
```

系统需要具备以下三个功能，以支持信号机制。

#### 系统要支持进程对信号的发送和接收系统:

在每个进程task_struct中都设置了用以接收信号的数据成员signal(信号位图)，每个进程接收到的信号
就"按位"存储在这个数据结构中。系统支持两种方式给进程发送信号：
* 一种方式是一个进程通过调用特定的库函数给另一个进程发送信号；
* 另一种方式是用户通过键盘输入信息产生键盘中断后，中断服务程序给进程发送信号。
这两种方式的信号发送原理是相同的，都是通过设置信号位图(signal)上的信号位来实现的。
本实例将结合第一种方式，即一个进程给另外一个进程发送信号来展现系统对信号的发送和接收.

#### 系统要能够及时检测到进程接收到的信号

系统通过两种方式来检测进程是否接收到信号：
* 一种方式是在系统调用返回之前检测当前进程是否接收到信号；
* 另一种方式是时钟中断产生后，其中断服务程序执行结束之前，检测当前进程是否接收到信号。
这两种信号检测方式大体类似。

#### 系统要支持进程对信号进行处理

系统要能够保证，当用户进程不需要处理信号时，信号处理函数完全不参与用户进程的执行；
当用户进程需要处理信号时，进程的程序将暂时停止执行，转而去执行信号处理函数，待信号
处理函数执行完毕后，进程程序将从“暂停的现场处”继续执行。

信号的使用
--------------------------------------------------------------------------------

在上述实例中，调用signal函数的进程(进程1的子进程进程2)开始执行，要为接收信号做准备，具体表现为，
指定对哪种信号进行什么样的处理。用户程序是通过调用signal()函数来实现这个绑定的。这个函数是
库函数，它执行后会产生软中断int 0x80，并映射到sys_signal()这个系统调用函数去执行。sys_signal()
函数的功能是将用户自定义的信号处理函数sig_usr()与进程绑定。这意味着，只要进程接收到SIGUSR1信号，
就调用sig_usr函数来处理该信号，绑定工作就是通过该函数来完成的。进入sys_signal()函数后，系统先要
在绑定之前检测用户指定的信号是否符合规定。由于Linux 0.11中只能默认处理32种信号，而且默认忽略
SIGKILL这个信号，所以只要用户给出的信号不符合这些要求，系统将不能处理。执行代码如下：

path: kernel/signal.c
```
// signal()系统调用。类似于 sigaction()。为指定的信号安装新的信号句柄(信号处理程序)。
// 信号句柄可以是用户指定的函数,也可以是 SIG_DFL(默认句柄)或 SIG_IGN(忽略)。
// 参数: signum - 指定的信号; handler - 指定的句柄; restorer – 恢复函数指针.
// 该函数由libc库提供。用于在信号处理程序结束后恢复系统调用返回时几个寄存器的原有值以及
// 系统调用的返回值,就好象系统调用没有执行过信号处理程序而直接返回到用户程序一样。
// 函数返回原信号句柄。
int sys_signal(int signum, long handler, long restorer)
{
    struct sigaction tmp;
    // 信号值要在(1-32)范围内,并且不得是SIGKILL
    if (signum<1 || signum>32 || signum==SIGKILL)
        return -1;
    tmp.sa_handler = (void (*)(int)) handler; // 指定的信号处理句柄。
    tmp.sa_mask = 0; // 执行时的信号屏蔽码。
    // 该句柄只使用 1 次后就恢复到默认值, 并允许信号在自己的处理句柄中收到。
    tmp.sa_flags = SA_ONESHOT | SA_NOMASK;
    // 保存恢复处理函数指针。
    tmp.sa_restorer = (void (*)(void)) restorer;

    handler = (long) current->sigaction[signum-1].sa_handler;
    current->sigaction[signum-1] = tmp;
    return handler;
}
```

在子进程的程序中，为了体现信号对进程执行状态的影响，我们特意调用了pause()函数。这个函数最终将
导致该进程被设置为“可中断等待状态”。等到该进程接收到信号后，它的状态将由“可中断等待状态”转换
为“就绪态”。执行完signal()函数后，将返回进程的用户空间继续执行，调用pause()函数。这个函数会
映射到系统调用函数sys_pause()中。子进程暂时挂起，父进程执行,父进程就会给子进程发送信号，然后
切换到子进程去执行。父进程会先执行"kill(2, SIGUSR1)"这一行代码，其中kill是个库函数，最终会映射
到sys_kill函数中去执行，给子进程发送SIGUSR1信号，执行代码如下：

path: kernel/exit.c
```
// 向指定任务(*p) 发送信号(sig),权限为 priv。
// 参数: sig - 信号值; p - 指定任务的指针;
//       priv - 强制发送信号的标志。即不需要考虑进程用户属性或级别而能发送信号的权利。
// 该函数首先在判断参数的正确性,然后判断条件是否满足。如果满足就向指定进程发送信号 sig
// 并退出,否则返回未许可错误号。
static inline int send_sig(long sig,struct task_struct * p,int priv)
{
    if (!p || sig<1 || sig>32) // 若信号不正确或任务指针为空则出错退出
        return -EINVAL;
    // 如果强制发送标志置位,或者当前进程的有效用户标识符(euid)就是指定进程的euid(也即是自己),
    // 或者当前进程是超级用户,则在进程位图中添加该信号,否则出错退出。
    // 其中 suser()定义为(current->euid==0),用于判断是否是超级用户。
    if (priv || (current->euid==p->euid) || suser())
        p->signal |= (1<<(sig-1));  // SIGUSR1这已信号对应的位置1
    else
        return -EPERM;
    return 0;
}

/*
* 为了向进程组等发送信号,XXX 需要检查许可。kill()的许可机制非常巧妙!
* /
// 系统调用 kill()可用于向任何进程或进程组发送任何信号,而并非只是杀死进程☺。
// 参数 pid 是进程号; sig 是需要发送的信号。
int sys_kill(int pid,int sig)
{
    struct task_struct **p = NR_TASKS + task;
    int err, retval = 0;

    // 若pid等于0,表明当前进程是进程组组长,因此需要向所有组内的进程强制发送信号sig。
    if (!pid) { // 如果 pid=0,那么信号就会被发送给当前进程的进程组中的所有进程。
        while (--p > &FIRST_TASK) {
            if (*p && (*p)->pgrp == current->pid)
                if (err=send_sig(sig,*p,1))
                    retval = err;
        }
    } else if (pid>0) { // 如果 pid 值>0,则信号被发送给进程号是 pid 的进程。
        while (--p > &FIRST_TASK) {
            if (*p && (*p)->pid == pid)
                if (err=send_sig(sig,*p,0))
                    retval = err;
        }
    } else if (pid == -1) { // 如果 pid=-1,则信号sig就会发送给除第一个进程外的所有进程。
        while (--p > &FIRST_TASK)
            if (err = send_sig(sig,*p,0))
                retval = err;
            else while (--p > &FIRST_TASK)
                     if (*p && (*p)->pgrp == -pid)
                         if (err = send_sig(sig,*p,0))
                             retval = err;
    }
    return retval;
}
```

父进程将SIGUSR1信号发送给子进程之后，就返回父进程用户进程空间内继续执行，最终执行进程切换，
schedule()函数开始执行。对应代码如下：

path: kernel/sched.c
```
void schedule(void)
{
    int i,next,c;
    struct task_struct ** p;

    /* check alarm, wake up any interruptible tasks that have
     * got a signal
     */
    for(p = &LAST_TASK ; p > &FIRST_TASK ; --p)
        if (*p) {
            if ((*p)->alarm && (*p)->alarm < jiffies) {
                    (*p)->signal |= (1<<(SIGALRM-1));
                    (*p)->alarm = 0;
                }
            // 遍历到子进程(进程2后)，检测其接收的信号,并且子进程还是可中断等待状态，
            // 将其设置为就绪态.
            if (((*p)->signal & ~(_BLOCKABLE & (*p)->blocked)) &&
            (*p)->state==TASK_INTERRUPTIBLE)
                (*p)->state=TASK_RUNNING;
        }

    /* this is the scheduler proper: */
    // 第二次遍历的时候，就会发现子进程处于就绪态，然后切换到子进程去执行.
    while (1) {
        c = -1;
        next = 0;
        i = NR_TASKS;
        p = &task[NR_TASKS];
        while (--i) {
            if (!*--p)
                continue;
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

子进程开始执行后，会继续在for循环中执行pause()函数。由于这个函数最终会映射到sys_pause()这个系统
调用函数中去执行，所以当系统调用返回时，就一定会执行到ret_from_sys_call:标号处，并最终调用
do_signal()函数，开始着手处理子进程的信号。执行代码如下：

path: kernel/system_call.s
```
...
# 以下这段代码执行从系统调用sys_pause()函数返回后,对信号量进行识别处理
ret_from_sys_call:
    # 首先判别当前任务是否是初始任务 task0,如果是则不必对其进行信号量方面的处理,直接返回。
    # task对应 C 程序中的task[]数组,直接引用 task 相当于引用 task[0]。
    movl current,%eax        # task[0] cannot have signals
    cmpl task,%eax
    je 3f
    # 通过对原调用程序代码选择符的检查来判断调用程序是否是内核任务, 如果是则直接退出中断。
    # 否则对于普通进程则需进行信号量的处理。这里比较选择符是否为普通用户代码段的选择符
    # 0x000f (RPL=3,局部表,第 1 个段(代码段)),如果不是则跳转退出中断程序。
    cmpw $0x0f,CS(%esp)        # was old code segment supervisor ?
    jne 3f
    # 如果原堆栈段选择符不为 0x17(也即原堆栈不在用户数据段中),则也退出。
    cmpw $0x17,OLDSS(%esp)        # was stack segment = 0x17 ?
    jne 3f
    # 下面这段代码的用途是首先取当前任务结构中的信号位图(32 位,每位代表 1 种信号),
    # 然后用任务结构中的信号阻塞(屏蔽)码,阻塞不允许的信号位,取得数值最小的信号值,再把
    # 原信号位图中该信号对应的位复位(置 0),最后将该信号值作为参数之一调用 do_signal()。
    movl signal(%eax),%ebx  # 取信号位图 ebx,每 1 位代表 1 种信号,共 32 个信号。
    movl blocked(%eax),%ecx # 取阻塞(屏蔽)信号位图 ecx。
    notl %ecx               # 每位取反。
    andl %ebx,%ecx          # 获得许可的信号位图。
    # 从低位(位 0)开始扫描位图,看是否有 1 的位,若有,则ecx保留该位的偏移值(即第几位 0-31)。
    bsfl %ecx,%ecx
    # 如果没有信号则向前跳转退出
    je 3f
    # 复位该信号(ebx 含有原 signal 位图)。
    btrl %ecx,%ebx
    # 重新保存 signal 位图信息 current->signal。
    movl %ebx,signal(%eax)
    # 将信号调整为从 1 开始的数(1-32)。
    incl %ecx
    # 信号值入栈作为调用 do_signal 的参数之一。
    pushl %ecx # 调用 C 函数信号处理程序
    call do_signal # 弹出信号值。
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

接下来内核程序调用do_signal来处理发送给子进程的信号,具体实现如下所示:

```
// 系统调用中断处理程序中真正的信号处理程序, 该段代码的主要作用是将信号的处理句柄插入到
// 用户程序堆栈中,并在本系统调用结束返回后立刻执行信号句柄程序,然后继续执行用户的程序。
void do_signal(long signr,long eax, long ebx, long ecx, long edx,
               long fs, long es, long ds,
               long eip, long cs, long eflags,
               unsigned long * esp, long ss)
{
    unsigned long sa_handler;
    long old_eip=eip;
    struct sigaction * sa = current->sigaction + signr - 1;
    int longs;
    unsigned long * tmp_esp;

    // 如果信号句柄为 SIG_IGN(忽略),则返回; 如果句柄为 SIG_DFL(默认处理),则如果信号是
    // SIGCHLD 则返回,否则终止进程的执行
    sa_handler = (unsigned long) sa->sa_handler;
    if (sa_handler==1)
        return;
    if (!sa_handler) {
        if (signr==SIGCHLD)
            return;
        else
            do_exit(1<<(signr-1));
    }
    // 如果该信号句柄只需使用一次,则将该句柄置空(该信号句柄已经保存在 sa_handler 指针中)。
    if (sa->sa_flags & SA_ONESHOT)
        sa->sa_handler = NULL;
    // 下面这段代码将信号处理句柄插入到用户堆栈中,同时也将sa_restorer,signr,进程屏蔽码(如果
    // SA_NOMASK 没置位),eax,ecx,edx 作为参数以及原调用系统调用的程序返回指针及标志寄存器值
    // 压入堆栈。因此在本次系统调用中断(0x80)返回用户程序时会首先执行用户的信号句柄程序,然后
    // 再继续执行用户程序。
    // 将用户调用系统调用的代码指针 eip 指向该信号处理句柄。
    *(&eip) = sa_handler;
    // 如果允许信号自己的处理句柄收到信号自己,则也需要将进程的阻塞码压入堆栈。
    // 注意,这里 longs 的结果应该选择(7*4):(8*4),因为堆栈是以 4 字节为单位操作的。
    longs = (sa->sa_flags & SA_NOMASK)?7:8;
    // 将原调用程序的用户堆栈指针向下扩展 7(或 8)个长字(用来存放调用信号句柄的参数等),
    // 并检查内存使用情况(例如如果内存超界则分配新页等)。
    *(&esp) -= longs;
    verify_area(esp,longs*4);
    // 在用户堆栈中从下到上存放 sa_restorer, 信号signr, 屏蔽码blocked(如果 SA_NOMASK 置位),
    // eax, ecx, edx, eflags 和用户程序原代码指针。
    tmp_esp=esp;
    put_fs_long((long) sa->sa_restorer,tmp_esp++);
    put_fs_long(signr,tmp_esp++);
    if (!(sa->sa_flags & SA_NOMASK))
        put_fs_long(current->blocked,tmp_esp++);
    put_fs_long(eax,tmp_esp++);
    put_fs_long(ecx,tmp_esp++);
    put_fs_long(edx,tmp_esp++);
    put_fs_long(eflags,tmp_esp++);
    put_fs_long(old_eip,tmp_esp++);
    current->blocked |= sa->sa_mask; // 进程阻塞码(屏蔽码)添上 sa_mask 中的码位。
}
```

do_signal() 函数是内核系统调用 (int 0x80) 中断处理程序中对信号的预处理程序。在进程每次调用
系统调用时,若该进程已收到信号,则该函数就会把信号的处理句柄(即对应的信号处理函数)插入到用户
程序堆栈中。这样,在当前系统调用结束返回后就会立刻执行信号句柄程序,然后再继续执行用户的程序,
如下图所示：

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/call_do_signal.png

在do_signal()函数把信号处理程序的参数插入到用户堆栈中之前,首先会把在用户程序堆栈指针向下扩展
longs 个长字,然后将相关的参数添入其中,参见下图所示：

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/modify_usr_stack.png

在用户程序调用系统调用刚进入内核时,该进程的内核态堆栈上会由 CPU 自动压入如上图所示的内容,
也即: 用户程序的SS和ESP以及用户程序中下一条指令的执行点位置CS和EIP。
在处理完此次指定的系统调用功能并准备调用do_signal()时,内核态堆栈中的内容见下图中左边所示。
因此 do_signal() 的参数即是这些在内核态堆栈上的内容。

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/modify_usr_stack_specific.png

在处理完两个默认信号句柄(SIG_IGN和SIG_DFL )之后,若用户自定义了信号处理程序(信号句柄sa_handler),
则do_signal()开始准备把用户自定义的句柄插入用户态堆栈中。它首先把内核态堆栈中原用户程序的返回
执行点指针eip保存为 old_eip ,然后将该eip替换成指向自定义句柄sa_handler ,也即让图中内核态堆栈中的
eip指向 sa_handler 。接下来通过把内核态中保存的“原 esp ”减去longs值,把用户态堆栈向下扩展了7或8个
长字空间。最后把内核堆栈上的一些寄存器内容复制到了这个空间中,见图中右边所示。
总共往用户态堆栈上放置了7到8个值,我们现在来说明这些值的含义以及放置这些值的原因:
* old_eip即是原用户程序的返回地址,是在内核堆栈上eip被替换成信号句柄地址之前保留下来的。
* eflags, edx和ecx是原用户程序在调用系统调用之前的值,基本上也是调用系统调用的参数,在系统调用返回
  后仍然需要恢复这些用户程序的寄存器值。
* eax中保存有系统调用的返回值。
* 如果所处理的信号还允许收到本身,则堆栈上还存放有该进程的阻塞码blocked。
* 下一个是信号signr值。最后一个是信号活动恢复函数的指针sa_restorer。
* 这个恢复函数不是由用户设定的,因为在用户定义signal()函数时只提供了一个信号值signr和
  一个信号处理句柄 handler 。

前面已经将信号处理函数sig_usr与子进程进行了绑定，因此系统调用返回后，就会到子进程的sig_usr函数
处执行，处理信号，函数执行结束后，会执行“ret”指令。ret的本质就是用当时保存在栈中的EIP的值来
恢复EIP寄存器，跳转到EIP指向的地址位置去执行。于是此时处于栈顶的sa->sa_restorer所代表的函数地址
值就发挥作用了，此时就应该跳转到sa->sa_restorer所代表的函数地址值位置去执行了。restorer是一个
库函数的地址，它是由signal这个库函数传递下来的实参。这个库函数将来会在信号处理工作结束后恢复
用户进程执行的“指令和数据”，并最终跳转到用户程序的“中断位置”处执行。现在信号已经处理完了，
restorer函数开始工作。我们先来看一下这个函数的代码：

```
.globl ____sig_restore
.globl ____masksig_restore
# 若没有 blocked 则使用这个 restorer 函数
____sig_restore:
    addl $4,%esp # 丢弃信号值 signr
    popl %eax # 恢复系统调用返回值。
    popl %ecx # 恢复原用户程序寄存器值。
    popl %edx
    popfl # 恢复用户程序时的标志寄存器。
    ret

# 若有 blocked 则使用下面这个 retorer 函数,blocked 供 ssetmask 使用。
____masksig_restore:
    addl $4,%esp # 丢弃信号值 signr
    call ____ssetmask # 设置信号屏蔽码 old blocking
    addl $4,%esp # 丢弃 blocked 值。
    popl %eax
    popl %ecx
    popl %edx
    popfl
    ret
```

该函数的主要作用是为了在信号处理程序结束后,恢复用户程序执行系统调用后的返回值和一些寄
存器内容,并清除作为信号处理程序参数的信号值 signr 。在编译连接用户自定义的信号处理程序时,编
译程序会把这个函数插入到用户程序中。由该函数负责清理在信号处理程序执行完后恢复用户程序的寄
存器值和系统调用返回值,就好象没有运行过信号处理程序,而是直接从系统调用中返回的。

注意看restorer函数最后一行汇编“ret”。由于ret的本质就是用当前栈顶的值设置EIP，并使程序跳转到
EIP指向的位置去执行，很显然，经过一系列清栈操作后，当前栈顶的数值就是
“put_fs_long（old_eip,tmp_esp + +）”这行代码设置的。这个old_eip就是pause()函数为了映射到
sys_pause()函数，产生软中断int 0x80的下一行代码，即子进程的“中断位置”。所以，ret执行后，
信号就处理完毕，并最终回到pause()函数中去继续执行。
这就是Linux 0.11中信号处理的全部过程。