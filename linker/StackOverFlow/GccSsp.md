GCC 中的编译器堆栈保护技术
================================================================================

以堆栈溢出为代表的缓冲区溢出已成为最为普遍的安全漏洞。由此引发的安全问题比比皆是。早在 1988 年，
美国康奈尔大学的计算机科学系研究生莫里斯 (Morris) 利用 UNIX fingered 程序的溢出漏洞，写了一段恶意
程序并传播到其他机器上，结果造成 6000 台 Internet 上的服务器瘫痪，占当时总数的 10%。各种操作系统
上出现的溢出漏洞也数不胜数。为了尽可能避免缓冲区溢出漏洞被攻击者利用，现今的编译器设计者已经开始
在编译器层面上对堆栈进行保护。现在已经有了好几种编译器堆栈保护的实现，其中最著名的是 StackGuard
和 Stack-smashing Protection (SSP，又名 ProPolice）。

编译器堆栈保护原理
--------------------------------------------------------------------------------

### GCC 4.x 中三个与堆栈保护有关的编译选项

* -fstack-protector：启用堆栈保护，不过只为局部变量中含有 char 数组的函数插入保护代码。
* -fstack-protector-all：启用堆栈保护，为所有函数插入保护代码。
* -fno-stack-protector：禁用堆栈保护。

### 编译器堆栈保护实例

#### 实例1

path: src/ex4/stack_guard.c
```
int function(int a, int b, int c)
{
    char buffer[14] = { 0 };
    int sum;

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

    sum = a + b + c;
    return sum;
}

int main(int argc, char **argv)
{
    int x;
    int y;

    x = function(1, 2, 3);
    y = x + 3;

    return 0;
}
```

编译为arm汇编文件如下:

path: src/ex4/nostackguard.s
```
# arm-linux-androideabi-gcc是android系统开发的arm gcc编译器
$ arm-linux-androideabi-gcc -fno-stack-protector -S stack_guard.c -o nostackguard.s
$ cat nostackguard.s
    .arch armv5te
    .fpu softvfp
    .eabi_attribute 20, 1
    .eabi_attribute 21, 1
    .eabi_attribute 23, 3
    .eabi_attribute 24, 1
    .eabi_attribute 25, 1
    .eabi_attribute 26, 2
    .eabi_attribute 30, 6
    .eabi_attribute 34, 0
    .eabi_attribute 18, 4
    .file    "stack_guard.c"
    .text
    .align    2
    .global    function
    .type    function, %function
function:
    @ args = 0, pretend = 0, frame = 40
    @ frame_needed = 1, uses_anonymous_args = 0
    @ link register save eliminated.
    # 将sp位置减4，然后将main函数fp进栈
    # 注意: !的作用是pre-index
    str    fp, [sp, #-4]!
    # 设置function函数的frame pointer寄存器为sp
    add    fp, sp, #0
    # 为function函数分配44个字的临时空间
    sub    sp, sp, #44
    # 将传递进来的参数保存到到function函数堆栈中
    str    r0, [fp, #-32]
    str    r1, [fp, #-36]
    str    r2, [fp, #-40]
    # 初始化buffer缓冲区为0
    sub    r3, fp, #24
    mov    r2, #0
    str    r2, [r3]
    add    r3, r3, #4
    mov    r2, #0
    str    r2, [r3]
    add    r3, r3, #4
    mov    r2, #0
    str    r2, [r3]
    add    r3, r3, #4
    mov    r2, #0
    strh    r2, [r3]    @ movhi
    add    r3, r3, #2
    # 初始化buffer缓冲区为字母
    mov    r3, #97
    strb    r3, [fp, #-24]
    mov    r3, #98
    strb    r3, [fp, #-23]
    mov    r3, #99
    strb    r3, [fp, #-22]
    mov    r3, #100
    strb    r3, [fp, #-21]
    mov    r3, #101
    strb    r3, [fp, #-20]
    mov    r3, #102
    strb    r3, [fp, #-19]
    mov    r3, #103
    strb    r3, [fp, #-18]
    mov    r3, #104
    strb    r3, [fp, #-17]
    mov    r3, #105
    strb    r3, [fp, #-16]
    mov    r3, #106
    strb    r3, [fp, #-15]
    mov    r3, #107
    strb    r3, [fp, #-14]
    mov    r3, #108
    strb    r3, [fp, #-13]
    mov    r3, #109
    strb    r3, [fp, #-12]
    mov    r3, #110
    strb    r3, [fp, #-11]
    # 取出第1个参数1的值到r2寄存器
    ldr    r2, [fp, #-32]
    # 取出第2个参数2的值到r3寄存器
    ldr    r3, [fp, #-36]
    # r2 + r3 -> r2 : 1 + 2 -> r2
    add    r2, r2, r3
    # 取出第3个参数的值放到r3寄存器: 1 + 2 + 3 -> r3
    ldr    r3, [fp, #-40]
    # 将计算出的和值存放到r3寄存器
    add    r3, r2, r3
    # 将和值保存到sum变量
    str    r3, [fp, #-8]
    ldr    r3, [fp, #-8]
    # 将r3值赋值到r0中
    mov    r0, r3
    # 出栈，直接将function函数fp赋值给sp
    sub    sp, fp, #0
    @ sp needed
    # 先将sp指向内存中的值赋值给fp，这时候fp就指向了main函数的frame pointer
    # 然后调整sp, 具体是在原来function函数frame pointer上调4字节位置
    ldr    fp, [sp], #4
    # 跳转会main函数执行"str r0,[fp,#-8]"指令
    # 注意: bl会将下一条指令地址保存到lr中，bx指令不会，直接跳转回去，不保存到lr
    bx    lr
    .size    function, .-function
    .align    2
    .global    main
    .type    main, %function
main:
    @ args = 0, pretend = 0, frame = 16
    @ frame_needed = 1, uses_anonymous_args = 0
    # ldm/stm的主要用途是把需要保存的寄存器复制到栈上.
    # stmfd - 预先减少存储; stmfa - 预先增加存储; stmed - 过后减少存储; stmea - 过后增加存储
    # 先将栈地址减少，然后将lr, fp寄存器值分别进栈
    stmfd    sp!, {fp, lr}
    # 设置main函数的frame pointer(fp)指针位置为sp + 4,此时fp指向的堆栈位置处保存的是
    # 调用main函数的函数的fp(frame pointer)
    add    fp, sp, #4
    # 为main函数分配16个字节的临时变量缓冲区.
    sub    sp, sp, #16
    # str/ldr用来 存储/装载 单一字节或字的数据 到/从 内存
    # 下面两条指令的作用就是分别存储r0,r1寄存器到fp - 16和fp - 20的位置
    str    r0, [fp, #-16]
    str    r1, [fp, #-20]
    # 将传递给function函数的参数1,2,3放到r0,r1,r2寄存器中去
    mov    r0, #1
    mov    r1, #2
    mov    r2, #3
    # 调用function函数, bl指令可将下一个指令"str r0,[fp, #-8]"的地址复制到lr寄存器中去
    # 接下来进入到function函数中去执行.
    bl    function(PLT)
    # 此时fp是main函数的frame pointer
    # 将和值保存到[fp, #-8]位置，这个位置是临时变量x的地址
    str    r0, [fp, #-8]
    # 取出和值并+3并赋值给临时变量y
    ldr    r3, [fp, #-8]
    add    r3, r3, #3
    str    r3, [fp, #-12]
    # 将r0, r3寄存器值清空
    mov    r3, #0
    mov    r0, r3
    # 将main函数栈帧弹出
    sub    sp, fp, #4
    @ sp needed
    # 将调用main函数的fp和下一条指令地址恢复到fp寄存器和pc寄存器
    # 这样可以接着调用main函数的位置接着执行后面的程序
    ldmfd    sp!, {fp, pc}
    .size    main, .-main
    .ident    "GCC: (GNU) 4.8"
    .section    .note.GNU-stack,"",%progbits
```

根据arm gcc编译生成的汇编程序，我们可以得到如下main函数调用function函数的堆栈

function_no_stack_chk_guard:

```
| lr (call main)     ------------------------ 高地址
|--------------------| main fp
| fp (call main)
|--------------------| -4  : sp(stmfd sp!, {fp, lr})
|
|--------------------| -8  : -4    : +12
|         x
|--------------------| -12 : -8    : +8
|         y
|--------------------| -16 : -12   : +4
| r0 -> [fp, #-16]
|--------------------| -20 : -16   : sp (sub, sp, sp, #16)
| r1 -> [fp, #-20]
|--------------------| function fp : sp (str fp, [sp,#-4]!)
|     fp(main)
|--------------------| -4   : +20
|    |sum3|sum2|sum1
|--------------------| -8   : +16
|sum0|    |    | buffer[13]
|--------------------| -12  : +12
| buffer[12-9]
|--------------------| -16  : +8
| buffer[8-5]
|--------------------| -20  : +4
| buffer[4-1]
|--------------------| -24  : r3 (sub r3, fp, #24)
|bf[0] |   |    |
|--------------------| -28
|
|--------------------| -32
| r0 -> [fp, #-32]
|--------------------| -36
| r1 -> [fp, #-36]
|--------------------| -40
| r2 -> [fp, #-40]
|--------------------| -44
|
|--------------------| ------------------------ 低地址
```

接下来我们在编译选项中添加-fstack-protector得到如下汇编代码:

path: src/ex4/stackguard.s
```
$ arm-linux-androideabi-gcc -fstack-protector -S stack_guard.c -o stackguard.s
$ cat stackguard.s
    .arch armv5te
    .fpu softvfp
    .eabi_attribute 20, 1
    .eabi_attribute 21, 1
    .eabi_attribute 23, 3
    .eabi_attribute 24, 1
    .eabi_attribute 25, 1
    .eabi_attribute 26, 2
    .eabi_attribute 30, 6
    .eabi_attribute 34, 0
    .eabi_attribute 18, 4
    .file    "stack_guard.c"
    .text
    .align    2
    .global    function
    .type    function, %function
function:
    @ args = 0, pretend = 0, frame = 40
    @ frame_needed = 1, uses_anonymous_args = 0
    stmfd    sp!, {fp, lr}
    add    fp, sp, #4
    sub    sp, sp, #40
    str    r0, [fp, #-32]
    str    r1, [fp, #-36]
    str    r2, [fp, #-40]

    # 以下便是在将要执行function函数之前多出来的代码

    # 将.L4标记处的值加载到r2寄存器, r2寄存器是GOT表去掉头三条的首地址.
    # 并加上pc指向指令的地址值存放到r2寄存器, 这样做的目的是获取当代码实际
    # 运行时GOT表加载到内存的地址
    ldr    r2, .L4
.LPIC0:
    add    r2, pc, r2
    # 将.L4+4处的值(__stack_chk_guard全局变量地址)加载到r3寄存器
    ldr    r3, .L4+4
    # 取出GOT表中标记__stack_chk_guard全局变量的条目
    ldr    r3, [r2, r3]
    # 从获取的条目中索引出__stack_chk_guard变量的地址保存到r3中
    ldr    r3, [r3]
    # 将r3寄存器的值(__stack_chk_guard全局变量变量的值)作为guard值保存到fp, #-8位置处
    str    r3, [fp, #-8]


    sub    r3, fp, #24
    mov    r1, #0
    str    r1, [r3]
    add    r3, r3, #4
    mov    r1, #0
    str    r1, [r3]
    add    r3, r3, #4
    mov    r1, #0
    str    r1, [r3]
    add    r3, r3, #4
    mov    r1, #0
    strh    r1, [r3]    @ movhi
    add    r3, r3, #2

    mov    r3, #97
    strb    r3, [fp, #-24]
    mov    r3, #98
    strb    r3, [fp, #-23]
    mov    r3, #99
    strb    r3, [fp, #-22]
    mov    r3, #100
    strb    r3, [fp, #-21]
    mov    r3, #101
    strb    r3, [fp, #-20]
    mov    r3, #102
    strb    r3, [fp, #-19]
    mov    r3, #103
    strb    r3, [fp, #-18]
    mov    r3, #104
    strb    r3, [fp, #-17]
    mov    r3, #105
    strb    r3, [fp, #-16]
    mov    r3, #106
    strb    r3, [fp, #-15]
    mov    r3, #107
    strb    r3, [fp, #-14]
    mov    r3, #108
    strb    r3, [fp, #-13]
    mov    r3, #109
    strb    r3, [fp, #-12]
    mov    r3, #110
    strb    r3, [fp, #-11]

    ldr    r1, [fp, #-32]
    ldr    r3, [fp, #-36]
    add    r1, r1, r3
    ldr    r3, [fp, #-40]
    add    r3, r1, r3
    str    r3, [fp, #-28]
    ldr    r3, [fp, #-28]
    mov    r0, r3

    # 以下是在要从function函数返回到main函数继续执行多出来的代码
    # 再次计算guard值
    ldr    r3, .L4+4
    ldr    r3, [r2, r3]
    # 从fp, #-8位置处取出前面保存的guard值
    ldr    r2, [fp, #-8]
    ldr    r3, [r3]
    # 比较原先保存的guard值和重新计算的guard值是否一致，一致的话返回到main函数继续执行
    # 如果继续向buffer[14], buffer[15], buffer[16]...中写数据的话，就会将原来保存起来的
    # guard值覆盖，最终导致两个值不相等就会跳转到__stack_chk_fail(bionic实现)函数执行.
    cmp    r2, r3
    beq    .L3
    bl    __stack_chk_fail(PLT)
.L3:
    sub    sp, fp, #4
    @ sp needed
    ldmfd    sp!, {fp, pc}
.L5:
    .align    2
.L4:
    .word    _GLOBAL_OFFSET_TABLE_-(.LPIC0+8) // 计算GOT的去掉头三条的地址
    .word    __stack_chk_guard(GOT) // 从GOT中获取__stack_chk_guard函数实际加载到内存的地址

    .size    function, .-function
    .align    2
    .global    main
    .type    main, %function
main:
    @ args = 0, pretend = 0, frame = 16
    @ frame_needed = 1, uses_anonymous_args = 0
    stmfd    sp!, {fp, lr}
    add    fp, sp, #4
    sub    sp, sp, #16
    str    r0, [fp, #-16]
    str    r1, [fp, #-20]
    mov    r0, #1
    mov    r1, #2
    mov    r2, #3
    bl    function(PLT)
    str    r0, [fp, #-12]
    ldr    r3, [fp, #-12]
    add    r3, r3, #3
    str    r3, [fp, #-8]
    mov    r3, #0
    mov    r0, r3
    sub    sp, fp, #4
    @ sp needed
    ldmfd    sp!, {fp, pc}
    .size    main, .-main
    .ident    "GCC: (GNU) 4.8"
    .section    .note.GNU-stack,"",%progbits
```

**注意**: __stack_chk_guard是程序每次启动的时候由bionic libc生成的一个随机数.
path: bionic/libc/bionic/libc_init_common.cpp

此时的函数调用堆栈如下所示:

function_stack_chk_guard:

```
| lr (call main)      ------------------------ 高地址
|--------------------| main fp
| fp (call main)
|--------------------| -4  : sp(stmfd sp!, {fp, lr})
|
|--------------------| -8  : -4    : +12
|         x
|--------------------| -12 : -8    : +8
|         y
|--------------------| -16 : -12   : +4
| r0 -> [fp, #-16]
|--------------------| -20 : -16   : sp (sub, sp, sp, #16)
| r1 -> [fp, #-20]
|--------------------|
|    lr(main)
|--------------------| function fp (add fp, sp, #4)
|    fp(main)
|--------------------| -4          : sp (stmfd sp!, {fp, lr})
|    |scg3|scg2|scg1       --> scg is __stack_chk_guard
|--------------------| -8
|scg0|    |    | bf[13]    --> bf is buffer
|--------------------| -12
|   buffer[12-9]
|--------------------| -16
|   buffer[8-5]
|--------------------| -20
|   buffer[4-1]
|--------------------| -24
| bf[0]|sum|sum| sum
|--------------------| -28
| sum |
|--------------------| -32
|        r0
|--------------------| -36
|        r1
|--------------------| -40
|        r3
|--------------------| -44 <-- function sp
|
|--------------------| ---------------------- 低地址
```

**注意**:

A. 函数function的局部变量buffer[14]由14个字符组成，其大小按说应为14字节，但是在堆栈帧中
却为其分配了16个字节。这是时间效率和空间效率之间的一种折衷，因为ARM是32架构的处理器，其每次内存
访问都必须是4字节对齐的，而高30位地址相同的4个字节就构成了一个机器字。因此，如果为了填补
buffer[14]留下的两个字节而将__stack_chk_guard分配在两个不同的机器字中，那么每次访问
__stack_chk_guard就需要两次内存操作，这显然是无法接受的。

根据这种规律，我们取出找到对任何长度的字符缓冲区对应的__stack_chk_guard值，只需要按照如下算法即可:
例如, char buffer[size];

**__stack_chk_guard值保存在堆栈中的地址 = (size % 4 == 0 ? size / 4 : (size / 4 + 1))**

B. 根据function_no_stack_chk_guard堆栈图和function_stack_chk_guard堆栈图我们还可以得到如下规律:
在gcc编译器添加对应的编译选项-fno-stack-protector的时候, 对于局部变量中含有char数组的函数,
char数组前一个对齐的字是其它局部变量;
在gcc编译器添加对应的编译选项-fstack-protector的时候, 对于局部变量中含有char数组的函数,
char数组前一个对齐的字是__stack_chk_guard值, 但是针对这种情况有多个char数组的，不会对
所有的char数组都设置一个__stack_chk_guard, 保护的仅仅是靠近frame pointer(fp)寄存器的那个
char数组,而在frame_pointer和被保护的char数组之间就是__stack_chk_guard值;

可参考如下例子:

https://github.com/leeminghao/doc-linux/blob/master/linker/StackOverFlow/src/ex4/stack_guard_double_buffer.c

https://github.com/leeminghao/doc-linux/blob/master/linker/StackOverFlow/src/ex4/stack_guard_double_buffer.s

**补充**:

由于android开发的arm-linux-androideabi-gcc编译器在链接时候采用的是bionic库以及linker链接器，
所以对于GOT表相关的看起来比较复杂, 可参考另外一个使用gnu库编译生成的汇编文件如下:

```
$ arm-none-linux-gnueabi-gcc -fstack-protector -S stack_guard.c -o stackguardgnu.s
```

生成的汇编文件如下:

https://github.com/leeminghao/doc-linux/blob/master/linker/StackOverFlow/src/ext4/stackguardgnu.s

### 实例2

如下所示的实例，有两个源代码文件overflow.c和nooverflow.c,其分别在Android系统上被编译为
overflow和nooverflow两个binary文件，其唯一的区别是overflow.c中多了一条"buffer[16] = 'q'"
语句，正是由于这条语句将guard值覆盖最终导致stack over flow.
具体代码如下所示:

* https://github.com/leeminghao/doc-linux/blob/master/linker/StackOverFlow/src/ex5/overflow.c

* https://github.com/leeminghao/doc-linux/blob/master/linker/StackOverFlow/src/ex5/nooverflow.c

* https://github.com/leeminghao/doc-linux/blob/master/linker/StackOverFlow/src/ex5/Android.mk

运行nooverflow得到的结果如下所示:

```
enter = e0e674e6
exit = e0e674e6
No stack overflow
```

运行overflow得到的结果如下所示:

```
enter = 73133bfd
exit = 73133b71
Aborted
```

小知识
--------------------------------------------------------------------------------

### _GLOBAL_OFFSET_TABLE_: 是全局偏移量表指针, 简称GOT.

GOT包含每个被当前这个目标模块引用的全局数据目标的表目。编译器还为GOT中每个表目生成一个重定位记录。
在加载时，动态链接器会重定位GOT中的每个表目，使得它包含正确的绝对地址。

ELF可以生成一种特殊的代码——与位置无关的代码(position-independent code,PIC)。
用户对gcc使用-fPIC指示GNU编译系统生成PIC代码。它是实现共享库或共享可执行代码的基础．这种代码的
特殊性在于它可以加载到内存地址空间的任何地址执行．这也是加载器可以很方便的在进程中动态链接共享库。

PIC的实现运用了一个事实: **就是代码段中任何指令和数据段中的任何变量之间的距离都是一个与代码段和数据段的绝对存储器位置无关的常量.**

因此，编译器在数据段开始的地方创建了一个表 - 叫做全局偏移量表(global offset table．GOT).
GOT包含每个被这个目标模块引用的全局数据目标的表目, 编译器还为GOT中每个表目生成一个重定位记录。
在加载时，动态链接器会重定位GOT中的每个表目，使得它包含正确的绝对地址。PIC代码在代码中实现通过
GOT间接的引用每个全局变量，这样，代码中本来简单的数据引用就变得复杂，必须加入得到GOT适当表目内容
的指令。对只读数据的引用也根据同样的道理，所以，加上PIC编译成的代码比一般的代码开销大.

如果一个elf可执行文件需要调用定义在共享库中的任何函数
那么它就有自己的GOT和PLT(procedure linkage table，过程链接表)．这两个节之间的交互可以实现延迟
绑定(lazy binging)，这种方法将过程地址的绑定推迟到第一次调用该函数。

为了实现延迟绑定，GOT的头三条表目是特殊的：

* GOT[0]: 包含.dynamic段的地址，.dynamic段包含了动态链接器用来绑定过程地址的信息，比如符号的位置
          和重定位信息;

* GOT[1]: 包含动态链接器的标识;

* GOT[2]: 包含动态链接器的延迟绑定代码的入口点。

GOT的其他表目为本模块要引用的一个全局变量或函数的地址。PLT是一个以16字节(32位平台中)表目的数组
形式出现的代码序列。其中PLT[0]是一个特殊的表目，它跳转到动态链接器中执行;每个定义在共享库中并被
本模块调用的函数在PLT中都有一个表目，从 PLT[1]开始．模块对函数的调用会转到相应PLT表目中执行，
这些表目由三条指令构成。第一条指令是跳转到相应的GOT存储的地址值中．第二条指令把函数相应的ID压入
栈中，第三条指令跳转到PLT[O]中调用动态链接器解析函数地址，并把函数真正地址存入相应的GOT表目中。
被调用函数GOT相应表目中存储的最初地址为相应PLT表目中第二条指令的地址值，函数第一次被调用后．
GOT表目中的值就为函数的真正地址。因此，第一次调用函数时开销比较大．但是其后的每次调用都只会花费
一条指令和一个间接的存储器引用。

参考资料
--------------------------------------------------------------------------------

* http://www.ibm.com/developerworks/cn/linux/l-cn-gccstack/