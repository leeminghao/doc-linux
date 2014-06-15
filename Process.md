Linux Process
================================================================================

基本概念
--------------------------------------------------------------------------------
进程: 程序执行的一个实例,目的就是担当分配系统资源(CPU时间,内存,文件等)的实体.

进程描述符
--------------------------------------------------------------------------------

为了管理进程,内核必须对每个进程所做的事情进行清楚的描述.例如:
进程优先级; 给它分配了什么地址空间; 允许它访问哪个文件等等.

路径: include/linux/sched.h
```
struct task_struct {
    volatile long state;    /* -1 unrunnable, 0 runnable, >0 stopped */

    void *stack;            // ==> "thread_info": 进程的基本信息.
    atomic_t usage;
    unsigned int flags;     /* per process flags, defined below */

    ......

    /* process credentials */  ==> 进程凭证
    /* objective and real subjective task credentials (COW) */
    const struct cred __rcu *real_cred;
    /* effective (overridable) subjective task credentials (COW) */
    const struct cred __rcu *cred;

    ......

    struct tty_struct *tty; /* NULL if no tty */ ==> "tty_struct": 与进程相关的tty

    ......

    struct mm_struct *mm, *active_mm; // ==> "mm_struct": 指向内存区描述符的指针.

    ......

    /* filesystem information */
    struct fs_struct *fs;  // ==> "fs_struct": 文件系统信息
    /* open file information */
    struct files_struct *files;  // ==> "files_struct": 所有打开文件的信息

    ......

    /* signal handlers */
    struct signal_struct *signal; // ==> "signal_struct": 所接收的信号

    ......
};
```

## 进程凭证(Process Credentials)

凭证把进程与一个特定的用户和用户组捆绑在一起.凭证在多用户系统上尤为重要,因为信任状可以决定每个进程能做什么,不能做什么.
credential的使用既要在进程相关的数据结构方面给予支持,也需要在被保护的资源方面给予支持.文件就是一种显而易见的资源.
当某个进程试图访问一个文件时,VFS总是根据文件的拥有者和进程的credential所建立的许可权来检查访问的合法性.

路径: include/linux/cred.h

```
/*
 * The security context of a task
 *
 * The parts of the context break down into two categories:
 *
 *  (1) The objective context of a task.  These parts are used when some other
 *  task is attempting to affect this one.
 *
 *  (2) The subjective context.  These details are used when the task is acting
 *  upon another object, be that a file, a task, a key or whatever.
 *
 * Note that some members of this structure belong to both categories - the
 * LSM security pointer for instance.
 *
 * A task has two security pointers.  task->real_cred points to the objective
 * context that defines that task's actual details.  The objective part of this
 * context is used whenever that task is acted upon.
 *
 * task->cred points to the subjective context that defines the details of how
 * that task is going to act upon another object.  This may be overridden
 * temporarily to point to another security context, but normally points to the
 * same context as task->real_cred.
 */
struct cred {
    atomic_t usage;

    ......

    /* 用户和组的实际ID, 标识我们究竟是谁(登录用户的uid和gid). */
    uid_t uid;    /* real UID of the task */
    gid_t gid;    /* real GID of the task */

    /* 用户和组保存的ID,由exec函数保存.在执行一个程序时包含了 */
    uid_t suid;   /* saved UID of the task */
    gid_t sgid;   /* saved GID of the task */

    /* 用户和组的有效ID, 用于除了对资源(文件)访问以外的所有操作. */
    uid_t euid;   /* effective UID of the task */
    gid_t egid;   /* effective GID of the task */

    /* 文件访问的用户和组的有效ID,进程用来决定对资源(文件)的访问权限. */
    uid_t fsuid;  /* UID for VFS ops */
    gid_t fsgid;  /* GID for VFS ops */

    unsigned securebits; /* SUID-less security management */

    ......

#ifdef CONFIG_SECURITY
   void *security; /* subjective LSM security */
#endif

    ......
};
```