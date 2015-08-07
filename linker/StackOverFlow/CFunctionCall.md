C 函数调用机制
================================================================================

环境
--------------------------------------------------------------------------------

* 3.13.0-35-generic #62-Ubuntu SMP 2014 x86_64 GNU/Linux
* Target: x86_64-linux-gnu
  gcc version 4.8.2 (Ubuntu 4.8.2-19ubuntu1)

简述
--------------------------------------------------------------------------------

函数调用操作包括从一块代码到另一块代码之间的双向数据传递和执行控制转移。
数据传递通过函数参数和返回值来进行。另外，我们还需要在进入函数时为函数的
局部变量分配存储空间，并且在退出函数时收回这部分空间。Intel 80x86 CPU为
控制传递提供了简单的指令，而数据的传递和局部变量存储空间的分配与回收则通过栈操作来实现。

栈帧结构和控制转移权方式
--------------------------------------------------------------------------------

大多数CPU上的程序实现使用栈来支持函数调用操作:
栈被用来传递函数参数、存储返回信息、临时保存寄存器原有值以备恢复以及用来存储局部数据。
单个函数调用操作所使用的栈部分被称为栈帧（stack frame）结构，栈帧结构的两端由两个指针来指定。

寄存器ebp通常用做帧指针（frame pointer），而esp则用作栈顶指针（stack pointer）。
在函数执行过程中: **栈指针esp会随着数据的入栈和出栈而移动，因此函数中对大部分数据的访问都基于帧指针ebp进行**
如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/linker/StackOverFlow/stack_frame.jpg

对于函数A调用函数B的情况: 传递给B的参数包含在A的栈帧中。当A调用B时，
函数A的返回地址（调用返回后继续执行的指令地址）被压入栈中，栈中该位置也明确指明了A栈帧的结束处。
而B的栈帧则从随后的栈部分开始，即图中保存帧指针（ebp）的地方开始。
再随后则用于存放任何保存的寄存器值以及函数的临时值。

B函数同样也使用栈来保存不能放在寄存器中的局部变量值:
例如,

* 由于通常CPU的寄存器数量有限而不能够存放函数的所有局部数据;
* 或者有些局部变量是数组或结构,因此必须使用数组或结构引用来访问;

另外，C语言的地址操作符"&"被应用到一个局部变量上时，我们就需要为该变量生成一个地址，
即为变量的地址指针分配一空间, 最后，B函数会使用栈来保存调用任何其他函数的参数。

栈是往低(小)地址方向扩展的，而esp指向当前栈顶处的元素。通过使用push和pop指令
我们可以把数据压入栈中或从栈中弹出。对于没有指定初始值的数据所需要的存储空间，
我们可以通过把栈指针递减适当的值来做到。类似地，通过增加栈指针值我们可以回收栈中已分配的空间。

指令call和ret用于处理函数调用和返回操作:

* 调用指令call的作用是: 把返回地址压入栈中并且跳转到被调用函数开始处执行,
  返回地址是程序中紧随调用指令call后面一条指令的地址, 因此当被调函数返回时就会从该位置继续执行。

* 返回指令ret的作用是: 用于弹出栈顶处的地址并跳转到该地址处, 在使用该指令之前，
  应该先正确处理栈中内容，使得当前栈指针所指位置内容正是先前call指令保存的返回地址。
  另外，若返回值是一个整数或一个指针，那么寄存器eax将被默认用来传递返回值。

通常的函数调用方法:
call指令会将EIP的值自动压栈, 保护返回现场, 然后执行被调函数的程序;
等到执行被调函数的ret指令时,自动出栈给eip并还原现场, 继续执行call的下一行指令.

函数调用举例
--------------------------------------------------------------------------------

path: src/ex2/main.c

```
void swap(int *a, int *b)
{
    int c;
    c = *a;
    *a = *b;
    *b = c;
}

int main()
{
    int a, b;
    a = 16;
    b = 32;
    swap(&a, &b);
    return (a - b);
}
```

使用如下命令生成该c语言程序的汇编程序exch.s代码如下所示:

path: src/exch.s
```
$ gcc -m32 -Wall -S -o exch.s exch.c
$ cat exch.s
  .file "exch.c"
  .text
  .globl        swap
  .type         swap, @function
swap:
.LFB0:
        .cfi_startproc
        pushl   %ebp             # 保存原ebp值
        .cfi_def_cfa_offset 8
        .cfi_offset 5, -8
        movl        %esp, %ebp   # 设置当前函数的帧指针
        .cfi_def_cfa_register 5
        subl                  $16, %esp # 为局部变量c在栈内分配空间
        # 取函数第1个参数，该参数是一个整数类型值的指针
        movl                  8(%ebp), %eax
        # 取该指针所指位置的内容，并保存到局部变量c中
        movl                  (%eax), %eax
        movl                  %eax, -4(%ebp)
        # 再次取第2个参数,将第2个参数的值放到edx寄存器中
        movl                  12(%ebp), %eax
        movl                  (%eax), %edx
        # 然后取第1个参数,将第2个参数的值放到第1个参数所指定的位置
        movl                  8(%ebp), %eax
        movl                  %edx, (%eax)
        # 再次取第2个参数的值
        movl                  12(%ebp), %eax
        # 提局部变量c中的值(第一个参数的值)放到edx寄存器中
        movl                  -4(%ebp), %edx
        # 将存放在局部变量的第一个参数的值放到第2个参数所指定的位置
        movl                  %edx, (%eax)
        # 恢复原ebp,esp值（即movl %ebp,%esp; popl %ebp;）
        leave
        .cfi_restore 5
        .cfi_def_cfa 4, 4
        ret # 返回值赋予eip寄存器返回到调用函数位置处继续执行
        .cfi_endproc
.LFE0:
        .size   swap, .-swap
        .globl  main
        .type   main, @function
main:
.LFB1:
        .cfi_startproc
        pushl   %ebp            # 保存原ebp值, 设置当前函数的帧指针
        .cfi_def_cfa_offset 8
        .cfi_offset 5, -8
        movl        %esp, %ebp  # 将ebp设为当前栈顶指针
        .cfi_def_cfa_register 5
        subl                  $24, %esp  # 为整型局部变量a和b在栈中分配空间
        # 为局部变量赋初值(a=16，b=32)
        movl                  $16, -8(%ebp)
        movl                  $32, -4(%ebp)
        # 为调用swap()函数作准备，取局部变量b的地址,作为调用的参数并压入栈中, 即先压入第2个参数。
        leal                  -4(%ebp), %eax
        movl                  %eax, 4(%esp)
        # 再取局部变量a的地址，作为第1个参数入栈
        leal                  -8(%ebp), %eax
        movl                  %eax, (%esp)
        # 调用函数swap()
        call                  swap
        # 将a值放到edx寄存器中，此时a=32
        movl                  -8(%ebp), %edx
        # 将b值放到eax寄存器中，此时b=16
        movl                  -4(%ebp), %eax
        # 将edx的值减去eax的值，结果值存放到edx寄存器中
        subl                  %eax, %edx
        movl                  %edx, %eax
        leave  # 恢复原ebp、esp值（即movl %ebp,%esp; popl %ebp;）
        .cfi_restore 5
        .cfi_def_cfa 4, 4
        ret
        .cfi_endproc
.LFE1:
        .size   main, .-main
        .ident  "GCC: (Ubuntu 4.8.2-19ubuntu1) 4.8.2"
        .section      .note.GNU-stack,"",@progbits
```

在分析完上述代码之后我们来分析一下main函数执行前后的栈帧结构，如下所示:

https://github.com/leeminghao/doc-linux/blob/master/linker/StackOverFlow/main_swap.jpg

main函数也是一个函数
--------------------------------------------------------------------------------

上面这段汇编程序是使用gcc编译产生的，可以看出其中有几行多余的代码。可见gcc编译器还不能产生最高效率的代码，
这也是为什么某些关键代码需要直接使用汇编语言编制的原因之一。另外，上面提到C程序的主程序main()也是一个函数。
这是因为在编译链接时它将会作为crt0.s汇编程序的函数被调用。crt0.s是一个桩（stub）程序，
名称中的"crt"是"C run-time"的缩写。该程序的目标文件将被链接在每个用户执行程序的开始部分，
主要用于设置一些初始化全局变量等。gcclib_1.40中的crt0.s汇编程序如下所示：

```
    .text
    .globl _environ # 声明全局变量 _environ（对应C程序中的environ变量）。

__entry:   # 代码入口标号。
    movl 8(%esp), %eax    # 取程序的环境变量指针envp并保存在_environ中。
    movl %eax, _environ   # envp是execve()函数在加载执行文件时设置的。
    call _main            # 调用我们的主程序。其返回状态值在eax寄存器中。
    pushl %eax            # 压入返回值作为exit()函数的参数并调用该函数。
1:  call _exit
    jmp 1b                # 控制应该不会到达这里。若到达这里则继续执行exit()。
data
    _environ:             # 定义变量_environ，为其分配一个长字空间。
.long 0
```

通常使用gcc编译链接生成执行文件时，gcc会自动把该文件的代码作为第一个模块链接在可执行程序中。
在编译时使用显示详细信息选项"-v"就可以明显地看出这个链接操作过程：

```
[/usr/root]# gcc -v -o exch exch.s
gcc version 1.40
/usr/local/lib/gcc-as -o exch.o exch.s
/usr/local/lib/gcc-ld -o exch /usr/local/
lib/crt0.o exch.o /usr/local/lib/gnulib -lc
/usr/local/lib/gnulib
[/usr/root]#
```

因此在通常的编译过程中，我们无需特别指定stub模块crt0.o，
但是若想根据上面给出的汇编程序手工使用ld（gld）从exch.o模块链接产生可执行文件exch，
那么就需要在命令行上特别指明crt0.o这个模块，并且链接的顺序应该是crt0.o、所有程序模块、库文件。

为了使用ELF格式的目标文件以及建立共享库模块文件，现在的gcc编译器（2.x）已经把这个crt0扩展成几个模块：

```
crt1.o、crti.o、crtbegin.o、crtend.o和crtn.o。
```

这些模块的链接顺序为：

```
crt1.o --> crti.o --> crtbegin.o（crtbeginS.o） --> 所有程序模块 -->
crtend.o（crtendS.o） --> crtn.o --> 库模块文件。
```

gcc的配置文件specfile指定了这种链接顺序。
其中

* ctr1.o、crti.o和crtn.o由C库提供，是C程序的"启动"模块；

* crtbegin.o和crtend.o是C++语言的启动模块，由编译器gcc提供；

**注意**:

* crt1.o则与crt0.o的作用类似，主要用于在调用main()之前做一些初始化工作，全局符号_start就定义在这个模块中;

* crtbegin.o和crtend.o主要用于C++语言，在.ctors和.dtors区中执行全局构造（constructor）和析构（destructor）函数;

* crtbeginS.o和crtendS.o的作用与前两者类似，但用于创建共享模块中;

* crti.o用于在.init区中执行初始化函数init();

* .init区中包含进程的初始化代码，即当程序开始执行时，系统会在调用main()之前先执行.init中的代码;

* crtn.o则用于在.fini区中执行进程终止退出处理函数fini()函数，即当程序正常退出时（main()返回之后），
  系统会安排执行.fini中的代码。

更详细有关链接的过程分析可参考:

https://github.com/leeminghao/doc-linux/blob/master/linker/StackOverFlow/LinkerAndLoader.md

Linux下进程地址空间的布局及堆栈帧的结构
--------------------------------------------------------------------------------

### 概述

任何一个程序通常都包括代码段和数据段，这些代码和数据本身都是静态的。程序要想运行，首先要由操作
系统负责为其创建进程，并在进程的虚拟地址空间中为其代码段和数据段建立映射。光有代码段和数据段是
不够的,进程在运行过程中还要有其动态环境，其中最重要的就是堆栈。

如下所示为Linux下进程的地址空间布局：

https://github.com/leeminghao/doc-linux/blob/master/linker/StackOverFlow/proc_address_layout.gif

* 首先，execve(2)会负责为进程代码段和数据段建立映射，真正将代码段和数据段的内容读入内存是由系统
的缺页异常处理程序按需完成的;

* 另外，execve(2)还会将bss段清零，这就是为什么未赋初值的全局变量以及static变量其初值为零的原因;

* 进程用户空间的最高位置是用来存放程序运行时的命令行参数及环境变量的.
在这段地址空间的下方和bss段的上方还留有一个很大的空洞，而作为进程动态运行环境的堆栈和堆就栖身其中
，其中堆栈向下伸展，堆向上伸展。

### 堆栈中的数据

实际上堆栈中存放的就是与每个函数对应的堆栈帧: 当函数调用发生时，新的堆栈帧被压入堆栈；当函数返回时，相应的堆栈帧从堆栈中弹出。典型的堆栈帧结构下图所示:

https://github.com/leeminghao/doc-linux/blob/master/linker/StackOverFlow/stack_frame.gif

堆栈的布局大致如下所示:

堆栈帧的顶部为传递给函数的参数
下面是函数的返回地址
前一个堆栈帧的指针
最下面是分配给函数的局部变量使用的空间

一个堆栈帧通常都有两个指针:

**其中一个称为堆栈帧指针(ebp)，另一个称为栈顶指针(esp)**

前者所指向的位置是固定的，而后者所指向的位置在函数的运行过程中可变。因此，在函数中访问参数和局部变量时都是以堆栈帧(ebp)指针为基址，再加上一个偏移。

对照上图可知: **实参的偏移为正，局部变量的偏移为负**

### 实例

path: src/ex2/stack_frame.c
```
int function(int a, int b, int c)
{
    char buffer[14] = { 0 };
    buffer[13] = 'a';
    int sum;
    sum = a + b + c;
    return sum;
}

void main()
{
    int i;
    i = function(1, 2, 3);
}
```

按照如下命令编译成的汇编程序如下所示:

```
src/ex2$ gcc -fno-stack-protector -m32 -S stack_frame.c -o stack_frame.s
src/ex2$ ls
exch  exch.c  exch.s  stack_frame.c  stack_frame.s
src/ex2$ cat stack_frame.s
    .file    "stack_frame.c"
    .text
    .globl    function
    .type    function, @function
function:
.LFB0:
    # 下面就进入function函数了
    .cfi_startproc
    # 首先将main函数的堆栈帧指针ebp保存在堆栈中
    pushl    %ebp
    .cfi_def_cfa_offset 8
    .cfi_offset 5, -8
    # 并将当前的栈顶指针esp保存在堆栈帧指针ebp中
    movl    %esp, %ebp
    .cfi_def_cfa_register 5
    # 最后为function函数的局部变量buffer[14]和sum在堆栈中分配空间。
    subl    $32, %esp

    # 初始化buffer
    movl    $0, -18(%ebp)
    movl    $0, -14(%ebp)
    movl    $0, -10(%ebp)
    movw    $0, -6(%ebp)

    movb    $97, -5(%ebp)

    # 取出b参数的值放到eax中去
    movl    12(%ebp), %eax
    # 取出a参数的值放到edx中去
    movl    8(%ebp), %edx
    # 设置edx = edx + eax
    addl    %eax, %edx
    # 取出c参数的值放到eax寄存器中去
    movl    16(%ebp), %eax
    # eax = eax(c) + edx(b + a)
    addl    %edx, %eax
    # 以下两条语句将sum值保存到堆栈，然后返回给main函数
    movl    %eax, -4(%ebp)
    movl    -4(%ebp), %eax

    # 执行完函数function之后其堆栈弹出
    # leave指令将function堆栈帧指针ebp拷贝到esp中，于是在堆栈帧中为局部变量buffer[14]和sum分配的空间就被释放了;
    # 接着，leave指令还有一个功能，就是从堆栈中弹出一个机器字并将其存放到ebp中，
    # 这样main函数的ebp就被恢复为main函数的堆栈帧指针了.
    leave
    .cfi_restore 5
    .cfi_def_cfa 4, 4
    # ret指令再次从堆栈中弹出一个机器字并将其存放到指令指针eip中，这样控制就返回到了main函数中的movl指令处。
    ret
    .cfi_endproc
.LFE0:
    .size    function, .-function
    .globl    main
    .type    main, @function
main:
.LFB1:
    .cfi_startproc
    pushl    %ebp # 将调用main函数的函数栈帧指针(ebp)压栈
    .cfi_def_cfa_offset 8
    .cfi_offset 5, -8
    movl    %esp, %ebp # 设置当前栈顶(esp)为main函数栈帧指针(ebp)
    .cfi_def_cfa_register 5
    # 为main函数分配临时变量空间
    subl    $28, %esp

    # 由于C语言中函数传参遵循从右向左的压栈顺序，所以将三个参数从右向左依次被压入堆栈。
    # 三个实参的值分别为1、2、3
    movl    $3, 8(%esp)
    movl    $2, 4(%esp)
    movl    $1, (%esp)

    # call指令除了将控制转移到function之外，还要将call的下一条指令movl的地址，也就是function
    # 函数的返回地址压入堆栈
    call    function

    # movl指令将之前的sum值保存到变量i所在位置,至此函数function的堆栈帧就完全被销毁了
    movl    %eax, -4(%ebp)
    leave
    .cfi_restore 5
    .cfi_def_cfa 4, 4
    ret
    .cfi_endproc
.LFE1:
    .size    main, .-main
    .ident    "GCC: (Ubuntu 4.8.2-19ubuntu1) 4.8.2"
    .section    .note.GNU-stack,"",@progbits
```

这里我们着重关心一下与函数function对应的堆栈帧形成和销毁的过程:
至此，函数function的堆栈帧就构建完成了，其结构如下所示:

```
|---------------------|
|         ...
|---------------------| +16
|           3
|---------------------| +12
|           2
|---------------------| +8           : base main esp
|           1
|---------------------| +4           : call function
| movl %eax,-4(%ebp)    <-- return address
|---------------------| function ebp : main esp
|      main ebp
|---------------------| -4
|  sum  | buffer[13-12]
|---------------------| -8
|    buffer[11-8]
|---------------------| -12
|    buffer[7-4]
|---------------------| -16
|    buffer[3-0]
|---------------------| -20
|
|---------------------| -24
|
|---------------------| -28
|
|---------------------| -32 : function esp
```

**注意**:

* 首先，在Intel i386体系结构下，堆栈帧指针的角色是由ebp扮演的，而栈顶指针的角色是由esp扮演的.

* 函数function的局部变量buffer[14]由14个字符组成，其大小为14字节.

  在某些低版本的gcc编译器中堆栈帧中会为buffer分配16个字节。这是时间效率和空间效率之间的
  一种折衷，因为Intel i386是32位的处理器，其每次内存访问都必须是4字节对齐的，而高30位地址相同的
  4个字节就构成了一个机器字。因此，如果为了填补buffer[14]留下的两个字节而将sum分配在两个不同的
  机器字中，那么每次访问sum就需要两次内存操作，这显然是无法接受的.
  在低版本的gcc编译器上function的栈帧如下:

```
|---------------------| -4
|    buffer[13-12]
|---------------------| -8
|    buffer[11-8]
|---------------------| -12
|    buffer[7-4]
|---------------------| -16
|    buffer[3-0]
|---------------------| -20
|     sum
```

但是现代编译器针对上述问题做了优化，将sum放到了靠近ebp寄存器指向的地址处,并且会先计算sum,如果尽可能
的少为sum分配地址空间，在这里仅仅为sum分配了两个字节的地址空间，但是int型值一般需要占用4字节.
并且将buffer[14]放到了sum的下面, 这样做的好处是可以尽可能的节省空间.


**还有一点需要说明的是**: 如果使用的是其它版本的gcc的话，所看到的函数function对应的堆栈帧可能
  和上图所示有所不同。上面已经讲过，为函数function的局部变量buffer[14]和sum在堆栈中分配空间是
  通过对esp进行减法操作完成的(subl $32, %esp)，而sub指令中的32足够满足这里两个局部变量所需的
  存储空间大小。

为什么分配的存储空间不是buffer(14) + sum(4) = 18呢?

这与优化编译技术有关，在当前版本的gcc中为了有效运用目前流行的各种优化编译技术，
通常需要在每个函数的堆栈帧中留出一定额外的空间。

栈缓冲区溢出的危害
--------------------------------------------------------------------------------

在明白了Linux下进程空间的布局以及栈帧的结构之后，下面我们来关注一下我们之前在编译时
使用的-fno-stack-protector选项，这是为了去除堆栈缓冲区溢出而设置的。
下面我们先来了解下添加这个选项去除gcc编译器对堆栈缓冲区溢出保护的危害.

https://github.com/leeminghao/doc-linux/blob/master/linker/StackOverFlow/StackBufferOverflower.md
