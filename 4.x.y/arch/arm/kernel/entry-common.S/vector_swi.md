vector_swi
========================================

对于swi软中断的中断函数入口表项如下:

path: arch/arm/kernel/entry-armv.S
```
__stubs_start:
	@ This must be the first word
	.word	vector_swi
```

当使用swi触发软中断的时候将会调用vector_swi处的中断处理函数来处理对应的软件中断.

path: kernel/arch/arm/kernel/entry-common.S
```
/*=============================================================================
 * SWI handler
 *-----------------------------------------------------------------------------
 */

	.align	5
ENTRY(vector_swi)
        ...

	/*
         * Get the system call number.
         */

#if defined(CONFIG_OABI_COMPAT)
    ...
#elif defined(CONFIG_AEABI)
    ...
#elif defined(CONFIG_ARM_THUMB)
    /* Legacy ABI only, possibly thumb mode. */
    tst	r8, #PSR_T_BIT			@ this is SPSR from save_user_regs
    # r7 = r7 + (#__NR_SYSCALL_BASE)
    addne scno, r7, #__NR_SYSCALL_BASE	@ put OS number in
    ldreq scno, [lr, #-4]
#else
    ...
#endif
        ...

	enable_irq

	get_thread_info tsk
        # sys_call_table 在内核中是个跳转表,这个表中存储的是一系列的函数指针,这些指针就是
        # 系统调用函数的指针
	adr	tbl, sys_call_table		@ load syscall table pointer

        ...

	cmp	scno, #NR_syscalls		@ check upper syscall limit
	adr	lr, BSYM(ret_fast_syscall)	@ return address

        # 从这里执行sys_call_table中fork对应的系统调用函数.
	ldrcc	pc, [tbl, scno, lsl #2]		@ call sys_* routine

        ...
ENDPROC(vector_swi)
```
