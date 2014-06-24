Linux Virtual File System
================================================================================

Overview
--------------------------------------------------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/filesystem/fs/vfs.txt

VFS的作用
--------------------------------------------------------------------------------

虚拟文件系统: 也可以称为虚拟文件系统转换(Virtual Filesystem Switch, VFS),是一个内核软件层,
用来处理与UNIX标准文件系统相关的所有系统调用.

VFS支持的文件系统类型:
* 磁盘文件系统: Ext2, Ext3, NTFS等.
* 网络文件系统: NFS, Coda, AFS, CIFS等.
* 特殊文件系统: /proc

基于磁盘的文件系统通常存放在硬件块设备中,如硬盘,软盘或者CD-ROM. Linux VFS的一个有用特点是能够处理如/dev/loop0这样的虚拟块设备,
这种设备可以用来安装普通文件所在的文件系统.

**注意**: 当一个文件系统被安装在某一个目录上时,在符文见系统中的目录内容不再是可访问的,因为任何路径(包括安装点),都将引用已安装的
文件系统.但是,当被安装文件系统卸载时,原目录的内容又可再现.

VFS除了能为所有文件系统的实现提供一个通用接口外,还具有另一个与系统性能相关的重要作用,最近最长使用的目录项对象被存放在所谓目录项
高速缓存(dentry cache)的磁盘高速缓存中,一般来说,磁盘高速缓存(disk cache)属于软件机制,它允许内核将原本存放在磁盘上的某些信息放到
RAM中,以便对这些数据的进一步访问能快速进行,而不必慢速访问磁盘本身.

通用文件模型
--------------------------------------------------------------------------------

* 超级块对象(superblock object): 存放已安装文件系统的有关信息. 对基于磁盘的文件系统,这类对象通常对应于存放在磁盘上的文件系统控制块.
* 索引节点对象(inode object): 存放关于具体文件的一般信息. 对基于磁盘的文件系统,这类对象通常对应于存放在磁盘上的文件控制块.
* 文件对象(file object): 存放打开文件与进程之间进行交互的有关信息. 这类信息仅当进程访问文件期间存在于内核内存中.
* 目录项对象(dentry object): 存放目录项与对应文件进行链接的有关信息. 每个磁盘文件系统都以自己特有的方式将该类信息存在磁盘上.

例子: 三个不同进程已经打开同一个文件,其中两个文件使用同一个硬链接,在这种情况下:

其中每个进程都使用自己的文件对象, 但只需要两个目录项对象,每个硬链接对应一个目录项对象.这两个目录项对象指向同一个索引节点对象,该索引节点
对象标识超级块对象,以及随后的普通磁盘文件.

VFS的注册
--------------------------------------------------------------------------------

首先,在内核启动过程,会初始化rootfs文件系统,rootfs和tmpfs都是内存中的文件系统,其类型为ramfs.
然后会把这个rootf挂载到根目录. 其代码如下:

## start_kernel

path: init/main.c
```
asmlinkage void __init start_kernel(void)
{
    char * command_line;
    extern const struct kernel_param __start___param[], __stop___param[];
    ......
    /* 初始化dache和inode */
    vfs_caches_init_early();
    ......
    /* 调用vfs_caches_init函数来初始化VFS */
    vfs_caches_init(totalram_pages);
    ......
}
```

## vfs_caches_init_early

path: fs/dcaches.c
```
void __init vfs_caches_init_early(void)
{
    /* 负责初始化dcahes相关的数据结构 */
    dcache_init_early();
    /* 负责初始化inode相关的数据结构 */
    inode_init_early();
}
```

## dcache_init_early

path: fs/dcaches.c
```
static void __init dcache_init_early(void)
{
    unsigned int loop;

    /* If hashes are distributed across NUMA nodes, defer
     * hash allocation until vmalloc space is available.
     */
     if (hashdist)
        return;

    dentry_hashtable =
        alloc_large_system_hash("Dentry cache",
            sizeof(struct hlist_bl_head),
            dhash_entries,
            13,
            HASH_EARLY,
            &d_hash_shift,
            &d_hash_mask,
            0,
            0);

    for (loop = 0; loop < (1U << d_hash_shift); loop++)
        INIT_HLIST_BL_HEAD(dentry_hashtable + loop);
}
```

## inode_init_early

path: fs/inode.c
```
/*
 * Initialize the waitqueues and inode hash table.
 */
void __init inode_init_early(void)
{
    unsigned int loop;

    /* If hashes are distributed across NUMA nodes, defer
     * hash allocation until vmalloc space is available.
     */
     if (hashdist)
        return;

     inode_hashtable =
         alloc_large_system_hash("Inode-cache",
             sizeof(struct hlist_head),
             ihash_entries,
             14,
             HASH_EARLY,
             &i_hash_shift,
             &i_hash_mask,
             0,
             0);

    for (loop = 0; loop < (1U << i_hash_shift); loop++)
        INIT_HLIST_HEAD(&inode_hashtable[loop]);
}
```
两个函数都是调用alloc_large_system_hash函数分别为dentry_hashtable和inode_hashtable分配空间.

## vfs_caches_init

path:

```
void __init vfs_caches_init(unsigned long mempages)
{
    unsigned long reserve;

    /* Base hash sizes on available memory, with a reserve equal to
       150% of current kernel size */

    reserve = min((mempages - nr_free_pages()) * 3/2, mempages - 1);
    mempages -= reserve;

    names_cachep = kmem_cache_create("names_cache", PATH_MAX, 0,
        SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);

    dcache_init();
    inode_init();
    files_init(mempages);

    mnt_init();

    bdev_cache_init();
    chrdev_init();
}
```

## mnt_init

```
void __init mnt_init(void)
{
    unsigned u;
    int err;

    mnt_cache = kmem_cache_create("mnt_cache", sizeof(struct mount),
        0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);

    mount_hashtable = alloc_large_system_hash("Mount-cache",
        sizeof(struct hlist_head),
        mhash_entries, 19,
        0,
        &m_hash_shift, &m_hash_mask, 0, 0);
    mountpoint_hashtable = alloc_large_system_hash("Mountpoint-cache",
        sizeof(struct hlist_head),
        mphash_entries, 19,
        0,
        &mp_hash_shift, &mp_hash_mask, 0, 0);

   if (!mount_hashtable || !mountpoint_hashtable)
       panic("Failed to allocate mount hash table\n");

   for (u = 0; u <= m_hash_mask; u++)
       INIT_HLIST_HEAD(&mount_hashtable[u]);
       for (u = 0; u <= mp_hash_mask; u++)
           INIT_HLIST_HEAD(&mountpoint_hashtable[u]);

   kernfs_init();

   err = sysfs_init();
   if (err)
       printk(KERN_WARNING "%s: sysfs_init error: %d\n",
       __func__, err);
   fs_kobj = kobject_create_and_add("fs", NULL);
   if (!fs_kobj)
       printk(KERN_WARNING "%s: kobj create error\n", __func__);

   init_rootfs();
   init_mount_tree();
}
```

## init_rootfs VS init_mount_tree

这两个函数用于安装根文件系统,具体实现见:
https://github.com/leeminghao/doc-linux/blob/master/filesystem/rootfs/RootFS.md

Blog
-------------------------------------------------------------------------------
* http://www.ibm.com/developerworks/cn/linux/l-vfs/ (解析Linux中的VFS文件系统机制)
* http://blog.csdn.net/yunsongice/article/details/5683859 (把Linux中的VFS对象串联起来)