do_fork
========================================

path: kernel/kernel/fork.c
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
        struct task_struct *p;
        int trace = 0;
        long nr;

        ......

        /* copy_process()复制进程描述符,该函数返回刚创建的task_struct描述符的地址. */
        p = copy_process(clone_flags, stack_start, regs, stack_size,
                         child_tidptr, NULL, trace);
        ......
}
```

#### copy_process

path: kernel/kernel/fork.c
```
/*
 * This creates a new process as a copy of the old one,
 * but does not actually start it yet.
 *
 * It copies the registers, and all the appropriate
 * parts of the process environment (as per the clone
 * flags). The actual kick-off is left to the caller.
 */
static struct task_struct *copy_process(unsigned long clone_flags,
    unsigned long stack_start,
    struct pt_regs *regs,
    unsigned long stack_size,
    int __user *child_tidptr,
    struct pid *pid,
    int trace)
{
        int retval;
        struct task_struct *p;
        int cgroup_callbacks_done = 0;

        /* 1. 检查clone_flags是否合法 */

        /* 2. 通过调用security_task_create(clone_flags)函数以及稍后的security_task_alloc(p)
         * 函数执行所有附加的安全检查.
         */
         retval = security_task_create(clone_flags);

        /* 3. 调用dup_task_struct为子进程获取进程描述符.
         */
         p = dup_task_struct(current);

        /* 4.得到的进程与父进程内容几乎完全一致，初始化新创建进程 */
        ......
        retval = -EAGAIN;
        if (atomic_read(&p->real_cred->user->processes) >=
           task_rlimit(p, RLIMIT_NPROC)) {
           if (!capable(CAP_SYS_ADMIN) && !capable(CAP_SYS_RESOURCE) &&
               p->real_cred->user != INIT_USER)
                    goto bad_fork_free;
        }
        current->flags &= ~PF_NPROC_EXCEEDED;
        /* 为新建的进程拷贝credentials */
        retval = copy_creds(p, clone_flags);
        if (retval < 0)
            goto bad_fork_free;

        return p;

        ......
}
```

当进程由于中断或系统调用从用户态转换到内核态时,进程所使用的栈也要从用户栈切换到内核栈.
通过内核栈获取栈尾thread_info,就可以获取当前进程描述符task_struct.每个进程的thread_info结构在
它的内核栈的尾端分配.

dup_task_struct的实现如下所示:

#### dup_task_struct

path: kernel/kernel/fork.c
```
static struct task_struct *dup_task_struct(struct task_struct *orig)
{
    struct task_struct *tsk;
    struct thread_info *ti;
    unsigned long *stackend;
    int node = tsk_fork_get_node(orig);
    int err;

    prepare_to_copy(orig);

    /* 1.执行alloc_task_struct_node()宏,为新进程获取进程描述符,并将描述符地址保存在tsk局部变量中.
     */
     tsk = alloc_task_struct_node(node);
     if (!tsk)
        return NULL;

    /* 2.执行alloc_thread_info_node宏以获取一块空闲内存区,用来存放新进程的thread_info结构和
     * 内核栈,并将这些块内存区字段的地址存在局部变量ti中.这块内存区的大小是8KB或4KB.
     */
     ti = alloc_thread_info_node(tsk, node);
     if (!ti) {
        free_task_struct(tsk);
        return NULL;
     }

    /* 3.将current进程描述符的内容复制到tsk所指向的task_struct结构中,然后把tsk->stack置为ti. */
     err = arch_dup_task_struct(tsk, orig);
     if (err)
        goto out;
     tsk->stack = ti;

    /* 4.把current进程的thread_info描述符的内容复制到ti中,然后把ti->task置为tsk.
     * 意味着子进程和父进程共享内核堆栈.
     */
     setup_thread_stack(tsk, orig);

     clear_user_return_notifier(tsk);
     clear_tsk_need_resched(tsk);
     stackend = end_of_stack(tsk);
     *stackend = STACK_END_MAGIC;    /* for overflow detection */

#ifdef CONFIG_CC_STACKPROTECTOR
     tsk->stack_canary = get_random_int();
#endif

    /*
     * One for us, one for whoever does the "release_task()" (usually
     * parent)
     */
    /* 5.把新进程描述符使用计数器(tsk->usage)置为2, 用来表示进程描述符正在被使用而且其
     * 相应的进程状态处于活动状态(进程状态既不是EXIT_ZOMBIE,也不是EXIT_DEAD).
     */
     atomic_set(&tsk->usage, 2);
#ifdef CONFIG_BLK_DEV_IO_TRACE
   tsk->btrace_seq = 0;
#endif
    tsk->splice_pipe = NULL;

    account_kernel_stack(ti, 1);

    return tsk;  /* 返回进程描述符 */

out:
    free_thread_info(ti);
    free_task_struct(tsk);
    return NULL;
}
```

#### copy_creds

https://github.com/leeminghao/doc-linux/blob/master/security/credentials/Credentials.md

**内核线程**: 内核线程(kernel_thread)或叫守护进程(daemon).在操作系统中占据相当大的比例,当Linux操作系统启动以后,
可以用”ps -ef”命令查看系统中的进程,这时会发现很多以"d"结尾的进程名,确切说名称显示里面加"[]"的,这些进程就是内核线程.
系统的启动是从硬件->内核->用户态进程的,pid的分配是一个往前的循环的过程,所以随系统启动的内核线程的pid往往很小.
内核线程与普通进程的区别:
* 内核线程只运行在内核态,而普通进程既可以运行在内核态也可以运行在用户态.
* 因为内核线程只运行在内核态,它们只能使用大于PAGE_OFFSET的线性地址空间.另一方面,不管在用户态还是内核态.普通进程都可以
  用4GB线性地址空间.

## 总结:

#### 父进程创建了一个子进程之后,父进程和子进程相同部分如下:

* 实际用户ID, 实际组ID, 有效用户ID, 有效组ID
* 附加组ID
* 进程组ID
* 会话ID
* 控制终端
* 设置用户ID标志和设置组ID标志
* 当前工作目录
* 根目录
* 文件模式创建屏蔽字
* 信号屏蔽和安排
* 针对任一打开文件描述符在执行时关闭(clone-on-exec)标志
* 环境
* 连接的共享存储段
* 存储映射
* 资源限制

_注意_: Linux内核中的如下几个概念

* 进程组

```
Shell 上的一条命令行形成一个进程组
每个进程属于一个进程组
每个进程组有一个领头进程
进程组的生命周期到组中最后一个进程终止, 或加入其他进程组为止
getpgrp: 获得进程组 id, 即领头进程的 pid
setpgid: 加入进程组和建立新的进程组
前台进程组和后台进程组

#include <unistd.h>

int setpgid (pid_t pid, pid_t pgid);
pid_t getpgid (pid_t pid);
int setpgrp (void);
pid_t getpgrp (void);

进程只能将自身和其子进程设置为进程组 id.
某个子进程调用exec函数之后, 就不能再将该子进程的id作为进程组 id.
```

* 会话

```
一次登录形成一个会话
一个会话可包含多个进程组, 但只能有一个前台进程组.
setsid 可建立一个新的会话

#include <unistd.h>

pid_t setsid(void);

如果调用进程不是进程组的领头进程, 该函数才能建立新的会话.
调用setsid之后, 进程成为新会话的领头进程.
进程成为新进程组的领头进程.
进程失去控制终端
```

* 控制终端

```
会话的领头进程打开一个终端之后, 该终端就成为该会话的控制终端 (SVR4/Linux)
与控制终端建立连接的会话领头进程称为控制进程 (session leader)
一个会话只能有一个控制终端
产生在控制终端上的输入和信号将发送给会话的前台进程组中的所有进程
终端上的连接断开时 (比如网络断开或 Modem 断开), 挂起信号将发送到控制进程(session leader)
```

#### 父进程和子进程之间的区别:
* fork的返回值
* 进程ID不同
* 两个进程具有不同进程ID.
* 子进程的tms_utime, tms_stime, tms_cutime和tms_ustime均被设置为0
* 父进程设置的文件锁不会被子进程继承
* 子进程的为处理闹钟(alarm)被清除
* 子进程为处理信号集设置为空集
