head.S
========================================

在zImage的生成过程中,是把arch/arm/boot/compressed/head.S和解压代码misc.c，decompress.c加在
压缩内核(piggy.gzip.o)的最前面最终生成vmlinux然后使用objcopy生成的原始二进制文件zImage的，
那么它的启动过程就是从这个head.S开始的，并且如果代码从RAM运行的话，是与位置无关的，可以
加载到内存的任何地方.

* head.o是内核的头部文件，负责初始设置;
* misc.o将主要负责内核的解压工作，它在head.o之后；
* piggy.gzip.o是一个中间文件，其实是一个压缩的内核(kernel/vmlinux).

例如在使用lk来加载内核是将kernel加载到地址0x80208000处.该地址一般由boot_img_hdr(boot.img
的header结构体)中指定.详情参考:

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/README.md

对应的内存布局如下：

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/memory_layout.md

在bootloader加载kernel映像zImage执行的过程我们知道,第一条指定即指向了head.S中start标志
开始代码，如下所示:

1.首先保存r1和r2的值，然后进入超级用户模式，并关闭中断。

path: arch/arm/boot/compressed/head.S
```
/*
 * sort out different calling conventions
 */
		.align
		.arm				@ Always enter in ARM state
start:
		.type	start,#function
		.rept	7
		mov	r0, r0
		.endr
   ARM(		mov	r0, r0		)
   ARM(		b	1f		)
 THUMB(		adr	r12, BSYM(1f)	)
 THUMB(		bx	r12		)

		.word	0x016f2818		@ Magic numbers to help the loader
		.word	start			@ absolute load/run zImage address
		.word	_edata			@ zImage end address
 THUMB(		.thumb			)
1:		mov	r7, r1			@ save architecture ID
		mov	r8, r2			@ save atags pointer

#ifndef __ARM_ARCH_2__
		/*
		 * Booting from Angel - need to enter SVC mode and disable
		 * FIQs/IRQs (numeric definitions from angel arm.h source).
		 * We only do this if we were in user mode on entry.
		 */
		mrs	r2, cpsr		@ get current mode
		tst	r2, #3			@ not user?
		bne	not_angel
		mov	r0, #0x17		@ angel_SWIreason_EnterSVC
 ARM(		swi	0x123456	)	@ angel_SWI_ARM
 THUMB(		svc	0xab		)	@ angel_SWI_THUMB
not_angel:
		mrs	r2, cpsr		@ turn off interrupts to
		orr	r2, r2, #0xc0		@ prevent angel from running
		msr	cpsr_c, r2
#else
		teqp	pc, #0x0c000003		@ turn off interrupts
#endif
```
