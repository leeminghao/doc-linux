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

### 读取根设备超级块

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

### 获取根目录i节点

接下来回到mount_root()函数中继续执行，执行代码如下所示:

path: fs/super.c
```
void mount_root(void)
{
    int i,free;
    struct super_block * p;
    struct m_inode * mi;
    ...
    if (!(p=read_super(ROOT_DEV)))
        panic("Unable to mount root");
    // 调用iget()函数，从虚拟盘上读取根i节点。根i节点的意义在于，通过它可以到文件系统中任何
    // 指定的i节点，也就是能找到任何指定的文件。
    if (!(mi=iget(ROOT_DEV,ROOT_INO)))
        panic("Unable to read root i-node");
    ...
}
```

接下来从mount_root函数中调用iget()函数从虚拟盘上读取指定节点号nr的i节点。
执行代码如下所示:

path: include/linux/fs.h
```
#define ROOT_INO 1  // 根 i 节点。
...
#define NR_INODE 32
...
// 这是在内存中的 i 节点结构。前 7 项与 d_inode 完全一样。
struct m_inode {
   unsigned short i_mode;       // 文件类型和属性(rwx 位)。
   unsigned short i_uid;        // 用户 id(文件拥有者标识符)。
   unsigned long i_size;        // 文件大小(字节数)。
   unsigned long i_mtime;       // 修改时间(自 1970.1.1:0 算起,秒)。
   unsigned char i_gid;         // 组 id(文件拥有者所在的组)。
   unsigned char i_nlinks;      // 文件目录项链接数。
   unsigned short i_zone[9];    // 直接(0-6)、间接(7)或双重间接(8)逻辑块号。
   /* these are in memory also */
   struct task_struct * i_wait; // 等待该 i 节点的进程。
   unsigned long i_atime;       // 最后访问时间。
   unsigned long i_ctime;       // i 节点自身修改时间。
   unsigned short i_dev;        // i 节点所在的设备号。
   unsigned short i_num;        // i 节点号。
   unsigned short i_count;      // i 节点被使用的次数,0 表示该 i 节点空闲。
   unsigned char i_lock;        // 锁定标志。
   unsigned char i_dirt;        // 已修改(脏)标志。
   unsigned char i_pipe;        // 管道标志。
   unsigned char i_mount;       // 安装标志。
   unsigned char i_seek;        // 搜寻标志(lseek 时)。
   unsigned char i_update;      // 更新标志。
};
```

path: fs/inode.c
```
struct m_inode inode_table[NR_INODE]={{0,},};  // NR_INODE = 32,
...
struct m_inode * iget(int dev,int nr)
{
    struct m_inode * inode, * empty;

    if (!dev)
        panic("iget with dev==0");
    // 操作系统从i节点表inode_table[32]中申请一个空闲的i节点位置（inode_table[32]是操作系统用来
    // 控制同时打开不同文件的最大数）。此时应该是首个i节点。对这个i节点进行初始化设置，其中包括
    // 该i节点对应的设备号、该i节点的节点号...
    empty = get_empty_inode();
    // 扫描i节点表。寻找指定节点号的i节点。并递增该节点的引用次数。
    inode = inode_table;
    while (inode < NR_INODE+inode_table) {
        // 如果当前扫描的i节点的设备号不等于指定的设备号或者节点号不等于指定的节点号,则继续扫描.
        if (inode->i_dev != dev || inode->i_num != nr) {
            inode++;
            continue;
        }
        // 找到指定设备号和节点号的 i 节点,等待该节点解锁(如果已上锁的话).
        wait_on_inode(inode);
        // 在等待该节点解锁的阶段,节点表可能会发生变化,所以再次判断,如果发生了变化,则再次重新
        // 扫描整个 i 节点表。
        if (inode->i_dev != dev || inode->i_num != nr) {
            inode = inode_table;
            continue;
        }
        // 将该i节点引用计数增1。
        inode->i_count++;
        // 如果该i节点是其它文件系统的安装点,则在超级块表中搜寻安装在此i节点的超级块。如果没有
        // 找到,则显示出错信息,并释放函数开始获取的空闲节点,返回该i节点指针。
        if (inode->i_mount) {
            int i;

            for (i = 0 ; i<NR_SUPER ; i++)
                if (super_block[i].s_imount==inode)
                    break;
            if (i >= NR_SUPER) {
                printk("Mounted inode hasn't got sb\n");
                if (empty)
                    iput(empty);
                return inode;
            }
            // 将该i节点写盘,从安装在此i节点文件系统的超级块上取设备号,并令i节点号为1. 然后重新
            // 扫描整个 i 节点表,取该被安装文件系统的根节点。
            iput(inode);
            dev = super_block[i].s_dev;
            nr = ROOT_INO;
            inode = inode_table;
            continue;
        }
        // 已经找到相应的i节点,因此放弃临时申请的空闲节点,返回该找到的i节点。
        if (empty)
            iput(empty);
        return inode;
    }
    // 如果在i节点表中没有找到指定的i节点,则利用前面申请的空闲i节点在i节点表中建立该节点。
    // 并从相应设备上读取该i节点信息, 返回该i节点。
    if (!empty)
        return (NULL);
    inode=empty;
    inode->i_dev = dev;
    inode->i_num = nr;
    read_inode(inode);
    return inode;
}
```

接下来将要从根设备上读取根目录i节点信息初始化前面申请到的空闲i节点表. 执行代码如下所示:

path: fs/inode.c
```
// 从设备上读取指定 i 节点的信息到内存中(缓冲区中)。
static void read_inode(struct m_inode * inode)
{
    struct super_block * sb;
    struct buffer_head * bh;
    int block;

    // 锁定inode
    lock_inode(inode);
    // 获得inode所在设备的超级块
    if (!(sb=get_super(inode->i_dev)))
        panic("trying to read inode without dev");
    // 该i节点所在的逻辑块号 = (启动块+超级块) + i 节点位图占用的块数 + 逻辑块位图占用的块数 +
    // (i 节点号 - 1) / 每块含有的i节点数。
    block = 2 + sb->s_imap_blocks + sb->s_zmap_blocks +
        (inode->i_num-1)/INODES_PER_BLOCK;
    // 从设备上读取该i节点所在的逻辑块,并将该inode指针指向对应i节点信息。
    if (!(bh=bread(inode->i_dev,block)))
        panic("unable to read i-node block");
    *(struct d_inode *)inode =
        ((struct d_inode *)bh->b_data)
            [(inode->i_num-1)%INODES_PER_BLOCK];
    // 最后释放读入的缓冲区,并解锁该i节点。
    brelse(bh);
    unlock_inode(inode);
}
```

回到iget()函数，将inode指针返回给mount_root()函数，并赋给mi指针。执行如下代码：

path: fs/super.c
```
void mount_root(void)
{
    int i,free;
    struct super_block * p;
    struct m_inode * mi;
    ...
    if (!(p=read_super(ROOT_DEV)))
        panic("Unable to mount root");
    // 调用iget()函数，从虚拟盘上读取根i节点。根i节点的意义在于，通过它可以到文件系统中任何
    // 指定的i节点，也就是能找到任何指定的文件。
    if (!(mi=iget(ROOT_DEV,ROOT_INO)))
        panic("Unable to read root i-node");
    // 该i节点引用次数递增3次。
    mi->i_count += 3 ;    /* NOTE! it is logically used 4 times, not 1 */
    // 将inode_table[32]中代表虚拟盘根i节点的项挂接到super_block[8]中代表根设备虚拟盘的项中的
    // s_isup, s_imount指针上. 这样,操作系统在根设备上可以通过这里建立的关系,一步步地把文件找到.
    // 标志性的一步！
    p->s_isup = p->s_imount = mi;
    // 当前进程（进程1）掌控根文件系统的根i节点.
    current->pwd = mi;
    // 父子进程创建机制将这个特性遗传给子进程
    current->root = mi;
    // 统计该设备上空闲块数。首先令 i 等于超级块中表明的设备逻辑块总数。
    free=0;
    i=p->s_nzones;
    // 然后根据区段块位图中相应比特位的占用情况统计出空闲块数。这里宏函数 set_bit()只是在测试
    // 比特位,而非设置比特位。"i&8191"用于取得 i 节点号在当前块中的偏移值。"i>>13"是将 i 除以
    // 8192,也即除一个磁盘块包含的比特位数。
    while (-- i >= 0)
        if (!set_bit(i&8191,p->s_zmap[i>>13]->b_data))
            free++;
    // 显示设备上空闲逻辑块数/逻辑块总数。
    printk("%d/%d free blocks\n\r",free,p->s_nzones);
    // 统计设备上空闲 i 节点数。首先令 i 等于超级块中表明的设备上 i 节点总数+1。加 1 是将 0 节点
    // 也统计进去。
    free=0;
    i=p->s_ninodes+1;
    // 然后根据 i 节点位图中相应比特位的占用情况计算出空闲 i 节点数。
    while (-- i >= 0)
        if (!set_bit(i&8191,p->s_imap[i>>13]->b_data))
            free++;
    printk("%d/%d free inodes\n\r",free,p->s_ninodes);
}
```

到此为止，sys_setup()函数就全都执行完毕了, 意味着完成了硬盘安装的准备工作，切换根设备为虚拟盘，
从虚拟盘中加载跟文件系统。因为这个函数也是由于产生软中断才被调用的，所以返回system_call中执行，
之后会执行ret_from_sys_call。这时候的当前进程是进程1，所以下面将调用do_signal()函数
（只要当前进程不是进程0，就要执行到这里），对当前进程的信号位图进行检测.
执行代码如下：

path: kernel/system_call.s
```
...
ret_from_sys_call:
    movl current,%eax        # task[0] cannot have signals
    cmpl task,%eax
    je 3f
    cmpw $0x0f,CS(%esp)        # was old code segment supervisor ?
    jne 3f
    cmpw $0x17,OLDSS(%esp)        # was stack segment = 0x17 ?
    jne 3f
    movl signal(%eax),%ebx
    movl blocked(%eax),%ecx
    notl %ecx
    andl %ebx,%ecx
    bsfl %ecx,%ecx
    je 3f
    btrl %ecx,%ebx
    movl %ebx,signal(%eax)
    incl %ecx
    pushl %ecx
    call do_signal
    popl %eax
3:    popl %eax
    popl %ebx
    popl %ecx
    popl %edx
    pop %fs
    pop %es
    pop %ds
    iret
```

现在，当前进程（进程1）并没有接收到信号，调用do_signal()函数并没有实际的意义。
至此，sys_setup()的系统调用结束，进程1将返回init代码的调用点，打开终端设备文件
以及复制文件句柄:

https://github.com/leeminghao/doc-linux/blob/master/0.11/filesystem/OpenTtyAndDup.md

总结
--------------------------------------------------------------------------------

从虚拟盘中安装根文件系统主要完成如下工作:

**从虚拟盘中读出根文件系统超级块** --> **从虚拟盘中读出根目录i节点信息** --> **将根目录i节点挂载到跟文件系统超级块上**