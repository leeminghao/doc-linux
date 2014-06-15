Linux Process Credential
================================================================================

进程凭证(Process Credentials)
--------------------------------------------------------------------------------

凭证把进程与一个特定的用户和用户组捆绑在一起.凭证在多用户系统上尤为重要,因为信任状可以决定每个进程能做什么,不能做什么.
credential的使用既要在进程相关的数据结构方面给予支持,也需要在被保护的资源方面给予支持.文件就是一种显而易见的资源.
当某个进程试图访问一个文件时,VFS总是根据文件的拥有者和进程的credential所建立的许可权来检查访问的合法性.

## DAC进程凭证

* DAC的核心思想: 进程理论上拥有的权限与执行它的用户的权限相同.
* 数据结构:
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

    unsigned securebits;       /* SUID-less security management */
    ......
    struct user_struct *user;  /* real user ID subscription */
    ......
    struct group_info *group_info;  /* supplementary groups for euid/fsgid */
};
```

  通常,有效用户ID等于实际用户ID,有效组ID等于实际组ID.
  每一个文件都有一个所有者和组所有者,所有者由stat结构中的st_uid成员表示,组所有者由st_gid成员表示.
  当执行一个程序时,进程的有效用户ID通常就是实际用户ID,有效组ID通常是实际组ID.但是可以在文件模式字
(st_mode)中设置一个特殊标志，其含义是"当执行此文件时，将进程的有效用户ID设置为文件所有者的用户ID
(st_uid)".与此同时在文件模式中可以设置另一位，它使得将执行此文件的进程的有效组ID设置为文件的组所有
者ID(st_gid), 文件模式中的这两位被称为设置用户ID(set-user-id)位和设置组ID(set-group-ID)位.

* 修改规则:
当一个进程被创建时,总是继承父进程的凭证.不过,这些凭证以后可以被修改,这发生在当进程开始
执行一个新的程序时,或者当前进程发出合适的系统调用时.通常情况下,进程的uid,euid,fsuid及suid字段具有
相同的值.可以用setuid函数设置实际用户ID和有效用户ID.注意,我们并不能想怎么设就怎么设,有若干规则需要我们遵守:

```
(1).只有root用户进程可以改变实际用户ID. 通常,实际用户ID是在用户登录时,由login(1)程序设置的,而且永远不会改变.
(2).仅当程序文件设置了(set-user-id)位时,exec函数才会设置有效用户ID.如果(set-user-id)位没有设置,则
exec函数不会改变有效用户ID,而将其维持为原先值. 任何时候都可以调用setuid,将有效用户ID设置为实际用
户ID或保存的设置用户ID. 自然,不能将有效用户ID设置为任意随机值.
(3).保存的设置用户ID是由exec复制有效用户ID而得来的.如果设置了文件的(set-user-id)位,则在exec根据文
件的用户ID设置了进程的有效用户ID以后，就将这个副本保存起来.
```

## MAC进程凭证

* 核心思想:何进程想在Linux系统中做任何事情,都必须先在安全策略配置文件中赋予权限,凡是没有出现在安全策略配置文件中的权限,进程就没有该权限.
* 数据结构:
路径: include/linux/cred.h
```
struct cred {
    ......
#ifdef CONFIG_SECURITY
   void *security; /* subjective LSM security */
#endif
    ......
};
```
