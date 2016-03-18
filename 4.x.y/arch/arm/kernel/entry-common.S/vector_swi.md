vector_swi
========================================

### swi中断

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/common/swi.md

当使用swi触发软中断的时候将会调用vector_swi处的中断处理函数来处理对应的软件中断.

vector_swi
----------------------------------------

path: arch/arm/kernel/asm-offsets.c
```
  DEFINE(S_FRAME_SIZE,		sizeof(struct pt_regs));
```

path: arch/arm/kernel/entry-common.S
```
ENTRY(vector_swi)
  @这个栈帧大小正好是struct pt_regs的大小. struct pt_regs中保存的是
　@线程用户态的寄存器上下文(模式上下文).
  sub    sp, sp, #S_FRAME_SIZE
  @ 将r0-r12寄存器压入内核栈中
  stmia  sp, {r0 - r12}            @ Calling r0 - r12
  ARM(   add    r8, sp, #S_PC    )
  @ 将用户态的sp、lr压入内核栈中
  ARM(   stmdb    r8, {sp, lr}^  )    @ Calling sp, lr
  THUMB( mov    r8, sp           )
  THUMB( store_user_sp_lr r8, r10, S_SP )    @ calling sp, lr
  @ sprs_svc中保存的是调用swi指令前的cpsr值，这里将它保存在寄存器r8中
  mrs    r8, spsr            @ called from non-FIQ mode, so ok.
  @ lr中的值是swi指令的下一行，也就是系统调用的用户态返回地址。将其压入内核栈中
  str    lr, [sp, #S_PC]            @ Save calling PC
  @ 将调用swi指令前的cpsr值压入内核栈中
  str    r8, [sp, #S_PSR]        @ Save CPSR
  @ 将r0压入内核栈中
  str    r0, [sp, #S_OLD_R0]        @ Save OLD_R0
  zero_fp
  ...
  /* Legacy ABI only. */
  ldr scno, [lr, #-4]  @ get SWI instruction
  ...
  enable_irq
  get_thread_info tsk
  adr    tbl, sys_call_table @ load syscall table pointer
  ...
  cmp    scno, #NR_syscalls        @ check upper syscall limit
  @ 这里先设置系统调用执行函数sys_xxx()的返回地址为ret_fast_syscall
  @ 这是设置的是当前线程lr_svc寄存器,当下次通过__switch_to恢复
  @ 当前线程的上下文(cpu_context)时首先调用ret_fast_syscall来恢复其用户态
  @ 的线程上下文(struct pt_regs).
  adr    lr, BSYM(ret_fast_syscall)    @ return address
  @ 以下就是根据系统调用号调用具体的执行函数。
  ldrcc  pc, [tbl, scno, lsl #2]        @ call sys_* routine
  ...
ENDPROC(vector_swi)
```

注意:

* 1.这里的sp已经是sp_svc了，也就是当前线程的内核栈了。
* 2.前面几句代码，就是保存调用swi之前的CPU的寄存器组。。
  分别为r0～r12、、sp、lr、pc、cpsr和r0,这里r0会存两个位置，一个代表第一个参数，另一个代表返回值。
  为什么会有两个r0？
* 3. {sp, lr}^中的"^"表示这里的sp和lr是用户态的寄存器。

### enable_irq

path: arch/arm/include/asm/assembler.h
```
/*
 * Enable and disable interrupts
 * CPSID   CPSIE  用于快速的开关中断。
 */
#if __LINUX_ARM_ARCH__ >= 6
    .macro disable_irq_notrace
    cpsid i
    .endm

    .macro enable_irq_notrace
    @保存完上下文后才使能中断,
    cpsie i
    .endm
#else
        ...
#endif
        ...
    .macro enable_irq
    asm_trace_hardirqs_on
    enable_irq_notrace
    .endm
```

* CPSID I PRIMASK=1 关中断
* CPSIE I PRIMASK=0 开中断
* CPSID F FAULTMASK=1 关异常
* CPSIE F FAULTMASK=0 开异常

I: IRQ F: FIQ

当系统调用退出时，将会调用ret_fast_syscall:

### 特殊寄存器标号定义

path: arch/arm/kernel/entry-header.S
```
/*
 * These are the registers used in the syscall handler, and allow us to
 * have in theory up to 7 arguments to a function - r0 to r6.
 *
 * r7 is reserved for the system call number for thumb mode.
 *
 * Note that tbl == why is intentional.
 *
 * We must set at least "tsk" and "why" when calling ret_with_reschedule.
 */
scno   .req    r7        @ syscall number
tbl    .req    r8        @ syscall table pointer
why    .req    r8        @ Linux syscall (!= 0)
tsk    .req    r9        @ current thread_info
```

ret_fast_syscall
----------------------------------------

path: arch/arm/kernel/entry-common.S
```
/*
 * This is the fast syscall return path.  We do as little as
 * possible here, and this includes saving r0 back into the SVC
 * stack.
 */
ret_fast_syscall:
    ...
    disable_irq                @ disable interrupts
    ldr    r1, [tsk, #TI_FLAGS]
    tst    r1, #_TIF_WORK_MASK
    bne    fast_work_pending

    ...

    /* perform architecture specific actions before user return */
    arch_ret_to_user r1, lr

    restore_user_regs fast = 1, offset = S_OFF
```

restore_user_regs
----------------------------------------

restore_user_regs基本上是vector_swi的逆过程了。注意restore_user_regs最后一句代码，mov后面带s，
且目标寄存器是pc。这是一种特殊的用法，CPU会将当前spsr中的值写入cpsr中，这样就回到了用户态。
以上就是系统调用时的CPU寄存器的保护和还原过程。

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/kernel/entry-header.S/restore_user_regs.md

系统调用刚进入到内核态，就会将当前的寄存器组保存在内核态的栈中；
当系统调用执行完内核态时，会将内核态栈中的寄存器组重新装载进来。
其他的模式切换也是相同的原理。
