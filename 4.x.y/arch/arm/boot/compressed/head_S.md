head.S
========================================

在zImage的生成过程中,是把arch/arm/boot/compressed/head.S和解压代码misc.c，decompress.c加在
压缩内核(piggy.gzip.o)的最前面最终生成vmlinux然后使用objcopy生成的原始二进制文件zImage的，
那么它的启动过程就是从这个head.S开始的，并且如果代码从RAM运行的话，是与位置无关的，可以
加载到内存的任何地方. 例如在使用lk来加载内核是将kernel加载到地址0x80208000处.该地址一般
由boot_img_hdr(boot.img的header结构体)中指定.详情参考:

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/README.md

在bootloader加载kernel映像zImage执行的过程我们知道,第一条指定即指向了head.S中start标志
开始代码，如下所示:

start
----------------------------------------

path: arch/arm/boot/compressed/head.S
```
/*
 * sort out different calling conventions
 */
        .align
        .arm                @ Always enter in ARM state
start:
        .type    start,#function
        .rept    7
        mov      r0, r0
        .endr
   ARM( mov r0, r0        )
   ARM( b   1f            )
 THUMB( adr r12, BSYM(1f) )
 THUMB( bx  r12           )

        .word    _magic_sig    @ Magic numbers to help the loader
        .word    _magic_start    @ absolute load/run zImage address
        .word    _magic_end    @ zImage end address
        .word    0x04030201    @ endianness flag

 THUMB( .thumb            )
1:
 ARM_BE8( setend    be    )            @ go BE8 if compiled for BE8
        mrs    r9, cpsr
#ifdef CONFIG_ARM_VIRT_EXT
        bl    __hyp_stub_install    @ get into SVC mode, reversibly
#endif
        mov    r7, r1            @ save architecture ID
        mov    r8, r2            @ save atags pointer

        /*
         * Booting from Angel - need to enter SVC mode and disable
         * FIQs/IRQs (numeric definitions from angel arm.h source).
         * We only do this if we were in user mode on entry.
         */
        mrs    r2, cpsr        @ get current mode
        tst    r2, #3          @ not user?
        bne    not_angel
        mov    r0, #0x17        @ angel_SWIreason_EnterSVC
 ARM(   swi    0x123456    )    @ angel_SWI_ARM
 THUMB( svc    0xab        )    @ angel_SWI_THUMB
no
```
