Linux 0.11 进程2的创建
================================================================================

在进程1打开标准输入，标准输出，标准出错设备为创建进程2作准备以后:

https://github.com/leeminghao/doc-linux/blob/master/0.11/filesystem/OpenTtyAndDup.md

接下来进程1要创建进程2.

创建进程2
--------------------------------------------------------------------------------

接下来进程1将调用fork函数创建进程2,执行代码如下所示:

path: init/main.c
```
void init(void)
{
    int pid,i;

    setup((void *) &drive_info);
    (void) open("/dev/tty0",O_RDWR,0);
    (void) dup(0);
    (void) dup(0);
    printf("%d buffers = %d bytes buffer space\n\r",NR_BUFFERS,
        NR_BUFFERS*BLOCK_SIZE);
    printf("Free mem: %d bytes\n\r",memory_end-main_memory_start);

    if (!(pid=fork())) { // 括号里面为进程2执行的代码
        close(0);
        if (open("/etc/rc",O_RDONLY,0))
            _exit(1);
        execve("/bin/sh",argv_rc,envp_rc);
        _exit(2);
    }
    if (pid>0)
        while (pid != wait(&i)) // 进程1等待子进程退出，最终会切换到进程2执行.
            /* nothing */;
    ...
}
```

fork函数映射到sys_fork来创建进程2，这个过程跟进程0创建进程1类似:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/CreateProcess1.md

进程2创建完毕后，fork函数返回，返回值为2，因此"!(pid=fork())"的值为假,于是调用wait函数，
该函数的功能是: 如果进程1有等待退出的子进程，就为该进程的退出做善后工作；如果有子进程，但
并不等待退出，则进行进程切换；如果没有子进程，函数返回.
wait函数最终会映射到系统调用函数sys_waitpid中执行.
执行代码如下：

path: kernel/exit.c
```
int sys_waitpid(pid_t pid,unsigned long * stat_addr, int options)
{
    int flag, code;
    struct task_struct ** p;

    verify_area(stat_addr,4);
repeat:
    flag=0;
    // 从任务数组末端开始扫描所有任务,跳过空项,本进程项以及非当前进程的子进程项。
    for(p = &LAST_TASK ; p > &FIRST_TASK ; --p) {

        if (!*p || *p == current) // 跳过空项和本进程项
            continue;
        // 筛选出当前进程(进程1)的子进程此时将会是进程2
        if ((*p)->father != current->pid) // 如果不是当前进程的子进程则跳过
            continue;

        // 此时扫描选择到的进程p肯定是当前进程的子进程。
        // 如果等待的子进程号 pid>0,但与被扫描子进程p的pid不相等,说明它是当前进程另外的子进程,
        // 于是跳过该进程,接着扫描下一个进程。
        if (pid>0) {
            if ((*p)->pid != pid)
                continue;
        // 否则,如果指定等待进程的pid=0,表示正在等待进程组号等于当前进程组号的任何子进程。
        // 如果此时被扫描进程 p 的进程组号与当前进程的组号不等,则跳过。
        } else if (!pid) {
            if ((*p)->pgrp != current->pgrp)
                continue;
        // 否则,如果指定的 pid<-1,表示正在等待进程组号等于pid绝对值的任何子进程。如果此时被扫描
        // 进程p的组号与 pid 的绝对值不等,则跳过。
        } else if (pid != -1) {
            if ((*p)->pgrp != -pid)
                continue;
        }

        // 此时所选择到的进程p正是所等待的子进程, 接下来根据这个子进程p所处的状态来处理。
        // 此时选择到的是进程2，判断进程2的状态并如下处理:
        switch ((*p)->state) {
            // 子进程p处于停止状态时:
            // 如果此时 WUNTRACED 标志没有置位,表示程序无须立刻返回,于是继续扫描处理其它进程。
            // 如果 WUNTRACED 置位,则把状态信息 0x7f 放入*stat_addr,并立刻返回子进程号 pid。
            // 这里 0x7f 表示的返回状态使 WIFSTOPPED()宏为真。
            case TASK_STOPPED:
                if (!(options & WUNTRACED))
                    continue;
                put_fs_long(0x7f,stat_addr);
                return (*p)->pid;
            // 如果子进程 p 处于僵死状态,则首先把它在用户态和内核态运行的时间分别累计到当前进程(父进程)
            // 中,然后取出子进程的 pid 和退出码,并释放该子进程。最后返回子进程的退出码和 pid。
            case TASK_ZOMBIE:
                current->cutime += (*p)->utime;
                current->cstime += (*p)->stime;
                flag = (*p)->pid;
                code = (*p)->exit_code;
                release(*p);
                put_fs_long(code,stat_addr);
                return flag;
            // 如果这个子进程 p 的状态既不是停止也不是僵死,那么就置 flag=1。表示找到过一个
            // 符合要求的子进程,但是它处于运行态或睡眠态。
            default:
                flag=1;
                continue;
        }
    }

    // 在上面对任务数组扫描结束后,如果 flag 被置位,说明有符合等待要求的子进程并没有处于退出或僵死状态。
    if (flag) {
        // 如果此时已设置 WNOHANG 选项(表示若没有子进程处于退出或终止态就立刻返回),就立刻返回 0,退出。
        if (options & WNOHANG)
            return 0;
        // 否则把当前进程置为可中断等待状态并重新执行调度
        current->state=TASK_INTERRUPTIBLE; // 将进程设置为可中断等待状态.
        // 切换到进程2中去执行.
        schedule();
        if (!(current->signal &= ~(1<<(SIGCHLD-1))))
            goto repeat;
        else
            return -EINTR;
    }
    return -ECHILD;
}
```

轮转到进程2执行
--------------------------------------------------------------------------------

接下来轮转到进程2以后，开始执行进程2的代码:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/Process2Running.md