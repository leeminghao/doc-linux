应用调试之配置内核输出应用程序的段错误信息
================================================================================

path: kernel/arch/arm/mm/fault.c
```
void do_bad_area(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
{
        struct task_struct *tsk = current;
        struct mm_struct *mm = tsk->active_mm;

        /*
         * If we are in kernel mode at this point, we
         * have no context to handle this fault with.
         */
         if (user_mode(regs)) //在用户态出现错误用： __do_user_fault
              __do_user_fault(tsk, addr, fsr, SIGSEGV, SEGV_MAPERR, regs);
         else
              __do_kernel_fault(mm, addr, fsr, regs); // 在内核态出现错误用：__do_kernel_fault
}
```

在用户态发生错误的话会调用__do_user_fault这个函数：

```
/*
 * Something tried to access memory that isn't in our memory map..
 * User mode accesses just cause a SIGSEGV
 */
static void
__do_user_fault(struct task_struct *tsk, unsigned long addr,
                                   unsigned int fsr, unsigned int sig, int code,
                                            struct pt_regs *regs)
{
        struct siginfo si;

        trace_user_fault(tsk, addr, fsr);

#ifdef CONFIG_DEBUG_USER // 1. 配置内核
       if (((user_debug & UDBG_SEGV) && (sig == SIGSEGV)) ||
           ((user_debug & UDBG_BUS)  && (sig == SIGBUS))) {
           printk(KERN_DEBUG "%s: unhandled page fault (%d) at 0x%08lx, code 0x%03x\n",
                                  tsk->comm, sig, addr, fsr);
           show_pte(tsk->mm, addr);
           show_regs(regs);
}
#endif

        tsk->thread.address = addr;
        tsk->thread.error_code = fsr;
        tsk->thread.trap_no = 14;
        si.si_signo = sig;
        si.si_errno = 0;
        si.si_code = code;
        si.si_addr = (void __user *)addr;
        force_sig_info(sig, &si, tsk);
}
```

因此如果我们需要在使用户态发生错误时打印更多信息的话，就需要两项配置：

1、在内核里面配置：配置内核
2、在u-boot里面设置启动参数：

```
set bootargs console=ttySAC0 root=/dev/nfs nfsroot=192.168.183.128:/home/share/jz2440/fs_mini_mdev ip=192.168.183.127:192.168.183.128:192.168.183.225:255.255.255.0::eth0:off user_debug=0xff
```

上面我们配置好了内核以及启动参数，下面我们开始实验一下：

```
$ ./test_debug
```

之前只有两条输出信息：

```
a = 0x12
Segmentation fault
```

现在出现一大堆输出信息：

```
a = 0x12
pgd = c3c38000
[00000000] *pgd=33c4a031, *pte=00000000, *ppte=00000000

Pid: 745, comm:           test_debug
CPU: 0    Not tainted  (2.6.22.6 #20)
PC is at 0x84ac
LR is at 0x84d0
pc : [<000084ac>]    lr : [<000084d0>]    psr: 60000010
sp : be8c7e30  ip : be8c7e44  fp : be8c7e40
r10: 4013365c  r9 : 00000000  r8 : 00008514
r7 : 00000001  r6 : 000085cc  r5 : 00008568  r4 : be8c7eb4
r3 : 00000012  r2 : 00000000  r1 : 00001000  r0 : 00000000
Flags: nZCv  IRQs on  FIQs on  Mode USER_32  Segment user
Control: c000717f  Table: 33c38000  DAC: 00000015
[<c002bd1c>] (show_regs+0x0/0x4c) from [<c0030a98>] (__do_user_fault+0x5c/0xa4)
r4:c04a8320
[<c0030a3c>] (__do_user_fault+0x0/0xa4) from [<c0030d38>] (do_page_fault+0x1dc/0x20c)
r7:c00251e0 r6:c0020908 r5:c04a8320 r4:ffffffec
[<c0030b5c>] (do_page_fault+0x0/0x20c) from [<c002a224>] (do_DataAbort+0x3c/0xa0)
[<c002a1e8>] (do_DataAbort+0x0/0xa0) from [<c002ae48>] (ret_from_exception+0x0/0x10)
Exception stack(0xc3c7bfb0 to 0xc3c7bff8)
bfa0:                                     00000000 00001000 00000000 00000012
bfc0: be8c7eb4 00008568 000085cc 00000001 00008514 00000000 4013365c be8c7e40
bfe0: be8c7e44 be8c7e30 000084d0 000084ac 60000010 ffffffff
r8:00008514 r7:00000001 r6:000085cc r5:00008568 r4:c038b6c8
Segmentation fault
```

这样我们就可以分析了：

我们从PC值：0x84ac来分析

（1）反汇编应用程序：arm-linux-objdump -D test_debug > test_debug.dis
（2）在test_debug.dis里面搜索0x84ac

```
 00008490 <C>:
    8490: e1a0c00d  mov ip, sp
    8494: e92dd800  stmdb sp!, {fp, ip, lr, pc}
    8498: e24cb004  sub fp, ip, #4 ; 0x4
    849c: e24dd004  sub sp, sp, #4 ; 0x4
    84a0: e50b0010  str r0, [fp, #-16]
    84a4: e51b2010  ldr r2, [fp, #-16]
    84a8: e3a03012  mov r3, #18 ; 0x12
    84ac: e5823000  str r3, [r2]
    84b0: e89da808  ldmia sp, {r3, fp, sp, pc}
```

我们看到错误出现在C函数里面，并且根据上下文确定了是那一句出现了错误！
在内核里面发生错误我们可以通过栈信息来推断函数的调用关系，那么用户态的程序发生错误的话，能不能也
打印出来错误信息呢？答案是肯定的，我们再开看之前的函数：__do_user_fault

```
__do_user_fault(struct task_struct *tsk, unsigned long addr,
  unsigned int fsr, unsigned int sig, int code,
  struct pt_regs *regs)
{
    struct siginfo si;

#ifdef CONFIG_DEBUG_USER
    if (user_debug & UDBG_SEGV) {
         printk(KERN_DEBUG "%s: unhandled page fault (%d) at 0x%08lx, code 0x%03x\n",
                          tsk->comm, sig, addr, fsr);
         show_pte(tsk->mm, addr);
         show_regs(regs);
    }
#endif
```

分析：struct pt_regs *regs这个结构体还记得吧，里面存放了发生错误时各个寄存器的值，我们把它里面的
sp打印出来不久行了吗！
修改后的函数如下：

```
__do_user_fault(struct task_struct *tsk, unsigned long addr,
                unsigned int fsr, unsigned int sig, int code,
                struct pt_regs *regs)
{
    struct siginfo si;

#ifdef CONFIG_DEBUG_USER
    unsigned long ret;
    unsigned long val ;
    int i=0;

    if (user_debug & UDBG_SEGV) {
        printk(KERN_DEBUG "%s: unhandled page fault (%d) at 0x%08lx, code 0x%03x\n",
                          tsk->comm, sig, addr, fsr);
    show_pte(tsk->mm, addr);
    show_regs(regs);

    printk("Stack: \n");
    while(i<1024) {
        if(copy_from_user(&val, (const void __user *)(regs->ARM_sp+i*4), 4))
            break;
        printk("%08x ",val);
        i++;
        if(i%8==0)
            printk("\n");
    }
    printk("\n END of Stack\n");
}
#endif
```

重新编译内核，并且重新启动开发板，运行之前的测试程序得到如下栈的信息：

```
00000000 be8efe54 be8efe44 000084d0 000084a0 || 00000000 be8efe68 be8efe58
000084f0 000084c4  || 00000000 be8efe88 be8efe6c 00008554 000084e4  || 00000000
00000012 be8efeb4 00000001 00000000 be8efe8c 40034f14 00008524 00000000
00000000 0000839c 00000000 00000000 4001d594 000083c4 000085cc 4000c02c
be8efeb4 be8eff6f 00000000 be8eff7c be8eff86 be8eff8f be8eff96 be8effa1
be8effc4 be8effd2 00000000 00000010 00000003 00000006 00001000 00000011
00000064 00000003 00008034 00000004 00000020 00000005 00000006 00000007
40000000 00000008 00000000 00000009 0000839c 0000000b 00000000 0000000c
00000000 0000000d 00000000 0000000e 00000000 00000017 00000000 0000000f
be8eff6b 00000000 00000000 00000000 00000000 00000000 76000000 2e006c34
7365742f 65645f74 00677562 52455355 6f6f723d 4c4f0074 44575044 48002f3d
3d454d4f 4554002f 763d4d52 32303174 54415000 732f3d48 3a6e6962 7273752f
6962732f 622f3a6e 2f3a6e69 2f727375 006e6962 4c454853 622f3d4c 732f6e69
57500068 6d2f3d44 632f746e 2f65646f 68743832 7070615f 6265645f 2e006775
7365742f 65645f74 00677562 0000000
END of Stack
```

我们试一下能否根据它来推测出来调用关系：

```
00008490 <C>:
8490: e1a0c00d mov ip, sp
8494: e92dd800 stmdb sp!, {fp, ip, lr, pc}  //四个，入栈顺序：pc、lr、ip、fp
8498: e24cb004 sub fp, ip, #4 ; 0x4
849c: e24dd004 sub sp, sp, #4 ; 0x4    //一个，总共5个（4代表一个）
84a0: e50b0010 str r0, [fp, #-16]
84a4: e51b2010 ldr r2, [fp, #-16]
84a8: e3a03012 mov r3, #18 ; 0x12
84ac: e5823000 str r3, [r2]   //出错位置
84b0: e89da808 ldmia sp, {r3, fp, sp, pc}
```

所以：lr=000084d0
查找：000084d0 ，发现如下信息：

```
000084b4 <B>:
    84b4: e1a0c00d  mov ip, sp
    84b8: e92dd800  stmdb sp!, {fp, ip, lr, pc}//四个
    84bc: e24cb004  sub fp, ip, #4 ; 0x4
    84c0: e24dd004  sub sp, sp, #4 ; 0x4//一个
    84c4: e50b0010  str r0, [fp, #-16]
    84c8: e51b0010  ldr r0, [fp, #-16]
    84cc: ebffffef  bl 8490 <C>
    84d0: e89da808  ldmia sp, {r3, fp, sp, pc}
```

所以：lr=000084f0
搜索：000084f0 ，发现如下信息：

```
000084d4 <A>:
    84d4: e1a0c00d  mov ip, sp
    84d8: e92dd800  stmdb sp!, {fp, ip, lr, pc}//四个
    84dc: e24cb004  sub fp, ip, #4 ; 0x4
    84e0: e24dd004  sub sp, sp, #4 ; 0x4//一个
    84e4: e50b0010  str r0, [fp, #-16]
    84e8: e51b0010  ldr r0, [fp, #-16]
    84ec: ebfffff0  bl 84b4 <B>
    84f0: e89da808  ldmia sp, {r3, fp, sp, pc}
```

所以：lr=00008554
查找：00008554 ，找到如下信息：

```
00008514 <main>:
    8514: e1a0c00d  mov ip, sp
    8518: e92dd800  stmdb sp!, {fp, ip, lr, pc}//4个
    851c: e24cb004  sub fp, ip, #4 ; 0x4
    8520: e24dd010  sub sp, sp, #16 ; 0x10 //4个
    8524: e50b0010  str r0, [fp, #-16]
    8528: e50b1014  str r1, [fp, #-20]
    852c: e3a03000  mov r3, #0 ; 0x0
    8530: e50b301c  str r3, [fp, #-28]
    8534: e24b3018  sub r3, fp, #24 ; 0x18
    8538: e1a00003  mov r0, r3
    853c: ebffffec  bl 84f4 <A2>
    8540: e59f001c  ldr r0, [pc, #28] ; 8564 <.text+0x1c8>
    8544: e51b1018  ldr r1, [fp, #-24]
    8548: ebffff90  bl 8390 <.text-0xc>
    854c: e51b001c  ldr r0, [fp, #-28]
    8550: ebffffdf  bl 84d4 <A>
    8554: e3a03000  mov r3, #0 ; 0x0
    8558: e1a00003  mov r0, r3
    855c: e24bd00c  sub sp, fp, #12 ; 0xc
    8560: e89da800  ldmia sp, {fp, sp, pc}
    8564: 0000867c  andeq r8, r0, ip, ror r6
```

果然我们找到了调用关系：main->A->B->C
不过为了进一步深究，我们可以来看看是谁调用了main函数：

由main函数知道：
lr=40034f14
不太好分析，算了！直接给答案吧！

libc由库函数lobc_start_main来调用！