Linux VFS Data Structure
================================================================================

与进程相关的文件
--------------------------------------------------------------------------------

## 简述

每个进程都有它当前的工作目录和它自己的根目录.这仅仅是内核用来表示进程与文件系统相互作用
所必须维护的数据中的两个例子,类型为fs_struct的整个数据结构就用于此目的.且每个进程描述符
的fs字段就指向进程的fs_struct结构.

## fs_struct

文件系统类型注册
--------------------------------------------------------------------------------

## 简述

通常,用户在为自己的系统编译内核时可以把Linux配置为能够识别所有需要的文件系统.
但是,文件系统的源代码实际上要么包含在内核的影像中,要么作为一个模块被动态装入.VFS必须对代码目前
已经在内核中的所有文件系统的类型进行跟踪,这就是通过进行文件系统类型注册来实现的.
每个注册的文件系统都用一个类型为file_system_type的对象来表示:

## file_system_type

#### 变量

path: include/linux/fs.h
```
struct file_system_type {
    const char *name;    /* 文件系统名称 */
    int fs_flags;        /* 文件系统类型标志 */

/* fs_flags存放几个标志 */
#define FS_REQUIRES_DEV      1  /* 这种类型的任何文件系统必须位于物理磁盘设备上 */
#define FS_BINARY_MOUNTDATA  2  /* 文件系统使用二进制安装数据 */
#define FS_HAS_SUBTYPE       4
#define FS_USERNS_MOUNT      8 /* Can be mounted by userns root */
#define FS_USERNS_DEV_MOUNT 16 /* A userns mount does not imply MNT_NODEV */
/* FS will handle d_move() during rename() internally. */
#define FS_RENAME_DOES_D_MOVE 32768

    struct dentry *(*mount) (struct file_system_type *, int,
       const char *, void *);   /* 成员函数负责超级块,根目录和索引节点的创建和初始化工作 */

    void (*kill_sb) (struct super_block *); /* 删除超级块的方法 */

    struct module *owner;  /* 指向实现文件系统的模块的指针 */
    struct file_system_type * next; /* 指向文件系统类型链表中下一个元素的指针 */
    struct hlist_head fs_supers;    /* 具有相同文件系统类型的超级块对象链表的头 */

    struct lock_class_key s_lock_key;
    struct lock_class_key s_umount_key;
    struct lock_class_key s_vfs_rename_key;
    struct lock_class_key s_writers_key[SB_FREEZE_LEVELS];

    struct lock_class_key i_lock_key;
    struct lock_class_key i_mutex_key;
    struct lock_class_key i_mutex_dir_key;
};
```

所有文件系统类型的对象都插入到一个单向链表中.由变量"file_systems"指向链表的第一个元素,
而结构中的"next"字段指向链表的下一个元素."file_systems_lock" 读写自旋锁保护整个链表免受同时访问.
"fs_supers" 字段表示给定类型的已安装文件系统所对应的超级块链表的头.

#### 函数

* register_filesystem: 注册编译时指定的每个文件系统,该函数把相应的file_system_type对象插入到文件系统类型的链表中.
  当实现了文件系统以模块方式装入的时候,也要调用该函数.
* unregister_filesystem: 当实现了文件系统以模块方式装入,当该模块卸载是,注销对应的文件系统
* get_fs_type: 扫描已注册的文件系统链表以查找文件系统类型的name字段,并返回指向相应的file_system_type对象(如果存在)的指针.