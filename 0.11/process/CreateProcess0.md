Linux 0.11 进程0
================================================================================

初始化进程0
--------------------------------------------------------------------------------

进程0是Linux操作系统中运行的第一个进程, 也是Linux操作系统父子进程创建机制的第一个父进程.

A. 系统先初始化进程0.
 进程0管理结构task_struct的母本(init_task = {INIT_TASK,})已经在代码设计阶段事先设计好了, 但这并不代表进程0已经可用了,
 还要将进程0的task_struct中的LDT,TSS与GDT相挂接, 并对GDT,task[64]以及与进程调度相关的寄存器进行初始化设置.

B. Linux 0.11作为一个现代操作系统, 其最重要的标志就是能够支持多进程轮流执行, 这要求进程具备参与多进程轮询的能力.
 系统这里对时钟中断进行设置, 以便在进程0运行后, 为进程0以及后续由它直接, 间接创建出来的进程能够参与轮转奠定基础.

C. 进程0要具备处理系统调用的能力. 每个进程在运算时都可能需要与内核进行交互, 而交互的端口就是系统调用程序.
 系统通过函数set_system_gate将system_call与IDT相挂接, 这样进程0就具备了处理系统调用的能力了.
 这个system_call就是系统调用的总入口。

进程0只有具备了以上三种能力才能保证将来在主机中正常地运行. 并将这些能力遗传给后续建立的进程.
这三点的实现都是在sched_init()函数中实现的, 具体代码如下:

path: kernel/sched.c
```
#define LATCH (1193180/HZ)
......
union task_union {
    struct task_struct task;
    char stack[PAGE_SIZE];
};
......
static union task_union init_task = {INIT_TASK,};
......
struct task_struct *current = &(init_task.task);
......
struct task_struct * task[NR_TASKS] = {&(init_task.task), };
......

void sched_init(void)
{
    int i;
    struct desc_struct * p;

    if (sizeof(struct sigaction) != 16)
        panic("Struct sigaction MUST be 16 bytes");
    set_tss_desc(gdt+FIRST_TSS_ENTRY,&(init_task.task.tss)); // set tss0
    set_ldt_desc(gdt+FIRST_LDT_ENTRY,&(init_task.task.ldt)); // set ldt0
    // 从gdt的6项, 即TSS1开始向上全部清零, 并且将进程槽从1往后的项清空, 0项为进程0所用
    p = gdt+2+FIRST_TSS_ENTRY;
    for(i=1;i<NR_TASKS;i++) {
        task[i] = NULL;
        p->a=p->b=0;
        p++;
        p->a=p->b=0;
        p++;
    }
    /* Clear NT, so that we won't have troubles with that later on */
    __asm__("pushfl ; andl $0xffffbfff,(%esp) ; popfl");
    ltr(0);  // 将TSS挂接到TR寄存器
    lldt(0); // 将LDT挂接到LDTR寄存器

    // 设置定时器
    outb_p(0x36,0x43);              /* binary, mode 3, LSB/MSB, ch 0 */
    // 每10毫秒一次时钟中断
    outb_p(LATCH & 0xff , 0x40);    /* LSB */
    outb(LATCH >> 8 , 0x40);        /* MSB */
    // 重要! 设置时钟中断，进程调度的基础
    set_intr_gate(0x20,&timer_interrupt);
    // 允许时钟中断
    outb(inb_p(0x21)&~0x01,0x21);
    // 重要! 设置系统调用总入口
    set_system_gate(0x80,&system_call);
}
```

gdt的声明如下所示:

path: include/linux/head.h
```
typedef struct desc_struct {
    unsigned long a,b;
} desc_table[256];

extern unsigned long pg_dir[1024];
extern desc_table idt,gdt;
```

sched_init函数比较难理解的是:
```
set_tss_desc(gdt+FIRST_TSS_ENTRY,&(init_task.task.tss)); // set tss0
set_ldt_desc(gdt+FIRST_LDT_ENTRY,&(init_task.task.ldt)); // set ldt0
```

这两行代码的目的就是要如下图表现的那样在GDT中初始化进程0所占的4,5两项,即初始化TSS0和LDT0:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/tss0_ldt0.jpg

path: include/asm/system.h
```
#define _set_tssldt_desc(n,addr,type) \
__asm__ ("movw $104,%1\n\t" \ // 将104, 即1101000存入描述符的第1,2字节
    "movw %%ax,%2\n\t" \      // 将tss或ldt基地址的低16位存入描述符的第3,4字节
    "rorl $16,%%eax\n\t" \    // 循环右移16位，即高、低字互换
    "movb %%al,%3\n\t" \      // 将互换完的第1字节，即地址的第3字节存入第5字节
    "movb $" type ",%4\n\t" \ // 将0x89或0x82存入第6字节
    "movb $0x00,%5\n\t" \     // 将0x00存入第7字节
    "movb %%ah,%6\n\t" \      // 将互换完的第2字节，即地址的第4字节存入第8字节
    "rorl $16,%%eax" \        // 复原eax
    ::"a" (addr), "m" (*(n)), "m" (*(n+2)), "m" (*(n+4)), \
     "m" (*(n+5)), "m" (*(n+6)), "m" (*(n+7)) \
    )

// n: gdt的项值; addr: tss或ldt的地址; 0x89对应tss，0x82对应ldt
#define set_tss_desc(n,addr) _set_tssldt_desc(((char *) (n)),((int)(addr)),"0x89")
#define set_ldt_desc(n,addr) _set_tssldt_desc(((char *) (n)),((int)(addr)),"0x82")
```

我们以TSS0为例,讲解如何拼接出段描述符结构:

TSS的段描述符:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/tss0_original.jpg

对比源代码, 注释和图, 可以看出:
movw $104,%1是将104赋给了段限长15:0的部分; 粒度G为0, 说明限长就是104字节,
而TSS除去struct i387_struct i387后长度正好是104字节;LDT是3×8=24字节, 所以104字节限长够用.
TSS的类型是0x89,即二进制的10001001,可以看出

```
movb $" type ",%4
```

在给type赋值1001的同时, 顺便将P,DPL,S字段都赋值好了. 同理，movb $0x00,%5在给段限长19:16
部分赋值0000的同时,顺便将G,D/B,保留,AVL字段都赋值好了.

最终拼接出的tss0段描述符如下所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/tss0_finish.jpg

path: include/linux/sched.h
```
/*
 * Entry into gdt where to find first TSS. 0-nul, 1-cs, 2-ds, 3-syscall
 * 4-TSS0, 5-LDT0, 6-TSS1 etc ...
 */
#define FIRST_TSS_ENTRY 4
#define FIRST_LDT_ENTRY (FIRST_TSS_ENTRY+1)
#define _TSS(n) ((((unsigned long) n)<<4)+(FIRST_TSS_ENTRY<<3))
// 计算任务0在GDT中的索引值.
// 左移三位的目的是将段选择符设置为索引GDT表，特权级为0
#define _LDT(n) ((((unsigned long) n)<<4)+(FIRST_LDT_ENTRY<<3))
#define ltr(n) __asm__("ltr %%ax"::"a" (_TSS(n)))
// 将段选择符保存到lldt寄存器中
#define lldt(n) __asm__("lldt %%ax"::"a" (_LDT(n)))

......

struct tss_struct {
    long    back_link;  /* 16 high bits zero */
    long    esp0;
    long    ss0;        /* 16 high bits zero */
    long    esp1;
    long    ss1;        /* 16 high bits zero */
    long    esp2;
    long    ss2;        /* 16 high bits zero */
    long    cr3;
    long    eip;
    long    eflags;
    long    eax,ecx,edx,ebx;
    long    esp;
    long    ebp;
    long    esi;
    long    edi;
    long    es;        /* 16 high bits zero */
    long    cs;        /* 16 high bits zero */
    long    ss;        /* 16 high bits zero */
    long    ds;        /* 16 high bits zero */
    long    fs;        /* 16 high bits zero */
    long    gs;        /* 16 high bits zero */
    long    ldt;       /* 16 high bits zero */
    long    trace_bitmap;    /* bits: trace 0, bitmap 16-31 */
    struct i387_struct i387;
};

struct task_struct {
    /* these are hardcoded - don't touch */
    long state;    /* -1 unrunnable, 0 runnable, >0 stopped */
    long counter;
    long priority;
    long signal;
    struct sigaction sigaction[32];
    long blocked;    /* bitmap of masked signals */
    /* various fields */
    int exit_code;
    unsigned long start_code,end_code,end_data,brk,start_stack;
    long pid,father,pgrp,session,leader;
    unsigned short uid,euid,suid;
    unsigned short gid,egid,sgid;
    long alarm;
    long utime,stime,cutime,cstime,start_time;
    unsigned short used_math;
    /* file system info */
    int tty;        /* -1 if no tty, so it must be signed */
    unsigned short umask;
    struct m_inode * pwd;
    struct m_inode * root;
    struct m_inode * executable;
    unsigned long close_on_exec;
    struct file * filp[NR_OPEN];
    /* ldt for this task 0 - zero 1 - cs 2 - ds&ss */
    struct desc_struct ldt[3];
    /* tss for this task */
    struct tss_struct tss;
};

/*
 *  INIT_TASK is used to set up the first task table, touch at
 * your own risk!. Base=0, limit=0x9ffff (=640kB)
 */
#define INIT_TASK \
/* state etc */    { 0,15,15, \
/* signals */      0,{{},},0, \
/* ec,brk... */    0,0,0,0,0,0, \
/* pid etc.. */    0,-1,0,0,0, \
/* uid etc */      0,0,0,0,0,0, \
/* alarm */        0,0,0,0,0,0, \
/* math */         0, \
/* fs info */      -1,0022,NULL,NULL,NULL,0, \
/* filp */         {NULL,}, \
                   { \
                   {0,0}, \
/* ldt */          {0x9f,0xc0fa00}, \ // 代码长 640K,基址 0x0,G=1,D=1,DPL=3,P=1 TYPE=0x0a
                   {0x9f,0xc0f200}, \ // 数据长 640K,基址 0x0,G=1,D=1,DPL=3,P=1 TYPE=0x02
                   }, \
/*tss*/            {0,PAGE_SIZE+(long)&init_task,0x10,0,0,0,0,(long)&pg_dir,\
                   0,0,0,0,0,0,0,0, \
                   0,0,0x17,0x17,0x17,0x17,0x17,0x17, \
                   _LDT(0),0x80000000, \
                   {} \
                   }, \
                   }
```

进程0的task_struct是由操作系统设计者事先写好的, 就是sched.h中的INIT_TASK, 并用INIT_TASK的指针
初始化task[64]的0项. 如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/task0.jpg

sched_init()函数接下来用for循环将task[64]除进程0占用的0项外的其余63项清空,同时将GDT的TSS1, LDT1往上的所有表项清零.

初始化进程0相关的管理结构的最后一步是非常重要的一步, 是将TR寄存器指向TSS0, LDTR寄存器指向LDT0,
这样, CPU就能通过TR,LDTR寄存器找到进程0的TSS0,LDT0, 也能找到一切和进程0相关的管理信息.

**注意**:

* 任务0的代码段和数据段基地址是0，段限长是640KB.
* 内核代码段和数据段的基地址是0，段限长是16MB.