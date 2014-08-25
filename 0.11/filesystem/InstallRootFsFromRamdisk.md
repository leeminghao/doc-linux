Linux 0.11 从虚拟盘中安装根文件系统
================================================================================

准备工作
--------------------------------------------------------------------------------

将根设备从软盘切换到虚拟盘:

https://github.com/leeminghao/doc-linux/blob/master/0.11/filesystem/ChangeRootDev.md

切换之后我们将要从虚拟盘中安装根文件系统.

理论知识
--------------------------------------------------------------------------------

操作系统中加载根文件系统涉及文件,文件系统,根文件系统,加载文件系统,加载根文件系统这几个概念。
为了更容易理解，这里我们只讨论块设备，也就是软盘、硬盘、虚拟盘.

操作系统中的文件系统可以大致分成两部分:

* 一部分在操作系统内核中;
* 另一部分在硬盘、软盘、虚拟盘中。

文件系统是用来管理文件的。

文件系统用i节点来管理文件，一个i节点管理一个文件，i节点和文件一一对应;
文件的路径在操作系统中由目录文件中的目录项管理，一个目录项对应一级路径，目录文件也是文件，也由i节点管理;
一个文件挂在一个目录文件的目录项上，这个目录文件根据实际路径的不同，又可能挂在另一个目录文件的目录项上。
一个目录文件有多个目录项，可以形成不同的路径。如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/filesystem/filesystem.jpg

所有的文件（包括目录文件）的i节点最终挂接成一个树形结构，树根i节点就叫这个文件系统的根i节点。
一个逻辑设备（一个物理设备可以分成多个逻辑设备，比如物理硬盘可以分成多个逻辑硬盘）只有一个
文件系统，一个文件系统只能包含一个这样的树形结构，也就是说，一个逻辑设备只能有一个根i节点。
加载文件系统最重要的标志，就是把一个逻辑设备上的文件系统的根i节点，关联到另一个文件系统的i节点上。
具体是哪一个i节点，由操作系统的使用者通过mount命令决定, 如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/filesystem/different_fs.jpg

另外，一个文件系统必须挂接在另一个文件系统上，按照这个设计，一定存在一个只被其他文件系统挂接的
文件系统，这个文件系统就叫根文件系统，根文件系统所在的设备就叫根设备。

别的文件系统可以挂在根文件系统上，根文件系统挂在哪呢？
挂在super_block[8]上。

Linux 0.11操作系统中只有一个super_block[8]，每个数组元素是一个超级块，一个超级块管理一个逻辑设备，
也就是说操作系统最多只能管理8个逻辑设备，其中只有一个根设备。加载根文件系统最重要的标志就是把
根文件系统的根i节点挂在super_block[8]中根设备对应的超级块上。

进程1在根设备上加载跟文件系统
--------------------------------------------------------------------------------

进程1通过调用mount_root()函数实现在根设备虚拟盘上加载根文件系统。
执行代码如下：

path: kernel/blk_drv/hd.c
```
/* This may be used only once, enforced by 'static int callable' */
int sys_setup(void * BIOS)
{
    ...

    rd_load();
    mount_root();
    return (0);
}
```

mount_root函数实现如下所示:

path: fs/super.c
```
void mount_root(void)
{
    int i,free;
    struct super_block * p;
    struct m_inode * mi;
    // 如果磁盘 i 节点结构不是 32 个字节,则出错,死机。该判断是用于防止修改源代码时的不一致性。
    if (32 != sizeof (struct d_inode))
        panic("bad i-node size");
    for(i=0;i<NR_FILE;i++)  // 初始化file_table[64]，为后续程序做准备
        file_table[i].f_count=0;
    // 2代表软盘，此时根设备是虚拟盘，是1。反之，没有虚拟盘，则加载软盘的根文件系统
    if (MAJOR(ROOT_DEV) == 2) {
        printk("Insert root floppy and press ENTER");
        wait_for_keypress();
    }
    // 初始化内存中的超级块super_block[8]，将每一项所对应的设备号加锁标志和等待它解锁的进程全部
    // 设置为0。系统只要想和任何一个设备以文件的形式进行数据交互，就要将这个设备的超级块存储在
    // super_block[8]中，这样可以通过super_block[8]获取这个设备中文件系统的最基本信息，根设备中
    // 的超级块也不例外
    for(p = &super_block[0] ; p < &super_block[NR_SUPER] ; p++) {
        p->s_dev = 0;
        p->s_lock = 0;
        p->s_wait = NULL;
    }
    // 前面的rd_load()函数已经“格式化”好虚拟盘，并设置为根设备。接下来调用read_super()函数，
    // 从虚拟盘中读取根设备的超级块，复制到super_block[8]中。
    if (!(p=read_super(ROOT_DEV)))
        panic("Unable to mount root");
    ...
}
```

接下来调用read_super函数从虚拟盘中读取根设备的超级块. 实现如下所示:

path: include/linux/fs.h
```
#define NR_SUPER 8
...
// 内存中块设备超级块结构。
struct super_block {
    unsigned short s_ninodes;       // 节点数。
    unsigned short s_nzones;        // 逻辑块数。
    unsigned short s_imap_blocks;   // i 节点位图所占用的数据块数。
    unsigned short s_zmap_blocks;   // 逻辑块位图所占用的数据块数。
    unsigned short s_firstdatazone; // 第一个数据逻辑块号。
    unsigned short s_log_zone_size; // log(数据块数/逻辑块)。(以 2 为底)。
    unsigned long s_max_size;       // 文件最大长度。
    unsigned short s_magic;         // 文件系统魔数。
    /* These are only in memory */
    struct buffer_head * s_imap[8]; // i 节点位图缓冲块指针数组(占用 8 块,可表示 64M)。
    struct buffer_head * s_zmap[8]; // 逻辑块位图缓冲块指针数组(占用 8 块)。
    unsigned short s_dev;           // 超级块所在的设备号。
    struct m_inode * s_isup;        // 被安装的文件系统根目录的 i 节点。(isup-super i)
    struct m_inode * s_imount;      // 被安装到的 i 节点。
    unsigned long s_time;           // 修改时间。
    struct task_struct * s_wait;    // 等待该超级块的进程。
    unsigned char s_lock;           // 被锁定标志。
    unsigned char s_rd_only;        // 只读标志。
    unsigned char s_dirt;           // 已修改(脏)标志。
};
```

path: fs/supper.c
```
struct super_block super_block[NR_SUPER];

...

// 取指定设备的超级块。返回该超级块结构指针。
struct super_block * get_super(int dev)
{
    struct super_block * s;
    // 如果没有指定设备,则返回空指针。
    if (!dev)
        return NULL;
    // s 指向超级块数组开始处。搜索整个超级块数组,寻找指定设备的超级块。
    s = 0+super_block;
    while (s < NR_SUPER+super_block)
    // 如果当前搜索项是指定设备的超级块,则首先等待该超级块解锁(若已经被其它进程上锁的话)。
    // 在等待期间,该超级块有可能被其它设备使用,因此此时需再判断一次是否是指定设备的超级块,
    // 如果是则返回该超级块的指针。否则就重新对超级块数组再搜索一遍,因此 s 重又指向超级块数组
    // 开始处。
        if (s->s_dev == dev) {
            wait_on_super(s);
            if (s->s_dev == dev)
                return s;
            s = 0+super_block;
    // 如果当前搜索项不是,则检查下一项。如果没有找到指定的超级块,则返回空指针。
        } else
            s++;
    return NULL;
}

...

static struct super_block * read_super(int dev)
{
    struct super_block * s;
    struct buffer_head * bh;
    int i,block;

    if (!dev)
        return NULL;
    // 首先检查该设备是否可更换过盘片(也即是否是软盘设备),如果更换过盘,则高速缓冲区有关该
    // 设备的所有缓冲块均失效,需要进行失效处理(释放原来加载的文件系统)。
    check_disk_change(dev); // 检查是否换过盘，并做相应处理
    // 因为此前没有加载过根文件系统，get_super函数返回NULL, 所以需要在super_block[8]中申请一项
    if ((s = get_super(dev)))
        return s;
    // 否则,首先在超级块数组中找出一个空项(也即其 s_dev=0 的项)。如果数组已经占满则返回空指针。
    // 此时返回的是第一项
    for (s = 0+super_block ;; s++) {
        if (s >= NR_SUPER+super_block)
            return NULL;
        if (!s->s_dev)
            break;
    }
    // 找到超级块空项后,就将该超级块用于指定设备,对该超级块的内存项进行部分初始化。
    s->s_dev = dev;
    s->s_isup = NULL;
    s->s_imount = NULL;
    s->s_time = 0;
    s->s_rd_only = 0;
    s->s_dirt = 0;
    // 然后锁定该超级块,并从设备上读取超级块信息到 bh 指向的缓冲区中。如果读超级块操作失败,
    // 则释放上面选定的超级块数组中的项,并解锁该项,返回空指针退出。
    lock_super(s);
    // 调用bread()函数，把超级块从虚拟盘上读进缓冲区，并从缓冲区复制到super_block[8]的第一项。
    // bread()函数在前面已经说明。这里有一点区别，如果给硬盘发送操作命令，则调用do_hd_request()
    // 函数，而此时操作的是虚拟盘，所以要调用do_rd_request()函数。值得注意的是，虚拟盘虽然被视为
    // 外设，但它毕竟是内存里面一段空间，并不是实际的外设，所以，调用do_rd_request()函数从虚拟盘
    // 上读取超级块，不会发生类似硬盘中断的情况。
    // 超级块复制进缓冲块以后，将缓冲块中的超级块数据复制到super_block[8]的第一项。
    // 从现在起，虚拟盘这个根设备就由super_block[8]的第一项来管理，之后调用brelse()
    // 函数释放这个缓冲块
    if (!(bh = bread(dev,1))) {
        s->s_dev=0;
        free_super(s);
        return NULL;
    }
    // 将设备上读取的超级块信息复制到超级块数组相应项结构中。并释放存放读取信息的高速缓冲块。
    *((struct d_super_block *) s) =
        *((struct d_super_block *) bh->b_data);
    brelse(bh);
    // 判断超级块的魔数(SUPER_MAGIC)是否正确
    if (s->s_magic != SUPER_MAGIC) {
        s->s_dev = 0;
        free_super(s);
        return NULL;
    }
    // 初始化s_imap[8]、s_zmap[8]
    for (i=0;i<I_MAP_SLOTS;i++)
        s->s_imap[i] = NULL;
    for (i=0;i<Z_MAP_SLOTS;i++)
        s->s_zmap[i] = NULL;
    // 虚拟盘的第一块是超级块，第二块开始是i节点位图和区段块位图
    block=2;
    // 把虚拟盘上i节点位图所占用的所有逻辑块读到缓冲区，分别挂接到s_zmap[8]上
    for (i=0 ; i < s->s_imap_blocks ; i++)
        if ((s->s_imap[i]=bread(dev,block)))
            block++;
        else
            break;
    // 把虚拟盘上区段块位图所占用的所有逻辑块读到缓冲区，分别挂接到s_zmap[8]上
    for (i=0 ; i < s->s_zmap_blocks ; i++)
        if ((s->s_zmap[i]=bread(dev,block)))
            block++;
        else
            break;
    // 如果读出的位图逻辑块数不等于位图应该占有的逻辑块数,说明文件系统位图信息有问题,超级块
    // 初始化失败。因此只能释放前面申请的所有资源,返回空指针并退出。
    if (block != 2+s->s_imap_blocks+s->s_zmap_blocks) {
        for(i=0;i<I_MAP_SLOTS;i++)
            brelse(s->s_imap[i]);
        for(i=0;i<Z_MAP_SLOTS;i++)
            brelse(s->s_zmap[i]);
        s->s_dev=0;
        free_super(s);
        return NULL;
    }

    // 否则一切成功。对于申请空闲 i 节点的函数来讲,如果设备上所有的 i 节点已经全被使用,则查找
    // 函数会返回 0 值。因此 0 号 i 节点是不能用的,所以这里将位图中的最低位设置为 1,以防止文件
    // 系统分配 0 号 i 节点。同样的道理,也将逻辑块位图的最低位设置为 1。
    s->s_imap[0]->b_data[0] |= 1;
    s->s_zmap[0]->b_data[0] |= 1;
    free_super(s);
    return s;
}
```