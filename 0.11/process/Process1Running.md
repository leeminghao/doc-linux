Linux 0.11 进程1执行
================================================================================

进程1是由进程0创建的，创建过程如下:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/CreateProcess1.md

创建完进程1还不能立即执行，需要系统调度调度进程1执行，调度过程如下：

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/ProcessSchedule0to1.md

在分析进程1如何开始执行之前，先回顾一下进程0创建进程1的过程。
在调用copy_process函数时曾强调过，当时为进程1设置的tss.eip就是进程0调用fork()
创建进程1时int 0x80中断导致的CPU硬件自动压栈的ss、esp、eflags、cs、eip中的EIP值，
这个值指向的是int 0x80的下一行代码的位置，即if （__res >= 0）.
前面讲述的ljmp 通过CPU的任务门机制自动将进程1的TSS的值恢复给CPU，自然也将其中的tss.eip恢复给CPU。
现在CPU中的EIP指向的就是fork中的if （__res >= 0）这一行，所以，进程1就要从这一行开始执行。

执行代码如下：

path: init/main.c
```
static inline _syscall0(int,fork)
```

syscall0展开之后如下所示:

```
int fork(void)
{
    long __res;
    // int 0x80是所有系统调用函数的总入口，fork()是其中之一
    __asm__ volatile ("int $0x80"
        : "=a" (__res)
        : "0" (__NR_fork));
    // 现在从这行开始执行，copy_process为进程1做的tss.eip就是指向这一行
    // 此时的__res值，就是进程1的TSS中eax的值，这个值被写死为0，即p->tss.eax = 0，
    // 因此，当执行到return （type） __res这一行时，返回值是0
    if (__res >= 0)
        return (int) __res;
    errno= -__res;
    return -1;
}
```

返回后，执行到main()函数中if （!fork( )）这一行，! 0为“真”，调用init()函数！

执行代码如下：

path: init/main.c
```
void main(void)
{
    ......
    if (!fork()) {        /* we count on this going ok */ // !0为真
        init();  // 跳转到进程1执行
    }
    ......
}
```

进入init()函数后，先调用setup()函数，执行代码如下：

path: init/main.c
```
...
static inline _syscall1(int,setup,void *,BIOS)
...
void init(void)
{
    ......
    setup((void *) &drive_info); // drive_info就是硬盘参数表
    ......
}
```

这个函数的调用与fork()、pause()函数的调用类似,略有区别的是setup()函数不是通过_syscall0()
而是通过_syscall1( )实现的；具体的实现过程基本类似，也是通过:

**int 0x80** --> **_system_call** --> **call _sys_call_table(,%eax,4) --> **sys_setup()**

提醒: 前面pause()函数的那个int 0x80中断还没有返回，现在setup()又产生了一个中断.

setup函数主要是进程1为安装硬盘文件系统做准备:

https://github.com/leeminghao/doc-linux/blob/master/0.11/filesystem/InstallDiskFs.md