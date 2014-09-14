Linux 0.11 跳转到main函数以后系统初始化
================================================================================

从开机加电到执行main函数过程
--------------------------------------------------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/Head.md

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
#define LOW_MEM 0x100000                     // 内存低端(1MB)
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

### 初始化异常中断服务程序

不论是用户进程还是系统内核都要经常使用中断或遇到很多异常情况需要处理, 如CPU在参与运算过程中,
可能会遇到除零错误,溢出错误,边界检查错误,缺页错误......免不了需要"异常处理".
中断技术也是广泛使用的, 系统调用就是利用中断技术实现的. 这些中断, 异常都需要具体的服务程序来执行.
trap_init()函数将中断, 异常处理的服务程序与IDT进行挂接, 逐步重建中断服务体系,支持内核,进程在主机
中的运算。挂接的具体过程如下所示:

path: init/main.c
```
void main(void)
{
    ......
    trap_init();
    ......
}
```

path: kernel/traps.c
```
void trap_init(void)
{
    int i;

    set_trap_gate(0,&divide_error);
    set_trap_gate(1,&debug);
    set_trap_gate(2,&nmi);
    set_system_gate(3,&int3);    /* int3-5 can be called from all */
    set_system_gate(4,&overflow);
    set_system_gate(5,&bounds);
    set_trap_gate(6,&invalid_op);
    set_trap_gate(7,&device_not_available);
    set_trap_gate(8,&double_fault);
    set_trap_gate(9,&coprocessor_segment_overrun);
    set_trap_gate(10,&invalid_TSS);
    set_trap_gate(11,&segment_not_present);
    set_trap_gate(12,&stack_segment);
    set_trap_gate(13,&general_protection);
    set_trap_gate(14,&page_fault);
    set_trap_gate(15,&reserved);
    set_trap_gate(16,&coprocessor_error);
    for (i=17;i<48;i++)
        set_trap_gate(i,&reserved);
    set_trap_gate(45,&irq13); // 协处理器

    outb_p(inb_p(0x21)&0xfb,0x21); // 允许主 8259A 芯片的 IRQ2 中断请求
    outb(inb_p(0xA1)&0xdf,0xA1);   // 允许主 8259A 芯片的 IRQ3 中断请求

    set_trap_gate(39,&parallel_interrupt);
}
```

path: include/asm/system.h
```
#define _set_gate(gate_addr,type,dpl,addr) \
__asm__ ("movw %%dx,%%ax\n\t" \  // 将edx的低字赋值给eax的低字
    "movw %0,%%dx\n\t" \         // %0对应第二个冒号后的第1行的"i"
    "movl %%eax,%1\n\t" \        // %1对应第二个冒号后的第2行的"o"
    "movl %%edx,%2" \            // %2对应第二个冒号后的第3行的"o"
    : \ // 这个冒号后面是输出，下面冒号后面是输入
    : "i" ((short) (0x8000+(dpl<<13)+(type<<8))), \ // 立即数
    "o" (*((char *) (gate_addr))), \   // 中断描述符前4个字节的地址
    "o" (*(4+(char *) (gate_addr))), \ // 中断描述符后4个字节的地址
    "d" ((char *) (addr)),"a" (0x00080000)) // "d"对应edx，"a"对应eax

#define set_intr_gate(n,addr) \
    _set_gate(&idt[n],14,0,addr)

#define set_trap_gate(n,addr) \
    _set_gate(&idt[n],15,0,addr)
```

这些代码的目的就是要拼出如下所示的中断描述符:

https://github.com/leeminghao/doc-linux/blob/master/0.11/init/idt_item.jpg

最终执行效果如下所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/init/installed_idt.jpg

example:
```
set_trap_gate（0,&divide_error）
set_trap_gate（n,addr）
_set_gate（&idt[n],15,0,addr）
_set_gate（gate_addr,type,dpl,addr）
```

可以看出: n是0; gate_addr是&idt[0]，也就是idt的第一项中断描述符的地址;
          type是15; dpl(描述符特权级)是0; addr是中断服务程序divide_error(void)的入口地址

"movw %%dx,%%ax\n\t" -- 是把edx的低字赋值给eax的低字;
 edx是(char *)(addr), 也就是&divide_error;
 eax的值是0x00080000, 这个数据在head.s中就提到过, 8应该看成1000, 每一位都有意义, 这样eax的值
 就是0x00080000+((char *)(addr)的低字), 其中的0x0008是段选择符;

"movw %0,%%dx\n\t" -- 是把(short)(0x8000+(dpl<<13)+(type<<8))赋值给dx.
 edx是(char *)(addr),也就是&divide_error。

 因为这部分数据是按位拼接的, 必须计算精确,如下:
 0x8000就是二进制的1000 0000 0000 0000；
 dpl是00，dpl<<13就是000 0000 0000 0000；
 type是15，type<<8就是1111 0000 0000；

加起来就是1000 1111 0000 0000, 这就是dx的值.
edx的计算结果就是(char *)(addr)的高字即&divide_error的高字 + 1000 1111 0000 0000.

"movl %%eax,%1\n\t" -- 是把eax的值赋给*((char *)(gate_addr)), 就是赋给idt[0]的前4字节.
"movl %%edx,%2" -- 是把edx的值赋给*(4+(char *)(gate_addr)), 就是赋给idt[0]的后4字节。
8字节合起来就是完整的idt[0].

IDT中的第一项除零错误中断描述符初始化完毕, 其余异常处理服务程序的中断描述符初始化过程大同小异.
后续介绍的所有中断服务程序与IDT的初始化基本上都是以这种方式进行的。

注意:
set_system_gate(n,addr)与set_trap_gate(n,addr)用的_set_gate(gate_addr,type,dpl,addr)是一样的;
差别是set_trap_gate的dpl是0，而set_system_gate的dpl是3. dpl为0的意思是只能由内核处理, dpl为3的意思是系统调用可以由3特权级(也就是用户特权级)调用。

32位中断服务体系是为适应"被动响应"中断信号机制而建立的.
其特点,技术路线是这样的:
一方面, 硬件产生信号传达给8259A, 8259A对信号进行初步处理并视CPU执行情况传递中断信号给CPU;
另一方面, CPU如果没有接收到信号, 就不断地处理正在执行的程序, 如果接收到信号, 就打断正在执行的程序并通过IDT找到具体的中断服务程序, 让其执行, 执行完后, 返回刚才打断的程序点继续执行. 如果又接收到中断信号, 就再次处理中断......

最原始的设计不是这样，那时候CPU每隔一段时间就要对所有硬件进行轮询，以检测它的工作是否完成，如果没有完成就继续轮询，这样就消耗了CPU处理用户程序的时间，降低了系统的综合效率。可见，CPU以“主动轮询”的方式来处理信号是非常不划算的。以“被动响应”模式替代“主动轮询”模式来处理主机与外设的I/O问题，是计算机历史上的一大进步。

### 初始化块设备请求项数据结构

Linux 0.11将外设分为两类:

* 块设备: 将存储空间分为若干同样大小的称为块的存储空间,每个块有块号,可以独立,随机读写.
* 字符设备: 以字符为单位进行I/O通信.

操作系统根据所有进程读写任务的轻重缓急, 决定缓冲块与块设备之间的读写操作, 并把需要操作的缓冲块记录在请求项上,
得到读写块设备操作指令后, 只根据请求项中的记录来决定当前需要处理哪个设备的哪个逻辑块.

进程要想与块设备进行沟通, 必须经过主机内存中的缓冲区, 请求项管理结构request[32]就是操作系统
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

### 初始化外设

Linus在操作系统源代码中本来设计了chr_dev_init()函数, 明显是要用这个函数初始化字符设备,但我们可以
看到这是一个空函数. Linus又设计了tty_init()函数, 内容就是初始化字符设备.
字符设备的初始化为进程与串行口(可以通信,连接鼠标...), 显示器以及键盘进行I/O通信准备工作环境,
主要是对串行口, 显示器, 键盘进行初始化设置, 以及与此相关的中断服务程序与IDT挂接.

path: init/main.c
```
/* This really IS void, no error here. */
/* The startup routine assumes (well, ...) this */
void main(void)
{
    tty_init();
}
```

在tty_init()函数中, 先调用rs_init()函数来设置串行口,再调用con_init()函数来设置显示器,
具体执行代码如下:

path: kernel/chr_drv/tty_io.c
```
void tty_init(void)
{
    rs_init();
    con_init();
}
```

#### 初始化串行口

path: kernel/chr_drv/serial.c
```
static void init(int port)
{
    outb_p(0x80,port+3);    /* set DLAB of line control reg */
    outb_p(0x30,port);      /* LS of divisor (48 -> 2400 bps */
    outb_p(0x00,port+1);    /* MS of divisor */
    outb_p(0x03,port+3);    /* reset DLAB */
    outb_p(0x0b,port+4);    /* set DTR,RTS, OUT_2 */
    outb_p(0x0d,port+1);    /* enable all intrs but writes */
    (void)inb(port);        /* read data port to reset things (?) */
}

void rs_init(void)
{
    set_intr_gate(0x24,rs1_interrupt); // 设置串行口1中断
    set_intr_gate(0x23,rs2_interrupt); // 设置串行口2中断

    init(tty_table[1].read_q.data); // 初始化串行口1
    init(tty_table[2].read_q.data); // 初始化串行口2

    outb(inb_p(0x21)&0xE7,0x21); // 允许IRQ3, IRQ4
}
```

tty_table的定义如下所示:

path: kernel/chr_drv/tty_io.c
```
struct tty_struct tty_table[] = {
    {
        {ICRNL,        /* change incoming CR to NL */
        OPOST|ONLCR,    /* change outgoing NL to CRNL */
        0,
        ISIG | ICANON | ECHO | ECHOCTL | ECHOKE,
        0,        /* console termio */
        INIT_C_CC},
        0,            /* initial pgrp */
        0,            /* initial stopped */
        con_write,
        {0,0,0,0,""},        /* console read-queue */
        {0,0,0,0,""},        /* console write-queue */
        {0,0,0,0,""}        /* console secondary queue */
    },{
        {0, /* no translation */
        0,  /* no translation */
        B2400 | CS8,
        0,
        0,
        INIT_C_CC},
        0,
        0,
        rs_write,
        {0x3f8,0,0,0,""},        /* rs 1 */
        {0x3f8,0,0,0,""},
        {0,0,0,0,""}
    },{
        {0, /* no translation */
        0,  /* no translation */
        B2400 | CS8,
        0,
        0,
        INIT_C_CC},
        0,
        0,
        rs_write,
        {0x2f8,0,0,0,""},        /* rs 2 */
        {0x2f8,0,0,0,""},
        {0,0,0,0,""}
    }
};
```

path: include/termios.h
```
struct termios {
    unsigned long c_iflag;        /* input mode flags */
    unsigned long c_oflag;        /* output mode flags */
    unsigned long c_cflag;        /* control mode flags */
    unsigned long c_lflag;        /* local mode flags */
    unsigned char c_line;        /* line discipline */
    unsigned char c_cc[NCCS];    /* control characters */
};
```

path: include/linux/tty.h
```
struct tty_queue {
    unsigned long data;
    unsigned long head;
    unsigned long tail;
    struct task_struct * proc_list;
    char buf[TTY_BUF_SIZE];
};

......

struct tty_struct {
    struct termios termios;
    int pgrp;
    int stopped;
    void (*write)(struct tty_struct * tty);
    struct tty_queue read_q;
    struct tty_queue write_q;
    struct tty_queue secondary;
};
```

#### 初始化显示器 & 键盘

A. 根据机器系统数据提供的显卡是“单色”还是“彩色”来设置配套信息。由于在Linux 0.11那个时代, 大部分
显卡器是单色的. 所以,

我们假设显卡的属性是:
单色EGA. 那么显存的位置就要被设置为0xb0000～0xb8000,索引寄存器端口被设置为0x3b4，数据寄存器端口
被设置为0x3b5, 再将显卡的属性——EGA这三个字符, 显示在屏幕上, 另外, 再初始化一些用于滚屏的变量,
其中包括滚屏的起始显存地址, 滚屏结束显存地址, 最顶端行号以及最低端行号.

B. 对键盘进行设置是先将键盘中断服务程序与IDT相挂接, 然后取消8259A中对键盘中断的屏蔽,
允许IRQ1发送中断信号, 通过先禁止键盘工作, 再允许键盘工作, 键盘便能够使用了.

初始化键盘和显示器的工作都是在con_init函数中实现的, 具体实现如下所示:

path: kernel/chr_dev/console.c
```
/*
 * These are set up by the setup-routine at boot-time:
 */

#define ORIG_X               (*(unsigned char *)0x90000)
#define ORIG_Y               (*(unsigned char *)0x90001)
#define ORIG_VIDEO_PAGE      (*(unsigned short *)0x90004)
#define ORIG_VIDEO_MODE      ((*(unsigned short *)0x90006) & 0xff)
#define ORIG_VIDEO_COLS      (((*(unsigned short *)0x90006) & 0xff00) >> 8)
#define ORIG_VIDEO_LINES     (25)
#define ORIG_VIDEO_EGA_AX    (*(unsigned short *)0x90008)
#define ORIG_VIDEO_EGA_BX    (*(unsigned short *)0x9000a)
#define ORIG_VIDEO_EGA_CX    (*(unsigned short *)0x9000c)

#define VIDEO_TYPE_MDA         0x10    /* Monochrome Text Display    */
#define VIDEO_TYPE_CGA         0x11    /* CGA Display             */
#define VIDEO_TYPE_EGAM        0x20    /* EGA/VGA in Monochrome Mode    */
#define VIDEO_TYPE_EGAC        0x21    /* EGA/VGA in Color Mode    */

/*
 *  void con_init(void);
 *
 * This routine initalizes console interrupts, and does nothing
 * else. If you want the screen to clear, call tty_write with
 * the appropriate escape-sequece.
 *
 * Reads the information preserved by setup.s to determine the current display
 * type and sets everything accordingly.
 */
void con_init(void)
{
    register unsigned char a;
    char *display_desc = "????";
    char *display_ptr;

    video_num_columns = ORIG_VIDEO_COLS;
    video_size_row = video_num_columns * 2;
    video_num_lines = ORIG_VIDEO_LINES;
    video_page = ORIG_VIDEO_PAGE;
    video_erase_char = 0x0720;

    if (ORIG_VIDEO_MODE == 7)            /* Is this a monochrome display? */
    {
        video_mem_start = 0xb0000;
        video_port_reg = 0x3b4;
        video_port_val = 0x3b5;
        if ((ORIG_VIDEO_EGA_BX & 0xff) != 0x10)
        {
            video_type = VIDEO_TYPE_EGAM;
            video_mem_end = 0xb8000;
            display_desc = "EGAm";
        }
        else
        {
            video_type = VIDEO_TYPE_MDA;
            video_mem_end    = 0xb2000;
            display_desc = "*MDA";
        }
    }
    else                                /* If not, it is color. */
    {
        video_mem_start = 0xb8000;
        video_port_reg    = 0x3d4;
        video_port_val    = 0x3d5;
        if ((ORIG_VIDEO_EGA_BX & 0xff) != 0x10)
        {
            video_type = VIDEO_TYPE_EGAC;
            video_mem_end = 0xbc000;
            display_desc = "EGAc";
        }
        else
        {
            video_type = VIDEO_TYPE_CGA;
            video_mem_end = 0xba000;
            display_desc = "*CGA";
        }
    }

    /* Let the user known what kind of display driver we are using */

    display_ptr = ((char *)video_mem_start) + video_size_row - 8;
    while (*display_desc)
    {
        *display_ptr++ = *display_desc++;
        display_ptr++;
    }

    /* Initialize the variables used for scrolling (mostly EGA/VGA)    */

    origin    = video_mem_start;
    scr_end    = video_mem_start + video_num_lines * video_size_row;
    top    = 0;
    bottom    = video_num_lines;

    gotoxy(ORIG_X,ORIG_Y);

    set_trap_gate(0x21,&keyboard_interrupt); // 设置键盘中断
    outb_p(inb_p(0x21)&0xfd,0x21); // 取消对键盘中断的屏蔽
    a=inb_p(0x61);
    outb_p(a|0x80,0x61); // 禁止键盘工作
    outb(a,0x61); // 再允许键盘工作
}
```

### 初始化开机启动时间

开机启动时间是大部分与时间相关的计算的基础:
操作系统中一些程序的运算需要时间参数; 很多事务的处理也都要用到时间, 比如文件修改的时间,
文件最近访问的时间, i节点自身的修改时间等.
有了开机启动时间, 其他时间就可据此推算出来.

具体执行步骤是:
CMOS是主板上的一个小存储芯片, 系统通过调用time_init()函数, 先对它上面记录的时间数据进行采集,
提取不同等级的时间要素，比如秒(time.tm_sec),分(time.tm_min),年(time.tm_year)等,然后对这些要素
进行整合, 并最终得出开机启动时间(startup_time).
执行代码如下:

path: init/main.c
```
#define CMOS_READ(addr) ({ \ // 读CMOS实时时钟信息
outb_p(0x80|addr,0x70); \    // 0x80|addr读CMOS地址，0x70写端口
inb_p(0x71); \               // 0x71读端口
})

#define BCD_TO_BIN(val) ((val)=((val)&15) + ((val)>>4)*10)

static void time_init(void)
{
    struct tm time;

    do {
        time.tm_sec = CMOS_READ(0);
        time.tm_min = CMOS_READ(2);
        time.tm_hour = CMOS_READ(4);
        time.tm_mday = CMOS_READ(7);
        time.tm_mon = CMOS_READ(8);
        time.tm_year = CMOS_READ(9);
    } while (time.tm_sec != CMOS_READ(0));
    BCD_TO_BIN(time.tm_sec);
    BCD_TO_BIN(time.tm_min);
    BCD_TO_BIN(time.tm_hour);
    BCD_TO_BIN(time.tm_mday);
    BCD_TO_BIN(time.tm_mon);
    BCD_TO_BIN(time.tm_year);
    time.tm_mon--;
    startup_time = kernel_mktime(&time); // 开机时间, 从1970年1月1日0时计算
}

...

/* This really IS void, no error here. */
/* The startup routine assumes (well, ...) this */
void main(void)
{
    time_init();
}
```

path: include/asm/io.h
```
#define outb_p(value,port) \  // 将value写到port
__asm__ ("outb %%al,%%dx\n" \
         "\tjmp 1f\n" \       // jmp到下面的第一个1:处, 目的是延迟
         "1:\tjmp 1f\n" \
         "1:"::"a" (value),"d" (port))

#define inb_p(port) ({ \
unsigned char _v; \
__asm__ volatile ("inb %%dx,%%al\n" \ // volatile，禁止编译器优化下列代码
                  "\tjmp 1f\n" \      // 延迟
                  "1:\tjmp 1f\n" \
                  "1:":"=a" (_v):"d" (port)); \
                  _v; \
                  })
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

path: include/linux/fs.h
```
struct buffer_head {
    char * b_data;            /* pointer to data block (1024 bytes) */
    unsigned long b_blocknr;    /* block number */
    unsigned short b_dev;        /* device (0 = free) */
    unsigned char b_uptodate;
    unsigned char b_dirt;        /* 0-clean,1-dirty */
    unsigned char b_count;        /* users using this block */
    unsigned char b_lock;        /* 0 - ok, 1 -locked */
    struct task_struct * b_wait;
    struct buffer_head * b_prev;
    struct buffer_head * b_next;
    struct buffer_head * b_prev_free;
    struct buffer_head * b_next_free;
};

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

整个高速缓冲区被划分成 1024 字节大小的缓冲块,正好与块设备上的磁盘逻辑块大小相同。高速缓
冲采用 hash 表和空闲缓冲块队列进行操作管理。在缓冲区初始化过程中,从缓冲区的两端开始,同时分
别设置缓冲块头结构和划分出对应的缓冲块。缓冲区的高端被划分成一个个 1024 字节的缓冲块,低端则
分别建立起对应各缓冲块的缓冲头结构 buffer_head,用于描述对应缓冲块的属性和把所有缓冲头连接成链表。
直到它们之间已经不能再划分出缓冲块为止。而各个buffer_head被链接成一个空闲缓冲块双向链表结构。
如下所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/init/buffer_init.png

https://github.com/leeminghao/doc-linux/blob/master/0.11/init/free_buffer_list.png

为了能够快速地在缓冲区中寻找请求的数据块是否已经被读入到缓冲区中, buffer.c程序使用了具有
307 个buffer_head 指针项的 hash 表结构。buffer_head 结构的指针 b_prev,b_next 就是用于hash
表中散列在同一项上多个缓冲块之间的双向连接。Hash表所使用的散列函数由设备号和逻辑块号组合而成:

https://github.com/leeminghao/doc-linux/blob/master/0.11/init/buffer_hashtable.png

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

### 初始化软盘

软盘和软盘驱动器可以分离, 合在一起才是一个整体, 为了方便起见, 软盘除特别声明之外都是指软盘驱动器
加软盘的整体. 软盘的初始化与硬盘的初始化类似, 区别是挂接的函数是do_fd_request, 初始化的是与软盘
相关的中断.
执行代码如下:

path: init/main.c
```
void main(void)
{
    ...
    floppy_init (); // 与hd_init()类似
    ...
}
```

path: kernel/floppy.c
```
void floppy_init(void)
{
    blk_dev[MAJOR_NR].request_fn= DEVICE_REQUEST; // 挂接do_fd_request()
    set_trap_gate(0x26,&floppy_interrupt);        // 设置软盘中断
    outb(inb_p(0x21)&～0x40,0x21);                // 允许软盘发送中断
}
```

### 开启中断

现在, 系统中所有中断服务程序都已经和IDT正常挂接, 这意味着中断服务体系已经构建完毕, 系统可以
在32位保护模式下处理中断, 重要意义之一是可以使用系统调用。
执行代码如下:

path: include/asm/system.h
```
#define sti() __asm__ ("sti"::)
```

path: init/main.c
```
void main(void)
{
    ...
    sti();
    ...
}
```

### 进程0特权级从0翻转到3,成为真正的进程

Linux操作系统规定:
除进程0之外, 所有进程都要由一个已有进程在3特权级下创建, 在Linux 0.11中, 进程0的代码和数据都是
由操作系统的设计者写在内核代码, 数据区, 并且, 此前处在0特权级, 严格说还不是真正意义上的进程.
为了遵守规则, 在进程0正式创建进程1之前, 要将进程0由0特权级转变为3特权级, 方法是调用
move_to_user_mode()函数, 模仿中断返回动作, 实现进程0的特权级从0转变为3.

执行代码如下所示:

path: init/main.c
```
void main(void)
{
    ...
    move_to_user_mode();
    ...
}
```

path: include/system.h
```
#define move_to_user_mode() \      // 模仿中断硬件压栈，顺序是ss、esp、eflags、cs、eip
__asm__("movl %%esp,%%eax\n\t" \
        "pushl $0x17\n\t" \        // SS进栈，0x17即二进制的10111（3特权级、LDT、数据段）
        "pushl %%eax\n\t" \        // ESP进栈
        "pushfl\n\t" \             // EFLAGS进栈
        "pushl $0x0f\n\t" \        // CS进栈，0x0f即1111（3特权级、LDT、代码段）
        "pushl $1f\n\t" \          // EIP进栈
        "iret\n" \                 // 出栈恢复现场、翻转特权级从0到3
        "1:\tmovl $0x17,%%eax\n\t" \ // 下面的代码使ds、es、fs、gs与ss一致
            "movw %%ax,%%ds\n\t" \
            "movw %%ax,%%es\n\t" \
            "movw %%ax,%%fs\n\t" \
            "movw %%ax,%%gs" \
   :::?ax?)
```

IA-32体系结构翻转特权级的方法之一是用中断:

当CPU接到中断请求时,能中断当前程序的执行序,将CS:EIP切换到相应的中断服务程序去执行,执行完毕又执行
iret指令返回被中断的程序继续执行.

这期间,CPU硬件还做了两件事: 一件是硬件保护现场和恢复现场, 另一件是可以翻转特权级.

中断与函数调用比较:

* 相同点:
从代码的执行序上看, 中断类似函数调用, 都是从一段正在执行的代码跳转到另一段代码执行,执行之后返回
原来的那段代码继续执行.为了保证执行完函数或中断服务程序的代码之后能准确返回原来的代码继续执行,
需要在跳转到函数或中断服务程序代码之前,将起跳点的下一行代码的CS:EIP的值压栈保存,保护现场.
函数或中断服务程序的代码执行完毕,再将栈中保存的值出栈给CS:EIP,此时的CS:EIP指向的就是起跳点的
下一行,恢复现场. 所以,CPU能准确地执行主调程序或被中断的程序.实际需要保护的寄存器还有EFLAGS等.

* 不同点:
中断与函数调用不同的是, 函数调用是程序员事先设计好的,知道在代码的哪个地方调用,编译器可以预先编译
出压栈保护现场和出栈恢复现场的代码; 而中断的发生是不可预见的,无法预先编译出保护、恢复的代码,只好
由硬件完成保护, 恢复的压栈, 出栈动作.所以,int指令会引发CPU硬件完成SS,ESP,EFLAGS,CS,EIP的值按序
进栈,同理,CPU执行iret指令会将栈中的值自动按反序恢复给这5个寄存器.

CPU响应中断的时候,根据DPL的设置,可以实现指定的特权级之间的翻转.前面的sched_init函数中的
set_system_gate（0x80,&system_call）就是设置的int 0x80中断由3特权级翻转到0特权级,3特权级的进程
做了系统调用int 0x80,CPU就会翻转到0特权级执行系统代码.同理,iret又会从0特权级的系统代码翻转回
3特权级执行进程代码.

move_to_user_mode()函数就是根据这个原理,利用iret实现从0特权级翻转到3特权级:

由于进程0的代码到现在一直处在0特权级,并不是从3特权级通过int翻转到0特权级的,栈中并没有int自动压栈
的5个寄存器的值.为了iret的正确使用,设计者手工写压栈代码模拟int的压栈,当执行iret指令时,CPU自动
将这5个寄存器的值按序恢复给CPU,CPU就会翻转到3特权级的段,执行3特权级的进程代码.

为了iret能翻转到3特权级,不仅手工模拟的压栈顺序必须正确,而且SS,CS的特权级还必须正确.
注意: 栈中的SS值是0x17,用二进制表示就是00010111,最后两位表示3,是用户特权级,倒数第3位是1,表示从
LDT中获取段描述符,第4～5位的10表示从LDT的第3项中得到进程栈段的描述符.

当执行iret时,硬件会按序将5个push压栈的数据分别出栈给SS,ESP,EFLAGS,CS,EIP. 压栈顺序与通常中断返回
时硬件的出栈动作一样,返回的效果也是一样的.

执行完move_to_user_mode( ),相当于进行了一次中断返回,进程0的特权级从0翻转为3,成为名副其实的进程.

在这里我们提到最多的就是栈，有关Linux 0.11的栈的介绍如下所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/misc/Stack.md

总结
--------------------------------------------------------------------------------

Linux 0.11跳转到main函数执行以后，其所做的初始化工作如下所示:

**设置根设备,硬盘参数表** --> **规划物理内存格局** --> **初始化虚拟盘** --> **初始化主内存管理结构** --> **初始化异常中断服务程序** --> **初始化块设备请求项数据结构** --> **初始化外设(串口，显示器，键盘)** --> **初始化开机启动时间** --> **创建并初始化进程0** --> **初始化缓冲区** --> **初始化硬盘** --> **初始化软盘** --> **开启中断** --> **进程0从特权级0翻转到3成为真正的进程**

Linux 0.11经过上面的初始化工作以后， 现在，计算机中已经有了一个名副其实的、3特权级的进程——进程0。
下面我们要详细讲解进程0做的第一项工作——创建进程1：

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/CreateProcess1.md