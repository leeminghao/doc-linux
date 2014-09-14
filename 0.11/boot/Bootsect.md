Linux 0.11 Bootsect
================================================================================

在BIOS程序将bootsect从引导扇区中加载到内存位置0x7c00处:

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/PowerUp2Bios.md

接下来便要执行bootsect程序.

bootsect程序作用
--------------------------------------------------------------------------------

bootsect是用来加载操作系统内核的程序,其作用是:

陆续把软盘中的操作系统程序载入内存.这样制作的第一扇区就称为启动扇区(boot sector).
第一扇区程序的载入,标志着Linux 0.11中的代码即将发挥作用了。

下面的工作就是执行bootsect把软盘的第二批, 第三批代码载入内存.

bootsect的执行过程
--------------------------------------------------------------------------------

BIOS已经把bootsect也就是引导程序载入内存了,现在它的作用就是把第二批和第三批程序陆续加载到内存中。
为了把第二批和第三批程序加载到内存中的适当位置，bootsect首先做的工作就是规划内存.

通常，我们是用高级语言编写应用程序的，这些程序是在操作系统的平台上运行的。我们只管写高级语言的
代码、数据。至于这些代码、数据在运行的时候放在内存的什么地方，是否会相互覆盖，我们都不用操心，
因为操作系统和高级语言的编译器替我们做了大量的看护工作，确保不会出错。现在我们讨论的是，操作系统
本身使用的是汇编语言，没有高级语言编译器替操作系统提供保障，只有靠操作系统的设计者把内存的安排想
清楚，确保无论操作系统如何运行，都不会出现代码与代码、数据与数据、代码与数据之间相互覆盖的情况。
为了更准确地理解操作系统的运行机制，我们必须清楚操作系统的设计者是如何规划内存的。

### 规划内存

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

### 复制bootsect

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

### 加载setup

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

### 加载setup程序

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

### 加载system模块

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

### 确认根设备

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

最终通过跳转指令跳转到setup模块继续执行:

https://github.com/leeminghao/doc-linux/blob/master/0.11/boot/Setup.md