Linux 0.11 内核环境搭建
================================================================================

PC 环境:

* ubuntu 14.04: Linux 3.13.0-35-generic x86_64 x86_64 x86_64 GNU/Linux
* gcc version 4.8.2 (Ubuntu 4.8.2-19ubuntu1)

Linux 0.11内核代码下载
--------------------------------------------------------------------------------

http://oldlinux.org/

准备工作
--------------------------------------------------------------------------------

### 安装as86

```
$ sudo apt-cache search as86
bin86 - 16-bit x86 assembler and loader
$ sudo apt-get install bin86
```

Linux 0.11内核代码修改
--------------------------------------------------------------------------------

### 修改Makefile及某些源文件

代码路径: sources/linux-org

* Makefile

A. 将AS由 gas 改为 as, LD由 gld 改为 ld, AR由gar改为ar

B. 将 linux-0.11-deb/Makefile 第34行中as的-c选项去除

C. 将所有CFLAGS中的 -fcombine-regs 与 -mstring-insns 选项去除, 并添加-fno-stack-protector

* 汇编程序

A. 将boot/bootsect.s中的C语言风格注释(/*) 用！替换

B. 将boot/下三个汇编程序的对齐指令由 .align n 改为 .align 2^n

C. 将所有汇编程序（包括用asm关键字内联的）中引用的C变量前的下划线去掉

* 头文件

  将segment.h和string.h中的"extern inline"改写为"static inline"

### make过程中出现的问题

##### 问题1

```
as -o boot/head.o boot/head.s
boot/head.s: Assembler messages:
boot/head.s:43: Error: unsupported instruction `mov'
```

这是因为本机系统为64位，因此需要给所有Makefile中的as命令加上 --32 选项。类似地，
根据GCC在线手册的说明 （见下方），需给所有Makefile中的CFLAGS加上 -m32 选项。

```
"The -m32 option sets int, long, and pointer types to 32 bits, and generates
code that runs on any i386 system."
```

##### 问题2

```
init/main.c:23:29: error: static declaration of ‘fork’ follows non-static declaration
     static inline _syscall0(int,fork)
include/unistd.h:134:6: note: in definition of macro ‘_syscall0’
     type name(void) \
init/main.c:24:29: error: static declaration of ‘pause’ follows non-static declaration
     static inline _syscall0(int,pause)
include/unistd.h:134:6: note: in definition of macro ‘_syscall0’
     type name(void) \
include/unistd.h:224:5: note: previous declaration of ‘pause’ was here
     int pause(void);
init/main.c:26:29: error: static declaration of ‘sync’ follows non-static declaration
     static inline _syscall0(int,sync)
include/unistd.h:134:6: note: in definition of macro ‘_syscall0’
     type name(void) \
include/unistd.h:235:5: note: previous declaration of ‘sync’ was here
     int sync(void);
```

这是因为fork(), pause(), sync()在unistd.h中被声明为int类型，而在main.c中它们却被定义成了
static inline int类型。（注意在内核代码中只有main.c中直接调用了了这三个函数） 可以用预处理指令的
方法在main.c中屏蔽上述三个函数在unistd.h中的声明（似乎也可以用extern inline的方法修改这三个函数
的定义来得到相同的效果，但是由于extern inline的特性比较奇怪，不推荐使用）:

在main.c中#include <unistd.h>之前加上一句#define __IN_MAIN__，然后用#ifndef将fork、pause、sync
在unistd.h中的声明包裹起来：

```
    #ifndef __IN_MAIN__
    int fork(void);
    int pause(void);
    int sync(void);
    #endif
```

##### 问题3

```
In file included from fork.c:15:0:
fork.c: In function ‘copy_mem’:
../include/linux/sched.h:189:1: error: ‘asm’ operand has impossible constraints
     __asm__("movw %%dx,%0\n\t" \
../include/linux/sched.h:211:28: note: in expansion of macro ‘_set_base’
     #define set_base(ldt,base) _set_base( ((char *)&(ldt)) , base )
fork.c:54:2: note: in expansion of macro ‘set_base’
      set_base(p->ldt[1],new_code_base);
../include/linux/sched.h:189:1: error: ‘asm’ operand has impossible constraints
     __asm__("movw %%dx,%0\n\t" \
../include/linux/sched.h:211:28: note: in expansion of macro ‘_set_base’
    #define set_base(ldt,base) _set_base( ((char *)&(ldt)) , base )
fork.c:55:2: note: in expansion of macro ‘set_base’
     set_base(p->ldt[2],new_data_base);
```

上述问题是由于内联汇编的写法不规范所致。根据GCC手册中对asm关键字的介绍

```
"You may not write a clobber description in a way that overlaps with an input
or output operand. For example, you may not have an operand describing a register
class with one member if you mention that register in the clobber list. Variables
declared to live in specific registers , and used as asm input or output operands
must have no part mentioned in the clobber description. There is no way for you
to specify that an input operand is modified without also specifying it as an output operand."
```

意即使用asm嵌入汇编语句时，若一个寄存器出现在“clobbered register”（即会被修改的寄存器）列表中，
则其不能再出现于输出寄存器或输入寄存器列表中。include/linux/sched.h的第189行开始的代码如下:

```
    #define _set_base(addr,base) \
    __asm__("movw %%dx,%0\n\t" \
    "rorl $16,%%edx\n\t" \
    "movb %%dl,%1\n\t" \
    "movb %%dh,%2" \
    ::"m" (*((addr)+2)), \
    "m" (*((addr)+4)), \
    "m" (*((addr)+7)), \
    "d" (base)) \
    :"dx")
```

可以看出寄存器dx同时出现在了输入寄存器列表和clobbered register列表中，因此编译无法通过。
修改方法：将clobbered register list删了即可。 同样的问题还出现在如下几个地方：

```
    include/linux/sched.h： set_base，set_limit
    include/string.h ：strcpy， strncpy，strcat，strncat，strcmp，strncmp，strchr， strrchr，strspn，strcspn，strpbrk，strstr，memcpy，memmove，memcmp，memchr，
    mm/memory.c：copy_page，get_free_page
    fs/buffer.c：COPY_BLK
    fs/namei.c：match
    fs/bitmap.c：clear_block，find_first_zero
    kernel/blk_drv/floppy.c：copy_buffer
    kernel/blk_drv/hd.c：port_read，port_write
    kernel/chr_drv/console.c：scrup，scrdown，csi_J，csi_K，con_write
```

##### 问题4

```
ld -r -o kernel.o sched.o system_call.o traps.o asm.o fork.o panic.o printk.o vsprintf.o sys.o exit.o signal.o mktime.o
ld: Relocatable linking with relocations from format elf32-i386 (sched.o) to format elf64-x86-64 (kernel.o) is not supported
```

同样，问题也是源于在64位系统上ld默认链接成的目标文件也为64位，只需将所有Makefile中的LD由ld改为
 ld -m elf_i386 即可。

##### 问题5

```
../include/asm/segment.h: Assembler messages:
../include/asm/segment.h:27: Error: bad register name `%dil'
../include/asm/segment.h:27: Error: bad register name `%sil'
```

include/asm/segment.h的第27行如下：

```
    extern inline void put_fs_byte(char val,char *addr)
    {
    __asm__ ("movb %0,%%fs:%1"::"r" (val),"m" (*addr));
    }
```

其中"r"表示使用任意动态分配的寄存器，将其改为"q"即可。"q"表示使用动态分配字节可寻址寄存器
（eax，ebx，ecx或edx）。

##### 问题6

```
exec.c: In function ‘copy_strings’:
exec.c:139:44: error: lvalue required as left operand of assignment
         !(pag = (char *) page[p/PAGE_SIZE] =
```

fs/exec.c的第139行如下:

```
    if (!(pag = (char *) page[p/PAGE_SIZE]) &&
    !(pag = (char *) page[p/PAGE_SIZE] =
    (unsigned long *) get_free_page()))
    return 0;
```

在if的条件判断式中，依连等号的求值顺序，首先求值的表达式是
(char *) page[p/PAGE_SIZE] = (unsigned long *) get_free_page()
这个是无法编译通过的，需要把它拆成两部分：

```
    if (!(pag = (char *) page[p/PAGE_SIZE])) {
    page[p/PAGE_SIZE] = (unsigned long *) get_free_page();
    if (!(pag = (char *)page[p/PAGE_SIZE]))
    return 0;
    }
```

malloc.c中也存在类似问题，应将156行的

```
    bdesc->page = bdesc->freeptr = (void *) cp = get_free_page();
```

改为

```
    cp = (char*)get_free_page();
    bdesc->page = bdesc->freeptr = (void *) cp;
```

##### 问题7

```
blk.h:87:6: error: #elif with no expression
 #elif
```

把kernel/blk_drv/blk.h中第87行的#elif改为#else即可。

##### 问题8

```
as --32 -c -o keyboard.o keyboard.s
keyboard.S: Assembler messages:
keyboard.S:47: Error: `%al' not allowed with `xorl'
```

将kernel/chr_drv/keyboard.S第47行的xorl改为xorb，因操作数是al寄存器，它是8位的。

##### 问题9

```
ld -m elf_i386 -s -x -M boot/head.o init/main.o \
        kernel/kernel.o mm/mm.o fs/fs.o \
        kernel/blk_drv/blk_drv.a kernel/chr_drv/chr_drv.a \
        kernel/math/math.a \
        lib/lib.a \
        -o tools/system > System.map
ld: warning: cannot find entry symbol _start; defaulting to 0000000008048098
```

这是因为ld在将所有目标文件链接起来时，不知道程序的入口点在哪里。由内核的启动过程知其从head.s中
开始执行，因此给head.s的 .text 段添加一句 .globl startup_32，然后给 ./Makefile 中的ld加上选项
 -e startup_32 以指定入口点。

另外注意，仅指定入口点的标号还不够，后续使用tools/build构建Image仍会出错，因为此时程序入口点的
地址仍是0x8048098（见上方出错信息的最后一行），而在tools/build.c中处理system模块时，认定的合法
入口点地址为0x0：

tools/build.c:

```
157        if ((id=open(argv[3],O_RDONLY,0))<0)
158                die("Unable to open 'system'");
159        if (read(id,buf,GCC_HEADER) != GCC_HEADER)
160                die("Unable to read header of 'system'");
161        if (((long *) buf)[5] != 0)       //判断入口点地址是否为0x0
162                die("Non-GCC header of 'system'");
```

因此还需添加 -Ttext 0 选项使startup_32标号对应的地址为0x0（更详细的说明见ld的手册，另有一个讨论见这里）。

还有一个问题是，上述代码中第161行上执行的检查是buf[]中第24-27的四个字节的内容，因为程序假设在
这个位置上保存着ELF头中的程序入口地址，然而事实上对于本机的GCC编译出的目标文件，使用readelf命令
查看其ELF头格式如下：

```
$ readelf -h tools/system
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           Intel 80386
  Version:                           0x1
  Entry point address:               0x0
  Start of program headers:          52 (bytes into file)
  ...
```

再结合od命令的结果：

```
$ od -w4 -N 80 -x tools/system
0000000 457f 464c
0000004 0101 0001
0000010 0000 0000
*
0000020 0002 0003
0000024 0001 0000
0000030 0000 0000
0000034 0034 0000
...
```

可以看出入口点地址事实上位于ELF头中第28-30字节的位置上，也就是((long*)buf)[6]处，所以应对
tools/build.c作对应的修改。（关于ELF头的格式，更详细的讨论见这里）

##### 问题10

```
gcc  -m32 -Wall -O -fstrength-reduce -fomit-frame-pointer -mtune=i386  \
    -o tools/build tools/build.c
In file included from /usr/include/features.h:395:0,
                 from /usr/include/stdio.h:27,
                 from tools/build.c:23:
/usr/include/gnu/stubs.h:7:27: fatal error: gnu/stubs-32.h: No such file or directory
 # include <gnu/stubs-32.h>
```

很显然这又是一个因64位系统上缺少32位库导致的问题（更多细节见这里），从源里装个32位库即可：

```
    sudo aptitude install libc6-dev-i386
```

##### 问题11

```
tools/build.c: In function ‘main’:
tools/build.c:72:4: warning: implicit declaration of function ‘MAJOR’ [-Wimplicit-function-declaration]
    major_root = MAJOR(sb.st_rdev);
tools/build.c:73:4: warning: implicit declaration of function ‘MINOR’ [-Wimplicit-function-declaration]
    minor_root = MINOR(sb.st_rdev);
/tmp/cctAdnmd.o: In function `main':
build.c:(.text+0xc7): undefined reference to `MAJOR'
build.c:(.text+0xe1): undefined reference to `MINOR'
collect2: error: ld returned 1 exit status
```

build.c中包含的是标准库的头文件 /usr/include/linux/fs.h ，但是这个头文件里并没有实现
MAJOR和MINOR宏。解决方法很简单，从include/linux/fs.h中把这两个宏复制到build.c中即可：

```
    #define MAJOR(a) (((unsigned)(a))>>8)
    #define MINOR(a) ((a)&0xff)
```

##### 问题12

```
tools/build boot/bootsect boot/setup tools/system /dev/hd6 > Image
/dev/hd6: No such file or directory
Couldn't stat root device.
```

这是因为在源代码顶层目录的Makefile中所指定的根设备为/dev/hd6（代表第二个硬盘的第一个分区）,
而本机上并不存在这个设备所致。Linus当年之所以指定根设备为/dev/hd6, 是因为他把Linux 0.11安装在了
机子的第二块硬盘上。我们这里打算通过在bochs中模拟软盘来启动编译好的系统，故在顶层目录Makefile中
设定根设备为软盘：

```
ROOT_DEV=FLOPPY
```

tools/build.c使用Makefile中指定的ROOT_DEV对应的设备号覆盖Image文件中的第509、510字节
（即地址508、509处），这两个字节所保存的根设备号将被bootsect.s使用。

tools/build.c
```
115    buf[508] = (char)minor_root
116    buf[509] = (char)major_root
117    i = write(1, buf, 512);    //注意标准输出已经被重定向至Image文件
```

更加详细的build过程可参考:

https://github.com/leeminghao/doc-linux/blob/master/0.11/tools/Build.md

Linux 0.11使用qemu调试
--------------------------------------------------------------------------------

在linux-mdf/目录下，打开另一个终端窗口，输入如下内容：

```
$ qemu-system-i386 -s -S -fda Image
```

在linux-mdf/目录下，打开另一个终端窗口，输入如下内容：

```
$ gdb
(gdb) set architecture i8086
(gdb) target remote localhost:1234
(gdb) set step-mode on
(gdb) break *0x7c00
(gdb) continue
```

进入如下命令的无限循环：

```
(gdb) info registers
(gdb) step
```

这样就可以使用qemu调试bootsect.s和其它文件的代码了

Linux 0.11内核运行
--------------------------------------------------------------------------------

若要运行一个Linux类操作系统，除了需要内核代码以外，还需要一个根文件系统设备，用来存储Linux系统
运行时必要文件. 对现代Linux系统来说，内核代码映像文件保存在根文件系统设备中，系统引导程序会从
根文件系统设备中将映像文件加载到内存中运行. 不过内核映像文件和根文件系统并不要求一定要存放在一个
设备上，即无须存放在一个软盘或一个硬盘分区中。对于只使用软盘的情况，由于软盘容量的限制，通常就把
内核映像文件与根文件系统分别放在一个盘片中，存放根文件系统的软盘就被称作根文件系统映像文件
（rootimage）。当然我们也可以从软盘中加载内核映像文件而使用硬盘中的根文件系统，或者直接让系统
直接从硬盘开始引导启动系统，即从硬盘的根文件系统设备中加载内核映像文件并使用硬盘中的根文件系统。
