Linux Linux下缓冲区溢出攻击的原理及对策
================================================================================

在分析完Linux C语言函数调用方式之后:

https://github.com/leeminghao/doc-linux/blob/master/linker/StackOverFlow/CFunctionCall.md

我们了解了c语言函数的调用方式，其中在使用gcc编译c语言程序的时候我们使用了-fno-stack-protector
标志，下面我们介绍下有关该编译选项的作用以及危害.

堆栈缓冲区溢出的危害
--------------------------------------------------------------------------------

从逻辑上讲进程的堆栈是由多个堆栈帧构成的，其中每个堆栈帧都对应一个函数调用。当函数调用发生时，
新的堆栈帧被压入堆栈；当函数返回时，相应的堆栈帧从堆栈中弹出。尽管堆栈帧结构的引入为在高级语言中
实现函数或过程这样的概念提供了直接的硬件支持，但是由于将函数返回地址这样的重要数据保存在程序员
可见的堆栈中，因此也给系统安全带来了极大的隐患。

历史上最著名的缓冲区溢出攻击可能要算是1988年11月2日的Morris Worm所携带的攻击代码了。这个因特网蠕虫
利用了fingerd程序的缓冲区溢出漏洞，给用户带来了很大危害。此后，越来越多的缓冲区溢出漏洞被发现。
从bind、wu-ftpd、telnetd、apache等常用服务程序，到Microsoft、Oracle等软件厂商提供的应用程序，
都存在着似乎永远也弥补不完的缓冲区溢出漏洞。

Linux下堆栈缓冲区溢出攻击原理
--------------------------------------------------------------------------------

下面我们通过一个小例子来说明堆栈缓冲区溢出的危害.

### 实例1

path: src/ex3/dander.c
```
#include <stdio.h>

int function(int a, int b, int c)
{
    char buffer[14] = { 0 };
    int sum;
    int *ret;

    buffer[0] = 'a';
    buffer[1] = 'b';
    buffer[2] = 'c';
    buffer[3] = 'd';
    buffer[4] = 'e';
    buffer[5] = 'f';
    buffer[6] = 'g';
    buffer[7] = 'h';
    buffer[8] = 'i';
    buffer[9] = 'j';
    buffer[10] = 'k';
    buffer[11] = 'l';
    buffer[12] = 'm';
    buffer[13] = 'n';

    // the location is function return address
    ret = (int*)(buffer + 26);
    // return address + 8 for jump to next instruct
    (*ret) += 8;
    sum = a + b + c;
    return sum;
}

void main()
{
    int x;

    x = 0;
    function(1, 2, 3);
    x = 1;
    printf("%d\n", x);
}
```

按如下方式编译运行:

```
src/ex3$ gcc -m32 -fno-stack-protector -S danger.c -o danger.s
src/ex3$ gcc -m32 -fno-stack-protector danger.s -o danger
src/ex3$ ./danger
0
```

在main函数中，局部变量x的初值首先被赋为0，然后调用与x毫无关系的function函数，最后将x的值改为1并打印出来。
结果是多少呢? 结果竟然是0.

为什么结果值会是0呢?
这里的function函数与c语言调用方式

* https://github.com/leeminghao/doc-linux/blob/master/linker/StackOverFlow/CFunctionCall.md

章节中的function函数只是多了一个指针变量ret以及两条对ret进行操作的语句，
就是它们使得main函数最后打印的结果变成了0。对照下图function的栈帧可知，
地址"buffer + 26"处保存的正是函数function的返回地址：

```
|        ...
|-------------------------------| main ebp     : 40      : 32
|       call main ebp
|-------------------------------| -4           : 36      : 28
|    x = 0 - movl $0, 28(%esp)
|-------------------------------| -8           : 32      : 24
|
|-------------------------------| -12          : 28      : 20
|
|-------------------------------| -16          : 24      : 16
|
|-------------------------------| -20          : 20      : 12
|
|-------------------------------| -24          : 16      : 8
|             3
|-------------------------------| -28          : 12      : 4
|             2
|-------------------------------| -32          : 8       : base main esp
|             1
|-------------------------------| -36          : 4       : call function
|   x = 1 - movl $1, 28(%esp)     <-- return address
|-------------------------------| function ebp : main esp
|      main ebp
|-------------------------------| -4           : 28
|            ret
|-------------------------------| -8           : 24
|  sum  |   buffer[13-11]
|-------------------------------| -12          : 20
| buffer[10-9] | buffer[8-7]
|-------------------------------| -16          : 16
| buffer[6-5]  | buffer[4-3]
|-------------------------------| -20          : 12
| buferr[2-1]  | buffer[0]
|-------------------------------| -24          : 8
|
|-------------------------------| -28          : 4
|
|-------------------------------| -32          : base function esp
```

之后的语句"(*ret) += 8"将function函数的返回地址加了8，这样会达到什么效果呢？
看一下main函数对应的汇编程序就一目了然了:

```
src/ex3$ gcc -g -m32 -fno-stack-protector danger.c -o danger
src/ex3$ gdb danger
(gdb) disassemble main
Dump of assembler code for function main:
   0x080484a1 <+0>:    push   %ebp
   0x080484a2 <+1>:    mov    %esp,%ebp
   0x080484a4 <+3>:    and    $0xfffffff0,%esp
   0x080484a7 <+6>:    sub    $0x20,%esp
   0x080484aa <+9>:    movl   $0x0,0x1c(%esp)
   0x080484b2 <+17>:   movl   $0x3,0x8(%esp)
   0x080484ba <+25>:   movl   $0x2,0x4(%esp)
   0x080484c2 <+33>:   movl   $0x1,(%esp)
   0x080484c9 <+40>:   call   0x804841d <function>   // call function
   0x080484ce <+45>:   movl   $0x1,0x1c(%esp)        // function 函数的返回地址
   0x080484d6 <+53>:   mov    0x1c(%esp),%eax
   0x080484da <+57>:   mov    %eax,0x4(%esp)
   0x080484de <+61>:   movl   $0x8048580,(%esp)
   0x080484e5 <+68>:   call   0x80482f0 <printf@plt>
   0x080484ea <+73>:   leave
   0x080484eb <+74>:   ret
End of assembler dump.
(gdb)
```

地址为0x080484c9的call指令会将0x080484ce压入堆栈作为函数function的返回地址，
而语句"(*ret) += 8"的作用就是将0x80483ce加8从而变成了0x080484d6.
这么一改当函数function返回时地址为0x80483ce的mov指令就被跳过了，而这条mov指令的作用正是用来将x的值改为1。
既然x的值没有改变，我们打印看到的结果就必然是其初值0了。

当然，上述所示只是一个示例性的程序，通过修改保存在堆栈帧中的函数的返回地址，我们改变了程序正常的控制流。
程序的运行结果可能会使很多读者感到新奇，但是如果函数的返回地址被修改为指向一段精心安排好的恶意代码，
那时你又会做何感想呢？缓冲区溢出攻击正是利用了在某些体系结构下函数的返回地址被保存在程序员可见的堆栈中这一缺陷，
修改函数的返回地址，使得一段精心安排好的恶意代码在函数返回时得以执行，从而达到危害系统安全的目的。

为了讲述如何将函数的返回地址替换为我们自身实现的函数地址，下面我们先来了解一下Linux系统调用的实现.

### Linux系统调用


参考资料:
--------------------------------------------------------------------------------

* http://www.ibm.com/developerworks/cn/linux/l-overflow/

* http://www.cnblogs.com/coderzh/archive/2008/09/06/1285693.html
