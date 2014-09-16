Arm 体系结构
================================================================================

寄存器和处理器模式
--------------------------------------------------------------------------------

### 处理器模式

arm处理器模式如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/arm_cpu_mode.png

CPU的模式可以简单的理解为当前CPU的工作状态.
比如：当前操作系统正在执行用户程序，那么当前CPU工作在用户模式，这时网卡上有数据到达，产生中断信号，
CPU自动切换到一般中断模式下处理网卡数据（普通应用程序没有权限直接访问硬件），处理完网卡数据，
返回到用户模式下继续执行用户程序。

**特权模式**: 除用户模式外，其它模式均为特权模式（Privileged Modes）。

  ARM内部寄存器和一些片内外设在硬件设计上只允许（或者可选为只允许）特权模式下访问。此外，特权模式
  可以自由的切换处理器模式，而用户模式不能直接切换到别的模式。

**异常模式**: 特权模式中除系统（system）模式之外的其他5种模式又统称为异常模式。

  它们除了可以通过在特权下的程序切换进入外，也可以由特定的异常进入。比如硬件产生中断信号进入中断异常
  模式，读取没有权限数据进入中止异常模式，执行未定义指令时进入未定义指令中止异常模式。

  其中管理模式也称为超级用户模式，是为操作系统提供软中断的特有模式，正是由于有了软中断，用户程序才
  可以通过系统调用切换到管理模式。

* 用户模式：

  用户模式是用户程序的工作模式，它运行在操作系统的用户态，它没有权限去操作其它硬件资源，
  只能执行处理自己的数据，也不能切换到其它模式下，要想访问硬件资源或切换到其它模式只能通过
  软中断或产生异常。

* 系统模式：

  系统模式是特权模式，不受用户模式的限制。用户模式和系统模式共用一套寄存器，操作系统在该模式下
  可以方便的访问用户模式的寄存器，而且操作系统的一些特权任务可以使用这个模式访问一些受控的资源。

* 一般中断模式：

  一般中断模式也叫普通中断模式，用于处理一般的中断请求，通常在硬件产生中断信号之后自动进入该模式，
  该模式为特权模式，可以自由访问系统硬件资源。

* 快速中断模式：

  快速中断模式是相对一般中断模式而言的，它是用来处理对时间要求比较紧急的中断请求，主要用于高速数据
  传输及通道处理中。

* 管理模式：

   管理模式是CPU上电后默认模式，因此在该模式下主要用来做系统的初始化，软中断处理也在该模式下，
   当用户模式下的用户程序请求使用硬件资源时通过软件中断进入该模式。

* 终止模式：

  中止模式用于支持虚拟内存或存储器保护，当用户程序访问非法地址，没有权限读取的内存地址时，会进入该
  模式，linux下编程时经常出现的segment fault通常都是在该模式下抛出返回的。

* 未定义模式：

  未定义模式用于支持硬件协处理器的软件仿真,CPU在指令的译码阶段不能识别该指令操作时,会进入未定义模式.

### 寄存器

CPU的模式不同，在其对应模式下可以使用的寄存器也不相同, 如下表所示:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/arm_registers.png

* R0~R7在所有模式下都可以使用的共有寄存器;

* R8~R12是快速中断模式下私有的寄存器，其它模式下不能使用，之所以叫其快速中断，是因为快速中断模式下，
  这几个私有寄存器里数据在模式切换时可以不用入栈保存。

* 除了用户模式和系统模式共用一组R13，R14，其余每种模式都私有自己的R13，R14.

  因为在每种模式下都有自己的栈空间用于执行程序，在执行程序过程中还要保存返回地址，这样可以保证在
  进入不同模式时，当前模式下栈空间不被破坏。
  比如：网卡因为数据到达，产生了中断进入中断模式，在中断模式下有自己的中断处理例程(ISR), ISR在
  执行时要用到栈空间，因此要使用R13，R14。中断处理完成后，返回用户模式下，要继续执行被网卡中断信号
  中断的执行程序。

**注意**: 用户模式和系统模式为什么要共用一组R13，R14呢?
这是因为，在特权模式下可以自由切换工作模式，但是如果切换到用户模式下，就不能再切换到特权模式了，
这是CPU为操作系统提供的保护机制，但是有的时候就需要切换到用户模式下去使用其R13，R14寄存器，
比如当操作系统的进程进行上下文切换时，如果用户模式和系统模式共用一组寄存器，那么可以切换到系统模式
下（系统模式是特权模式）进行操作。

* 所有R15和CPU同时只能处理一条指令，在取指时，有一个CPSR表示当前CPU的状态即可。

理论上来说，ARM的15个通用寄存器是通用的，但实际上并非如此，特别是在过程调用的过程中。

#### ACPS寄存器的名称和用法(来源于Arm Software development tools)

**参考**：

http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0040d/ch06s02s01.html

```
Register        APCS name       APCS role
r0              a1            argument 1/scratch register/result
r1              a2            argument 2/scratch register/result
r2              a3            argument 3/scratch register/result
r3              a4            argument 4/scratch register/result
r4              v1            register variable
r5              v2            register variable
r6              v3            register variable
r7              v4            register variable
r8              v5            register variable
r9              sb/v6         static base/register variable
r10             sl/v7         stack limit/stack chunk handle/register variable
r11             fp/v8         frame pointer/register variable
r12             ip            scratch register/new -sb in inter-link-unit calls
r13             sp            lower end of the current stack frame
r14             lr            link register/scratch register
r15             pc            program counter
```



A more detailed look at APCS register usage
Although sb, sl, fp, ip, sp and lr are dedicated registers, the example in Example 6.2 shows ip and lr being used as temporary registers. Sometimes these registers are not used for their APCS roles. The details given below will enable you to write efficient and safe code that uses as many of the registers as possible, and avoids unnecessary saving and restoring of registers:

```
ip
Is used only during function calls, so it is not preserved across function calls. It is conventionally used as a local code generation temporary register. At other times it can be used as a corruptible temporary register. ip is not preserved in either its dedicated or non-dedicated APCS role.
lr
Holds the address to which control must return on function exit. It can be (and often is) used as a temporary register after pushing its contents onto the stack. This value can be loaded directly into the program counter when returning. lr is not preserved in either its dedicated or non-dedicated APCS role.
sp
Is the stack pointer. It is always valid in strictly conforming code, but need only be preserved in handwritten code. Note, however, that if any handwritten code makes use of the stack, or if interrupts can use the user mode stack, sp must be valid. In its non-dedicated APCS role, sp must be preserved. sp must be preserved on function exit for APCS conforming code.
sl
Is the stack limit register. If stack limit checking is enabled sl must be valid whenever sp is valid. In its non-dedicated APCS role, sl must be preserved.
fp
Is the frame pointer register. In the obsolete APCS variants that use fp, this register contains either zero, or a pointer to the most recently created stack backtrace data structure. As with the stack pointer, the frame pointer must be preserved, but in handwritten code it does not need to be available at every instant. However, it must be valid whenever any strictly conforming function is called. fp must always be preserved.
sb
Is the static base register. This register is used to access static data. If sb is not used, it is available as an additional register variable, v6, that must be preserved across function calls. sb must always be preserved.
```