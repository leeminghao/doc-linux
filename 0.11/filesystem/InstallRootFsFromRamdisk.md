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
static struct super_block * read_super(int dev)
{
    struct super_block * s;
    struct buffer_head * bh;
    int i,block;

    if (!dev)
        return NULL;
    check_disk_change(dev); // 检查是否换过盘，并做相应处理
    if ((s = get_super(dev)))
        return s;

    ...
}
```