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

path: init/main.c
```
/* This really IS void, no error here. */
/* The startup routine assumes (well, ...) this */
void main(void)
{
    sched_init();
}
```

path: kernel/sched.c
```
void sched_init(void)
{
    int i;
    struct desc_struct * p;

    if (sizeof(struct sigaction) != 16)
        panic("Struct sigaction MUST be 16 bytes");
    set_tss_desc(gdt+FIRST_TSS_ENTRY,&(init_task.task.tss)); // set tss0
    set_ldt_desc(gdt+FIRST_LDT_ENTRY,&(init_task.task.ldt)); // set ldt0
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
    ltr(0);
    lldt(0);
    outb_p(0x36,0x43);              /* binary, mode 3, LSB/MSB, ch 0 */
    outb_p(LATCH & 0xff , 0x40);    /* LSB */
    outb(LATCH >> 8 , 0x40);        /* MSB */
    set_intr_gate(0x20,&timer_interrupt);
    outb(inb_p(0x21)&~0x01,0x21);
    set_system_gate(0x80,&system_call);
}
```

path: include/asm/system.h
```
#define _set_tssldt_desc(n,addr,type) \
__asm__ ("movw $104,%1\n\t" \
    "movw %%ax,%2\n\t" \
    "rorl $16,%%eax\n\t" \
    "movb %%al,%3\n\t" \
    "movb $" type ",%4\n\t" \
    "movb $0x00,%5\n\t" \
    "movb %%ah,%6\n\t" \
    "rorl $16,%%eax" \
    ::"a" (addr), "m" (*(n)), "m" (*(n+2)), "m" (*(n+4)), \
     "m" (*(n+5)), "m" (*(n+6)), "m" (*(n+7)) \
    )

#define set_tss_desc(n,addr) _set_tssldt_desc(((char *) (n)),((int)(addr)),"0x89")
#define set_ldt_desc(n,addr) _set_tssldt_desc(((char *) (n)),((int)(addr)),"0x82")
```

path: include/linux/sched.h
```
/*
 * Entry into gdt where to find first TSS. 0-nul, 1-cs, 2-ds, 3-syscall
 * 4-TSS0, 5-LDT0, 6-TSS1 etc ...
 */
#define FIRST_TSS_ENTRY 4
#define FIRST_LDT_ENTRY (FIRST_TSS_ENTRY+1)
#define _TSS(n) ((((unsigned long) n)<<4)+(FIRST_TSS_ENTRY<<3))
#define _LDT(n) ((((unsigned long) n)<<4)+(FIRST_LDT_ENTRY<<3))
#define ltr(n) __asm__("ltr %%ax"::"a" (_TSS(n)))
#define lldt(n) __asm__("lldt %%ax"::"a" (_LDT(n)))
```