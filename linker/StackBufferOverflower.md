Linux Linux下缓冲区溢出攻击的原理及对策
================================================================================

前言
--------------------------------------------------------------------------------

从逻辑上讲进程的堆栈是由多个堆栈帧构成的，其中每个堆栈帧都对应一个函数调用。当函数调用发生时，
新的堆栈帧被压入堆栈；当函数返回时，相应的堆栈帧从堆栈中弹出。尽管堆栈帧结构的引入为在高级语言中
实现函数或过程这样的概念提供了直接的硬件支持，但是由于将函数返回地址这样的重要数据保存在程序员
可见的堆栈中，因此也给系统安全带来了极大的隐患。

历史上最著名的缓冲区溢出攻击可能要算是1988年11月2日的Morris Worm所携带的攻击代码了。这个因特网蠕虫
利用了fingerd程序的缓冲区溢出漏洞，给用户带来了很大危害。此后，越来越多的缓冲区溢出漏洞被发现。
从bind、wu-ftpd、telnetd、apache等常用服务程序，到Microsoft、Oracle等软件厂商提供的应用程序，
都存在着似乎永远也弥补不完的缓冲区溢出漏洞。

Linux下缓冲区溢出攻击实例
--------------------------------------------------------------------------------

path: src/ex3/danger.c
```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void foo(const char *input)
{
    char buf[10];

    printf("My stack looks like:\n%p\n%p\n%p\n%p\n%p\n%p\n%p\n\n");
    strcpy(buf, input);
    printf("buf = %s\n", buf);
    printf("Now the stack looks like:\n%p\n%p\n%p\n%p\n%p\n%p\n%p\n\n");
}

void bar(void)
{
    printf("Oh, I've been hacked!\n");
}

int main(int argc, char *argv[])
{

    printf("address of foo = %p\n", foo);
    printf("address of bar = %p\n", bar);

    if (argc != 2) {
        printf("Please supply a string as an argument\n");
        return 1;
    }

    foo(argv[1]);
    printf("Exit");

    return 0;
}
```

按照如下方式编译:

```
$ gcc -m32 -g -fno-stack-protector danger.c -o danger
```

参考C函数的调用方式:

https://github.com/leeminghao/doc-linux/blob/master/linker/CFunctionCall.md

使用gdb来调试上述编译出来的程序找出返回地址:

```
```

参考资料:
--------------------------------------------------------------------------------

* http://www.ibm.com/developerworks/cn/linux/l-overflow/

* http://www.cnblogs.com/coderzh/archive/2008/09/06/1285693.html

* http://www.ibm.com/developerworks/cn/linux/l-cn-gccstack/