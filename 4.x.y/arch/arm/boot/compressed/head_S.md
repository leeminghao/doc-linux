head.S
========================================

在zImage的生成过程中,是把arch/arm/boot/compressed/head.S和解压代码misc.c，decompress.c加在
压缩内核(piggy.gzip.o)的最前面最终生成vmlinux然后使用objcopy生成的原始二进制文件zImage的，
那么它的启动过程就是从这个head.S开始的，并且如果代码从RAM运行的话，是与位置无关的，可以
加载到内存的任何地方.

反汇编kbuild/binary/arch/arm/boot/compressed/vmlinux，查看0地址开始处的代码:

反汇编命令:
```
$ arm-eabi-objdump -Sl vmlinux > vmlinux.S
```

反汇编后代码如下所示:

path: vmlinux.S
```
...
00000000 <start>:
$a():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:113
       0:	e1a00000 	nop			; (mov r0, r0)
       4:	e1a00000 	nop			; (mov r0, r0)
       8:	e1a00000 	nop			; (mov r0, r0)
       c:	e1a00000 	nop			; (mov r0, r0)
      10:	e1a00000 	nop			; (mov r0, r0)
      14:	e1a00000 	nop			; (mov r0, r0)
      18:	e1a00000 	nop			; (mov r0, r0)
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:114
      1c:	e1a00000 	nop			; (mov r0, r0)
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:115
      20:	ea000003 	b	34 <start+0x34>
$d():
      24:	016f2818 	.word	0x016f2818
      28:	00000000 	.word	0x00000000
      2c:	0034a288 	.word	0x0034a288
      30:	04030201 	.word	0x04030201
$a():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:127
      34:	e10f9000 	mrs	r9, CPSR
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:129
      38:	eb000e00 	bl	3840 <__hyp_stub_install>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:131
      3c:	e1a07001 	mov	r7, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:132
      40:	e1a08002 	mov	r8, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:140
      44:	e10f2000 	mrs	r2, CPSR
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:141
      48:	e3120003 	tst	r2, #3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:142
      4c:	1a000001 	bne	58 <not_angel>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:143
      50:	e3a00017 	mov	r0, #23
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:144
      54:	ef123456 	svc	0x00123456
...
```
