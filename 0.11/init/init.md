Linux 0.11 系统初始化
================================================================================

从开机加电到执行main函数过程
--------------------------------------------------------------------------------

### 大致过程

BIOS --> BOOTSECT --> SETUP --> SYSTEM --> main

跳转到main函数以后
--------------------------------------------------------------------------------

### 设置根设备,硬盘参数表

path: init/main.c
```
#define DRIVE_INFO (*(struct drive_info *)0x90080)  // 硬盘参数表
#define ORIG_ROOT_DEV (*(unsigned short *)0x901FC)  // 根设备号

......

struct drive_info { char dummy[32]; } drive_info;

/* This really IS void, no error here. */
/* The startup routine assumes (well, ...) this */
void main(void)
{
   /*
    * Interrupts are still disabled. Do necessary setups, then
    * enable them
    */
    ROOT_DEV = ORIG_ROOT_DEV;
    drive_info = DRIVE_INFO;
    ...
}
```

### 规划物理内存格局,设置缓冲区,虚拟盘,主内存

具体规划如下:
除内核代码和数据所占的内存空间外,其余物理内存主要分为三部分: 主内存区, 缓冲区和虚拟盘

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

### 初始化虚拟盘(rd_init)

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

    blk_dev[MAJOR_NR].request_fn = DEVICE_REQUEST;
    rd_start = (char *) mem_start;
    rd_length = length;
    cp = rd_start;
    for (i=0; i < length; i++)
        *cp++ = '\0'; /* 初始化为0 */
    return(length);
}
```