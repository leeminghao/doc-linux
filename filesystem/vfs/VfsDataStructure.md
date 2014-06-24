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

超级块对象
--------------------------------------------------------------------------------

超级块结构表示一个文件系统. 它包含管理文件系统所需的信息, 包括文件系统名称(比如ext2),文件系统的大小和状态,块设备的引用和
元数据信息(比如空闲列表等等).超级块通常存储在存储媒体上, 但是如果超级块不存在, 也可以实时创建它.

#### super_block

path: include/linux/fs.h
```
struct super_block {
    struct list_head s_list;    /* Keep this first */ /* 指向超级块链表的指针 */
    dev_t s_dev;  /* search index; _not_ kdev_t */ /* 设备标识符 */
    unsigned char s_blocksize_bits;  /* 以位为单位的块大小 */
    unsigned long s_blocksize;       /* 以字节为单位的快大小 */
    loff_t s_maxbytes; /* Max file size */ /* 文件的最大长度 */
    struct file_system_type *s_type;       /* 文件系统类型 */

    const struct super_operations *s_op;   /* 操作超级块的方法 */
    const struct dquot_operations *dq_op;  /* 磁盘限额处理方法 */
    const struct quotactl_ops *s_qcop;     /* 磁盘限额管理方法 */
    const struct export_operations *s_export_op; /* 网络文件系统使用的输出操作 */

    unsigned long s_flags;    /* 安装标志 */
    unsigned long s_magic;    /* 文件系统的魔数 */
    struct dentry *s_root;    /* 文件系统根目录的目录项对象 */
    struct rw_semaphore s_umount; /* 卸载所用的信号量 */
    int s_count;          /* 引用计数器 */
    atomic_t s_active;    /* 次级引用计数器 */
#ifdef CONFIG_SECURITY
    void                    *s_security; /* 指向超级块安全数据结构的指针 */
#endif
    const struct xattr_handler **s_xattr; /* 指向超级块扩展属性结构的指针 */

    struct list_head s_inodes; /* all inodes */ /* 所有索引节点的链表 */
    /* 用于处理远程网络文件系统的匿名目录项的链表 */
    struct hlist_bl_head s_anon; /* anonymous dentries for (nfs) exporting */
    struct list_head s_mounts;   /* list of mounts; _not_ for fs use */

    struct block_device *s_bdev; /* 指向块设备驱动程序描述符的指针 */
    struct backing_dev_info *s_bdi;
    struct mtd_info *s_mtd;
    struct hlist_node s_instances; /* 用于给定文件系统类型的超级块对象链表的指针 */
    struct quota_info s_dquot; /* Diskquota specific options */ /* 磁盘限额的描述符 */

    struct sb_writers s_writers;

    char s_id[32]; /* Informational name */ /* 包含超级块的块设备名称 */
    u8 s_uuid[16]; /* UUID */

    void *s_fs_info; /* Filesystem private info */  /* 指向文件系统的私有信息 */
    unsigned int s_max_links;
    fmode_t s_mode;

    /* Granularity of c/m/atime in ns.
       Cannot be worse than a second */
    u32 s_time_gran;

    /*
     * The next field is for VFS *only*. No filesystems have any business
     * even looking at it. You had been warned.
     */
    struct mutex s_vfs_rename_mutex; /* Kludge */

    /*
     * Filesystem subtype.  If non-empty the filesystem type field
     * in /proc/mounts will be "type.subtype"
     */
    char *s_subtype;

     /*
      * Saved mount options for lazy filesystems using
      * generic_show_options()
      */
     char __rcu *s_options;
     const struct dentry_operations *s_d_op; /* default d_op for dentries */

     /*
      * Saved pool identifier for cleancache (-1 means none)
      */
     int cleancache_poolid;

     struct shrinker s_shrink; /* per-sb shrinker handle */

     /* Number of inodes with nlink == 0 but still referenced */
     atomic_long_t s_remove_count;

     /* Being remounted read-only */
     int s_readonly_remount;

     /* AIO completions deferred from interrupt context */
     struct workqueue_struct *s_dio_done_wq;

     /*
      * Keep the lru lists last in the structure so they always sit on their
      * own individual cachelines.
      */
     struct list_lru s_dentry_lru ____cacheline_aligned_in_smp;
     struct list_lru s_inode_lru ____cacheline_aligned_in_smp;
     struct rcu_head rcu;
};
```

所有超级块对象都以双向循环链表的形式链接在一起,链表中的第一个元素用"super_blocks"变量来表示.
而超级块对象的"s_list"字段存放指向链表相邻元素的指针. "sb_lock"自旋锁保护链表妙手多处理器系统上的同时访问.
"s_fs_info"字段指向属于具体文件系统的超级块信息; 例如,假如超级块对象指向的是Ext2文件系统,该字段就指向
ext2_sb_info数据结构.为了效率起见,由s_fs_info所指向的数据被复制到内存.任何基于磁盘的文件系统都需要访问
和更改自己的磁盘分配位图,以便分配或释放磁盘块. VFS允许这些文件系统直接对内存超级块的s_fs_info字段进行
操作,而无需访问磁盘.


#### super_operations

与超级块关联的方法就是所谓的超级块操作.这些操作是由数据结构super_operations来描述的.

path: include/linux/fs.h
```
struct super_operations {
    /* 为索引节点对象分配空间,包括文件系统数据所需要的空间 */
    struct inode *(*alloc_inode)(struct super_block *sb);
    /* 撤销索引节点对象,包括具体文件系统的数据 */
    void (*destroy_inode)(struct inode *);

    /* 当索引节点标记为修改(脏)时调用. */
    void (*dirty_inode) (struct inode *, int flags);
    /* 用通过传递参数指定的索引节点对象的内容更新一个文件系统的索引节点.索引节点对象的i_ino字段表示所涉及磁盘上文件系统的索引节点 */
    int (*write_inode) (struct inode *, struct writeback_control *wbc);
    int (*drop_inode) (struct inode *);
    void (*evict_inode) (struct inode *);
    void (*put_super) (struct super_block *);
    int (*sync_fs)(struct super_block *sb, int wait);
    int (*freeze_fs) (struct super_block *);
    int (*unfreeze_fs) (struct super_block *);
    int (*statfs) (struct dentry *, struct kstatfs *);
    int (*remount_fs) (struct super_block *, int *, char *);
    void (*umount_begin) (struct super_block *);

    int (*show_options)(struct seq_file *, struct dentry *);
    int (*show_devname)(struct seq_file *, struct dentry *);
    int (*show_path)(struct seq_file *, struct dentry *);
    int (*show_stats)(struct seq_file *, struct dentry *);
#ifdef CONFIG_QUOTA
    ssize_t (*quota_read)(struct super_block *, int, char *, size_t, loff_t);
    ssize_t (*quota_write)(struct super_block *, int, const char *, size_t, loff_t);
#endif
    int (*bdev_try_to_free_page)(struct super_block*, struct page*, gfp_t);
    long (*nr_cached_objects)(struct super_block *, int);
    long (*free_cached_objects)(struct super_block *, long, int);
};
```


Blog
--------------------------------------------------------------------------------
http://www.ibm.com/developerworks/cn/linux/l-linux-filesystem/ (Linux文件系统剖析)