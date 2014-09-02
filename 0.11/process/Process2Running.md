Linux 0.11 进程2的执行
================================================================================

在进程1创建完进程2之后:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/CreateProcess2.md

接下来轮转到进程2中执行进程2的代码.

进程2的执行
--------------------------------------------------------------------------------

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