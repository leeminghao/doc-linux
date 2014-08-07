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