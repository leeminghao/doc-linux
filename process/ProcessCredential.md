Linux Process Credential
================================================================================

进程凭证(Process Credentials)
--------------------------------------------------------------------------------

凭证把进程与一个特定的用户和用户组捆绑在一起.凭证在多用户系统上尤为重要,因为信任状可以决定每个进程能做什么,不能做什么.
credential的使用既要在进程相关的数据结构方面给予支持,也需要在被保护的资源方面给予支持.文件就是一种显而易见的资源.
当某个进程试图访问一个文件时,VFS总是根据文件的拥有者和进程的credential所建立的许可权来检查访问的合法性.

## 进程凭证描述符(struct cred)

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
	atomic_t	usage;
#ifdef CONFIG_DEBUG_CREDENTIALS
	atomic_t	subscribers;	/* number of processes subscribed */
	void		*put_addr;
	unsigned	magic;
#define CRED_MAGIC	0x43736564
#define CRED_MAGIC_DEAD	0x44656144
#endif
        /* 用户和组的实际ID, 标识我们究竟是谁(登录用户的uid和gid). */
	uid_t		uid;		/* real UID of the task */
	gid_t		gid;		/* real GID of the task */
       /* 用户和组保存的ID,由exec函数保存. */
	uid_t		suid;		/* saved UID of the task */
	gid_t		sgid;		/* saved GID of the task */
        /* 用户和组的有效ID, 用于除了对资源(文件)访问以外的所有操作. */
	uid_t		euid;		/* effective UID of the task */
	gid_t		egid;		/* effective GID of the task */
        /* 文件访问的用户和组的有效ID,进程用来决定对资源(文件)的访问权限. */
	uid_t		fsuid;		/* UID for VFS ops */
	gid_t		fsgid;		/* GID for VFS ops */
	unsigned	securebits;	/* SUID-less security management */


	kernel_cap_t	cap_inheritable; /* caps our children can inherit */
	kernel_cap_t	cap_permitted;	/* caps we're permitted */
	kernel_cap_t	cap_effective;	/* caps we can actually use */
	kernel_cap_t	cap_bset;	/* capability bounding set */

#ifdef CONFIG_KEYS
	unsigned char	jit_keyring;	/* default keyring to attach requested
					 * keys to */
	struct key	*thread_keyring; /* keyring private to this thread */
	struct key	*request_key_auth; /* assumed request_key authority */
	struct thread_group_cred *tgcred; /* thread-group shared credentials */
#endif

#ifdef CONFIG_SECURITY
	void		*security;	/* subjective LSM security */
#endif

	struct user_struct *user;	/* real user ID subscription */
	struct user_namespace *user_ns; /* cached user->user_ns */
	struct group_info *group_info;	/* supplementary groups for euid/fsgid */
	struct rcu_head	rcu;		/* RCU deletion hook */
};
```

## idle进程的credential初始化

idle进程是linux中的第一个进程,其进程credential是由内核开发者手动设置的,
idle进程的credential初始化是通过宏RCU_INIT_POINTER来实现的,其声明如下:

路径: include/linux/rcupdate.h

```
/* 将init_cred的地址赋值给real_cred和cred指针 */
#define RCU_INIT_POINTER(p, v) \
		p = (typeof(*v) __force __rcu *)(v)
```

## init_cred的定义

路径: linux/kernel/cred.c

```
/*
 * The initial credentials for the initial task
 */
struct cred init_cred = {
	.usage			= ATOMIC_INIT(4),
#ifdef CONFIG_DEBUG_CREDENTIALS
	.subscribers		= ATOMIC_INIT(2),
	.magic			= CRED_MAGIC,
#endif
	.securebits		= SECUREBITS_DEFAULT,
	.cap_inheritable	= CAP_EMPTY_SET,
	.cap_permitted		= CAP_FULL_SET,
	.cap_effective		= CAP_FULL_SET,
	.cap_bset		= CAP_FULL_SET,
	.user			= INIT_USER,
	.user_ns		= &init_user_ns,
	.group_info		= &init_groups,
#ifdef CONFIG_KEYS
	.tgcred			= &init_tgcred,
#endif
};
```