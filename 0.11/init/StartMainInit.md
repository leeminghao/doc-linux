Linux 0.11 跳转到main函数以后系统初始化
================================================================================

从开机加电到执行main函数过程
--------------------------------------------------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/Bios2Main.md

跳转到main函数以后
--------------------------------------------------------------------------------

系统之前所做的一切准备工作的核心目的就是让用户程序能够以“进程”的方式正常运行, 能够实现这一目的的标准包括三方面的内容:
* 用户程序能够在主机上进行运算;
* 能够与外设进行交互;
* 能够让用户以它为媒介进行人机交互.

为了实现这个目标, 如下所示的分析是对设备环境进行初始化, 并激活第一个进程——进程0.

### 设置根设备,硬盘参数表

path: init/main.c
```
#define DRIVE_INFO (*(struct drive_info *)0x90080)  // 硬盘参数表
#define ORIG_ROOT_DEV (*(unsigned short *)0x901FC)  // 根设备号

......

struct drive_info { char dummy[32]; } drive_info;   // 存放硬盘参数表的数据结构

/* This really IS void, no error here. */
/* The startup routine assumes (well, ...) this */
void main(void)
{
   /*
    * Interrupts are still disabled. Do necessary setups, then
    * enable them
    */
    ROOT_DEV = ORIG_ROOT_DEV; // 根据setup中写入机器系统数据的信息设置根设备为软盘
    drive_info = DRIVE_INFO;
    ...
}
```

### 规划物理内存格局,设置缓冲区,虚拟盘,主内存

接下来设置缓冲区, 虚拟盘, 主内存. 主机中的运算需要CPU, 内存相互配合工作才能实现, 内存也是参与
运算的重要部件. 对内存中缓冲区, 主内存的设置, 规划, 从根本上决定了所有进程使用内存的数量和方式，
必然会影响到进程在主机中的运算速度。

具体规划如下:
* 内核代码和数据所占内存空间
* 除了内核代码数据所占内存空间, 其余物理内存主要分为三部分: 分别是主内存区, 缓冲区和虚拟盘.
主内存区: 是进程代码运行的空间，也包括内核管理进程的数据结构;
缓冲区: 主要作为主机与外设进行数据交互的中转站;
虚拟盘区: 是一个可选的区域, 如果选择使用虚拟盘, 就可以将外设上的数据先复制进虚拟盘区, 然后加以
使用. 由于从内存中操作数据的速度远高于外设, 因此这样可以提高系统执行效率.

path: init/main.c
```
#define EXT_MEM_K (*(unsigned short *)0x90002)

void main(void)
{
    ......
    /* 1MB + 扩展内存数，即内存总数 */
    memory_end = (1<<20) + (EXT_MEM_K<<10);
    /* 按页的倍数取整,忽略内存末端不足一页的部分 */
    memory_end &= 0xfffff000;
    if (memory_end > 16*1024*1024)
        memory_end = 16*1024*1024;
    /* 根据总内存大小设置缓冲区大小. 缓冲区: 作为主机与外设进行数据交互的中转站 */
    if (memory_end > 12*1024*1024)
        buffer_memory_end = 4*1024*1024;
    else if (memory_end > 6*1024*1024)
        buffer_memory_end = 2*1024*1024;
    else
        buffer_memory_end = 1*1024*1024;
    /* 缓冲区之后就是主内存. 主内存区是: 进程代码运行的空间，也包括内核管理进程的数据结构 */
    main_memory_start = buffer_memory_end;

    /* 如果有虚拟盘区,则将主内存区跟在虚拟盘区之后. 虚拟盘区: 可以选择将外设的数据复制进虚拟盘然后再加以使用 */
    #ifdef RAMDISK
    main_memory_start += rd_init(main_memory_start, RAMDISK*1024);
    #endif
    ......
}
```

先根据内存大小对缓冲区和主内存区的位置和大小的初步设置如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/init/memory_layout0.jpg

### 初始化虚拟盘(rd_init)

接下来将对外设中的虚拟盘区进行设置. 检查makefile文件中"虚拟盘使用标志"是否设置, 以此确定本系统
是否使用了虚拟盘. 我们在开始假设了所用计算机有16 MB的内存, 有虚拟盘, 且将虚拟盘大小设置为2 MB.
操作系统从缓冲区的末端起开辟2 MB内存空间设置为虚拟盘, 主内存起始位置后移2 MB至虚拟盘的末端.

path: init/main.c
```
void main(void)
{
#ifdef RAMDISK
    main_memory_start += rd_init(main_memory_start, RAMDISK*1024);
#endif
}
```

path: kernel/blk_drv/blk.h
```
#define NR_BLK_DEV 7
......
struct blk_dev_struct {
    void (*request_fn)(void);
    struct request * current_request;
};
......
#if (MAJOR_NR == 1)  // 虚拟盘
/* ram disk */
#define DEVICE_NAME "ramdisk"
#define DEVICE_REQUEST do_rd_request
#define DEVICE_NR(device) ((device) & 7)
#define DEVICE_ON(device)
#define DEVICE_OFF(device)

#elif (MAJOR_NR == 2)
......
#elif (MAJOR_NR == 3)
......
#elif
/* unknown blk device */
#error "unknown blk device"

#endif
```

path: kernel/blk_drv/ll_rw_blk.c
```
/* blk_dev_struct is:
 * do_request-address
 * next-request
 */
/* blk_dev的主要功能是将某一类设备与它对应的请求项处理函数挂钩, 可以看出我们讨论的操作系统最多
 * 可以管理6类设备.
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

初始化虚拟盘:

path: kernel/blk_drv/ramdisk.c
```
/*
 * Returns amount of memory which needs to be reserved.
 */
long rd_init(long mem_start, int length)
{
    int    i;
    char    *cp;
    /* 先要将虚拟盘区的请求项处理函数do_rd_request()与请求项函数控制结构blk_dev的第二项挂接
     * 这个挂接动作意味着以后内核能够通过调用do_rd_request函数处理与虚拟盘相关的请求项操作,
     * 挂接之后，将虚拟盘所在的内存区域全部初始化为0.
     */
    blk_dev[MAJOR_NR].request_fn = DEVICE_REQUEST;
    rd_start = (char *) mem_start;
    rd_length = length;
    cp = rd_start;
    for (i=0; i < length; i++)
        *cp++ = '\0'; /* 初始化为0 */
    /* 最后将虚拟盘区的长度值返回,这个返回值将用来重新设置主内存区的起始位置. */
    return(length);
}
```

设置完成后的物理内存的规划格局:
https://github.com/leeminghao/doc-linux/blob/master/0.11/init/memory_layout1.jpg

### 初始化内存管理结构mem_map

对主内存区起始位置的重新确定, 标志着主内存区和缓冲区的位置和大小已经全都确定了,
于是系统开始调用mem_init()函数, 先对主内存区的管理结构进行设置, 该过程如下所示:

path: init/main.c
```
void main(void)
{
    ......
    mem_init(main_memory_start,memory_end);
    ......
}
```

path: mm/memory.c
```
/* these are not to be changed without changing head.s etc */
#define LOW_MEM 0x100000                     // 16 MB的页数
#define PAGING_MEMORY (15*1024*1024)         // 分页内存 15MB,主内存区最多 15M.
#define PAGING_PAGES (PAGING_MEMORY>>12)     // 分页后的物理内存页数.
#define MAP_NR(addr) (((addr)-LOW_MEM)>>12)  // 指定内存地址映射为页号.
#define USED 100
......
static long HIGH_MEMORY = 0;                 // 全局变量,存放实际物理内存最高端地址.
......
static unsigned char mem_map [ PAGING_PAGES ] = {0,};
......
void mem_init(long start_mem, long end_mem)
{
    int i;

    HIGH_MEMORY = end_mem; // 设置内存最高端。
    for (i=0 ; i<PAGING_PAGES ; i++) // 首先置所有页面为已占用(USED=100)状态,
        mem_map[i] = USED; // 即将页面映射数组全置成 USED。
    i = MAP_NR(start_mem); // 然后计算可使用起始内存的页面号。
    // 再计算可分页处理的内存块大小,从而计算出可用于分页处理的页面数.
    end_mem -= start_mem;  // start_mem为6 MB(虚拟盘之后)
    end_mem >>= 12;        // 16 MB的页数
    // 最后将这些可用页面对应的页面映射数组清零.
    while (end_mem-->0)
        mem_map[i++]=0;
}
```

系统通过mem_map[]对1 MB以上的内存分页进行管理,记录一个页面的使用次数.
mem_init()函数先将所有的内存页面使用计数均设置成USED(100,即被使用),然后再将主内存中的所有页面
使用计数全部清零, 系统以后只把使用计数为0的页面视为空闲页面.

那么为什么系统对1 MB以内的内存空间不用这种分页方法管理呢?
这是因为操作系统的设计者对内核和用户进程采用了两套不同的分页管理方法:
* 内核采用分页管理方法,线性地址和物理地址是完全一样的,是一一映射的,等价于内核可以直接获得物理地址.
* 用户进程则不然, 线性地址和物理地址差异很大, 之间没有可递推的逻辑关系, 操作系统设计者的目的就是
让用户进程无法通过线性地址推算出具体的物理地址, 让内核能够访问用户进程，用户进程不能访问其他的
用户进程，更不能访问内核。

1 MB以内是内核代码和只有由内核管控的大部分数据所在内存空间, 是绝对不允许用户进程访问的.
1 MB以上,特别是主内存区主要是用户进程的代码,数据所在内存空间, 所以采用专门用来管理用户进程的
分页管理方法, 这套方法当然不能用在内核上.

### 初始化缓冲区

Linux 0.11通过hash_table[NR_HASH], buffer_head双向循环链表组成的复杂哈希表管理缓冲区.
缓冲区的初始化是通过buffer_init函数对缓冲区进行设置的，如下所示：

path: init/main.c
```
void main(void)
{
    ......
    buffer_init(buffer_memory_end);
    ......
}
```

path: fs/buffer.c
```
/* 这个end是内核代码末端的地址,这个值是在内核模块链接期间设置end这个值,
** 然后在这里使用.
*/
struct buffer_head * start_buffer = (struct buffer_head *) &end;
struct buffer_head * hash_table[NR_HASH];
static struct buffer_head * free_list;
......
/* 在buffer_init函数里,从内核的末端及缓冲区的末端开始,方向相对增长,配对的做出buffer_head,缓冲块
** 直到不足一对buffer_head, 缓冲块.
*/
void buffer_init(long buffer_end)
{
    struct buffer_head * h = start_buffer;
    void * b;
    int i;

    if (buffer_end == 1<<20)
        b = (void *) (640*1024);
    else
        b = (void *) buffer_end;
    /* h, b分别从缓冲区的低地址和高地址开始,每次取buffer_head, 缓冲块各一个.
     * 忽略剩余不足一对buffer_head, 缓冲块的空间
     */
    while ( (b -= BLOCK_SIZE) >= ((void *) (h+1)) ) {
        h->b_dev = 0;
        h->b_dirt = 0;
        h->b_count = 0;
        h->b_lock = 0;
        h->b_uptodate = 0;
        h->b_wait = NULL;
        /* 这两项初始化为NULL, 后续使用将与hash_table挂接 */
        h->b_next = NULL;
        h->b_prev = NULL;
        /* 每个buffer_head关联一个缓冲块 */
        h->b_data = (char *) b;
        /* 这两项使buffer_head分别与前,后buffer_head链接形成双链表 */
        h->b_prev_free = h-1;
        h->b_next_free = h+1;
        h++;
        NR_BUFFERS++;
        if (b == (void *) 0x100000) // 避开ROMBIOS & VGA
            b = (void *) 0xA0000;
    }
    h--;
    free_list = start_buffer;
    free_list->b_prev_free = h;
    h->b_next_free = free_list;
    for (i=0;i<NR_HASH;i++)
        hash_table[i]=NULL;
}
```

### 初始化块设备请求项数据结构

Linux 0.11将外设分为两类:
块设备: 将存储空间分为若干同样大小的称为块的存储空间,每个块有块号,可以独立,随机读写.
字符设备: 以字符为单位进行I/O通信.

进程要想与块设备进行沟通,必须经过主机内存中的缓冲区，请求项管理结构request[32]就是操作系统
与块设备上逻辑块之间读写关系的数据结构,如下所示:

kernel/blk_dev/blk.h
```
/*
 * NR_REQUEST is the number of entries in the request-queue.
 * NOTE that writes may use only the low 2/3 of these: reads
 * take precedence.
 *
 * 32 seems to be a reasonable number: enough to get some benefit
 * from the elevator-mechanism, but not so much as to lock a lot of
 * buffers when they are in the queue. 64 seems to be too many (easily
 * long pauses in reading when heavy writing/syncing is going on)
 */
#define NR_REQUEST    32

/*
 * Ok, this is an expanded form so that we can use the same
 * request for paging requests when that is implemented. In
 * paging, 'bh' is NULL, and 'waiting' is used to wait for
 * read/write completion.
 */
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
```

path: kernel/blk_drv/ll_rw_blk.c
```
/*
 * The request-struct contains all necessary data
 * to load a nr of sectors into memory
 */
struct request request[NR_REQUEST];
```

OS根据所有进程读写任务的轻重缓急,决定缓冲块与块设备之间的读写操作,并把需要操作的缓冲块
记录在请求项链表中，得到读写块设备的操作指令之后，只根据请求项中的记录来决定当前需要处理
哪个设备的哪个逻辑块. 请求项链表初始化过程如下所示:

path: init/main.c
```
void main(void)
{
    ......
    blk_dev_init();
    ......
}
```

path: kernel/blk_drv/ll_rw_blk.c
```
void blk_dev_init(void)
{
    int i;

    /* request[32]是一个由数组组成的链表 */
    for (i=0 ; i<NR_REQUEST ; i++) {
        request[i].dev = -1;
        request[i].next = NULL;
    }
}
```

### 初始化进程0

path: init/main.c
```
/* This really IS void, no error here. */
/* The startup routine assumes (well, ...) this */
void main(void)
{
    sched_init();
}
```

sched_init创建初始化进程0的过程如下所示:
https://github.com/leeminghao/doc-linux/blob/master/0.11/process/CreateProcess0.md

### 初始化硬盘

path: init/main.c
```
void main(void)
{
    ......
    hd_init();
    ......
}
```

path: kernel/blk_drv/blk.h
```
#if (MAJOR_NR == 1)
/* ram disk */
......
#elif (MAJOR_NR == 2)
/* floppy */
......
#elif (MAJOR_NR == 3)
/* harddisk */
#define DEVICE_NAME "harddisk"
#define DEVICE_INTR do_hd
#define DEVICE_REQUEST do_hd_request
#define DEVICE_NR(device) (MINOR(device)/5)
#define DEVICE_ON(device)
#define DEVICE_OFF(device)
#elif
/* unknown blk device */
#error "unknown blk device"
#endif
```

path: kernel/blk_drv/hd.c
```
void hd_init(void)
{
    /* 挂接do_hd_request函数 */
    blk_dev[MAJOR_NR].request_fn = DEVICE_REQUEST;
    /* 设置硬盘中断 */
    set_intr_gate(0x2E,&hd_interrupt);
    /* 允许8259A发出中断请求 */
    outb_p(inb_p(0x21)&0xfb,0x21);
    /* 允许硬盘发送中断请求 */
    outb(inb_p(0xA1)&0xbf,0xA1);
}
```