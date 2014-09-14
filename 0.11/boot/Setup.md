Linux Setup模块的执行
================================================================================

在bootsect程序将setup程序加载到0x90200位置处:

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/Bootsect.md

之后便跳转到0x90200位置处执行setup程序，执行过程如下所示:

利用ROM BIOS中断读取机器系统数据
--------------------------------------------------------------------------------

setup程序的作用主要是利用ROM BIOS中断读取机器系统数据,并将这些数据保存到0x90000开始的位置
(覆盖掉了bootsect 程序所在的地方).这些参数将被内核中相关程序使用.

path: boot/setup.s
```
    mov    ax,#INITSEG    ! this is done in bootsect already, but...
                          ! 将 ds 置成#INITSEG(0x9000)。这已经在 bootsect 程序中
                          ! 设置过,但是现在是 setup 程序,Linus 觉得需要再重新
                          ! 设置一下。

    mov    ds,ax
    mov    ah,#0x03    ! read cursor pos
    xor    bh,bh
    int    0x10        ! save it in known place, con_init fetches
    mov    [0],dx        ! it from 0x90000.
! Get memory size (extended mem, kB)

    mov    ah,#0x88
    int    0x15
    mov    [2],ax

! Get video-card data:

    mov    ah,#0x0f
    int    0x10
    mov    [4],bx        ! bh = display page
    mov    [6],ax        ! al = video mode, ah = window width

! check for EGA/VGA and some config parameters

    mov    ah,#0x12
    mov    bl,#0x10
    int    0x10
    mov    [8],ax
    mov    [10],bx
    mov    [12],cx

! Get hd0 data

    mov    ax,#0x0000
    mov    ds,ax
    lds    si,[4*0x41]
    mov    ax,#INITSEG
    mov    es,ax
    mov    di,#0x0080
    mov    cx,#0x10
    rep
    movsb

! Get hd1 data

    mov    ax,#0x0000
    mov    ds,ax
    lds    si,[4*0x46]
    mov    ax,#INITSEG
    mov    es,ax
    mov    di,#0x0090
    mov    cx,#0x10
    rep
    movsb

! Check that there IS a hd1 :-)

    mov    ax,#0x01500
    mov    dl,#0x81
    int    0x13
    jc    no_disk1
    cmp    ah,#3
    je    is_disk1
no_disk1:
    mov    ax,#INITSEG
    mov    es,ax
    mov    di,#0x0090
    mov    cx,#0x10
    mov    ax,#0x00
    rep
    stosb
is_disk1:
```

执行完上述程序以后, setup获取到的系统参数信息如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/system_machine_table.png

移动system模块到内存起始位置0x00000
--------------------------------------------------------------------------------

这个准备工作先要关闭中断，即将CPU的标志寄存器(EFLAGS)中的中断允许标志(IF)置0。这意味着，程序在
接下来的执行过程中,无论是否发生中断，系统都不再对此中断进行响应，直到main函数中能够适应保护模式
的中断服务体系被重建完毕才会打开中断，而那时候响应中断的服务程序将不再是BIOS提供的中断服务程序，
取而代之的是由系统自身提供的中断服务程序。代码如下:

path: boot/setup.s
```
! now we want to move to protected mode ...

    cli            ! no interrupts allowed !
```

EFLAGS: 标志寄存器，存在于CPU中，32位，包含一组状态标志, 控制标志及系统标志.
如第0位的CF(Carry Flag)为CPU计算用到的进位标志;第9位IF(Interrupt Flag)中断允许标志.

关中断(cli)和开中断(sti)操作将在操作系统代码中频繁出现，其意义深刻.cli,sti总是在一个完整操作
过程的两头出现，目的是避免中断在此期间的介入.接下来的代码将为操作系统进入保护模式做准备.
此处即将进行实模式下中断向量表和保护模式下中断描述符表(IDT)的交接工作.

试想? 如果没有cli，又恰好发生中断，如用户不小心碰了一下键盘，中断就要切进来，就不得不面对实模式
的中断机制已经废除, 保护模式的中断机制尚未完成的尴尬局面，结果就是系统崩溃。cli,sti保证了这个
过程中,IDT能够完整创建，以避免不可预料中断的进入造成IDT创建不完整或新老中断机制混用。甚至可以
理解为cli,sti是为了保护一个新的计算机生命的完整而创建的。

下面, setup程序做了一个影响深远的动作: 将位于0x10000的内核程序复制至内存地址起始位置0x00000处.

代码如下:
path: boot/setup.s
```
! first we move the system to it's rightful place

    mov    ax,#0x0000
    cld            ! 'direction'=0, movs moves forward
do_move:
    mov    es,ax        ! destination segment
    add    ax,#0x1000
    cmp    ax,#0x9000
    jz    end_move
    mov    ds,ax        ! source segment
    sub    di,di
    sub    si,si
    mov     cx,#0x8000
    rep
    movsw
    jmp    do_move
```

0x00000这个位置原来存放着由BIOS建立的中断向量表及BIOS数据区. 这个复制动作将BIOS中断向量表和
BIOS数据区完全覆盖，使它们不复存在。直到新的中断服务体系构建完毕之前，操作系统不再具备响应并
处理中断的能力。现在，我们开始体会到关中断操作的意义。

这样做能取得“一箭三雕”的效果：

 A. 废除BIOS的中断向量表,等同于废除了BIOS提供的实模式下的中断服务程序;

 B. 收回刚刚结束使用寿命的程序所占内存空间;

 C. 让内核代码占据内存物理地址最开始的,天然的,有利的位置.

"破旧立新" 这个成语用在这里特别贴切. system模块复制到0x00000这个动作, 废除了BIOS的中断向量表,
也就是废除了16位的中断机制. 操作系统是不能没有中断的，对外设的使用,系统调用,进程调度都离不开
中断. Linux操作系统是32位的现代操作系统，16位的中断机制对32位的操作系统而言,显然是不合适的，
这也是废除16位中断机制的根本原因. 为了建立32位的操作系统, 我们不但要"破旧"，还要"立新" -- 建立新的中断机制.

设置中断描述符表和全局描述符表
--------------------------------------------------------------------------------

setup程序继续为保护模式做准备. 此时要通过setup程序自身提供的数据信息对中断描述符表寄存器(IDTR)
和全局描述符表寄存器(GDTR)进行初始化设置.

* GDT(Global Descriptor Table，全局描述符表): 在系统中唯一的存放段寄存器内容(段描述符)的数组,配合
程序进行保护模式下的段寻址.它在操作系统的进程切换中具有重要意义,可理解为所有进程的总目录表, 其中
存放每一个任务(task)局部描述符表(LDT，Local Descriptor Table)地址和任务状态段(TSS,Task Structure
Segment)地址,完成进程中各段的寻址,现场保护与现场恢复.
* GDTR(Global Descriptor Table Register，GDT基地址寄存器), GDT可以存放在内存的任何位置. 当程序
通过段寄存器引用一个段描述符时, 需要取得GDT的入口, GDTR标识的即为此入口. 在操作系统对GDT的初始化
完成后,可以用LGDT(Load GDT)指令将GDT基地址加载至GDTR.
* IDT(Interrupt Descriptor Table，中断描述符表),保存保护模式下所有中断服务程序的入口地址,类似于
实模式下的中断向量表.
* IDTR(Interrupt Descriptor Table Register，IDT基地址寄存器)，保存IDT的起始地址.

代码实现如下所示:

path: boot/setup.s
```
! then we load the segment descriptors

end_move:
    mov     ax,#SETUPSEG  ! right, forgot this at first. didn't work :-)
    mov     ds,ax
    lidt    idt_48        ! load idt with 0,0
    lgdt    gdt_48        ! load gdt with whatever appropriate
......
gdt:
    .word    0,0,0,0      ! dummy

    .word    0x07FF        ! 8Mb - limit=2047 (2048*4096=8Mb)
    .word    0x0000        ! base address=0
    .word    0x9A00        ! code read/exec
    .word    0x00C0        ! granularity=4096, 386

    .word    0x07FF        ! 8Mb - limit=2047 (2048*4096=8Mb)
    .word    0x0000        ! base address=0
    .word    0x9200        ! data read/write
    .word    0x00C0        ! granularity=4096, 386

idt_48:
    .word    0            ! idt limit=0
    .word    0,0            ! idt base=0L

gdt_48:
    .word    0x800        ! gdt limit=2048, 256 GDT entries
    .word    512+gdt,0x9    ! gdt base = 0X9xxxx

.text
endtext:
.data
enddata:
.bss
endbss:
```

32位的中断机制和16位的中断机制,在原理上有比较大的差别:

A. 最明显的是16位的中断机制用的是中断向量表,中断向量表的起始位置在0x00000处,这个位置是固定的;

B. 32位的中断机制用的是中断描述符表(IDT), 位置是不固定的, 可以由操作系统的设计者根据设计要求灵活安排, 由IDTR来锁定其位置.

GDT是保护模式下管理段描述符的数据结构，对操作系统自身的运行以及管理、调度进程有重大意义.
因为, 此时此刻内核尚未真正运行起来, 还没有进程,所以现在创建的GDT第一项为空,第二项为内核代码段描述符第三项为内核数据段描述符,其余项皆为空.

IDT虽然已经设置,实为一张空表,原因是目前已关中断,无需调用中断服务程序.此处反映的是数据"够用即得"的思想.

创建这两个表的过程可理解为是分两步进行的:

A. 在设计内核代码时,已经将两个表写好,并且把需要的数据也写好.

B. 将专用寄存器(IDTR,GDTR)指向表.

此处的数据区域是在内核源代码中设定,编译并直接加载至内存形成的一块数据区域.专用寄存器的指向由
程序中的lidt和lgdt指令完成.

值得一提的是,在内存中做出数据的方法有两种:

A. 划分一块内存区域并初始化数据,"看住"这块内存区域,使之能被找到;

B. 由代码做出数据,如用push代码压栈,"做出"数据.

此处采用的是第一种方法.

打开A20,实现32位寻址
--------------------------------------------------------------------------------

打开A20,意味着CPU可以进行32位寻址,最大寻址空间为4 GB. 内存范围变化: 从5个F扩展到8个F,即:0xFFFFFFFF--4 GB.
Linux 0.11最大只能支持16 MB的物理内存，但是其线性寻址空间已经是不折不扣的4 GB.
具体实现如下所示:

path: boot/setup.s
```
! that was painless, now we enable A20

    call    empty_8042
    mov     al,#0xD1        ! command write
    out     #0x64,al
    call    empty_8042
    mov     al,#0xDF        ! A20 on
    out     #0x60,al
    call    empty_8042
......
! This routine checks that the keyboard command queue is empty
! No timeout is used - if this hangs there is something wrong with
! the machine, and we probably couldn't proceed anyway.
empty_8042:
    .word    0x00eb,0x00eb
    in       al,#0x64    ! 8042 status port
    test     al,#2       ! is input buffer full?
    jnz      empty_8042  ! yes - loop
    ret
```

实模式下CPU寻址范围为0～0xFFFFF,共1 MB寻址空间,需要0～19号共20根地址线.进入保护模式后,将使用32
位寻址模式,即采用32根地址线进行寻址,第21根(A20)至第32根地址线的选通控制将意味着寻址模式的切换.

实模式下,当程序寻址超过0xFFFFF时,CPU将"回滚"至内存地址起始处寻址(注意,在只有20根地址线的条件下,
0xFFFFF+1=0x00000，最高位溢出).例如，系统的段寄存器(CS)的最大允许地址为0xFFFF,指令指针(IP)的
最大允许段内偏移也为0xFFFF,两者确定的最大绝对地址为0x10FFEF,这将意味着程序中可产生的实模式下的
寻址范围比1 MB多出将近64 KB(一些特殊寻址要求的程序就利用了这个特点). 这样，此处对A20地址线的启用
相当于关闭CPU在实模式下寻址的"回滚"机制。在后续代码中也将看到利用此特点来验证A20地址线是否确实
已经打开.

初始化可编程中断控制器8259A
--------------------------------------------------------------------------------

为了建立保护模式下的中断机制，setup程序将对可编程中断控制器8259A进行重新编程。
8259A: 专门为了对8085A和8086/8088进行中断控制而设计的芯片,是可以用程序控制的中断控制器.单个的
8259A能管理8级向量优先级中断,在不增加其他电路的情况下,最多可以级联成64级的向量优先级中断系统.
具体代码如下：

path: boot/setup.s
```
! well, that went ok, I hope. Now we have to reprogram the interrupts :-(
! we put them right after the intel-reserved hardware interrupts, at
! int 0x20-0x2F. There they won't mess up anything. Sadly IBM really
! messed this up with the original PC, and they haven't been able to
! rectify it afterwards. Thus the bios puts interrupts at 0x08-0x0f,
! which is used for the internal hardware interrupts as well. We just
! have to reprogram the 8259's, and it isn't fun.

    mov    al,#0x11        ! initialization sequence
    out    #0x20,al        ! send it to 8259A-1
    .word    0x00eb,0x00eb        ! jmp $+2, jmp $+2
    out    #0xA0,al        ! and to 8259A-2
    .word    0x00eb,0x00eb
    mov    al,#0x20        ! start of hardware int's (0x20)
    out    #0x21,al
    .word    0x00eb,0x00eb
    mov    al,#0x28        ! start of hardware int's 2 (0x28)
    out    #0xA1,al
    .word    0x00eb,0x00eb
    mov    al,#0x04        ! 8259-1 is master
    out    #0x21,al
    .word    0x00eb,0x00eb
    mov    al,#0x02        ! 8259-2 is slave
    out    #0xA1,al
    .word    0x00eb,0x00eb
    mov    al,#0x01        ! 8086 mode for both
    out    #0x21,al
    .word    0x00eb,0x00eb
    out    #0xA1,al
    .word    0x00eb,0x00eb
    mov    al,#0xFF        ! mask off all interrupts for now
    out    #0x21,al
    .word    0x00eb,0x00eb
    out    #0xA1,al
```

CPU在保护模式下, int 0x00～int 0x1F被Intel保留作为内部(不可屏蔽)中断和异常中断.如果不对8259A
进行重新编程,int 0x00～int 0x1F中断将被覆盖. 例如,IRQ0(时钟中断)为8号(int 0x08)中断,但在保护模式下
此中断号是Intel保留的“Double Fault”(双重故障).因此，必须通过8259A编程将原来的IRQ0x00～IRQ0x0F对
应的中断号重新分布,即在保护模式下,IRQ0x00～IRQ0x0F的中断号是int 0x20～int 0x2F。
重新编程的结果如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/int_8259a.jpg

设置CPU工作模式为保护模式
--------------------------------------------------------------------------------

setup程序通过下面代码的前两行将CPU工作方式设为保护模式.将CR0寄存器第0位(PE)置1,即设定处理器
工作方式为保护模式.
CR0寄存器: 0号32位控制寄存器,存放系统控制标志.第0位为PE(Protected Mode Enable,保护模式使能)标志,
置1时CPU工作在保护模式下,置0时为实模式.
具体代码如下:

path: boot/setup.s
```
! well, that certainly wasn't fun :-(. Hopefully it works, and we don't
! need no steenking BIOS anyway (except for the initial loading :-).
! The BIOS-routine wants lots of unnecessary data, and it's less
! "interesting" anyway. This is how REAL programmers do it.
!
! Well, now's the time to actually move into protected mode. To make
! things as simple as possible, we do no register set-up or anything,
! we let the gnu-compiled 32-bit programs do that. We just jump to
! absolute address 0x00000, in 32-bit protected mode.
    mov    ax,#0x0001    ! protected mode (PE) bit
    lmsw    ax        ! This is it!
    jmpi    0,8        ! jmp offset 0 of segment 8 (cs)
```

CPU工作方式转变为保护模式,一个重要的特征就是要根据GDT决定后续执行哪里的程序.
开启保护模式前后工作对比图如下所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/protect_before_and_after.jpg

跳转到system模块head程序继续执行
--------------------------------------------------------------------------------

setup程序在完成如下流程后:

**利用ROM BIOS获取系统机器数据** -->
**移动system模块到内存0x00000** -->
**设置IDT与GDT** -->
**打开A20,实现32位寻址** -->
**初始化可编程中断控制器8259A** -->
 **设置CPU工作模式为保护模式**

接下来将要跳转到system模块中的head程序执行,如下所示:

path: boot/setup.s
```
jmpi 0,8
```

这一行代码中的"0"是段内偏移,"8"是保护模式下的段选择符,用于选择描述符表和描述符表项以及所要求的
特权级. 这里"8"的解读方式很有意思. 如果把"8"当做6,7,8...中的"8"这个数来看待,这行程序的意思就
很难理解了. 必须把"8"看成二进制的1000,再把前后相关的代码联合起来当做一个整体看, 注意：这是一个
以位为操作单位的数据使用方式,4 bit的每一位都有明确的意义，这是底层源代码的一个特点.
这里1000的最后两位(00)表示内核特权级,与之相对的用户特权级是11; 第三位的0表示GDT,如果是1,则表示
LDT; 1000的1表示所选的表(在此就是GDT)的1项(GDT项号排序为0项,1项,2项,这里也就是第2项)来确定
代码段的段基址和段限长等信息.

从下图我们可以看到,代码是从段基址0x00000000,偏移为0处,也就是head程序的开始位置开始执行的,这意味着执行head程序.

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/gdt_code_item.jpg

接下来便要跳转到head程序处执行:

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/Head.md