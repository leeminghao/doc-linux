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

因为汇编中对应C语言的函数名在前面多加一个下划线“_”（C语言的sys_fork()对应汇编的就是_sys_fork），所以跳转到 _sys_fork处执行.
执行代码如下所示:

path: kernel/system_call.s
```
.align 2
sys_fork:
    call find_empty_process
    testl %eax,%eax
    js 1f
    push %gs
    pushl %esi
    pushl %edi
    pushl %ebp
    pushl %eax
    call copy_process
    addl $20,%esp
1:  ret
```
