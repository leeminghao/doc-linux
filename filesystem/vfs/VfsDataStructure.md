Linux VFS Data Structure
================================================================================

与进程相关的文件
--------------------------------------------------------------------------------

每个进程都有它当前的工作目录和它自己的根目录.这仅仅是内核用来表示进程与文件系统相互作用
所必须维护的数据中的两个例子,类型为fs_struct的整个数据结构就用于此目的.且每个进程描述符
的fs字段就指向进程的fs_struct结构.

#### fs_struct

文件系统类型注册
--------------------------------------------------------------------------------

通常,用户在为自己的系统编译内核时可以把Linux配置为能够识别所有需要的文件系统.
但是,文件系统的源代码实际上要么包含在内核的影像中,要么作为一个模块被动态装入.VFS必须对代码目前
已经在内核中的所有文件系统的类型进行跟踪,这就是通过进行文件系统类型注册来实现的.
每个注册的文件系统都用一个类型为file_system_type的对象来表示:

#### file_system_type

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

文件系统安装
--------------------------------------------------------------------------------

在大多数传统的类Unix内核中,每个文件系统只能安装一次.假定存放在/dev/fd0软盘上的ext2文件系统通过如下命令安装在/flp:

```
$ mount -t ext2 /dev/fd0 /flp
```
在用umount命令卸载该文件系统前,所有其他作用于/dev/fd0的安装命令都会失败.
然而,Linux有所不同: 同一个文件系统被安装多次是可能的. 当然,如果一个文件系统被安装了n次,那么它的根目录就可以通过n个安装点来访问.
尽管同一个文件系统可以通过不同的安装点来访问,但是文件系统的的确确是唯一的.因此,不管一个文件系统被安装了多少次,都仅有一个超级块对象.

安装的文件系统形成一个层次: 一个文件系统的安装点可能成为第二个文件系统的目录,而第二个文件系统又安装在第三个文件系统之上.

把多个文件系统安装堆叠在一个单独的安装点上也是可能的.尽管已经使用先前安装下的文件和目录的进程可以继续使用,但在统一安装点上,
隐藏前一个安装的文件系统.当最顶层的被删除时,下一层的再一次变为可见.

综上, 跟踪已安装的文件系统会变为一场噩梦.对于每个安装操作,内核必须在内存中保存安装点和安装标志,以及要安装文件系统与其它已安装文件系统
的关系.这样的信息保存在已安装文件系统描述符中.每个描述符是一个具有vfsmount类型的数据结构:

#### vfsmount

path: include/linux/mount.h
```
struct vfsmount {
    /* 指向这个文件系统根目录的dentry */
    struct dentry *mnt_root;    /* root of the mounted tree */
    /* 指向这个文件系统的超级块对象 */
    struct super_block *mnt_sb; /* pointer to superblock */
    /* 标志 */
    int mnt_flags;
};
```
**注意**: 一个文件系统的安装点可能就是同一文件系统的一个目录,例如:

```
$ mount -t ext2 /dev/fd0 /flp
$ touch /flp/foo
$ mkdir /flp/mnt
$ mount -t ext2 /dev/fd0 /flp/mnt
```
现在,软盘文件系统上的空foo文件就可以通过/flp/foo和/flp/mnt/foo来访问