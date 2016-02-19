进程id号
========================================

UNIX进程总是会分配一个号码用于在其命名空间中唯一地标识它们。该号码被称作进程ID号，简称PID。
用fork或clone产生的每个进程都由内核自动地分配了一个新的唯一的PID值。

进程ID
----------------------------------------

但每个进程除了PID这个特征值之外，还有其他的ID。有下列几种可能的类型:

* 处于某个线程组（在一个进程中，以标志CLONE_THREAD来调用clone建立的该进程的不同的执行上下文）中的
所有进程都有统一的线程组ID（TGID）。如果进程没有使用线程，则其PID和TGID相同。线程组中的主进程被
称作组长（group leader）。通过clone创建的所有线程的task_struct的group_leader成员，会指向组长的
task_struct实例.

* 另外，独立进程可以合并成进程组（使用setpgrp系统调用）。进程组成员的task_struct的pgrp属性值
都是相同的，即进程组组长的PID。进程组简化了向组的所有成员发送信号的操作，这对于各种系统程序设计
应用是有用的。请注意，用管道连接的进程包含在同一个进程组中。

* 几个进程组可以合并成一个会话。会话中的所有进程都有同样的会话ID，保存在task_struct的session成员中。
SID可以使用setsid系统调用设置。

命名空间增加了PID管理的复杂性。回想一下，PID命名空间按层次组织。在建立一个新的命名空间时，
该命名空间中的所有PID对父命名空间都是可见的，但子命名空间无法看到父命名空间的PID。但这意味着
某些进程具有多个PID，凡可以看到该进程的命名空间，都会为其分配一个PID。这必须反映在数据结构中。
我们必须区分局部ID和全局ID。

* 全局ID是在内核本身和初始命名空间中的唯一ID号，在系统启动期间开始的init进程即属于初始命名空间。
对每个ID类型，都有一个给定的全局ID，保证在整个系统中是唯一的。

* 局部ID属于某个特定的命名空间，不具备全局有效性。对每个ID类型，它们在所属的命名空间内部有效，
但类型相同、值也相同的ID可能出现在不同的命名空间中。全局PID和TGID直接保存在task_struct中，
分别是task_struct的pid和tgid成员：

```
    pid_t pid;
    pid_t tgid;
```

这两项都是pid_t类型，该类型定义为__kernel_pid_t，后者由各个体系结构分别定义。通常定义为int，
即可以同时使用232个不同的ID。会话和进程组ID不是直接包含在task_struct本身中，但保存在用于信号
处理的结构中。task_struct->signal->__ses-sion表示全局SID，而全局PGID则保存在
task_struct->signal->__pgrp。辅助函数set_task_session和set_task_pgrp可用于修改这些值。

管理PID
----------------------------------------

除了这两个字段之外，内核还需要找一个办法来管理所有命名空间内部的局部量，以及其他ID（如TID和SID）。
这需要几个相互连接的数据结构，以及许多辅助函数，在必要的情况下，我会明确地说明ID类型
（例如，TGID，即线程组ID）。一个小型的子系统称之为PID分配器（pid allocator）用于加速新ID的分配。
此外，内核需要提供辅助函数，以实现通过ID及其类型查找进程的task_struct的功能，以及将ID的内核表示
形式和用户空间可见的数值进行转换的功能。

在介绍表示ID本身所需的数据结构之前，我需要讨论PID命名空间的表示方式。我们所需查看的代码如下所示：

path: include/linux/pid_namespace.h
```
struct pid_namespace {
	struct kref kref;
	struct pidmap pidmap[PIDMAP_ENTRIES];
	struct rcu_head rcu;
	int last_pid;
	unsigned int nr_hashed;
	struct task_struct *child_reaper;
	struct kmem_cache *pid_cachep;
	unsigned int level;
	struct pid_namespace *parent;
#ifdef CONFIG_PROC_FS
	struct vfsmount *proc_mnt;
	struct dentry *proc_self;
	struct dentry *proc_thread_self;
#endif
#ifdef CONFIG_BSD_PROCESS_ACCT
	struct bsd_acct_struct *bacct;
#endif
	struct user_namespace *user_ns;
	struct work_struct proc_work;
	kgid_t pid_gid;
	int hide_pid;
	int reboot;	/* group exit code if this pidns was rebooted */
	struct ns_common ns;
};
```

实际上PID分配器也需要依靠该结构的某些部分来连续生成唯一ID，但我们目前对此无需关注。
我们上述代码中给出的下列成员更感兴趣。

* 每个PID命名空间都具有一个进程，其发挥的作用相当于全局的init进程。init的一个目的是对孤儿进程调用
wait4，命名空间局部的init变体也必须完成该工作。child_reaper保存了指向该进程的task_struct的指针。

* parent是指向父命名空间的指针，层次表示当前命名空间在命名空间层次结构中的深度。初始命名空间的
level为0，该命名空间的子空间level为1，下一层的子空间level为2，依次递推。level的计算比较重要，
因为level较高的命名空间中的ID，对level较低的命名空间来说是可见的。从给定的level设置，内核即可推断
进程会关联到多少个ID。

PID的管理围绕两个数据结构展开：struct pid是内核对PID的内部表示，而struct upid则表示特定的命名空间
中可见的信息。两个结构的定义如下：

path: include/linux/pid.h
```
/*
 * struct upid is used to get the id of the struct pid, as it is
 * seen in particular namespace. Later the struct pid is found with
 * find_pid_ns() using the int nr and struct pid_namespace *ns.
 */

struct upid {
	/* Try to keep pid_chain in the same cacheline as nr for find_vpid */
	int nr;
	struct pid_namespace *ns;
	struct hlist_node pid_chain;
};

struct pid
{
	atomic_t count;
	unsigned int level;
	/* lists of tasks that use this pid */
	struct hlist_head tasks[PIDTYPE_MAX];
	struct rcu_head rcu;
	struct upid numbers[1];
};
```

对于struct upid，nr表示ID的数值，ns是指向该ID所属的命名空间的指针。所有的upid实例都保存在一个
散列表中，稍后我们会看到该结构。pid_chain用内核的标准方法实现了散列溢出链表。
struct pid的定义首先是一个引用计数器count。tasks是一个数组，每个数组项都是一个散列表头，对应于
一个ID类型。这样做是必要的，因为一个ID可能用于几个进程。所有共享同一给定ID的task_struct实例，
都通过该列表连接起来。PIDTYPE_MAX表示ID类型的数目:

path: include/linux/pid.h
```
enum pid_type
{
	PIDTYPE_PID,
	PIDTYPE_PGID,
	PIDTYPE_SID,
	PIDTYPE_MAX
};
```