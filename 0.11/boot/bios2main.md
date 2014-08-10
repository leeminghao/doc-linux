Linux 0.11 从开机加电到main - x86
================================================================================

机器参数
--------------------------------------------------------------------------------

假定计算机是基于IA-32系列的CPU, 标准单色显示器, 标准键盘, 一个软驱, 一块硬盘,
16MB内存, 在内存开辟2MB内存作为虚拟盘, 并在BIOS中设置软驱为启动设备.

Linux 0.11 启动过程
--------------------------------------------------------------------------------

### 开机加电一瞬间

计算机RAM中, 什么都没有, 软盘里虽然有OS程序, 但是CPU逻辑电路只能执行内存中程序,
没有能力执行软盘中操作系统程序. 若要执行软盘中OS程序，必须将软盘中的OS程序加载到RAM中.

谁来负责加载软盘OS程序到RAM? --> BIOS

### BIOS启动

在开机加电一瞬间,RAM中什么都没有,没有任何程序在运行，没有OS程序，我们更无法人为的执行BIOS程序.

##### 那么BIOS程序是谁来执行?

既然用软件方法不能执行BIOS, 那么只能靠硬件方法完成了.

从硬件角度看, Intel 80x86系列的CPU可以分别在16位实模式和32位保护模式下运行, 为了兼容, 也为了解决
最开始的启动问题, Intel将所有80x86系列的CPU,包括最新型号的CPU硬件都设计为: **加电即进入16位实模式
状态运行**. 同时，将CPU硬件逻辑设计为加电瞬间强行将: **CS设置为0xF000, IP的值设置为0xFFF0**, 这样
CS:IP就指向了0xFFFF0这个地址位置, BIOS程序的第一条指令就设计在这个位置, 这是一个纯硬件的动作, 如果
此时这个位置没有可执行代码，计算机就此死机. 如果这个位置有可执行代码，计算机将从这里的代码开始，
沿着后续程序一直执行下去.

```
CS: 代码段寄存器，存在于CPU中，指向CPU当前执行代码在内存中的起始区域.
IP: 指令指针寄存器, 存在于CPU中，记录将要执行的指令在代码段内的偏移地址,和CS组合即为将要执行的
    指令内存地址. 实模式为物理地址，指令指针为16位，即IP; 保护模式下为线性地址，指令指针为32位，
    即EIP
```

###### BIOS开始执行

BIOS程序被固化在计算机主机板上的一块很小的ROM芯片里. 通常不同的主机板所用的BIOS也有所不同。
就启动部分而言，各种类型的BIOS的基本原理大致相似。为了便于大家理解，我们选用的BIOS程序只有8 KB，
所占地址段为0xFE000～0xFFFFF.现在CS:IP已经指向0xFFFF0这个位置了，这意味着BIOS开始启动了。
随着BIOS程序的执行，屏幕上会显示显卡的信息、内存的信息……说明BIOS程序在检测显卡、内存... 这期间，
有一项对启动(boot)操作系统至关重要的工作，那就是BIOS在内存中建立中断向量表和中断服务程序。

##### BIOS构建中断向量表和中断服务程序

BIOS程序在内存最开始的位置(0x00000)用1 KB的内存空间(0x00000～0x003FF)构建中断向量表，在紧挨着
它的位置用256字节的内存空间构建BIOS数据区(0x00400～0x004FF), 并在大约57KB以后的位置(0x0E05B)
加载了8 KB左右的与中断向量表相应的若干中断服务程序。

**注意**: 中断向量表中有256个中断向量,每个中断向量占4字节,其中两个字节是CS的值,两个字节是IP的值.
每个中断向量都指向一个具体的中断服务程序。

```
INT(Interrupt): 中断,顾名思义,中途打断一件正在进行中的事。
其最初的意思是: 外在的事件打断正在执行的程序,转而执行处理这个事件的特定程序,处理结束后,回到被
打断的程序继续执行.
```

##### 加载操作系统内核程序(bootsect)

一般,在开机的时候马上按F2键,屏幕上会显示一个BIOS画面,可以在里面设置启动设备。现在我们基本上都是
将硬盘设置为启动盘.Linux 0.11是1991年设计的操作系统,那时常用的启动设备是软驱以及其中的软盘。
站在体系结构的角度看，从软盘启动和从硬盘启动的基本原理和机制是类似的。

经过执行一系列BIOS代码之后,计算机完成了自检等操作. 由于我们把软盘设置为启动设备,计算机硬件体系
结构的设计与BIOS联手操作,会让CPU接收到一个int 0x19中断. CPU接收到这个中断后,会立即在中断向量表
中找到int 0x19中断向量。这个位置几乎紧挨着内存的0x00000位置。

接下来,中断向量把CPU中执行指令寄存器指向0x0E6F2,这个位置就是int 0x19相对应的中断服务程序的
入口地址。这个中断服务程序的作用就是把软盘第一扇区中的程序(512 B)加载到内存中的指定位置.
这个中断服务程序的功能是BIOS事先设计好的，代码是固定的，与Linux操作系统无关。无论Linux 0.11的
内核是如何设计的，这段BIOS程序所要做的就是“找到软盘”并“加载第一扇区”，其余的它什么都不知道，
也不必知道。

按照这个简单, "生硬"的规则, int 0x19中断向量所指向的中断服务程序，即启动加载服务程序，将软驱0号
磁头对应盘面的0磁道1扇区的内容复制至内存0x07C00处.

这个扇区里的内容就是Linux 0.11的引导程序 --> bootsect.

其作用是: 陆续把软盘中的操作系统程序载入内存.这样制作的第一扇区就称为启动扇区(boot sector).
第一扇区程序的载入,标志着Linux 0.11中的代码即将发挥作用了。

这是非常关键的动作,从此计算机开始和软盘上的操作系统程序产生关联.第一扇区中的程序由bootsect.s中的
汇编程序汇编而成(以后简称bootsect).这是计算机自开机以来, 内存中第一次有了Linux操作系统自己的代码,
虽然只是启动代码. 至此,已经把第一批代码bootsect从软盘载入计算机的内存了.下面的工作就是执行
bootsect把软盘的第二批, 第三批代码载入内存.

**注意**: BIOS程序固化在主机板上的ROM中，是根据具体的主机板而不是根据具体的操作系统设计的:

理论上, 计算机可以安装任何适合其安装的操作系统, 既可以安装Windows, 也可以安装Linux. 不难想象
每个操作系统的设计者都可以设计出一套自己的操作系统启动方案, 而操作系统和BIOS通常是由不同的
专业团队设计和开发的, 为了能协同工作，必须建立操作系统和BIOS之间的协调机制。与已有的操作系统
建立一一对应的协调机制虽然麻烦，但尚有可能，难点在于与未来的操作系统应该如何建立协调机制。

现行的方法是两头"约定"和"定位":

A. 对操作系统Linux 0.11而言, "约定"操作系统的设计者必须把最开始执行的程序"定位"在启动扇区
(软盘中的0盘面0磁道1扇区)，其余的程序可以依照操作系统的设计顺序加载在后续的扇区中。

B. 对BIOS而言, "约定"接到启动操作系统的命令, "定位"只从启动扇区把代码加载到0x07C00这个位置.
至于这个扇区中是否是启动程序, 是什么操作系统, 则不闻不问, 一视同仁. 如果不是启动代码, 只会
提示错误, 其余是用户的责任, 与BIOS无关。

在BIOS完成上述工作:
**构建中断向量表和中断服务程序** --> **加载bootsect**
之后接下来便要执行bootsect程序

### bootsect

BIOS已经把bootsect也就是引导程序载入内存了,现在它的作用就是把第二批和第三批程序陆续加载到内存中。
为了把第二批和第三批程序加载到内存中的适当位置，bootsect首先做的工作就是规划内存.

通常，我们是用高级语言编写应用程序的，这些程序是在操作系统的平台上运行的。我们只管写高级语言的
代码、数据。至于这些代码、数据在运行的时候放在内存的什么地方，是否会相互覆盖，我们都不用操心，
因为操作系统和高级语言的编译器替我们做了大量的看护工作，确保不会出错。现在我们讨论的是，操作系统
本身使用的是汇编语言，没有高级语言编译器替操作系统提供保障，只有靠操作系统的设计者把内存的安排想
清楚，确保无论操作系统如何运行，都不会出现代码与代码、数据与数据、代码与数据之间相互覆盖的情况。
为了更准确地理解操作系统的运行机制，我们必须清楚操作系统的设计者是如何规划内存的。

##### 规划内存

在实模式状态下,寻址的最大范围是1 MB.为了规划内存, bootsect首先设计了如下代码：

path: boot/bootsect.s
```
.globl begtext, begdata, begbss, endtext, enddata, endbss
.text
begtext:
.data
begdata:
.bss
begbss:
.text

! 将要加载的SETUP程序的扇区数.
SETUPLEN = 4                 ! nr of setup-sectors
! 启动扇区被BIOS加载的位置
BOOTSEG  = 0x07c0            ! original address of boot-sector
! 启动扇区将要移动到的新位置
INITSEG  = 0x9000            ! we move boot here - out of the way
! SETUP将被加载到的位置
SETUPSEG = 0x9020            ! setup starts here
! 内核代码(kernel)被加载的位置
SYSSEG   = 0x1000            ! system loaded at 0x10000 (65536).
! 内核的末尾位置
ENDSEG   = SYSSEG + SYSSIZE  ! where to stop loading

! ROOT_DEV:    0x000 - same type of floppy as boot.
!        0x301 - first partition on first drive etc
! 根文件系统设备号
ROOT_DEV = 0x306
```

**注意**: 操作系统的设计者是要全面地、整体地考虑内存的规划的, 精心安排内存是操作系统设计者时时刻刻都要关心的事.

##### 复制bootsect

接下来, bootsect启动程序将它自身(全部的512 B内容)从内存0x07C00(BOOTSEG)处复制至内存
0x90000(INITSEG)处。

path: boot/bootsect.s
```
entry _start
_start:
    mov    ax,#BOOTSEG
    mov    ds,ax
    mov    ax,#INITSEG
    mov    es,ax
    mov    cx,#256
    sub    si,si
    sub    di,di
    rep
    movw
```

在这次复制过程中, ds(0x07C0)和si(0x0000)联合使用，构成了源地址0x07C00;
es(0x9000)和di(0x0000)联合使用，构成了目的地址0x90000. 而mov cx, #256这一行循环控制量, 提供了
需要复制的"字"数(一个字为2字节，256个字正好是512字节，也就是第一扇区的字节数).

**注意**: 此时CPU的段寄存器(CS)指向0x07C0(BOOTSEG), 即原来bootsect程序所在的位置。

由于“两头约定”和“定位识别”, 所以在开始时bootsect“被迫”加载到0x07C00位置。现在将自身移至0x90000处,
说明操作系统开始根据自己的需要安排内存了。

##### 加载setup

bootsect复制到新位置完毕后，会执行下面的代码:

path: boot/bootsect.s
```
    rep
    movw
    jmpi    go,INITSEG
go: mov    ax,cs
    mov    ds,ax
```

当前CS的值为0x07C0, 执行完这个跳转后, CS值变为0x9000(INITSEG), IP的值为从0x9000(INITSEG)到go.

```
mov ax, cs
```

这一行对应指令的偏移。换句话说，此时CS:IP指向go: mov ax, cs这一行，程序从这一行开始往下执行。
此前的0x07C00这个位置是根据"两头约定"和"定位识别"而确定的. 从现在起，操作系统已经不需要完全依赖
BIOS，可以按照自己的意志把自己的代码安排在内存中自己想要的位置。

```
    jmpi go, INITSEG
go: mov ax, cs
```

这两行代码写得很巧. 复制bootsect完成后，在内存的0x07C00和0x90000位置有两段完全相同的代码。
复制代码这件事本身也是要靠指令执行的，执行指令的过程就是CS和IP不断变化的过程。执行到
"jmpi go, INITSEG"这行之前，代码的作用就是复制代码自身; 执行了jmpi go, INITSEG之后，程序就
转到执行0x90000这边的代码了。Linus的设计意图是想跳转之后，在新位置接着执行后面的mov ax, cs,
而不是死循环。"jmpi go, INITSEG"与"go: mov ax, cs"配合，巧妙地实现了**到新位置后接着原来的执行序继续执行下去**的目的。

bootsect复制到了新的地方，并且要在新的地方继续执行。因为代码的整体位置发生了变化，所以代码中的
各个段也会发生变化。前面已经改变了CS，现在对DS、ES、SS和SP进行调整。我们看看下面的代码:

path: boot/bootsect.s
```
go: mov    ax,cs
    mov    ds,ax
    mov    es,ax
    ! put stack at 0x9ff00.
    mov    ss,ax
    mov    sp,#0xFF00        ! arbitrary value >>512
```

上述代码的作用是通过ax, 用CS的值0x9000来把数据段寄存器(DS), 附加段寄存器(ES), 栈基址寄存器(SS)
设置成与代码段寄存器(CS)相同的位置，并将栈顶指针SP指向偏移地址为0xFF00处。

**注意**:
SS和SP联合使用,就构成了栈数据在内存中的位置值。对这两个寄存器的设置为后面程序的栈操作
(如push、pop等)打下了基础.现在可以观察一下bootsect中的程序，在执行设置SS和SP的代码之前,
没有出现过栈操作指令，而在此之后就陆续使用。**这里对SS和SP进行的设置是分水岭**: 它标志着从现在
开始，程序可以执行一些更为复杂的数据运算类指令了.

栈操作是有方向的注意是由高地址到低地址的方向.
DS/ES/FS/GS/SS: 这些段寄存器存在于CPU中,其中SS(Stack Segment)指向栈段,此区域将按栈机制进行管理.
SP(Stack Pointer): 栈顶指针寄存器，指向栈段的当前栈顶.

##### 加载setup程序

加载setup这个程序,要借助BIOS提供的int 0x13中断向量所指向的中断服务程序(也就是磁盘服务程序)来完成.
"int 13"中断服务程序的执行过程与前面讲解bios利用"int 0x19"中断向量所指向的启动加载服务程序不同:

A. int 0x19中断向量所指向的启动加载服务程序是BIOS执行的; 而int 0x13的中断服务程序是Linux操作系统
自身的启动代码bootsect执行的.
B. int 0x19的中断服务程序只负责把软盘的第一扇区的代码加载到0x07C00位置，而int 0x13的中断服务程序
则不然，它可以根据设计者的意图，把指定扇区的代码加载到内存的指定位置。

针对服务程序的这个特性, 使用int 0x13中断时, 就要事先将指定的扇区,加载的内存位置等信息传递给服务
程序,即传参。执行代码如下:

path: boot/bootsect.s
```
! load the setup-sectors directly after the bootblock.
! Note that 'es' is already set up.

load_setup:
    mov    dx,#0x0000          ! drive 0, head 0
    mov    cx,#0x0002          ! sector 2, track 0
    mov    bx,#0x0200          ! address = 512, in INITSEG
    mov    ax,#0x0200+SETUPLEN ! service 2, nr of sectors
    int    0x13                ! read it
    jnc    ok_load_setup       ! ok - continue
    mov    dx,#0x0000
    mov    ax,#0x0000          ! reset the diskette
    int    0x13
    j      load_setup

ok_load_setup:
```

从代码开始处的4个mov指令可以看出, 系统给BIOS中断服务程序传参是通过几个通用寄存器实现的.这是汇编
程序的常用方法,与C语言的函数调用形式有很大不同.
参数传递完毕后,执行int 0x13指令, 产生0x13中断，通过中断向量表找到这个中断服务程序, 将软盘从
第二扇区开始的4个扇区, 即setup.s对应的程序加载至内存的SETUPSEG(0x90200)处.复制后的bootsect的
起始位置是0x90000, 占用512字节的内存空间。不难看出0x90200紧挨着bootsect的尾端，所以bootsect和
setup是连在一起的。

现在,操作系统已经从软盘中加载了5个扇区的代码.等bootsect执行完毕后,setup这个程序就要开始工作了.

*注意*: 之前SS:SP指向的位置为0x9FF00, 这与setup程序的起始位置0x90200还有很大的距离, 即便setup
加载进来后, 系统仍然有足够的内存空间用来执行数据压栈操作; 而且, 在启动部分, 要压栈的数据毕竟也
是有限的. 设计者在此是进行过精密测算的.

##### 加载system模块

接下来, bootsect程序要执行第三批程序的载入工作, 即将系统模块载入内存, 具体实现如下:

path: boot/bootsect.s
```
ok_load_setup:

   ! Get disk drive parameters, specifically nr of sectors/track
    mov    dl,#0x00
    mov    ax,#0x0800        ! AH=8 is get drive parameters
    int    0x13
    mov    ch,#0x00
    seg cs
    mov    sectors,cx
    mov    ax,#INITSEG
    mov    es,ax

   ! Print some inane message

    mov    ah,#0x03        ! read cursor pos
    xor    bh,bh
    int    0x10

    mov    cx,#24
    mov    bx,#0x0007        ! page 0, attribute 7 (normal)
    mov    bp,#msg1
    mov    ax,#0x1301        ! write string, move cursor
    int    0x10

    ! ok, we've written the message, now
    ! we want to load the system (at 0x10000)

    mov    ax,#SYSSEG
    mov    es,ax        ! segment of 0x010000
    call    read_it
    call    kill_motor
```

这次载入从底层技术上看,与前面的setup程序的载入没有本质的区别. 比较突出的特点是这次加载的扇区数是
240个, 足足是之前的4个扇区的60倍，所需时间也是几十倍。为了防止加载期间用户误认为是机器故障而执行
不适当的操作,Linus在此设计了显示一行屏幕信息"Loading system ..."以提示用户计算机此时正在加载系统。
值得注意的是，此时操作系统的main函数还没有开始执行，在屏幕上显示一行字符串远没有用C语言写一句
printf（"Loading system ...\n"）调用那么容易，所有工作都要靠一行一行的汇编代码来实现。从体系结构
的角度看，显示器也是一个外设，所以还要用到其他BIOS中断。这些代码比较多，对理解操作系统的启动原理
没有特别直接的帮助，只要知道大意就可以了。我们真正需要掌握的是，bootsect借着BIOS中断int 0x13，
将240个扇区的system模块加载进内存。加载工作主要是由bootsect调用read_it子程序完成的。这个子程序将
软盘第六扇区开始的约240个扇区的system模块加载至内存的SYSSEG(0x10000)处往后的120 KB空间中.

由于是长时间操作软盘，所以需要对软盘设备进行更多的监控，对读盘结果不断地进行检测。因此read_it
后续的调用步骤比较多一些。但读盘工作最终是由0x13对应的中断服务程序完成的.

到此为止，第三批程序已经加载完毕，整个操作系统的代码已全部加载至内存.

##### 确认根设备

根文件系统设备(Root Device): Linux 0.11使用Minix操作系统的文件系统管理方式, 要求系统必须存在一个
根文件系统, 其他文件系统挂接其上, 而不是同等地位. Linux 0.11没有提供在设备上建立文件系统的工具,
故必须在一个正在运行的系统上利用工具(类似FDISK和Format)做出一个文件系统并加载至本机。因此
Linux 0.11的启动需要两部分数据，即系统内核镜像和根文件系统。

注意: 这里的文件系统指的不是操作系统内核中的文件系统代码，而是有配套的文件系统格式的设备，如一张格式化好的软盘。

执行代码如下:

path: boot/bootsect.s
```
! After that we check which root-device to use. If the device is
! defined (!= 0), nothing is done and the given device is used.
! Otherwise, either /dev/PS0 (2,28) or /dev/at0 (2,8), depending
! on the number of sectors that the BIOS reports currently.

    seg cs
    mov    ax,root_dev
    cmp    ax,#0
    jne    root_defined
    seg cs
    mov    bx,sectors
    mov    ax,#0x0208        ! /dev/ps0 - 1.2Mb
    cmp    bx,#15
    je     root_defined
    mov    ax,#0x021c        ! /dev/PS0 - 1.44Mb
    cmp    bx,#18
    je     root_defined
undef_root:
    jmp undef_root
root_defined:
    seg cs
    mov    root_dev,ax

......

.org 508
root_dev:
    .word ROOT_DEV
boot_flag:
    .word 0xAA55

.text
endtext:
.data
enddata:
.bss
endbss:
```

在bootsect完成上述工作:
**规划内存** --> **复制bootsect** --> **加载setup** --> **加载system模块** --> **确认根设备**
之后，便要跳转执行setup程序, 如下所示:

path: boot/bootsect.s
```
! after that (everyting loaded), we jump to
! the setup-routine loaded directly after
! the bootblock:

    jmpi    0,SETUPSEG
```

### setup

##### 移动system模块到内存起始位置0x00000

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

##### 设置中断描述符表和全局描述符表

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

##### 打开A20,实现32位寻址

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

##### 初始化可编程中断控制器8259A

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

##### 设置CPU工作模式为保护模式

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

setup程序在完成如下流程后:

**移动system模块到内存0x00000** --> **设置IDT与GDT** --> **打开A20,实现32位寻址** --> **初始化可编程中断控制器8259A** --> **设置CPU工作模式为保护模式**

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

### head

在执行main函数之前,先要执行三个由汇编代码生成的程序,即bootsect,setup和head.之后,才执行由
main函数开始的用C语言编写的操作系统内核程序.

A. 加载bootsect到0x07C00, 然后复制到0x90000;

B. 加载setup到0x90200.

*注意*: 这两段程序是分别加载,分别执行的.

head程序与它们的加载方式有所不同. 大致的过程是: 先将head.s汇编成目标代码, 将用C语言编写的内核程序编译成目标代码,
然后链接成system模块. 也就是说, system模块里面既有c编写的内核程序, 又有head程序. 两者是紧挨着的, head程序在前,
c内核程序在后, 所以head程序名字为"head". head程序在内存中占有25 KB?+?184 B的空间. system模块加载到内存后,
setup将system模块复制到0x00000位置, 由于head程序在system的前面, 所以实际上, head程序就在0x00000这个位置.

##### 设置保护模式下的寄存器

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

##### 设置IDT

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

##### 设置GDT

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

##### 检验A20是否打开

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

##### 检测数学处理器

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

##### 为调用main函数作准备

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

##### 安装页表

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

总结
--------------------------------------------------------------------------------

**开机加电** --> **bios** --> **bootsect** --> **setup** --> **head** --> **main**

## bios --> bootsect

**构建中断向量表和中断服务程序** --> **加载bootsect**

## bootsect --> setup

**规划内存** --> **复制bootsect** --> **加载setup** --> **加载system模块** --> **确认根设备**

## setup --> head

**移动system模块到内存0x00000** --> **设置IDT与GDT** --> **打开A20,实现32位寻址** --> **初始化可编程中断控制器8259A** --> **设置CPU工作模式为保护模式**

## head --> main

**设置保护模式下寄存器** --> **设置IDT/GDT** --> **检验A20是否打开** --> **检测数学处理器** --> **为调用main函数准备** --> **安装页表** --> **返回到main执行**