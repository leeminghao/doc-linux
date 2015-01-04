Linux 0.11 安装硬盘文件系统
================================================================================

在系统轮转到进程1中执行之后,进过下列执行过程:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/Process1Running.md

之后将调用setup函数来为安装硬盘文件系统作准备.
下面我们来分析整个过程:

块高速缓存(struct buffer_head):
--------------------------------------------------------------------------------

块高速缓存用来改进文件系统性能. 高速缓存用一个缓冲数组来实现,其中每个缓冲区由包含指针，计数器和标志的头以及用于存放磁盘块的体组成。
所有未使用的缓冲区均使用双链表, 按最近一次使用时间从近到远的顺序链接起来.

为了迅速判断某一块是否在内存中,我们使用了哈希表。所有缓冲区,如果它所包含块的哈希代码为k,在哈希表中用第k项指向的单链表链接在一起。
哈希函数提取块号低n位作为哈希代码,因此不同设备的块可以出现在同一哈希链之中.每个缓冲区都在其中某个链中。在Linux 0.11启动,初始化文件系统时,
所有缓冲区均未使用,并且全部在哈希表第0项指向的单链表中. 这时,哈希表其他项均为空指针.但是一旦系统启动完成,缓冲区将从0号链中删除,
放到其他链中。

其初始化过程如下：

https://github.com/leeminghao/doc-linux/blob/master/0.11/init/StartMainInit.md

准备过程
--------------------------------------------------------------------------------

### 轮转到进程1执行

执行进程1过程如下:

path: init/main.c
```
void main(void)
{
    ......
    if (!fork()) {        /* we count on this going ok */
        init();  // 跳转到进程1执行
    }
    ......
}
```

path: init/main.c
```
void init(void)
{
    ......
    setup((void *) &drive_info); // drive_info就是硬盘参数表
    ......
}
```

### 根据机器系统数据(DRIVE_INFO)设置硬盘参数(hd_info):

#### 硬盘参数表(DRIVE_INFO):

硬盘参数表是由setup程序利用ROM BIOS的中断读取的机器系统数据.

path: init/main.c
```
#define DRIVE_INFO (*(struct drive_info*)0x90080)  内存0x90080开始32字节的机器系统数据用于存放硬盘参数表.
```

#### 硬盘参数描述符:

所有硬盘的参数存放到类型为(struct hd_i_struct)的变量hd_info中

path: kernel/blk_drv/hd.c
```
struct hd_i_struct {
    int head; // 磁头数
    int sect; // 每磁道扇区数
    int cyl;  // 柱面数
    int wpcom;
    int lzone;
    int ctl;
};
```

#### 硬盘信息描述符:

所有的硬盘信息存放到类型为(struct hd_struct)的变量hd中

path: kernel/blk_drv/hd.c
```
static struct hd_struct {
    long start_sect;  // 起始扇区
    long nr_sects;    // 总扇区数
} hd[5*MAX_HD]={{0,0},};
```

#### 过程:

设置硬盘参数信息是通过调用sys_setup来实现的,具体过程如下:

根据硬盘参数表中的信息设置hd_info; 根据hd_info中的硬盘参数描述符中的信息设置hd

具体实现如下所示:

path: kernel/blk_drv/hd.c
```
/* This may be used only once, enforced by 'static int callable' */
int sys_setup(void * BIOS)
{
    static int callable = 1;
    int i,drive;
    unsigned char cmos_disks;
    struct partition *p;
    struct buffer_head * bh;

    if (!callable)
        return -1;
    callable = 0;
#ifndef HD_TYPE
    /* A. 读取drive_info设置hd_info */
    for (drive=0 ; drive<2 ; drive++) {
        hd_info[drive].cyl = *(unsigned short *) BIOS;
        hd_info[drive].head = *(unsigned char *) (2+BIOS);
        hd_info[drive].wpcom = *(unsigned short *) (5+BIOS);
        hd_info[drive].ctl = *(unsigned char *) (8+BIOS);
        hd_info[drive].lzone = *(unsigned short *) (12+BIOS);
        hd_info[drive].sect = *(unsigned char *) (14+BIOS);
        BIOS += 16;
    }
    /* 判断有几个硬盘 */
    if (hd_info[1].cyl)
        NR_HD=2;
    else
        NR_HD=1;
#endif
    /* 一个物理硬盘最多可以分为4各逻辑盘,0是物理盘,1~4是逻辑盘,共5个.
     * 第1个物理盘是0 * 5, 第2个物理盘是1 * 5.
     */
    // 设置每个硬盘的起始扇区号和扇区总数。
    for (i=0 ; i<NR_HD ; i++) {
        hd[i*5].start_sect = 0;
        hd[i*5].nr_sects = hd_info[i].head*
                hd_info[i].sect*hd_info[i].cyl;
    }

    /*
        We querry CMOS about hard disks : it could be that
        we have a SCSI/ESDI/etc controller that is BIOS
        compatable with ST-506, and thus showing up in our
        BIOS table, but not register compatable, and therefore
        not present in CMOS.

        Furthurmore, we will assume that our ST-506 drives
        <if any> are the primary drives in the system, and
        the ones reflected as drive 1 or 2.

        The first drive is stored in the high nibble of CMOS
        byte 0x12, the second in the low nibble.  This will be
        either a 4 bit drive type or 0xf indicating use byte 0x19
        for an 8 bit type, drive 1, 0x1a for drive 2 in CMOS.

        Needless to say, a non-zero value means we have
        an AT controller hard disk for that drive.
    */
    /*
     * 我们对 CMOS 有关硬盘的信息有些怀疑:可能会出现这样的情况,我们有一块 SCSI/ESDI/等的
     * 控制器,它是以 ST-506 方式与 BIOS 兼容的,因而会出现在我们的 BIOS 参数表中,但却又不
     * 是寄存器兼容的,因此这些参数在 CMOS 中又不存在。
     * 另外,我们假设 ST-506 驱动器(如果有的话)是系统中的基本驱动器,也即以驱动器 1 或 2
     * 出现的驱动器。
     * 第 1 个驱动器参数存放在 CMOS 字节 0x12 的高半字节中,第 2 个存放在低半字节中。该 4 位字节
     * 信息可以是驱动器类型,也可能仅是 0xf。0xf 表示使用 CMOS 中 0x19 字节作为驱动器 1 的 8 位
     * 类型字节,使用 CMOS 中 0x1A 字节作为驱动器 2 的类型字节。
     * 总之,一个非零值意味着我们有一个 AT 控制器硬盘兼容的驱动器。
     */
    // 这里根据上述原理来检测硬盘到底是否是 AT 控制器兼容的。
    if ((cmos_disks = CMOS_READ(0x12)) & 0xf0)
        if (cmos_disks & 0x0f)
            NR_HD = 2;
        else
            NR_HD = 1;
    else
        NR_HD = 0;
    for (i = NR_HD ; i < 2 ; i++) {
        hd[i*5].start_sect = 0;
        hd[i*5].nr_sects = 0;
    }

    /* 第一个物理盘号是0x300, 第2个是0x305, 读每个物理硬盘的0号块，即引导块, 有分区信息 */
    /* MBR(master boot record)扇区：
     * 计算机在按下power键以后，开始执行主板bios程序。进行完一系列检测和配置以后。
     * 开始按bios中设定的系统引导顺序引导系统。假定现在是硬盘。Bios执行完自己的程序
     * 后如何把执行权交给硬盘呢。交给硬盘后又执行存储在哪里的程序呢。
     * 其实，称为mbr的一段代码起着举足轻重的作用。MBR(master boot record),即主引导记录，
     * 有时也称主引导扇区。位于整个硬盘的0柱面0磁头1扇区(可以看作是硬盘的第一个扇区)，
     * bios在执行自己固有的程序以后就会jump到mbr中的第一条指令。将系统的控制权交由mbr来执行。
     * 在总共512byte的主引导记录中，MBR的引导程序占了其中的前446个字节(偏移0H~偏移1BDH)，
     * 随后的64个字节(偏移1BEH~偏移1FDH)为DPT(Disk PartitionTable，硬盘分区表)，
     * 最后的两个字节“55 AA”(偏移1FEH~偏移1FFH)是分区有效结束标志。
     * MBR不随操作系统的不同而不同，意即不同的操作系统可能会存在相同的MBR，
     * 即使不同，MBR也不会夹带操作系统的性质。具有公共引导的特性。
     */
    for (drive=0 ; drive<NR_HD ; drive++) {
        if (!(bh = bread(0x300 + drive*5,0))) {
            printk("Unable to read partition table of drive %d\n\r",
                drive);
            panic("");
        }
        if (bh->b_data[510] != 0x55 || (unsigned char)
            bh->b_data[511] != 0xAA) {
            printk("Bad partition table on drive %d\n\r",drive);
            panic("");
        }
        p = 0x1BE + (void *)bh->b_data; // 分区表位于硬盘第1扇区的 0x1BE 处。
        for (i=1;i<5;i++,p++) {
            hd[i+5*drive].start_sect = p->start_sect;
            hd[i+5*drive].nr_sects = p->nr_sects;
        }
        brelse(bh);
    }
    ......
}
```

### 读取硬盘引导块.

#### 过程:

读取硬盘引导块是通过在sys_setup中通过向bread函数传递硬盘设备号和块号0(引导块)来读取的,具体过程如下:

path: kernel/blk_drv/hd.c
```
/* This may be used only once, enforced by 'static int callable' */
int sys_setup(void * BIOS)
{
    ......
    struct partition *p;
    struct buffer_head * bh;
    ......
    for (drive=0 ; drive<NR_HD ; drive++) {
        /* 第一个物理盘号是0x300, 第2个是0x305, 读每个物理硬盘的0号块，即引导块, 有分区信息 */
        if (!(bh = bread(0x300 + drive*5,0))) {
            printk("Unable to read partition table of drive %d\n\r",
                drive);
            panic("");
        }
        if (bh->b_data[510] != 0x55 || (unsigned char)
            bh->b_data[511] != 0xAA) {
            printk("Bad partition table on drive %d\n\r",drive);
            panic("");
        }
        p = 0x1BE + (void *)bh->b_data;
        for (i=1;i<5;i++,p++) {
            hd[i+5*drive].start_sect = p->start_sect;
            hd[i+5*drive].nr_sects = p->nr_sects;
        }
        brelse(bh);
    }
    if (NR_HD)
        printk("Partition table%s ok.\n\r",(NR_HD>1)?"s":"");

    rd_load();
    mount_root();
    return (0);
}
```

进入bread函数中以后调用getblk在缓冲区中申请一个空闲的缓冲块(struct buffer_head):

path: fs/buffer.c
```
/*
 * bread() reads a specified block and returns the buffer that contains
 * it. It returns NULL if the block was unreadable.
 */
struct buffer_head * bread(int dev,int block) // 读制定dev, block, 第一块硬盘是0x300, block是0
{
    struct buffer_head * bh;
    /* 申请一个空闲缓冲块 */
    if (!(bh=getblk(dev,block)))
        panic("bread: getblk returned NULL\n");
    if (bh->b_uptodate)
        return bh;

    ll_rw_block(READ,bh);
    wait_on_buffer(bh);
    if (bh->b_uptodate)
        return bh;
    brelse(bh);
    return NULL;
}
```

进入getblk后首先调用get_hash_table查找hash表，检索此前是否有程序把现在要读的硬盘逻辑块
(相同设备号和块号)已经读到缓冲区. 使用hash表的目的是提高查询速度:

path: fs/buffer.c
```
struct buffer_head * getblk(int dev,int block)
{
    struct buffer_head * tmp, * bh;

repeat:
    /* 因为是第一次调用hash_table中肯定没有指定设备号，块号的缓冲块. */
    if ((bh = get_hash_table(dev,block)))
        return bh;
    ......
}
```

进入get_hash_table后调用find_buffer从hash表查找缓冲区中是否有指定设备号,块号的缓冲块,
如果能找到指定缓冲块，就直接用:

path: fs/buffer.c
```
/*
 * Why like this, I hear you say... The reason is race-conditions.
 * As we don't lock buffers (unless we are readint them, that is),
 * something might happen to it while we sleep (ie a read-error
 * will force it bad). This shouldn't really happen currently, but
 * the code is ready.
 */
struct buffer_head * get_hash_table(int dev, int block)
{
    struct buffer_head * bh;

    for (;;) {
        /* 现在是第一次使用缓冲区,缓冲区的hash_table中不可能存在已读入的缓冲块,
         * 也就是hash_table中没有挂接任何节点. find_buffer返回的一定是NULL.
         */
        if (!(bh=find_buffer(dev,block)))
            return NULL;
        bh->b_count++;
        wait_on_buffer(bh);
        if (bh->b_dev == dev && bh->b_blocknr == block)
            return bh;
        bh->b_count--;
    }
}
```

find_buffer的具体实现如下所示:

path: fs/buffer.c
```
#define _hashfn(dev,block) (((unsigned)(dev^block))%NR_HASH)
#define hash(dev,block) hash_table[_hashfn(dev,block)]
......
static struct buffer_head * find_buffer(int dev, int block)
{
    struct buffer_head * tmp;

    for (tmp = hash(dev,block) ; tmp != NULL ; tmp = tmp->b_next)
        if (tmp->b_dev==dev && tmp->b_blocknr==block)
            return tmp;
    return NULL;
}
```

返回到getblk函数中去从空闲缓冲区中申请一个空闲缓冲块

path: fs/buffer.c
```
struct buffer_head * getblk(int dev,int block)
{
    struct buffer_head * tmp, * bh;

repeat:
    /* 因为是第一次调用hash_table中肯定没有指定设备号，块号的缓冲块. */
    if ((bh = get_hash_table(dev,block)))
        return bh;

    /* 在hash_table中没有查询到对应的缓冲块,所以要在空闲链表中申请新的缓冲块 */
    tmp = free_list;
    do {
        if (tmp->b_count)
            continue;
        if (!bh || BADNESS(tmp)<BADNESS(bh)) { // bh现在为NULL, 取得空闲的缓冲块
            bh = tmp;
            if (!BADNESS(tmp))
                break;
        }
    /* and repeat until we find something good */
    } while ((tmp = tmp->b_next_free) != free_list);
    if (!bh) {
        sleep_on(&buffer_wait);
        goto repeat;
    }
    /* 缓冲块没有加锁 */
    wait_on_buffer(bh);
    /* 现在还没有使用缓冲块 */
    if (bh->b_count)
        goto repeat;

    /* 缓冲块的内容没有被修改 */
    while (bh->b_dirt) {
        sync_dev(bh->b_dev);
        wait_on_buffer(bh);
        if (bh->b_count)
            goto repeat;
    }

    /* NOTE!! While we slept waiting for this block, somebody else might */
    /* already have added "this" block to the cache. check it */
    if (find_buffer(dev,block))
        goto repeat;
    /* OK, FINALLY we know that this buffer is the only one of it's kind, */
    /* and that it's unused (b_count=0), unlocked (b_lock=0), and clean */
    /* 申请到缓冲块后,对它进行初始化设置,并将这个缓冲块挂接到hash_table中 */
    bh->b_count=1;
    bh->b_dirt=0;
    bh->b_uptodate=0;
    /* 将空闲缓冲块从空闲链表中移出 */
    remove_from_queues(bh);
    bh->b_dev=dev;
    bh->b_blocknr=block;
    /* 将空闲缓冲块添加到hash表中去 */
    insert_into_queues(bh);
    return bh;
}
```

remove_from_queues与insert_into_queues函数用于将缓冲块挂接在hash_table中，具体实现如下所示:

path: fs/buffer.c
```
static inline void remove_from_queues(struct buffer_head * bh)
{
    /* remove from hash-queue */
    if (bh->b_next)
        bh->b_next->b_prev = bh->b_prev;
    if (bh->b_prev)
        bh->b_prev->b_next = bh->b_next;
    if (hash(bh->b_dev,bh->b_blocknr) == bh)
        hash(bh->b_dev,bh->b_blocknr) = bh->b_next;
    /* remove from free list */
    if (!(bh->b_prev_free) || !(bh->b_next_free))
        panic("Free block list corrupted");
    bh->b_prev_free->b_next_free = bh->b_next_free;
    bh->b_next_free->b_prev_free = bh->b_prev_free;
    if (free_list == bh)
        free_list = bh->b_next_free;
}

static inline void insert_into_queues(struct buffer_head * bh)
{
    /* put at end of free list */
    bh->b_next_free = free_list;
    bh->b_prev_free = free_list->b_prev_free;
    free_list->b_prev_free->b_next_free = bh;
    free_list->b_prev_free = bh;
    /* put the buffer in new hash-queue if it has a device */
    bh->b_prev = NULL;
    bh->b_next = NULL;
    if (!bh->b_dev)
        return;
    bh->b_next = hash(bh->b_dev,bh->b_blocknr);
    hash(bh->b_dev,bh->b_blocknr) = bh;
    bh->b_next->b_prev = bh;
}
```

接着返回到bread函数之后,调用ll_rw_block这个函数,将缓冲块与请求项挂接.如下所示:

path: fs/buffer.c
```
struct buffer_head * bread(int dev,int block)
{
    struct buffer_head * bh;

    if (!(bh=getblk(dev,block)))
        panic("bread: getblk returned NULL\n");
    if (bh->b_uptodate)
        return bh;
    ll_rw_block(READ,bh);
    wait_on_buffer(bh);
    if (bh->b_uptodate)
        return bh;
    brelse(bh);
    return NULL;
}
```

path: kernel/blk_drv/ll_rw_blk.c
```
void ll_rw_block(int rw, struct buffer_head * bh)
{
    unsigned int major;

    /* 判断对应缓冲块对应的设备是否存在，存在的话需要判断对应的设备请求项函数是否挂接正常 */
    if ((major=MAJOR(bh->b_dev)) >= NR_BLK_DEV ||
    !(blk_dev[major].request_fn)) {
        printk("Trying to read nonexistent block-device\n\r");
        return;
    }

    make_request(major,rw,bh);
}
```

接下来,调用make_request函数，将缓冲块与请求项建立联系:

path: kernel/blk_drv/ll_rw_blk.c
```
static void make_request(int major,int rw, struct buffer_head * bh)
{
    struct request * req;
    int rw_ahead;

    /* WRITEA/READA is special case - it is not really needed, so if the */
    /* buffer is locked, we just forget about it, else it's a normal read */
    /* 检查传递进来的缓冲块是否已经加锁 */
    if ((rw_ahead = (rw == READA || rw == WRITEA))) {
        if (bh->b_lock)  // 现在还没有加锁
            return;
        if (rw == READA) // 放弃预读写,改为普通读写
            rw = READ;
        else
            rw = WRITE;
    }
    if (rw!=READ && rw!=WRITE)
        panic("Bad block dev command, must be R/W/RA/WA");
    /* 先将这个缓冲块加锁,目的是保护这个缓冲块在解锁之前将不再被任何进程操作,
     * 这是因为这个缓冲块现在已经被使用,如果此后再被挪作它用，里面数据会发生混乱.
     */
    lock_buffer(bh);
    if ((rw == WRITE && !bh->b_dirt) || (rw == READ && bh->b_uptodate)) {
        unlock_buffer(bh);
        return;
    }

repeat:
   /* we don't allow the write-requests to fill up the queue completely:
    * we want some room for reads: they take precedence. The last third
    * of the requests are only for reads.
    */
    /* 如果是读请求,则从整个请求项结构的最末端开始寻找空闲请求项; 如果是写请求,则从这个结构的
     * 2/3处,申请空闲请求项. 这是从用户使用的系统心里学来说，用户更希望读取的数据能更快的显现
     * 出来，所以给读取操作更大空间.
     */
    if (rw == READ)
        req = request+NR_REQUEST;
    else
        req = request+((NR_REQUEST*2)/3);

    /* find an empty request */
    /* 从后向前搜索空闲缓冲块 */
    while (--req >= request)
        if (req->dev<0)
            break;

    /* if none found, sleep on new requests: check for rw_ahead */
    if (req < request) {
        if (rw_ahead) {
            unlock_buffer(bh);
            return;
        }
        sleep_on(&wait_for_request);
        goto repeat;
    }

    /* fill up the request-info, and add it to the queue */
    /* 设置请求项 */
    req->dev = bh->b_dev;
    req->cmd = rw;
    req->errors=0;
    req->sector = bh->b_blocknr<<1;
    req->nr_sectors = 2;
    req->buffer = bh->b_data;
    req->waiting = NULL;
    req->bh = bh;
    req->next = NULL;

    /* 调用add_request函数，向请求队列中加载该请求项, 在这里blk_dev+major指向的是硬盘设备 */
    add_request(major+blk_dev,req);
}
```

path: kernel/blk_drv/blk.h
```
struct request {
    int dev;        /* -1 if no request */
    int cmd;        /* READ or WRITE */
    int errors;
    unsigned long sector;
    unsigned long nr_sectors;
    char * buffer;
    struct task_struct * waiting;
    struct buffer_head * bh;
    struct request * next;
};

...

struct blk_dev_struct {
    void (*request_fn)(void);
    struct request * current_request;
};
```

path: kernel/blk_drv/ll_rw_blk.c
```
/* blk_dev_struct is:
 *    do_request-address
 *    next-request
 */
struct blk_dev_struct blk_dev[NR_BLK_DEV] = {
    { NULL, NULL },        /* no_dev */
    { NULL, NULL },        /* dev mem */
    { NULL, NULL },        /* dev fd */
    { NULL, NULL },        /* dev hd */
    { NULL, NULL },        /* dev ttyx */
    { NULL, NULL },        /* dev tty */
    { NULL, NULL },        /* dev lp */
};
```

add_request的具体实现如下所示:

path: kernel/blk_drv/ll_rw_blk.c
```
/*
 * add-request adds a request to the linked list.
 * It disables interrupts so that it can muck with the
 * request-lists in peace.
 */
static void add_request(struct blk_dev_struct * dev, struct request * req)
{
    struct request * tmp;

    req->next = NULL;
    cli();
    if (req->bh)
        req->bh->b_dirt = 0;
    /* 如果当前硬盘设备当前请求项为空，没有进程发起请求，则设置硬盘设备的当前请求项为
     * 前面设置的请求项, 并调用硬盘请求项处理函数 */
    if (!(tmp = dev->current_request)) {
        dev->current_request = req;
        sti();
        (dev->request_fn)();  // do_hd_request
        return;
    }
    /* 如果当前硬盘设备有请求项，那么利用电梯算法将前面设置的请求项挂在请求项队列中 */
    for ( ; tmp->next ; tmp=tmp->next)
        if ((IN_ORDER(tmp,req) ||
            !IN_ORDER(tmp,tmp->next)) &&
            IN_ORDER(req,tmp->next))
            break;
    req->next=tmp->next;
    tmp->next=req;
    sti();
}
```

接下来，进入do_hd_request函数去执行,为读硬盘做最后准备工作, 具体实现如下所示:

path: kernel/blk_drv/blk.h
```
#define CURRENT (blk_dev[MAJOR_NR].current_request)
#define CURRENT_DEV DEVICE_NR(CURRENT->dev)
```

path: kernel/blk_drv/hd.c
```
static int recalibrate = 1;
static int reset = 1;

void do_hd_request(void)
{
    int i,r = 0;
    unsigned int block,dev;
    unsigned int sec,head,cyl;
    unsigned int nsect;

    /* 通过对当前请求项数据成员的分析,解析出需要操作的磁头,扇区,柱面,操作多少个扇区.
     * 之后,建立硬盘读盘必要的参数,将磁头移动到0柱面
     */
    INIT_REQUEST;
    dev = MINOR(CURRENT->dev);
    block = CURRENT->sector;
    if (dev >= 5*NR_HD || block+2 > hd[dev].nr_sects) {
        end_request(0);
        goto repeat;
    }
    block += hd[dev].start_sect;
    dev /= 5;
    __asm__("divl %4":"=a" (block),"=d" (sec):"0" (block),"1" (0),
        "r" (hd_info[dev].sect));
    __asm__("divl %4":"=a" (cyl),"=d" (head):"0" (block),"1" (0),
        "r" (hd_info[dev].head));
    sec++;
    nsect = CURRENT->nr_sectors;

    if (reset) {
        reset = 0;         /* 防止多次执行if(reset) */
        recalibrate = 1;   /* 确保执行下面if(recalibrate)*/
        /* 将通过调用hd_out向硬盘发送WIN_SPECIFY命令,建立硬盘读盘必要的参数 */
        reset_hd(CURRENT_DEV);
        return;
    }

    if (recalibrate) {
        recalibrate = 0; /* 防止多次执行if (recalibrate) */
        /* 将向硬盘发送WIN_RESTORE命令，将磁头移动到0柱面，以便从硬盘上读取数据 */
        hd_out(dev,hd_info[CURRENT_DEV].sect,0,0,0,
            WIN_RESTORE,&recal_intr);
        return;
    }

    /* 针对命令的性质给硬盘发送操作命令 */
    if (CURRENT->cmd == WRITE) {
        hd_out(dev,nsect,sec,head,cyl,WIN_WRITE,&write_intr);
        for(i=0 ; i<3000 && !(r=inb_p(HD_STATUS)&DRQ_STAT) ; i++)
            /* nothing */ ;
        if (!r) {
            bad_rw_intr();
            goto repeat;
        }
        port_write(HD_DATA,CURRENT->buffer,256);
    /* 因为是读盘操作，所以接下来调用hd_out函数来下达最后的硬盘操作指令.
     * WIN_READ表示接下来要进行读操作,read_intr是读盘操作对应的中断服务程序
     * 所以要提取它的函数地址，准备挂接，这是通过hd_out来实现的.
     */
    } else if (CURRENT->cmd == READ) {
        hd_out(dev,nsect,sec,head,cyl,WIN_READ,&read_intr);
    } else
        panic("unknown hd-command");
}
```

进入hd_out函数中去执行读盘的最后一步,下达读盘命令.
hd_out() 是硬盘控制器操作命令发送函数。该函数带有一个中断过程中调用的 C 函数指针参数,在
向控制器发送命令之前,它首先使用这个参数预置好中断过程中会调用的函数指针(do_hd),然后它按
照规定的方式依次向硬盘控制器 0x1f0 至 0x1f7 发送命令参数块。除控制器诊断( WIN_DIAGNOSE )和
建立驱动器参数( WIN_SPECIFY )两个命令以外,硬盘控制器在接收到任何其它命令并执行了命令以后,
都会向 CPU 发出中断请求信号,从而引发系统去执行硬盘中断处理过程

```
static void hd_out(unsigned int drive,unsigned int nsect,unsigned int sect,
        unsigned int head,unsigned int cyl,unsigned int cmd,
        void (*intr_addr)(void))
{
    register int port asm("dx");

    if (drive>1 || head>15)
        panic("Trying to write bad sector");
    if (!controller_ready())
        panic("HD controller not ready");
    do_hd = intr_addr; // do_hd被设置为read_intr
    outb_p(hd_info[drive].ctl,HD_CMD);
    port=HD_DATA;
    outb_p(hd_info[drive].wpcom>>2,++port);
    outb_p(nsect,++port);
    outb_p(sect,++port);
    outb_p(cyl,++port);
    outb_p(cyl>>8,++port);
    outb_p(0xA0|(drive<<4)|head,++port);
    outb(cmd,++port);
}
```

向硬盘发送一个命令之后,硬盘控制器接受到命令,然后开始执行,命令执行完毕之后,
硬盘开始将引导块中的数据不断读入它的缓存中,同时,程序也返回了，将会沿着前面调用的反方向,即:

```
hd_out --> do_hd_request --> add_request --> make_request --> ll_rw_block --> bread
```

path: fs/buffer.c
```
struct buffer_head * bread(int dev,int block)
{
    struct buffer_head * bh;

    if (!(bh=getblk(dev,block)))
        panic("bread: getblk returned NULL\n");
    if (bh->b_uptodate)
        return bh;
    ll_rw_block(READ,bh);
    wait_on_buffer(bh);  // 将等待缓冲块解锁的进程挂起,现在是进程1
    if (bh->b_uptodate)
        return bh;
    brelse(bh);
    return NULL;
}
```

现在,硬盘正在继续读引导块.如果程序继续执行,则需要对引导块中的数据进行操作.但这些数据还没有从
硬盘中读完，所以调用wait_on_buffer函数，挂起等待.

path: fs/buffer.c
```
static inline void wait_on_buffer(struct buffer_head * bh)
{
    cli();
    /* 判断刚才申请到的缓冲块是否被加锁,现在,缓冲块确实加锁了,调用sleep_on函数. */
    while (bh->b_lock)
        sleep_on(&bh->b_wait);
    sti();
}
```

path: kernel/sched.c
```
void sleep_on(struct task_struct **p)
{
    struct task_struct *tmp;

    if (!p)
        return;
    if (current == &(init_task.task))
        panic("task[0] trying to sleep");
    /* 将进程1设置为不可中断等待状态,进程1挂起，然后调用shedule()函数 */
    tmp = *p;
    *p = current;
    current->state = TASK_UNINTERRUPTIBLE; // 将进程1设置为不可中断等待状态
    schedule();
    if (tmp)
        tmp->state=0;
}
```

在等待硬盘读数据时,进程调度切换到进程0执行, 从进程1调度到进程0过程如下所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/ProcessSchedule1to0.md

硬盘在某一时刻把一个扇区的数据读出来了，产生硬盘中断。CPU接到中断指令后，终止正在执行的进程0的程序，
终止的位置肯定是在pause(), sys_pause(), schedule(), switch_to (n)循环里面的某行指令处.
然后转去执行硬盘中断服务程序. 执行代码如下：

path: kernel/system_call.s
```
hd_interrupt:
    pushl %eax
    pushl %ecx
    pushl %edx
    push %ds
    push %es
    push %fs
    movl $0x10,%eax
    mov %ax,%ds
    mov %ax,%es
    movl $0x17,%eax
    mov %ax,%fs
    movb $0x20,%al
    outb %al,$0xA0        # EOI to interrupt controller #1
    jmp 1f                # give port chance to breathe
1:  jmp 1f
1:  xorl %edx,%edx
    xchgl do_hd,%edx # do_hd=read_intr,在硬盘中断服务程序中将执行do_hd函数.
    testl %edx,%edx
    jne 1f
    movl $unexpected_hd_interrupt,%edx
1:  outb %al,$0x20
    call *%edx        # "interesting" way of handling intr.
    ...
    iret
```

别忘了中断会自动压栈ss,esp,eflags,cs,eip. 硬盘中断服务程序的代码接着将一些寄存器的数据压栈以保存程序的中断处的现场。
之后，执行_do_hd处的读盘中断处理程序，对应的代码应该是call *%edx这一行。这个edx里面是读盘中断处理程序read_intr的地址.
read_intr()函数会将已经读到硬盘缓存中的数据复制到刚才被锁定的那个缓冲块中.

**注意**:
锁定是阻止进程方面的操作，而不是阻止外设方面的操作，这时1个扇区256字(512字节)的数据读入前面申请到的缓冲块，
执行代码如下：

path: kernel/blk_drv/hd.c
```
static void read_intr(void)
{
    if (win_result()) {
        bad_rw_intr();
        do_hd_request();
        return;
    }
    port_read(HD_DATA,CURRENT->buffer,256);
    CURRENT->errors = 0;
    CURRENT->buffer += 512;
    CURRENT->sector++;
    /* 判断进程是否已经将数据读取完 */
    if (--CURRENT->nr_sectors) {
        do_hd = &read_intr;
        return;
    }
    end_request(1);
    do_hd_request();
}
```

但是，引导块的数据是1024字节，请求项要求的也是1024字节，现在仅读出了一半，硬盘会继续读盘。
与此同时，在得知请求项对应的缓冲块数据没有读完的情况下，内核将再次把read_intr()绑定在硬盘中断服务程序上，
以待下次使用，之后中断服务程序返回, 进程1在等待硬盘读取数据，切换到进程0执行。进程0仍处在被挂起状态，
pause()、sys_pause()、schedule()、switch_to(0)循环从刚才硬盘中断打断的地方继续循环，硬盘继续读盘.

又过了一段时间后，硬盘剩下的那一半数据也读完了，硬盘产生中断，读盘中断服务程序再次响应这个中断，
进入read_intr()函数后，仍然会判断请求项对应的缓冲块的数据是否读完了.

### 从引导块中获取信息

进入end_request()后，由于此时缓冲块的内容已经全部读进来了，将这个缓冲块的更新标志b_uptodate置1，
说明它可用了，执行代码如下：

**注意**: 此时程序既没有在进程0，也没有在进程1中执行，而是CPU处理硬盘中断服务程序.

path: kernel/blk_dev/blk.h
```
static inline void end_request(int uptodate)
{
    DEVICE_OFF(CURRENT->dev);
    if (CURRENT->bh) {
        CURRENT->bh->b_uptodate = uptodate; // uptodate是参数，为1
        unlock_buffer(CURRENT->bh);
    }
    if (!uptodate) {
        printk(DEVICE_NAME " I/O error\n\r");
        printk("dev %04x, block %d\n\r",CURRENT->dev,
            CURRENT->bh->b_blocknr);
    }
    wake_up(&CURRENT->waiting);
    wake_up(&wait_for_request);
    CURRENT->dev = -1;
    CURRENT = CURRENT->next;
}
```

之后，调用unlock_buffer()函数为缓冲块解锁, 在unlock_buffer()函数中调用wake_up()函数，
将等待这个缓冲块解锁的进程(进程1)唤醒(设置为就绪态)，并对刚刚使用过的请求项进行处理，
如将它对应的请求项设置为空闲, 执行代码如下：

path: kernel/blk_dev/blk.h
```
static inline void unlock_buffer(struct buffer_head * bh)
{
    if (!bh->b_lock)
        printk(DEVICE_NAME ": free buffer being unlocked\n");
    bh->b_lock=0;
    wake_up(&bh->b_wait); // b_wait指向进程1
}
```

path: kernel/sched.c
```
void wake_up(struct task_struct **p)
{
    if (p && *p) {
        (**p).state=0; // 设置为就绪态
        *p=NULL;
    }
}
```

硬盘中断处理结束，也就是载入硬盘引导块的工作结束后，计算机在进程0的
pause(), sys_pause(), schedule(), switch_to(0)循环中继续执行.

现在，引导块的两个扇区已经载入内核的缓冲块，进程1已经处于就绪态。
**注意**：
虽然进程0一直参与循环运行，但它是非就绪态。现在只有进程0和进程1，
当循环执行到schedule函数时就会切换进程1去执行。

现在，返回切换进程的发起者sleep_on()函数中，并最终返回bread()函数中。
执行代码如下：

path: fs/buffer.c
```
struct buffer_head * bread(int dev,int block)
{
    struct buffer_head * bh;

    if (!(bh=getblk(dev,block)))
        panic("bread: getblk returned NULL\n");
    if (bh->b_uptodate)
        return bh;
    ll_rw_block(READ,bh);
    wait_on_buffer(bh);
    if (bh->b_uptodate)
        return bh;
    brelse(bh);
    return NULL;
}
```

在bread()函数中判断缓冲块的b_uptodate 标志已被设置为1，直接返回，bread()函数执行完毕。
回到sys_setup函数继续执行，处理硬盘引导块载入缓冲区后的事务:

path: kernel/blk_drv/hd.c
```
/* This may be used only once, enforced by 'static int callable' */
int sys_setup(void * BIOS)
{
    ......
    struct partition *p;
    struct buffer_head * bh;
    ......
    for (drive=0 ; drive<NR_HD ; drive++) {
        /* 第一个物理盘号是0x300, 第2个是0x305, 读每个物理硬盘的0号块，即引导块, 有分区信息 */
        if (!(bh = bread(0x300 + drive*5,0))) {
            printk("Unable to read partition table of drive %d\n\r",
                drive);
            panic("");
        }
        /* 缓冲块里面装载着硬盘的引导块的内容，先来判断硬盘信息有效标志'55AA'。
         * 如果第一个扇区的最后2字节不是'55AA'，就说明这个扇区中的数据是无效的
         */
        if (bh->b_data[510] != 0x55 || (unsigned char)
            bh->b_data[511] != 0xAA) {
            printk("Bad partition table on drive %d\n\r",drive);
            panic("");
        }
        /* 利用从引导块中采集到的分区表信息来设置hd[]
         * 分区表位于硬盘第 1 扇区的 0x1BE 处。
         */
        p = 0x1BE + (void *)bh->b_data;
        for (i=1;i<5;i++,p++) {
            hd[i+5*drive].start_sect = p->start_sect;
            hd[i+5*drive].nr_sects = p->nr_sects;
        }
        brelse(bh);  // 释放缓冲块（引用计数减1）
    }
    if (NR_HD)
        printk("Partition table%s ok.\n\r",(NR_HD>1)?"s":"");

    rd_load();
    mount_root();
    return (0);
}
```

根据硬盘分区信息设置hd[]，为安装硬盘文件系统做准备的工作都已完成。
下面，我们将介绍进程1用虚拟盘替代软盘使之成为根设备，为加载根文件系统做准备:

https://github.com/leeminghao/doc-linux/blob/master/0.11/filesystem/ChangeRootDev.md

总结
--------------------------------------------------------------------------------

为安装硬盘文件系统作准备大致经过如下步骤:

**根据机器系统数据设置硬盘参数** --> **读取硬盘引导块** --> **从引导块中获取信息**
