__switch_to
========================================

path: arch/arm/kernel/entry-armv.S
```
/*
 * Register switch for ARMv3 and ARMv4 processors
 * r0 = previous task_struct, r1 = previous thread_info, r2 = next thread_info
 * previous and next are guaranteed not to be the same.
 */
ENTRY(__switch_to)
 UNWIND(.fnstart    )
 UNWIND(.cantunwind    )
    @ r1是被切换出去的线程的thread_info
    add  ip, r1, #TI_CPU_SAVE
    @ 保存被切换出去的线程的寄存器到自己的线程栈中，保存再它自己的thread_info的cpu_context里
    ldr  r3, [r2, #TI_TP_VALUE]
 ARM(    stmia    ip!, {r4 - sl, fp, sp, lr} )    @ Store most regs on stack
 THUMB(  stmia    ip!, {r4 - sl, fp}       )    @ Store most regs on stack
 THUMB(  str    sp, [ip], #4           )
 THUMB(  str    lr, [ip], #4           )
#ifdef CONFIG_CPU_USE_DOMAINS
    ldr  r6, [r2, #TI_CPU_DOMAIN]
#endif
    set_tls    r3, r4, r5
#if defined(CONFIG_CC_STACKPROTECTOR) && !defined(CONFIG_SMP)
    ldr  r7, [r2, #TI_TASK]
    ldr  r8, =__stack_chk_guard
    ldr  r7, [r7, #TSK_STACK_CANARY]
#endif
#ifdef CONFIG_CPU_USE_DOMAINS
#ifdef CONFIG_EMULATE_DOMAIN_MANAGER_V7
    stmdb r13!, {r0-r3, lr}
    mov   r0, r6
    bl    emulate_domain_manager_set
    ldmia r13!, {r0-r3, lr}
#else
    mcr   p15, 0, r6, c3, c0, 0        @ Set domain register
#endif
#endif
    mov   r5, r0
    add   r4, r2, #TI_CPU_SAVE
    ldr   r0, =thread_notify_head
    mov   r1, #THREAD_NOTIFY_SWITCH
    bl    atomic_notifier_call_chain
#if defined(CONFIG_CC_STACKPROTECTOR) && !defined(CONFIG_SMP)
    str   r7, [r8]
#endif
 THUMB(   mov    ip, r4               )
    mov   r0, r5
 ARM(    ldmia    r4, {r4 - sl, fp, sp, pc}  )    @ Load all regs saved previously
 THUMB(  ldmia    ip!, {r4 - sl, fp}       )    @ Load all regs saved previously
 THUMB(  ldr    sp, [ip], #4           )
 THUMB(  ldr    pc, [ip]           )
 UNWIND(.fnend        )
ENDPROC(__switch_to)
```