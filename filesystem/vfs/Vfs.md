Linux Virtual File System
================================================================================

Overview
--------------------------------------------------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/filesystem/fs/vfs.txt

VFS的注册
--------------------------------------------------------------------------------

首先, 在内核启动过程,会初始化rootfs文件系统,rootfs和tmpfs都是内存中的文件系统,其类型为ramfs.
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