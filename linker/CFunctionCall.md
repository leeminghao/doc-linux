C 函数调用机制
================================================================================

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

https://github.com/leeminghao/doc-linux/blob/master/linker/stack_frame.jpg

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

https://github.com/leeminghao/doc-linux/blob/master/linker/main_swap.jpg

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

https://github.com/leeminghao/doc-linux/blob/master/linker/LinkerAndLoader.md