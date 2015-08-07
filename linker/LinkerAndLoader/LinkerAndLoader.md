Linker And Loader(连接器和加载器)
================================================================================

为了生成内核代码文件，Linux 0.11使用了两种编译器:

* 第一种是汇编编译器as86和相应的链接程序（或称为链接器）ld86:
  它们专门用于编译和链接运行在实地址模式下的16位内核引导扇区程序bootsect.S和设置程序setup.s。

* 第二种是GNU 的汇编器as和C语言编译器gcc以及相应的链接程序ld。
  编译器用于为源程序文件产生对应的二进制代码和数据目标文件,链接程序用于对相关的所有目标文件进行组合处理，
  形成一个可被内核加载执行的目标文件，即可执行文件。

链接器和加载器做什么?

任何一个链接器和加载器的基本工作都非常简单: 将更抽象的名字与更底层的名字绑
定起来,好让程序员使用更抽象的名字编写代码。也就是说,它可以将程序员写的一个诸如:
"getline"的名字绑定到"iosys 模块内可执行代码的 612 字节处"或者可以采用诸如"这个模
块的静态数据开始的第 450 个字节处"这样更抽象的数字地址, 然后将其绑定到数字地址上.

从历史角度看地址绑定
--------------------------------------------------------------------------------

### 机器语言

最早的计算机完全是用机器语言进行编程的。程序员需要在纸质表格上写下符号化程序,
然后手工将其汇编为机器码,通过开关、纸带或卡片将其输入到计算机中(真正的高手
可以在开关上直接编码)。如果程序员使用符号化的地址,那他就得手工完成符号到地址的
绑定。如果后来发现需要添加或删除一条指令,那么整个程序都必须手工检查一遍并将所有
被添加或删除的指令影响的地址都进行修改。

**缺点**：

这个问题就在于: **名字和地址绑定的过早了**. 汇编器通过让程序员使用符号化名字编写
程序,然后由程序将名字绑定到机器地址的方法解决了这个问题。如果程序被改变了,那么
程序员必须重新汇编它,但是地址分配的工作已经从程序员推给计算机了.

### 子程序(代码库)的出现

代码的库使得地址分配工作更加复杂。由于计算机可以执行的基本操作极其简单,有
用的程序都是由那些可以执行更高级、更复杂操作的子程序组成的。计算机在安装时都带有
一些预先编写好、调试好的子例程库,程序员可以将它们用在自己写的新程序中,而不需编
写所有的子程序。然后程序员可以将这些子例程加载到主程序中以构成一个完整的可以工作
的程序。

程序员们甚至在使用汇编语言之前就使用子程序库了。在 1947 年,领导 ENIAC 项目的
John Macuchly,就写文章描述了如何将主程序和磁带中一系列选定的子程序一起加载到计
算机中,并通过将子程序代码重定位以反映实际被加载的地址。鉴于 Mauchly 认为程序和子
程序都是由机器语言编写的,因此我们可能会惊奇的发现,甚至在汇编语言出现之前,链接
器的两个基本功能重定位和库查询就已经出现了。**可重定位的加载器允许子例程的作者或用
户在编写子例程时认为它们都起始于地址 0,并将实际的地址绑定延迟到这些例程被链接到
某个特定的程序中**。

### 操作系统出现

* 在有操作系统之前:

一个程序可以支配机器所有的内存,由于知道计算机中所有的地址都是可用的,因此它能以固定的内存地址来汇编和链接。

* 有了操作系统以后:

程序就必须和操作系统甚至其它程序共享计算机的内存。这意味着在操作系统将程序加载到内存之前是无法确定
程序运行的确切地址的,并将最终的地址绑定从链接时推延到了加载时。现在链接器和加载器已经将这个工作划分开了:
**链接器对每一个程序的部分地址进行绑定并分配相对地址,加载器完成最后的重定位步骤并赋予的实际地址**

### 高级语言出现

随着计算机系统变得越来愈复杂,链接器被用来做了更多、更复杂的名字管理和地址绑定的工作。

Fortran 程序使用了多个子程序和公共块(被多个子程序共享的数据区域),
而它是由链接器来为这些子程序和公共数据块进行存储布局和地址分配的。
逐渐地链接器还需要处理目标代码库。包括:

* 用Fortran 或其它语言编写的应用程序库;
* 被编译器支持的那些可以从被编译好的处理I/O或其它高级操作的代码中隐含调用的库.

由于程序很快就变得比可用的内存大了,因此链接器提供了**覆盖技术**,它可以让程序员安排程序的
不同部分来分享相同的内存,当程序的某一部分被其它部分调用时可以按需加载。

上世纪 60 年代在硬盘出现后覆盖技术在大型主机系统上得到了广泛的应用,一直持续到 70 年代中期虚拟内存技术出现。
然后重新以几乎相同的形式在80年代早期的微型机算机上出现,并在90年代PC上采用虚拟内存后逐渐没落。

现在它们仍被应用在内存受限的嵌入式环境中,并且当程序员或者编译器为了提高性能而精确的控制内存使用时可能会再次出现。

### 硬件重定位和虚拟内存的出现

随着硬件重定位和虚拟内存的出现,每一个程序可以再次拥有整个地址空间,因此链接器和加载器变得不那么复杂了。
由于硬件(而不是软件)重定位可以对任何加载时重定位进行处理,程序可以**按照被加载到固定地址的方式来链接**
但是具有硬件重定位功能的计算机往往不止运行一个程序,而且经常会运行同一个程序的多个副本。
当计算机运行一个程序的多个实例时,程序中的某些部分在所有的运行实例中都是相同的(尤其是可执行代码),
而另一些部分是各实例独有的。

如果不变的部分可以从发生改变的部分中分离出来,那么操作系统就可以只使用一份不变部分的副本,
节省相当可观的存储空间。

编译器和汇编器可以被修改为:

在多个段内创建目标代码,为只读代码分配一个段,为别的可写数据分配其它段。
链接器必须能够将相同类型的所有段都合并在一起,以使得被链接程序的所有代码都放置在一个地方,
而所有的数据放在另一个地方。由于地址仍然是在链接时被分配的,因此和之前相比并不能延迟地址绑定的时机,
但更多的工作被延迟到了链接器为所有段分配地址的时候。

即使多个不同的程序运行在一个计算机上时,这些不同的程序实际上仍会共享很多公共代码。

**例如**:

几乎每一个 C 语言的程序都会使用诸如 fopen 和 printf 这样的例程,数据库应用程序都会
使用一个巨大的访问库来链接数据库,运行在诸如 X Window,MS Windows,或Macintosh 这样的
图形用户界面下的应用程序会使用到部分的图形用户界面库。

多数系统现在都会提供共享库给应用程序使用,这样所有使用某个库的程序可以仅共享一份副本。这既
提升了不少运行时的性能也节省了大量磁盘空间, 在小程序中通用库例程会占用比主程序本身更多的空间.

### 静态库动态库的出现

##### 静态链接库

在较简单的静态共享库中,每个库在创建时会被绑定到特定的地址,链接器在链接时
将程序中引用的库例程绑定到这些特定的地址。由于当静态库中的任何部分变化时程序都需
要被重新链接,而且创建静态链接库的细节也是非常冗长乏味的,因此静态链接库实际上很麻烦死板。

##### 动态链接库

使用动态链接库的程序在开始运行之前不会将所用库中的段和符号绑定到确切的地址上。
有时这种绑定还会更为延迟: **在完全的动态链接中,被调用例程的地址在第一次调用前都不会被绑定**。
此外在程序运行过程中也可以加载库并进行绑定。这提供了一种强大且高性能的扩展程序功能的方法。

链接与加载过程
--------------------------------------------------------------------------------

### 基本动作

##### 程序加载

将程序从辅助存储设备(自 1968 年后这就意味着磁盘)拷贝到主内存中准备运行。在某些情况下,加载仅仅是将数据从磁盘拷入内存;
在其他情况下,还包括分配存储空间,设置保护位或通过虚拟内存将虚拟地址映射到磁盘内存页上。

##### 重定位

编译器和汇编器通常为每个文件创建程序地址从0开始的目标代码,但是几乎没有计算机会允许从地址0加载你的程序。
如果一个程序是由多个子程序组成的,那么所有的子程序必须被加载到互不重叠的地址上。重定位就是为程序不同部分
分配加载地址,调整程序中的数据和代码以反映所分配地址的过程。在很多系统中,重定位不止进行一次。
对于链接器的一种普遍情景是由多个子程序来构建一个程序,并生成一个链接好的起始地址为 0 的输出程序,
各个子程序通过重定位在大程序中确定位置。当这个程序被加载时,系统会选择一个加载地址,而链接好的程
序会作为整体被重定位到加载地址。

##### 符号解析

当通过多个子程序来构建一个程序时,子程序间的相互引用是通过符号进行的;
主程序可能会调用一个名为 sqrt 的计算平方根例程,并且数学库中定义了sqrt 例程。
链接器通过标明分配给 sqrt 的地址在库中来解析这个符号,并通过修改目标代码使得call指令引用该地址。

**注意**:

尽管有相当一部分功能在链接器和加载器之间重叠,定义一个仅完成程序加载的程序为加载器,
一个仅完成符号解析的程序为链接器是合理的。他们任何一个都可以进行重定位,
而且曾经也出现过集三种功能为一体的链接加载器。

重定位和符号解析的划分界线是模糊的。由于链接器已经可以解析符号的引用:
一种处理代码重定位的方法就是为程序的每一部分分配一个指向基址的符号,然后将重定位地址
认为是对该基址符号的引用。

链接器和加载器共有的一个重要特性就是他们都会修改目标代码,他们也许是唯一比调试程序在
这方面应用更为广泛的程序。这是一个独特而强大的特性,而且细节非常依赖于机器的规格,
如果做错的话就会引发令人困惑的 bug。

### 两遍链接

现在我们来看看链接器的普遍结构, 就象编译或汇编一样,链接基本上也是一个两遍的过程。

链接器将一系列的目标文件、库、及可能的命令文件作为它的输入,然后将输出的
目标文件作为产品结果,此外也可能有诸如加载映射信息或调试器符号文件的副产品

https://github.com/leeminghao/doc-linux/blob/master/linker/linker_process.png

每个输入文件都包含一系列的段(segments),即会被连续存放在输出文件中的代码或数据块。

每一个输入文件至少还包含一个符号表(symbol table):
有一些符号会作为导出符号: **他们在当前文件中定义并在其他文件中使用,通常都是可以在其它地方被调用的当前文件内例程的名字**
其它符号会作为导入符号: **在当前文件中使用但不在当前文件中定义,通常都是在该文件中调用但不存在于该文件中的例程的名字**

##### 两遍扫描过程

* 当链接器运行时,会首先对输入文件进行扫描,得到各个段的大小,并收集对所有符号的定义和引用。
它会创建一个: **列出输入文件中定义的所有段的段表,和包含所有导出、导入符号的符号表**

* 利用第一遍扫描得到的数据,链接器可以为符号分配数字地址,决定各个段在输出地址空间中的大小和位置,
并确定每一部分在输出文件中的布局。第二遍扫描会利用第一遍扫描中收集的信息来控制实际的链接过程。
**它会读取并重定位目标代码,为符号引用替换数字地址,调整代码和数据的内存地址以反映重定位的段地址,
并将重定位后的代码写入到输出文件中。通常还会再向输出文件中写入文件头部信息,重定位的段和符号表信息**

**补充**:

A. 如果程序使用了动态链接,那么符号表中还要包含运行时链接器解析动态符号时所需的信息;

B. 在很多情况下,链接器自己将会在输出文件中生成少量代码或数据,例如用来调用覆盖中或
动态链接库中的例程的“胶水代码”,或在程序启动时需要被调用的指向各初始化例程的函数指针数组;

C. 不论程序是否使用了动态链接,文件中都会保存一个程序本身不会使用的重链接或调试用符号表,
但是这些信息可以被处理输出文件的其它程序所使用;

D. 有些目标代码的格式是可以重链接的,也就是一次链接器运行的输出文件可以作为下次链接器运行的输入。
这要求输出文件要包含一个像输入文件中那样的符号表,以及其它会出现在输入文件中的辅助信息;

E. 几乎所有的目标代码格式都预备有调试符号,这样当程序在调试器控制下运行时,调试器可以使用这些符号
让程序员通过源代码中的行号或名字来控制程序。根据目标代码格式细节的不同,调试符号可能会与链接器需要
的符号混合在一个符号表中,也可能独立于链接器需要的符号表为链接器建立单独建立一个有些许冗余的符号表

**注意**

有很少的一些链接器可以在一次扫描中完成工作。他们是通过在链接过程中将输入文件的部分或全部缓冲在内存或磁盘中,
并稍后读取被缓冲的信息的方法来实现的。由于这是一个并不影响链接过程两边扫描实质的实现技巧,因此这里我们不再赘述.

### 目标代码库

所有的链接器都会以这样或那样的形式来支持目标代码库,同时它们中的大多数还会支持各种各样的共享库。

目标代码库的基本原则是很非常简单的:
**当链接器处理完所有规则的输入文件后,如果还存在未解析的导入名称(imported name),
它就会查找一个或多个库,然后将输出这些未解析名字的库中的任何文件链接进来**
如下图所示：

https://github.com/leeminghao/doc-linux/blob/master/linker/objlib.png

由于链接器将部分工作从链接时推迟到了加载时,使这项任务稍微复杂了一些。在链接器运行时,
链接器会识别出解析未定义符号所需的共享库,但是链接器会在输出文件中标明用来解析这些符号的库名称,
而不是在链接时将他们链入程序,这样可以在程序被加载时进行共享库绑定。

### 重定位和代码修改

链接器和加载器的核心动作是: **重定位和代码修改**。当编译器或汇编器产生一个目标代码文件时,
它使用文件中定义的未重定位代码地址和数据地址来生成代码,对于其它地方定义的数据或代码通常就是0。
作为链接过程的一部分,链接器会修改目标代码以反映实际分配的地址。

##### 实例

例如,考虑如下这段将变量a中的内容通过寄存器eax移动到变量b的 x86 代码片段:

```
mov a,%eax
mov %eax,b
```

如果 a 定义在同一文件的位置 0x1234,而 b 是从其它地方导入的,那么生成的代码将会是:

```
A1 34 12 00 00 mov a,%eax
A3 00 00 00 00 mov %eax,b
```

每条指令包含了一个字节的操作码和其后 4 个字节的地址。第一个指令有对地址 1234的引用
(由于 x86 使用从右向左的字节序,因此这里是逆序),而第二个指令由于 b 的位置是未知的因此引用位置为 0。

现在想象链接器将这段代码进行链接,a所属段被重定位到了0x10000, b最终位于地址 0x9A12。

则链接器会将代码修改为:

```
A1 34 12 01 00 mov a,%eax
A3 12 9A 00 00 mov %eax,b
```

也就是说,链接器将第一条指令中的地址加上0x10000,现在它所标识的 a 的重定位地址就是 0x11234,
并且也补上了 b 的地址。虽然这些调整影响的是指令,但是目标文件中数据部分任何相关的指针也必须修改。

在稍老一些的地址空间很小、直接寻址的计算机系统上,由于只有一到两种链接器需要处理的地址格式,因此代码修改的过程相当简单。
对于现代计算机,包括所有的 RISC 架构,都需要进行复杂的多的代码修改。没有一条指令有足够的空间容纳一个直接地址,
因此编译器和链接器不得不才用复杂的寻址技巧来处理任意地址上的数据。某些情况下,使用两到三条指令来组成一个地址都是有可能的,
每个指令包含地址的一部分,然后使用位操作将它们组合为一个完整的地址。在这种情况下,链接器不得不对每个指令都进行恰当的修改,
将地址中的某些位插入到每一个指令中。

其它情况下,一个例程或一组例程使用的所有地址都被放置在一个作为“地址池”的数组中,初始化代码将某一个机器寄存器指向这个数组,
当需要时,代码会将该寄存器作为基址寄存器从地址池中加载所需指针。链接器需要由被程序使用的所有地址来创建这个数组,
并修改各指令使它们可以关联到正确的地址池入口处。

有些系统需要无论加载到什么位置都可以正常工作的位置无关代码。链接器需要提供额外的技巧来支持位置无关代码,
与程序中无法做到位置无关的部分隔离开来,并设法使这两部分可以互相通讯.

链接: 一个真实的例子
--------------------------------------------------------------------------------

我们通过一个简小的链接实例来结束对链接过程的介绍:

有关编译c代码函数的调用过程分析可参考:

https://github.com/leeminghao/doc-linux/blob/master/linker/CFunctionCall.md

path: src/ex1/m.c
```
extern void a(char *);

int main(int argc, char **argv)
{
    static char string[] = "hello world\n";
    a(string);
}
```

path: src/ex1/a.c
```
#include <string.h>

#include <unistd.h>

void a(char *s)
{
    write(1, s, strlen(s));
}
```

### m.c文件的编译过程

主程序m.c在用 gcc 编译成一个典型 a.out 目标代码格式如下所示:

```
$ gcc -m32 -c m.c -o m.o
$ ll m.o
-rw-rw-r-- 1 liminghao liminghao 976 Sep  8 12:14 m.o
$ objdump -h -S m.o > m.map
$ cat m.map

m.o:     file format elf32-i386
# 目标文件包含一个固定长度的头部.
Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         00000017  00000000  00000000  00000034  2**0
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
  1 .data         0000000d  00000000  00000000  0000004b  2**0
                  CONTENTS, ALLOC, LOAD, DATA
  2 .bss          00000000  00000000  00000000  00000058  2**0
                  ALLOC
  3 .comment      00000025  00000000  00000000  00000058  2**0
                  CONTENTS, READONLY
  4 .note.GNU-stack 00000000  00000000  00000000  0000007d  2**0
                  CONTENTS, READONLY
  5 .eh_frame     00000038  00000000  00000000  00000080  2**2
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, DATA

Disassembly of section .text:
# ebp 是"基址指针"(BASE POINTER), 它最经常被用作高级语言函数调用的"框架指针"(frame pointer).
# esp 专门用作堆栈指针，被形象地称为栈顶指针，堆栈的顶部是地址小的区域，压入堆栈的数据越多,
# esp也就越来越小,在32位平台上,esp每次减少4字节.
#
# 注意: esp - 寄存器存放当前线程的栈顶指针; ebp - 寄存器存放当前线程的栈底指针
00000000 <main>:
   0:    55                     push   %ebp        # 保存当前ebp
   1:    89 e5                  mov    %esp,%ebp   # ebp设为当前堆栈指针
   3:    83 e4 f0               and    $0xfffffff0,%esp
   6:    83 ec 10               sub    $0x10,%esp  # 给函数临时变量预留空间
   # 这样一来,ebp构成了该函数的一个框架, 在ebp上方分别是原来的ebp, 返回地址和参数.
   # ebp下方则是临时变量. 函数返回时作 mov esp, ebp; pop ebp; ret 即可.
   #
   # 注意由于和字符串 string 在同一个文件中,pushl 指令引用了 string 的临时地址 0x0,而
   # 由于_a 的地址是未知的所以 call 指令引用的地址为 11。
   9:    c7 04 24 00 00 00 00   movl   $0x0,(%esp)
  10:    e8 fc ff ff ff         call   11 <main+0x11>
  15:    c9                     leave
  16:    c3                     ret

$ gcc -m32 -S m.c -o m.s
$ cat m.s
        .file   "m.c"
        .text
        .globl       main
        .type        main, @function
main:
.LFB0:
        .cfi_startproc
        pushl   %ebp
        .cfi_def_cfa_offset 8
        .cfi_offset 5, -8
        movl        %esp, %ebp
        .cfi_def_cfa_register 5
        andl                  $-16, %esp
        subl                  $16, %esp
        movl                  $string.1374, (%esp)
        call                  a
        leave
        .cfi_restore 5
        .cfi_def_cfa 4, 4
        ret
        .cfi_endproc
.LFE0:
        .size   main, .-main
        .data
        .type   string.1374, @object
        .size   string.1374, 13
string.1374:
        .string "hello world\n"
        .ident  "GCC: (Ubuntu 4.8.2-19ubuntu1) 4.8.2"
        .section      .note.GNU-stack,"",@progbits
```

### a.c文件的编译过程

程序a.c在用 gcc 编译成一个典型 a.out 目标代码格式如下所示:

```
$ gcc -m32 -S a.c -o a.s
$ gcc -m32 -c a.c -o a.o
$ objdump -h -S a.o > a.map
$ cat a.map

a.o:     file format elf32-i386

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         0000002a  00000000  00000000  00000034  2**0
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
  1 .data         00000000  00000000  00000000  0000005e  2**0
                  CONTENTS, ALLOC, LOAD, DATA
  2 .bss          00000000  00000000  00000000  0000005e  2**0
                  ALLOC
  3 .comment      00000025  00000000  00000000  0000005e  2**0
                  CONTENTS, READONLY
  4 .note.GNU-stack 00000000  00000000  00000000  00000083  2**0
                  CONTENTS, READONLY
  5 .eh_frame     00000038  00000000  00000000  00000084  2**2
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, DATA

Disassembly of section .text:

00000000 <a>:
   0:    55                       push   %ebp
   1:    89 e5                    mov    %esp,%ebp
   3:    83 ec 18                 sub    $0x18,%esp
   6:    8b 45 08                 mov    0x8(%ebp),%eax
   9:    89 04 24                 mov    %eax,(%esp)
   c:    e8 fc ff ff ff           call   d <a+0xd>
  11:    89 44 24 08              mov    %eax,0x8(%esp)
  15:    8b 45 08                 mov    0x8(%ebp),%eax
  18:    89 44 24 04              mov    %eax,0x4(%esp)
  1c:    c7 04 24 01 00 00 00     movl   $0x1,(%esp)
  23:    e8 fc ff ff ff           call   24 <a+0x24>
  28:    c9                       leave
  29:    c3                       ret

$ cat a.s
    .file    "a.c"
    .text
    .globl    a
    .type    a, @function
a:
.LFB0:
    .cfi_startproc
    pushl    %ebp
    .cfi_def_cfa_offset 8
    .cfi_offset 5, -8
    movl    %esp, %ebp
    .cfi_def_cfa_register 5
    subl    $24, %esp
    movl    8(%ebp), %eax
    movl    %eax, (%esp)
    call    strlen
    movl    %eax, 8(%esp)
    movl    8(%ebp), %eax
    movl    %eax, 4(%esp)
    movl    $1, (%esp)
    call    write
    leave
    .cfi_restore 5
    .cfi_def_cfa 4, 4
    ret
    .cfi_endproc
.LFE0:
    .size    a, .-a
    .ident    "GCC: (Ubuntu 4.8.2-19ubuntu1) 4.8.2"
    .section    .note.GNU-stack,"",@progbits
```

### 将m.o与a.o链接成可执行文件

为了产生一个可执行程序,链接器将这两个目标文件,以及一个标准的 C 程序启动初始
化例程,和必要的 C 库例程整合到一起,产生一个如下所示的可执行文件:

path: src/ex1/a.out.map
```
$ gcc -m32 a.o m.o
$ ll a.out
-rwxrwxr-x 1 liminghao liminghao 7405 Sep  9 11:40 a.out*
$ objdump -h -S a.out > a.out.map
$ cat a.out.map

a.out:     file format elf32-i386

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .interp       00000013  08048154  08048154  00000154  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  1 .note.ABI-tag 00000020  08048168  08048168  00000168  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .note.gnu.build-id 00000024  08048188  08048188  00000188  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .gnu.hash     00000020  080481ac  080481ac  000001ac  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .dynsym       00000060  080481cc  080481cc  000001cc  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  5 .dynstr       00000052  0804822c  0804822c  0000022c  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  6 .gnu.version  0000000c  0804827e  0804827e  0000027e  2**1
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  7 .gnu.version_r 00000020  0804828c  0804828c  0000028c  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  8 .rel.dyn      00000008  080482ac  080482ac  000002ac  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  9 .rel.plt      00000020  080482b4  080482b4  000002b4  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 10 .init         00000023  080482d4  080482d4  000002d4  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 11 .plt          00000050  08048300  08048300  00000300  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 12 .text         000001b2  08048350  08048350  00000350  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 13 .fini         00000014  08048504  08048504  00000504  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 14 .rodata       00000008  08048518  08048518  00000518  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 15 .eh_frame_hdr 00000034  08048520  08048520  00000520  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 16 .eh_frame     000000d0  08048554  08048554  00000554  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 17 .init_array   00000004  08049f08  08049f08  00000f08  2**2
                  CONTENTS, ALLOC, LOAD, DATA
 18 .fini_array   00000004  08049f0c  08049f0c  00000f0c  2**2
                  CONTENTS, ALLOC, LOAD, DATA
 19 .jcr          00000004  08049f10  08049f10  00000f10  2**2
                  CONTENTS, ALLOC, LOAD, DATA
 20 .dynamic      000000e8  08049f14  08049f14  00000f14  2**2
                  CONTENTS, ALLOC, LOAD, DATA
 21 .got          00000004  08049ffc  08049ffc  00000ffc  2**2
                  CONTENTS, ALLOC, LOAD, DATA
 22 .got.plt      0000001c  0804a000  0804a000  00001000  2**2
                  CONTENTS, ALLOC, LOAD, DATA
 23 .data         00000015  0804a01c  0804a01c  0000101c  2**2
                  CONTENTS, ALLOC, LOAD, DATA
 24 .bss          00000003  0804a031  0804a031  00001031  2**0
                  ALLOC
 25 .comment      00000024  00000000  00000000  00001031  2**0
                  CONTENTS, READONLY

Disassembly of section .init:

080482d4 <_init>:
 80482d4:    53                       push   %ebx
 80482d5:    83 ec 08                 sub    $0x8,%esp
 80482d8:    e8 a3 00 00 00           call   8048380 <__x86.get_pc_thunk.bx>
 80482dd:    81 c3 23 1d 00 00        add    $0x1d23,%ebx
 80482e3:    8b 83 fc ff ff ff        mov    -0x4(%ebx),%eax
 80482e9:    85 c0                    test   %eax,%eax
 80482eb:    74 05                    je     80482f2 <_init+0x1e>
 80482ed:    e8 1e 00 00 00           call   8048310 <__gmon_start__@plt>
 80482f2:    83 c4 08                 add    $0x8,%esp
 80482f5:    5b                       pop    %ebx
 80482f6:    c3                       ret

Disassembly of section .plt:

08048300 <__gmon_start__@plt-0x10>:
 8048300:    ff 35 04 a0 04 08        pushl  0x804a004
 8048306:    ff 25 08 a0 04 08        jmp    *0x804a008
 804830c:    00 00                    add    %al,(%eax)
    ...

08048310 <__gmon_start__@plt>:
 8048310:    ff 25 0c a0 04 08        jmp    *0x804a00c
 8048316:    68 00 00 00 00           push   $0x0
 804831b:    e9 e0 ff ff ff           jmp    8048300 <_init+0x2c>

08048320 <strlen@plt>:
 8048320:    ff 25 10 a0 04 08        jmp    *0x804a010
 8048326:    68 08 00 00 00           push   $0x8
 804832b:    e9 d0 ff ff ff           jmp    8048300 <_init+0x2c>

08048330 <__libc_start_main@plt>:
 8048330:    ff 25 14 a0 04 08        jmp    *0x804a014
 8048336:    68 10 00 00 00           push   $0x10
 804833b:    e9 c0 ff ff ff           jmp    8048300 <_init+0x2c>

08048340 <write@plt>:
 8048340:    ff 25 18 a0 04 08        jmp    *0x804a018
 8048346:    68 18 00 00 00           push   $0x18
 804834b:    e9 b0 ff ff ff           jmp    8048300 <_init+0x2c>

Disassembly of section .text:

08048350 <_start>:
 8048350:    31 ed                    xor    %ebp,%ebp
 8048352:    5e                       pop    %esi
 8048353:    89 e1                    mov    %esp,%ecx
 8048355:    83 e4 f0                 and    $0xfffffff0,%esp
 8048358:    50                       push   %eax
 8048359:    54                       push   %esp
 804835a:    52                       push   %edx
 804835b:    68 00 85 04 08           push   $0x8048500
 8048360:    68 90 84 04 08           push   $0x8048490
 8048365:    51                       push   %ecx
 8048366:    56                       push   %esi
 8048367:    68 77 84 04 08           push   $0x8048477
 804836c:    e8 bf ff ff ff           call   8048330 <__libc_start_main@plt>
 8048371:    f4                       hlt
 8048372:    66 90                    xchg   %ax,%ax
 8048374:    66 90                    xchg   %ax,%ax
 8048376:    66 90                    xchg   %ax,%ax
 8048378:    66 90                    xchg   %ax,%ax
 804837a:    66 90                    xchg   %ax,%ax
 804837c:    66 90                    xchg   %ax,%ax
 804837e:    66 90                    xchg   %ax,%ax

08048380 <__x86.get_pc_thunk.bx>:
 8048380:    8b 1c 24                 mov    (%esp),%ebx
 8048383:    c3                       ret
 8048384:    66 90                    xchg   %ax,%ax
 8048386:    66 90                    xchg   %ax,%ax
 8048388:    66 90                    xchg   %ax,%ax
 804838a:    66 90                    xchg   %ax,%ax
 804838c:    66 90                    xchg   %ax,%ax
 804838e:    66 90                    xchg   %ax,%ax

08048390 <deregister_tm_clones>:
 8048390:    b8 37 a0 04 08           mov    $0x804a037,%eax
 8048395:    2d 34 a0 04 08           sub    $0x804a034,%eax
 804839a:    83 f8 06                 cmp    $0x6,%eax
 804839d:    77 01                    ja     80483a0 <deregister_tm_clones+0x10>
 804839f:    c3                       ret
 80483a0:    b8 00 00 00 00           mov    $0x0,%eax
 80483a5:    85 c0                    test   %eax,%eax
 80483a7:    74 f6                    je     804839f <deregister_tm_clones+0xf>
 80483a9:    55                       push   %ebp
 80483aa:    89 e5                    mov    %esp,%ebp
 80483ac:    83 ec 18                 sub    $0x18,%esp
 80483af:    c7 04 24 34 a0 04 08     movl   $0x804a034,(%esp)
 80483b6:    ff d0                    call   *%eax
 80483b8:    c9                       leave
 80483b9:    c3                       ret
 80483ba:    8d b6 00 00 00 00        lea    0x0(%esi),%esi

080483c0 <register_tm_clones>:
 80483c0:    b8 34 a0 04 08           mov    $0x804a034,%eax
 80483c5:    2d 34 a0 04 08           sub    $0x804a034,%eax
 80483ca:    c1 f8 02                 sar    $0x2,%eax
 80483cd:    89 c2                    mov    %eax,%edx
 80483cf:    c1 ea 1f                 shr    $0x1f,%edx
 80483d2:    01 d0                    add    %edx,%eax
 80483d4:    d1 f8                    sar    %eax
 80483d6:    75 01                    jne    80483d9 <register_tm_clones+0x19>
 80483d8:    c3                       ret
 80483d9:    ba 00 00 00 00           mov    $0x0,%edx
 80483de:    85 d2                    test   %edx,%edx
 80483e0:    74 f6                    je     80483d8 <register_tm_clones+0x18>
 80483e2:    55                       push   %ebp
 80483e3:    89 e5                    mov    %esp,%ebp
 80483e5:    83 ec 18                 sub    $0x18,%esp
 80483e8:    89 44 24 04              mov    %eax,0x4(%esp)
 80483ec:    c7 04 24 34 a0 04 08     movl   $0x804a034,(%esp)
 80483f3:    ff d2                    call   *%edx
 80483f5:    c9                       leave
 80483f6:    c3                       ret
 80483f7:    89 f6                    mov    %esi,%esi
 80483f9:    8d bc 27 00 00 00 00     lea    0x0(%edi,%eiz,1),%edi

08048400 <__do_global_dtors_aux>:
 8048400:    80 3d 31 a0 04 08 00     cmpb   $0x0,0x804a031
 8048407:    75 13                    jne    804841c <__do_global_dtors_aux+0x1c>
 8048409:    55                       push   %ebp
 804840a:    89 e5                    mov    %esp,%ebp
 804840c:    83 ec 08                 sub    $0x8,%esp
 804840f:    e8 7c ff ff ff           call   8048390 <deregister_tm_clones>
 8048414:    c6 05 31 a0 04 08 01     movb   $0x1,0x804a031
 804841b:    c9                       leave
 804841c:    f3 c3                    repz ret
 804841e:    66 90                    xchg   %ax,%ax

08048420 <frame_dummy>:
 8048420:    a1 10 9f 04 08           mov    0x8049f10,%eax
 8048425:    85 c0                    test   %eax,%eax
 8048427:    74 1f                    je     8048448 <frame_dummy+0x28>
 8048429:    b8 00 00 00 00           mov    $0x0,%eax
 804842e:    85 c0                    test   %eax,%eax
 8048430:    74 16                    je     8048448 <frame_dummy+0x28>
 8048432:    55                       push   %ebp
 8048433:    89 e5                    mov    %esp,%ebp
 8048435:    83 ec 18                 sub    $0x18,%esp
 8048438:    c7 04 24 10 9f 04 08     movl   $0x8049f10,(%esp)
 804843f:    ff d0                    call   *%eax
 8048441:    c9                       leave
 8048442:    e9 79 ff ff ff           jmp    80483c0 <register_tm_clones>
 8048447:    90                       nop
 8048448:    e9 73 ff ff ff           jmp    80483c0 <register_tm_clones>

0804844d <a>:
 804844d:    55                       push   %ebp
 804844e:    89 e5                    mov    %esp,%ebp
 8048450:    83 ec 18                 sub    $0x18,%esp
 8048453:    8b 45 08                 mov    0x8(%ebp),%eax
 8048456:    89 04 24                 mov    %eax,(%esp)
 8048459:    e8 c2 fe ff ff           call   8048320 <strlen@plt>
 804845e:    89 44 24 08              mov    %eax,0x8(%esp)
 8048462:    8b 45 08                 mov    0x8(%ebp),%eax
 8048465:    89 44 24 04              mov    %eax,0x4(%esp)
 8048469:    c7 04 24 01 00 00 00     movl   $0x1,(%esp)
 8048470:    e8 cb fe ff ff           call   8048340 <write@plt>
 8048475:    c9                       leave
 8048476:    c3                       ret

08048477 <main>:
 8048477:    55                       push   %ebp
 8048478:    89 e5                    mov    %esp,%ebp
 804847a:    83 e4 f0                 and    $0xfffffff0,%esp
 804847d:    83 ec 10                 sub    $0x10,%esp
 8048480:    c7 04 24 24 a0 04 08     movl   $0x804a024,(%esp)
 8048487:    e8 c1 ff ff ff           call   804844d <a>
 804848c:    c9                       leave
 804848d:    c3                       ret
 804848e:    66 90                    xchg   %ax,%ax

08048490 <__libc_csu_init>:
 8048490:    55                       push   %ebp
 8048491:    57                       push   %edi
 8048492:    31 ff                    xor    %edi,%edi
 8048494:    56                       push   %esi
 8048495:    53                       push   %ebx
 8048496:    e8 e5 fe ff ff           call   8048380 <__x86.get_pc_thunk.bx>
 804849b:    81 c3 65 1b 00 00        add    $0x1b65,%ebx
 80484a1:    83 ec 1c                 sub    $0x1c,%esp
 80484a4:    8b 6c 24 30              mov    0x30(%esp),%ebp
 80484a8:    8d b3 0c ff ff ff        lea    -0xf4(%ebx),%esi
 80484ae:    e8 21 fe ff ff           call   80482d4 <_init>
 80484b3:    8d 83 08 ff ff ff        lea    -0xf8(%ebx),%eax
 80484b9:    29 c6                    sub    %eax,%esi
 80484bb:    c1 fe 02                 sar    $0x2,%esi
 80484be:    85 f6                    test   %esi,%esi
 80484c0:    74 27                    je     80484e9 <__libc_csu_init+0x59>
 80484c2:    8d b6 00 00 00 00        lea    0x0(%esi),%esi
 80484c8:    8b 44 24 38              mov    0x38(%esp),%eax
 80484cc:    89 2c 24                 mov    %ebp,(%esp)
 80484cf:    89 44 24 08              mov    %eax,0x8(%esp)
 80484d3:    8b 44 24 34              mov    0x34(%esp),%eax
 80484d7:    89 44 24 04              mov    %eax,0x4(%esp)
 80484db:    ff 94 bb 08 ff ff ff     call   *-0xf8(%ebx,%edi,4)
 80484e2:    83 c7 01                 add    $0x1,%edi
 80484e5:    39 f7                    cmp    %esi,%edi
 80484e7:    75 df                    jne    80484c8 <__libc_csu_init+0x38>
 80484e9:    83 c4 1c                 add    $0x1c,%esp
 80484ec:    5b                       pop    %ebx
 80484ed:    5e                       pop    %esi
 80484ee:    5f                       pop    %edi
 80484ef:    5d                       pop    %ebp
 80484f0:    c3                       ret
 80484f1:    eb 0d                    jmp    8048500 <__libc_csu_fini>
 80484f3:    90                       nop
 80484f4:    90                       nop
 80484f5:    90                       nop
 80484f6:    90                       nop
 80484f7:    90                       nop
 80484f8:    90                       nop
 80484f9:    90                       nop
 80484fa:    90                       nop
 80484fb:    90                       nop
 80484fc:    90                       nop
 80484fd:    90                       nop
 80484fe:    90                       nop
 80484ff:    90                       nop

08048500 <__libc_csu_fini>:
 8048500:    f3 c3                    repz ret

Disassembly of section .fini:

08048504 <_fini>:
 8048504:    53                       push   %ebx
 8048505:    83 ec 08                 sub    $0x8,%esp
 8048508:    e8 73 fe ff ff           call   8048380 <__x86.get_pc_thunk.bx>
 804850d:    81 c3 f3 1a 00 00        add    $0x1af3,%ebx
 8048513:    83 c4 08                 add    $0x8,%esp
 8048516:    5b                       pop    %ebx
 8048517:    c3                       ret
```

链接器将每个输入文件中相应的段合并在一起,故只存在一个合并后的文本段,一个合并后的数据段和
一个 bss 段(两个输入文件不会使用的,被初始化为 0 的数据段)。由于每个段都会被填充为 4K 对齐
以满足 x86 的页尺寸,因此文本段为 4K(减去文件中 20 字节长度的 a.out 头部,逻辑上它并不属于该段),
数据段和 bss 段每个同样也是 4K 字节。

合并后的文本段包含:

* 名为 _start 的库启动代码;

* 由 m.o 重定位到 0x8048477 的代码;

* 重定位到 0x804844d 的 a.o;

* 以及被重定位到文本段更高地址从 C 库中链接来的例程;

数据段,没有显示在这里,按照和文本段相同的顺序包含了合并后的数据段。

* 由于main 的代码被重定位到地址 0x8048477,所以这个代码要被修改到 start 代码的 push 指令中。

* 在main例程内部, 对字符串 string 的引用被重定位到 0x804a024, 这是 string 在数据段最终的位置,
  并且 call 指令中地址修改为 0x804844d, 这是 a 最终确定的地址.

* 在a内部, 对 strlen 和 write 的 call 指令也要修改为这两个例程的最终地址。

由于可执行程序的文件格式不是可以重链接的,且操作系统从已知的固定位置加载它,因此它不包含重定位数据。
它带有一个有助于调试器(debugger)工作的符号表,尽管这个程序没有使用这个符号表并且可以将其删除以节省空间。
