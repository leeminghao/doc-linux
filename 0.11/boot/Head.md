Linux Head程序的执行
================================================================================

在执行main函数之前,先要执行三个由汇编代码生成的程序,即bootsect,setup和head.之后,才执行由
main函数开始的用C语言编写的操作系统内核程序.

A. 加载bootsect到0x07C00, 然后复制到0x90000;

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/Bootsect.md

B. 加载setup到0x90200处执行.

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/Setup.md

*注意*: 这两段程序是分别加载,分别执行的.

head程序与它们的加载方式有所不同. 大致的过程是: 先将head.s汇编成目标代码, 将用C语言编写的内核程序编译成目标代码,
然后链接成system模块. 也就是说, system模块里面既有c编写的内核程序, 又有head程序. 两者是紧挨着的, head程序在前,
c内核程序在后, 所以head程序名字为"head". head程序在内存中占有25 KB?+?184 B的空间. system模块加载到内存后,
setup将system模块复制到0x00000位置, 由于head程序在system的前面, 所以实际上, head程序就在0x00000这个位置.

下面我们来分析head的详细执行流程:

设置保护模式下的寄存器
--------------------------------------------------------------------------------

现在head程序正式开始执行,一切都是为适应保护模式做准备. 其本质就是让CS的用法从实模式转变到保护模式.
在实模式下时: **CS本身就是代码段基址**. 在保护模式下时: **CS本身并不是代码段基址, 而是代码段选择符**.
经前面分析知, jmpi 0, 8这句代码使CS和GDT表的第2项关联, 并且使代码段的基址指向了0x000000.
从现在开始, 要将DS, ES, FS和GS等其他寄存器从实模式转变到保护模式. 执行代码如下:

path: boot/head.s
```
pg_dir:
.globl startup_32
startup_32:
    movl $0x10,%eax
    mov %ax,%ds
    mov %ax,%es
    mov %ax,%fs
    mov %ax,%gs
```

标号_pg_dir用于标识内核分页机制完成后的内核起始位置, 也就是物理内存的起始位置0x000000.
head程序马上就要在此处建立页目录表, 为分页机制做准备. 执行完毕后, DS,ES,FS和GS中的值都变为0x10.
与前面提到的jmpi 0，8中8的分析方法相同, 0x10也应看成二进制的00010000, 最后三位与前面讲解的一样,
其中最后两位的00表示内核特权级, 第3位的0表示选择GDT表, 第4,5两位的10是GDT表的2项,也就是第3项.
也就是说, 4个寄存器用的是同一个全局描述符, 它们的段基址,段限长和特权级都是相同的, 特别要注意的是,
影响段限长的关键字段的值是0x7ff, 段限长就是8MB.
如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/gdt_data_item.jpg

movl $0x10,%eax中的0x10是GDT表中的偏移值(用二进制表示就是10000), 即要参考GDT表中第2项的信息
(GDT表项号排序为第0项,第1项,第2项)来设置这些段寄存器,这一项就是内核数据段描述符.

SS现在也要转变为栈段选择符, 栈顶指针也成为32位的esp, 如下所示:

path: boot/head.s
```
    lss stack_start, %esp
```

在kernel/sched.c中, stack_start = { & user_stack [PAGE_SIZE>>2] , 0x10 }这行代码将栈顶指针
指向user_stack数据结构的最末位置, 这个数据结构是在kernel/sched.c中定义的, 如下所示:

path: kernel/sched.c
```
long user_stack [ PAGE_SIZE>>2 ] ;

struct {
    long * a;
    short b;
} stack_start = { & user_stack [PAGE_SIZE>>2] , 0x10 };
```

**注意**:
取段寄存器指令(Load Segment Instruction):
该组指令的功能是把内存单元的一个"低字"传送给指令中指定的16位寄存器,把随后的一个"高字"传给相应的段寄存器(DS,ES,FS,GS和SS).
其指令格式如下:

```
LDS/LES/LFS/LGS/LSS　Reg, Mem
```

指令LDS(Load Data Segment Register)和LES(Load Extra Segment Register)在8086CPU中就存在,
而LFS和LGS(Load Extra Segment Register),LSS(Load Stack Segment Register)是80386及其以后CPU中才有的指令.

A. 如果Reg是16位寄存器,那么Mem必须是32位指针;

B. 如果Reg是32位寄存器, 那么Men必须是48位指针, 其低32位给指令中指定的寄存器, 高16位给指令中的段寄存器.

0x10将SS的值设置为与前面4个段选择符的值相同. 这样, SS与前面讲解过的4个段选择符相同, 段基址都指向0x000000,
段限长都是8MB,特权级都是内核特权级,后面的压栈动作就要在这里进行.
现在刚刚从实模式转变到保护模式, 段基址的使用方法和实模式差别非常大, 要使用GDT产生段基址, 前面讲到的那几行
设置段选择符的指令本身都是要用GDT寻址的. 现在就能清楚地看出, 如果没有setup程序在16位实模式下模拟32位保护模式而创建的GDT,
恐怕前面这几行指令都无法执行.

设置IDT
--------------------------------------------------------------------------------

head程序接下来对中断描述符表进行设置, 代码如下所示:

path: boot/head.s
```
.text
.globl idt,gdt,pg_dir,tmp_floppy_area
pg_dir:
.globl startup_32
startup_32:
......
    lss stack_start,%esp
    call setup_idt
    call setup_gdt
......
/*
 *  setup_idt
 *
 *  sets up a idt with 256 entries pointing to
 *  ignore_int, interrupt gates. It then loads
 *  idt. Everything that wants to install itself
 *  in the idt-table may do so themselves. Interrupts
 *  are enabled elsewhere, when we can be relatively
 *  sure everything is ok. This routine will be over-
 *  written by the page tables.
 */
setup_idt:
    lea ignore_int,%edx
    movl $0x00080000,%eax
    movw %dx,%ax        /* selector = 0x0008 = cs */
    movw $0x8E00,%dx    /* interrupt gate - dpl=0, present */

    lea idt,%edi
    mov $256,%ecx
rp_sidt:
    movl %eax,(%edi)
    movl %edx,4(%edi)
    addl $8,%edi
    dec %ecx
    jne rp_sidt
    lidt idt_descr
    ret
......
ignore_int:
    pushl %eax
    pushl %ecx
    pushl %edx
    push %ds
    push %es
    push %fs
    movl $0x10,%eax
    mov %ax,%ds
    mov %ax,%es
    mov %ax,%fs
    pushl $int_msg
    call printk
    popl %eax
    pop %fs
    pop %es
    pop %ds
    popl %edx
    popl %ecx
    popl %eax
    iret
```

一个中断描述符的结构如下:

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/idt_item.jpg

中断描述符为64位, 包含了其对应中断服务程序的段内偏移地址(OFFSET),所在段选择符(SELECTOR),
段特权级(DPL),段存在标志(P), 段描述符类型(TYPE)等信息,供CPU在程序中需要进行中断服务时找到
相应的中断服务程序:
第0～15位和第48～63位组合成32位的中断服务程序的段内偏移地址;
第16～31位为段选择符(SELECTOR), 定位中断服务程序所在段;
第47位为段存在标志(P),用于标识此段是否存在于内存中,为虚拟存储提供支持;
第45～46位为特权级标志(DPL),特权级范围从0～3;
第40～43位为段描述符类型标志(TPYE), 中断描述符对应的类型标志为1110(0xE), 即将此段描述符标记为"386中断门".

这是重建保护模式下中断服务体系的开始,程序先让所有的中断描述符默认指向ignore_int这个位置
(将来main函数里面还要让中断描述符对应具体的中断服务程序), 之后还要对中断描述符表寄存器的值进行设置.
构造中断描述符表, 并使所有中断服务程序指向同一段只显示一行提示信息就返回的服务程序, 先使中断机制的整体架构搭建起来
(实际的中断服务程序挂接则在main函数中完成).从编程技术上讲, 这是一个占位的操作方式, 也防止了"野指针".

设置GDT
--------------------------------------------------------------------------------

现在, head程序要废除已有的GDT, 并在内核中的新位置重新创建全局描述符表,
其中第二项和第三项分别为内核代码段描述符和内核数据段描述符, 其段限长均被设置为16MB,
并设置全局描述符表寄存器的值. 代码执行如下所示:

path: boot/head.s
```
.text
.globl idt,gdt,pg_dir,tmp_floppy_area
pg_dir:
.globl startup_32
startup_32:
......
    lss stack_start,%esp
    call setup_idt
    call setup_gdt
......
/*
 *  setup_gdt
 *
 *  This routines sets up a new gdt and loads it.
 *  Only two entries are currently built, the same
 *  ones that were built in init.s. The routine
 *  is VERY complicated at two whole lines, so this
 *  rather long comment is certainly needed :-).
 *  This routine will beoverwritten by the page tables.
 */
setup_gdt:
    lgdt gdt_descr
    ret

......

gdt_descr:
    .word 256*8-1    # so does gdt (not that that's any
    .long gdt        # magic number, but it works for me :^)

    .align 8
idt:.fill 256,8,0        # idt is uninitialized

gdt:.quad 0x0000000000000000    /* NULL descriptor */
    .quad 0x00c09a0000000fff    /* 16Mb */
    .quad 0x00c0920000000fff    /* 16Mb */
    .quad 0x0000000000000000    /* TEMPORARY - don't use */
    .fill 252,8,0            /* space for LDT's and TSS's etc */
```

A. 为什么要废除原来的GDT而重新设置一套GDT呢?

原来GDT所在的位置是设计代码时在setup.s里面设置的, 将来这个setup模块所在的内存位置会在设计缓冲区时被覆盖.
如果不改变位置, GDT的内容将来肯定会被缓冲区覆盖掉, 从而影响系统的运行. 这样一来, 将来整个内存中唯一安全
的地方就是现在head.s所在的位置了.

B. 那么有没有可能在执行setup程序时直接把GDT的内容拷贝到head.s所在的位置呢?

肯定不能, 如果先复制GDT的内容, 后移动system模块, 它就会被后者覆盖掉; 如果先移动system模块, 后复制GDT的内容,
它又会把head.s对应的程序覆盖掉, 而这时head.s还没有执行呢. 所以, 无论如何都要重新建立GDT.

全局描述符表GDT的位置和内容发生了变化, 特别要注意最后的三位是fff, 说明段限长不是原来的8MB, 而是现在的16MB.
如果后面的代码第一次使用这几个段选择符就是访问8MB以后的地址空间, 将会产生段限长超限报警, 为了防止这类可能发生的情况,
这里再次对一些段选择符进行重新设置, 包括DS,ES,FS,GS和SS,主要是段限长增加了一倍,变为了16MB.
调整DS和ES等寄存器的对应代码如下:

path: boot/head.s
```
    movl $0x10,%eax    # reload all the segment registers
    mov %ax,%ds        # after changing gdt. CS was already
    mov %ax,%es        # reloaded in 'setup_gdt'
    mov %ax,%fs
    mov %ax,%gs
    lss stack_start,%esp
```

这是一种舍近求远的方法,其实只要在setup中构建第一个GDT表时把控制段限长的7ff直接设置为fff就可以一步到位了,
不需要在这里重新设置段选择符.

检验A20是否打开
--------------------------------------------------------------------------------

因为A20地址线是否打开是保护模式与实模式的根本区别, 所以, 现在要检验A20地址线是否确实打开了.
具体代码实现如下所示:

path: boot/head.s
```
    xorl %eax,%eax
1:  incl %eax        # check that A20 really IS enabled
    movl %eax,0x000000    # loop forever if it isn't
    cmpl %eax,0x100000
    je 1b
```

A20如果没有打开,则计算机处于实模式下,超过0xFFFFF寻址必然"回滚".
一个特例是0x100000就会回滚到0x000000,也就是说, 地址0x100000处存储的值必然和地址0x000000处存储
的值完全相同. 通过在内存0x000000位置写入一个数据, 然后比较此处和1MB(即0x100000，注意，已超过实模式寻址范围)
处数据是否一致，就可以检验A20地址线是否已打开.

检测数学处理器
--------------------------------------------------------------------------------

确定A20地址线已经打开之后, head程序如果检测到数学协处理器存在, 则将其设置为保护模式工作状态,
x87协处理器: 为了弥补x86系列在进行浮点运算时的不足, Intel于1980年推出了x87系列数学协处理器,
那时还是一个外置的, 可选的芯片(笔者当时的80386计算机上就没有安装80387协处理器). 1989年,
Intel发布了486处理器, 自此之后, CPU一般都内置了协处理器. 这样, 对于486以前的计算机而言, 操作系统检验x87协处理器是否存在就非常必要了。
检测数学协处理器对应的代码如下:

path: boot/head.s
```
/*
 * NOTE! 486 should set bit 16, to check for write-protect in supervisor
 * mode. Then it would be unnecessary with the "verify_area()"-calls.
 * 486 users probably want to set the NE (#5) bit also, so as to use
 * int 16 for math errors.
 */
    movl %cr0,%eax        # check math chip
    andl $0x80000011,%eax    # Save PG,PE,ET
    /* "orl $0x10020,%eax" here for 486 might be good */
    orl $2,%eax        # set MP
    movl %eax,%cr0
    call check_x87
```

为调用main函数作准备
--------------------------------------------------------------------------------

head程序将为调用main函数做最后的准备,这是head程序执行的最后阶段,也是main函数执行前的最后阶段.

path: boot/head.s
```
    call check_x87
    jmp after_page_tables
......
# Linus在代码中的原注释是“These are the parameters to main :-)”,
# 但实际上我们并没有看到,也没有测试到main函数使用这三个参数
after_page_tables:
    pushl $0        # These are the parameters to main :-)
    pushl $0
    pushl $0
# head程序将L6标号和main函数入口地址压栈，栈顶为main函数地址，目的是使head程序执行完后通过ret指令就可以直接执行main函数
# 如果main函数退出，就会返回到这里的标号L6处继续执行下去，并产生死循环。
    pushl $L6        # return address for main, if it decides to.
    pushl $main
    jmp setup_paging
L6:
    jmp L6            # main should never return here, but
                      # just in case, we know what happens.
```

安装页表
--------------------------------------------------------------------------------

这些压栈动作完成后, head程序将跳转至setup_paging, 去执行, 开始创建分页机制.
首先会将页目录表和4个页表放在物理内存的起始位置. 从内存起始位置开始的5页空间内容全部清零(每页4KB),
为初始化页目录和页表做准备.
*注意*: 这个动作起到了用一个页目录表和4个页表覆盖head程序自身所占内存空间的作用.

path: boot/head.s
```
/*
 * Setup_paging
 *
 * This routine sets up paging by setting the page bit
 * in cr0. The page tables are set up, identity-mapping
 * the first 16MB. The pager assumes that no illegal
 * addresses are produced (ie >4Mb on a 4Mb machine).
 *
 * NOTE! Although all physical memory should be identity
 * mapped by this routine, only the kernel page functions
 * use the >1Mb addresses directly. All "normal" functions
 * use just the lower 1Mb, or the local data space, which
 * will be mapped to some other place - mm keeps track of
 * that.
 *
 * For those with more memory than 16 Mb - tough luck. I've
 * not got it, why should you :-) The source is here. Change
 * it. (Seriously - it shouldn't be too difficult. Mostly
 * change some constants etc. I left it at 16Mb, as my machine
 * even cannot be extended past that (ok, but it was cheap :-)
 * I've tried to show which constants to change by having
 * some kind of marker at them (search for "16Mb"), but I
 * won't guarantee that's all :-( )
 */
.align 2

setup_paging:
    movl $1024*5,%ecx         /* 5 pages - pg_dir+4 page tables */
    xorl %eax,%eax
    xorl %edi,%edi            /* pg_dir is at 0x000 */
    cld;rep;stosl
    movl $pg0+7,pg_dir        /* set present bit/user r/w */
    movl $pg1+7,pg_dir+4      /*  --------- " " --------- */
    movl $pg2+7,pg_dir+8      /*  --------- " " --------- */
    movl $pg3+7,pg_dir+12     /*  --------- " " --------- */
    movl $pg3+4092,%edi
    movl $0xfff007,%eax       /*  16Mb - 4096 + 7 (r/w user,p) */
    std

# head程序将页目录表和4个页表所占物理内存空间清0后,设置页目录表的前4项, 使之分别指向4个页表,head程序设置完页目录表后,
# Linux 0.11在保护模式下支持的最大寻址地址为0xFFFFFF(16MB),此处将第4张页表(由pg3指向的位置)的最后一个页表项
# (pg3+4902指向的位置)指向寻址范围的最后一个页面, 即0xFFF000开始的4KB字节大小的内存空间。
# 然后开始从高地址向低地址方向填写全部的4个页表, 依次指向内存从高地址向低地址方向的各个页面,
# 继续设置页表. 将第4张页表(由pg3指向的位置)的倒数第二个页表项(pg3-4+4902指向的位置)指向倒数第二个页面，
# 即0xFFF000-0x1000(0x1000即4k，一个页面的大小)开始的4k字节内存空间. 最终,从高地址向低地址方向完成全部4个
# 页表的填写, 页表中的每一个页表项分别指向内存从高地址向低地址方向的各个页面, 这4个页表都是内核专属的页表,
# 将来每个用户进程都有它们专属的页表.
1:  stosl            /* fill pages backwards - more efficient :-) */
    subl $0x1000,%eax
    jge 1b
# 前两行的动作是将CR3指向页目录表, 意味着操作系统认定0x0000这个位置就是页目录表的起始位置,
# 后3行的动作是启动分页机制开关PG标志置位,以启用分页寻址模式,两个动作一气呵成,到这里为止, 内核的分页机制构建完毕.

# 下面这一行代码, 它看似简单, 但用意深远. 回过头来看, setup程序将system模块移动到0x00000,
# head在内存的起始位置建立内核分页机制, 认定页目录表在内存的起始位置, 三个动作联合起来为
# 操作系统中最重要的目的—内核控制用户程序奠定了基础,.
# 这个位置是内核通过分页机制能够实现线性地址等于物理地址的唯一起始位置.
    xorl %eax,%eax        /* pg_dir is at 0x0000 */
    movl %eax,%cr3        /* cr3 - page directory start */
    movl %cr0,%eax
    orl $0x80000000,%eax
    movl %eax,%cr0        /* set paging (PG) bit */
    ret            /* this also flushes prefetch-queue */
......
/*
 * I put the kernel page tables right after the page directory,
 * using 4 of them to span 16 Mb of physical memory. People with
 * more than 16MB will have to expand this.
 */
.org 0x1000
pg0:

.org 0x2000
pg1:

.org 0x3000
pg2:

.org 0x4000
pg3:
```

将页目录表和4个页表放在物理内存的起始位置,这个动作的意义重大,是操作系统能够掌控全局,掌控进程在内存中安全运行的基石之一.
这些工作完成后, 内存中的布局如下图:

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/memory_after_setup_page.jpg

可以看出, 只有184个字节的剩余代码, 由此可见在设计head程序和system模块时, 其计算是非常精确的, 对head.s的代码量的控制非常到位.
head程序已将页表设置完毕了，但分页机制的建立还没有完成。需要设置页目录基址寄存器CR3，使之指向页目录表，
再将CR0寄存器设置的最高位（31位）置为1，如下图的右中部CR0寄存器的示意图:

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/memory.jpg

* PG(Paging)标志:
CR0寄存器的第32位, 分页机制控制位. 当CPU的控制寄存器CR0第1位PE(保护模式)置为1时,可设置PG位为开启.
在开启后, 地址映射模式采取分页机制. 当CPU的控制寄存器CR0第1位PE(保护模式)置为0时, 此时设置PG位将引起CPU发出异常。
* CR3寄存器:
3号32位控制寄存器,高20位存放页目录的基地址.当CR0中的PG标志置位时,CPU使用CR3指向的页目录和页表进行虚拟地址到物理地址的映射.

跳转到main函数继续执行
--------------------------------------------------------------------------------

head程序执行最后一步: ret. 跳入main函数程序执行.
在上面程序中, main函数的入口地址被压入了栈顶, 现在执行ret了, 正好将压入的main函数的执行入口地址弹出给EIP.
出栈动作如下所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/jmp_main.jpg

我们先看看普通函数的调用和返回方法, 因为Linux 0.11 用返回方法调用main函数, 返回位置和main函数的入口在同一段内,
我们只讲解段内调用和返回:

CALL指令会将EIP的值自动压栈, 保护返回现场, 然后执行被调函数的程序. 等到执行被调函数的ret指令时,自动出栈给EIP并还原现场,
继续执行CALL的下一行指令. 这是通常的函数调用方法. 对操作系统的main来说, 这个方法就有些怪异了, main函数是操作系统的，
如果用CALL调用操作系统的main函数, 那么ret时返回给谁呢? 难道还有一个更底层的系统程序接收操作系统的返回吗?
操作系统已经是最底层的系统了, 所以逻辑上不成立. 那么如何既调用了操作系统的main函数, 又不需要返回呢?

可以用ret实现的调用操作系统的main函数, 既然是ret调用, 当然就不需要再用ret了. 不过, CALL做的压栈和跳转的动作谁来完成呢?
操作系统的设计者做了一个仿CALL的动作, 手工编写压栈和跳转代码，模仿了CALL的全部动作，实现了调用setup_paging函数.
注意, 压栈的EIP值并不是调用setup_paging函数的下一行指令的地址, 而是操作系统的main函数的执行入口地址_main.
这样,当setup_paging函数执行到ret时,从栈中将操作系统的main函数的执行入口地址_main自动出栈给EIP,EIP指向main函数的入口地址,
实现了用返回指令调用main函数. 将压入的main函数的执行入口地址弹出给CS:EIP, 这句话等价于CPU开始执行main函数程序.

至此, Linux 0.11操作系统内核启动的一个重要阶段已经完成, 接下来就要进入main函数对应的代码了.
需要特别提示的是, 此时仍处在关闭中断的状态!

head程序在完成如下工作以后:

**设置保护模式下寄存器** -->
**设置IDT/GDT** -->
**检验A20是否打开** -->
**检测数学处理器** -->
**为调用main函数准备** -->
**安装页表** -->
**返回到main执行**

跳转到main以后的执行:

https://github.com/leeminghao/doc-linux/blob/master/0.11/init/Main.md
