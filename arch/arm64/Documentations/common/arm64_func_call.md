AARCH64
========================================

本文通过实例描述arm与arm64在函数调用过程中栈帧的处理方法.

src
----------------------------------------

path: src/test.c

```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int
func2(int x, int y, int z)
{
    int r = 0;

    r = x + y + z;

    return r;
}

static int
func1(int i, int j)
{
    int tmp = 3;
    int k = 0;
    k = func2(i, j, tmp);
    return k;
}

int main(int argc, char *argv[])
{
    int i = 1;
    int j = 2;
    int k = 0;

    k = func1(i, j);

    return 0;
}
```

test32.maps
----------------------------------------

```
00000398 <func2>:
 398:	b086      	sub	sp, #24
 39a:	9003      	str	r0, [sp, #12]
 39c:	9102      	str	r1, [sp, #8]
 39e:	9201      	str	r2, [sp, #4]
 3a0:	2300      	movs	r3, #0
 3a2:	9305      	str	r3, [sp, #20]
 3a4:	9a03      	ldr	r2, [sp, #12]
 3a6:	9b02      	ldr	r3, [sp, #8]
 3a8:	441a      	add	r2, r3
 3aa:	9b01      	ldr	r3, [sp, #4]
 3ac:	4413      	add	r3, r2
 3ae:	9305      	str	r3, [sp, #20]
 3b0:	9b05      	ldr	r3, [sp, #20]
 3b2:	4618      	mov	r0, r3
 3b4:	b006      	add	sp, #24
 3b6:	4770      	bx	lr

000003b8 <func1>:
 3b8:	b500      	push	{lr}
 3ba:	b085      	sub	sp, #20
 3bc:	9001      	str	r0, [sp, #4]
 3be:	9100      	str	r1, [sp, #0]
 3c0:	2303      	movs	r3, #3
 3c2:	9302      	str	r3, [sp, #8]
 3c4:	2300      	movs	r3, #0
 3c6:	9303      	str	r3, [sp, #12]
 3c8:	9801      	ldr	r0, [sp, #4]
 3ca:	9900      	ldr	r1, [sp, #0]
 3cc:	9a02      	ldr	r2, [sp, #8]
 3ce:	f7ff ffe3 	bl	398 <func2>
 3d2:	9003      	str	r0, [sp, #12]
 3d4:	9b03      	ldr	r3, [sp, #12]
 3d6:	4618      	mov	r0, r3
 3d8:	b005      	add	sp, #20
 3da:	f85d fb04 	ldr.w	pc, [sp], #4
 3de:	bf00      	nop

000003e0 <main>:
 3e0:	b500      	push	{lr}
 3e2:	b087      	sub	sp, #28
 3e4:	9001      	str	r0, [sp, #4]
 3e6:	9100      	str	r1, [sp, #0]
 3e8:	2301      	movs	r3, #1
 3ea:	9303      	str	r3, [sp, #12]
 3ec:	2302      	movs	r3, #2
 3ee:	9304      	str	r3, [sp, #16]
 3f0:	2300      	movs	r3, #0
 3f2:	9305      	str	r3, [sp, #20]
 3f4:	9803      	ldr	r0, [sp, #12]
 3f6:	9904      	ldr	r1, [sp, #16]
 3f8:	f7ff ffde 	bl	3b8 <func1>
 3fc:	9005      	str	r0, [sp, #20]
 3fe:	2300      	movs	r3, #0
 400:	4618      	mov	r0, r3
 402:	b007      	add	sp, #28
 404:	f85d fb04 	ldr.w	pc, [sp], #4
```

test64.S
----------------------------------------

```
0000000000000628 <func2>:
 628:	d10083ff 	sub	sp, sp, #0x20
 62c:	b9000fe0 	str	w0, [sp,#12]
 630:	b9000be1 	str	w1, [sp,#8]
 634:	b90007e2 	str	w2, [sp,#4]
 638:	b9001fff 	str	wzr, [sp,#28]
 63c:	b9400fe1 	ldr	w1, [sp,#12]
 640:	b9400be0 	ldr	w0, [sp,#8]
 644:	0b000021 	add	w1, w1, w0
 648:	b94007e0 	ldr	w0, [sp,#4]
 64c:	0b000020 	add	w0, w1, w0
 650:	b9001fe0 	str	w0, [sp,#28]
 654:	b9401fe0 	ldr	w0, [sp,#28]
 658:	910083ff 	add	sp, sp, #0x20
 65c:	d65f03c0 	ret

0000000000000660 <func1>:
 660:	a9bd7bfd 	stp	x29, x30, [sp,#-48]!
 664:	910003fd 	mov	x29, sp
 668:	b9001fa0 	str	w0, [x29,#28]
 66c:	b9001ba1 	str	w1, [x29,#24]
 670:	52800060 	mov	w0, #0x3                   	// #3
 674:	b9002ba0 	str	w0, [x29,#40]
 678:	b9002fbf 	str	wzr, [x29,#44]
 67c:	b9401fa0 	ldr	w0, [x29,#28]
 680:	b9401ba1 	ldr	w1, [x29,#24]
 684:	b9402ba2 	ldr	w2, [x29,#40]
 688:	97ffffe8 	bl	628 <func2>
 68c:	b9002fa0 	str	w0, [x29,#44]
 690:	b9402fa0 	ldr	w0, [x29,#44]
 694:	a8c37bfd 	ldp	x29, x30, [sp],#48
 698:	d65f03c0 	ret

000000000000069c <main>:
 69c:	a9bd7bfd 	stp	x29, x30, [sp,#-48]! # x30 - lr ; x29 - fp
 6a0:	910003fd 	mov	x29, sp
 6a4:	b9001fa0 	str	w0, [x29,#28]
 6a8:	f9000ba1 	str	x1, [x29,#16]
 6ac:	52800020 	mov	w0, #0x1                   	// #1
 6b0:	b90027a0 	str	w0, [x29,#36]
 6b4:	52800040 	mov	w0, #0x2                   	// #2
 6b8:	b9002ba0 	str	w0, [x29,#40]
 6bc:	b9002fbf 	str	wzr, [x29,#44]
 6c0:	b94027a0 	ldr	w0, [x29,#36]
 6c4:	b9402ba1 	ldr	w1, [x29,#40]
 6c8:	97ffffe6 	bl	660 <func1>
 6cc:	b9002fa0 	str	w0, [x29,#44]
 6d0:	52800000 	mov	w0, #0x0                   	// #0
 6d4:	a8c37bfd 	ldp	x29, x30, [sp],#48
 6d8:	d65f03c0 	ret
```