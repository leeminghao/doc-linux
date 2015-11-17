
out/target/product/leo/symbols/system/bin/test32:     file format elf32-littlearm


Disassembly of section .interp:

00000134 <.interp>:
 134:	7379732f 	cmnvc	r9, #-1140850688	; 0xbc000000
 138:	2f6d6574 	svccs	0x006d6574
 13c:	2f6e6962 	svccs	0x006e6962
 140:	6b6e696c 	blvs	1b9a6f8 <_end+0x1b986f4>
 144:	Address 0x0000000000000144 is out of bounds.


Disassembly of section .dynsym:

00000148 <.dynsym>:
	...
 158:	00000001 	andeq	r0, r0, r1
	...
 164:	00000012 	andeq	r0, r0, r2, lsl r0
 168:	0000000d 	andeq	r0, r0, sp
	...
 174:	00000012 	andeq	r0, r0, r2, lsl r0
 178:	0000001a 	andeq	r0, r0, sl, lsl r0
	...
 184:	00000012 	andeq	r0, r0, r2, lsl r0
 188:	00000031 	andeq	r0, r0, r1, lsr r0
 18c:	00002000 	andeq	r2, r0, r0
 190:	00000000 	andeq	r0, r0, r0
 194:	fff10010 			; <UNDEFINED> instruction: 0xfff10010
 198:	00000038 	andeq	r0, r0, r8, lsr r0
 19c:	00002000 	andeq	r2, r0, r0
 1a0:	00000000 	andeq	r0, r0, r0
 1a4:	fff10010 			; <UNDEFINED> instruction: 0xfff10010
 1a8:	00000044 	andeq	r0, r0, r4, asr #32
 1ac:	00002004 	andeq	r2, r0, r4
 1b0:	00000000 	andeq	r0, r0, r0
 1b4:	fff10010 			; <UNDEFINED> instruction: 0xfff10010

Disassembly of section .dynstr:

000001b8 <.dynstr>:
 1b8:	6c5f5f00 	mrrcvs	15, 0, r5, pc, cr0	; <UNPREDICTABLE>
 1bc:	5f636269 	svcpl	0x00636269
 1c0:	74696e69 	strbtvc	r6, [r9], #-3689	; 0xfffff197
 1c4:	635f5f00 	cmpvs	pc, #0, 30
 1c8:	615f6178 	cmpvs	pc, r8, ror r1	; <UNPREDICTABLE>
 1cc:	69786574 	ldmdbvs	r8!, {r2, r4, r5, r6, r8, sl, sp, lr}^
 1d0:	5f5f0074 	svcpl	0x005f0074
 1d4:	62616561 	rsbvs	r6, r1, #406847488	; 0x18400000
 1d8:	6e755f69 	cdpvs	15, 7, cr5, cr5, cr9, {3}
 1dc:	646e6977 	strbtvs	r6, [lr], #-2423	; 0xfffff689
 1e0:	7070635f 	rsbsvc	r6, r0, pc, asr r3
 1e4:	3072705f 	rsbscc	r7, r2, pc, asr r0
 1e8:	64655f00 	strbtvs	r5, [r5], #-3840	; 0xfffff100
 1ec:	00617461 	rsbeq	r7, r1, r1, ror #8
 1f0:	73625f5f 	cmnvc	r2, #380	; 0x17c
 1f4:	74735f73 	ldrbtvc	r5, [r3], #-3955	; 0xfffff08d
 1f8:	00747261 	rsbseq	r7, r4, r1, ror #4
 1fc:	646e655f 	strbtvs	r6, [lr], #-1375	; 0xfffffaa1
 200:	62696c00 	rsbvs	r6, r9, #0, 24
 204:	6f732e63 	svcvs	0x00732e63
 208:	62696c00 	rsbvs	r6, r9, #0, 24
 20c:	6f732e6d 	svcvs	0x00732e6d
 210:	62696c00 	rsbvs	r6, r9, #0, 24
 214:	63647473 	cmnvs	r4, #1929379840	; 0x73000000
 218:	732e2b2b 	teqvc	lr, #44032	; 0xac00
 21c:	Address 0x000000000000021c is out of bounds.


Disassembly of section .hash:

00000220 <.hash>:
 220:	00000003 	andeq	r0, r0, r3
 224:	00000007 	andeq	r0, r0, r7
 228:	00000004 	andeq	r0, r0, r4
 22c:	00000006 	andeq	r0, r0, r6
 230:	00000005 	andeq	r0, r0, r5
	...
 240:	00000002 	andeq	r0, r0, r2
 244:	00000000 	andeq	r0, r0, r0
 248:	00000001 	andeq	r0, r0, r1
 24c:	00000003 	andeq	r0, r0, r3

Disassembly of section .rel.dyn:

00000250 <.rel.dyn>:
 250:	00001fdc 	ldrdeq	r1, [r0], -ip
 254:	00000017 	andeq	r0, r0, r7, lsl r0
 258:	00001fe0 	andeq	r1, r0, r0, ror #31
 25c:	00000017 	andeq	r0, r0, r7, lsl r0
 260:	00001fe4 	andeq	r1, r0, r4, ror #31
 264:	00000017 	andeq	r0, r0, r7, lsl r0
 268:	00001fe8 	andeq	r1, r0, r8, ror #31
 26c:	00000017 	andeq	r0, r0, r7, lsl r0

Disassembly of section .rel.plt:

00000270 <.rel.plt>:
 270:	00001ff8 	strdeq	r1, [r0], -r8
 274:	00000116 	andeq	r0, r0, r6, lsl r1
 278:	00001ffc 	strdeq	r1, [r0], -ip
 27c:	00000216 	andeq	r0, r0, r6, lsl r2

Disassembly of section .plt:

00000280 <__libc_init@plt-0x14>:
 280:	e52de004 	push	{lr}		; (str lr, [sp, #-4]!)
 284:	e59fe004 	ldr	lr, [pc, #4]	; 290 <__libc_init@plt-0x4>
 288:	e08fe00e 	add	lr, pc, lr
 28c:	e5bef008 	ldr	pc, [lr, #8]!
 290:	00001d5c 	andeq	r1, r0, ip, asr sp

00000294 <__libc_init@plt>:
 294:	e28fc600 	add	ip, pc, #0, 12
 298:	e28cca01 	add	ip, ip, #4096	; 0x1000
 29c:	e5bcfd5c 	ldr	pc, [ip, #3420]!	; 0xd5c

000002a0 <__cxa_atexit@plt>:
 2a0:	e28fc600 	add	ip, pc, #0, 12
 2a4:	e28cca01 	add	ip, ip, #4096	; 0x1000
 2a8:	e5bcfd54 	ldr	pc, [ip, #3412]!	; 0xd54

Disassembly of section .text:

000002ac <_start>:
 2ac:	e92d4800 	push	{fp, lr}
 2b0:	e28db004 	add	fp, sp, #4
 2b4:	e24dd010 	sub	sp, sp, #16
 2b8:	e59f3050 	ldr	r3, [pc, #80]	; 310 <_start+0x64>
 2bc:	e08f3003 	add	r3, pc, r3
 2c0:	e59f204c 	ldr	r2, [pc, #76]	; 314 <_start+0x68>
 2c4:	e7932002 	ldr	r2, [r3, r2]
 2c8:	e50b2014 	str	r2, [fp, #-20]	; 0xffffffec
 2cc:	e59f2044 	ldr	r2, [pc, #68]	; 318 <_start+0x6c>
 2d0:	e7932002 	ldr	r2, [r3, r2]
 2d4:	e50b2010 	str	r2, [fp, #-16]
 2d8:	e59f203c 	ldr	r2, [pc, #60]	; 31c <_start+0x70>
 2dc:	e7932002 	ldr	r2, [r3, r2]
 2e0:	e50b200c 	str	r2, [fp, #-12]
 2e4:	e1a0200b 	mov	r2, fp
 2e8:	e2822004 	add	r2, r2, #4
 2ec:	e50b2008 	str	r2, [fp, #-8]
 2f0:	e24bc014 	sub	ip, fp, #20
 2f4:	e51b0008 	ldr	r0, [fp, #-8]
 2f8:	e3a01000 	mov	r1, #0
 2fc:	e59f201c 	ldr	r2, [pc, #28]	; 320 <_start+0x74>
 300:	e7933002 	ldr	r3, [r3, r2]
 304:	e1a02003 	mov	r2, r3
 308:	e1a0300c 	mov	r3, ip
 30c:	ebffffe0 	bl	294 <__libc_init@plt>
 310:	00001d28 	andeq	r1, r0, r8, lsr #26
 314:	fffffff0 			; <UNDEFINED> instruction: 0xfffffff0
 318:	fffffff4 			; <UNDEFINED> instruction: 0xfffffff4
 31c:	fffffff8 			; <UNDEFINED> instruction: 0xfffffff8
 320:	fffffffc 			; <UNDEFINED> instruction: 0xfffffffc

00000324 <__atexit_handler_wrapper>:
 324:	e92d4800 	push	{fp, lr}
 328:	e28db004 	add	fp, sp, #4
 32c:	e24dd008 	sub	sp, sp, #8
 330:	e50b0008 	str	r0, [fp, #-8]
 334:	e51b3008 	ldr	r3, [fp, #-8]
 338:	e3530000 	cmp	r3, #0
 33c:	0a000001 	beq	348 <__atexit_handler_wrapper+0x24>
 340:	e51b3008 	ldr	r3, [fp, #-8]
 344:	e12fff33 	blx	r3
 348:	e24bd004 	sub	sp, fp, #4
 34c:	e8bd8800 	pop	{fp, pc}

00000350 <atexit>:
 350:	e92d4800 	push	{fp, lr}
 354:	e28db004 	add	fp, sp, #4
 358:	e24dd008 	sub	sp, sp, #8
 35c:	e50b0008 	str	r0, [fp, #-8]
 360:	e59f3028 	ldr	r3, [pc, #40]	; 390 <atexit+0x40>
 364:	e08f3003 	add	r3, pc, r3
 368:	e1a00003 	mov	r0, r3
 36c:	e51b1008 	ldr	r1, [fp, #-8]
 370:	e59f301c 	ldr	r3, [pc, #28]	; 394 <atexit+0x44>
 374:	e08f3003 	add	r3, pc, r3
 378:	e1a02003 	mov	r2, r3
 37c:	ebffffc7 	bl	2a0 <__cxa_atexit@plt>
 380:	e1a03000 	mov	r3, r0
 384:	e1a00003 	mov	r0, r3
 388:	e24bd004 	sub	sp, fp, #4
 38c:	e8bd8800 	pop	{fp, pc}
 390:	ffffffb8 			; <UNDEFINED> instruction: 0xffffffb8
 394:	00001c84 	andeq	r1, r0, r4, lsl #25

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

Disassembly of section .note.android.ident:

00000408 <abitag>:
 408:	00000008 	andeq	r0, r0, r8
 40c:	00000004 	andeq	r0, r0, r4
 410:	00000001 	andeq	r0, r0, r1
 414:	72646e41 	rsbvc	r6, r4, #1040	; 0x410
 418:	0064696f 	rsbeq	r6, r4, pc, ror #18
 41c:	00000016 	andeq	r0, r0, r6, lsl r0

Disassembly of section .ARM.exidx:

00000420 <.ARM.exidx>:
 420:	7fffff78 	svcvc	0x00ffff78
 424:	8005b0b0 	strhhi	fp, [r5], -r0
 428:	7fffff90 	svcvc	0x00ffff90
 42c:	80048400 	andhi	r8, r4, r0, lsl #8
 430:	7fffffb0 	svcvc	0x00ffffb0
 434:	80068400 	andhi	r8, r6, r0, lsl #8
 438:	7fffffd0 	svcvc	0x00ffffd0
 43c:	00000001 	andeq	r0, r0, r1

Disassembly of section .preinit_array:

00001ecc <__PREINIT_ARRAY__>:
    1ecc:	ffffffff 			; <UNDEFINED> instruction: 0xffffffff
    1ed0:	00000000 	andeq	r0, r0, r0

Disassembly of section .init_array:

00001ed4 <__INIT_ARRAY__>:
    1ed4:	ffffffff 			; <UNDEFINED> instruction: 0xffffffff
    1ed8:	00000000 	andeq	r0, r0, r0

Disassembly of section .fini_array:

00001edc <__FINI_ARRAY__>:
    1edc:	ffffffff 			; <UNDEFINED> instruction: 0xffffffff
    1ee0:	00000000 	andeq	r0, r0, r0

Disassembly of section .dynamic:

00001ee4 <_DYNAMIC>:
    1ee4:	00000003 	andeq	r0, r0, r3
    1ee8:	00001fec 	andeq	r1, r0, ip, ror #31
    1eec:	00000002 	andeq	r0, r0, r2
    1ef0:	00000010 	andeq	r0, r0, r0, lsl r0
    1ef4:	00000017 	andeq	r0, r0, r7, lsl r0
    1ef8:	00000270 	andeq	r0, r0, r0, ror r2
    1efc:	00000014 	andeq	r0, r0, r4, lsl r0
    1f00:	00000011 	andeq	r0, r0, r1, lsl r0
    1f04:	00000011 	andeq	r0, r0, r1, lsl r0
    1f08:	00000250 	andeq	r0, r0, r0, asr r2
    1f0c:	00000012 	andeq	r0, r0, r2, lsl r0
    1f10:	00000020 	andeq	r0, r0, r0, lsr #32
    1f14:	00000013 	andeq	r0, r0, r3, lsl r0
    1f18:	00000008 	andeq	r0, r0, r8
    1f1c:	6ffffffa 	svcvs	0x00fffffa
    1f20:	00000004 	andeq	r0, r0, r4
    1f24:	00000015 	andeq	r0, r0, r5, lsl r0
    1f28:	00000000 	andeq	r0, r0, r0
    1f2c:	00000006 	andeq	r0, r0, r6
    1f30:	00000148 	andeq	r0, r0, r8, asr #2
    1f34:	0000000b 	andeq	r0, r0, fp
    1f38:	00000010 	andeq	r0, r0, r0, lsl r0
    1f3c:	00000005 	andeq	r0, r0, r5
    1f40:	000001b8 			; <UNDEFINED> instruction: 0x000001b8
    1f44:	0000000a 	andeq	r0, r0, sl
    1f48:	00000066 	andeq	r0, r0, r6, rrx
    1f4c:	00000004 	andeq	r0, r0, r4
    1f50:	00000220 	andeq	r0, r0, r0, lsr #4
    1f54:	00000001 	andeq	r0, r0, r1
    1f58:	00000049 	andeq	r0, r0, r9, asr #32
    1f5c:	00000001 	andeq	r0, r0, r1
    1f60:	00000051 	andeq	r0, r0, r1, asr r0
    1f64:	00000001 	andeq	r0, r0, r1
    1f68:	00000059 	andeq	r0, r0, r9, asr r0
    1f6c:	00000020 	andeq	r0, r0, r0, lsr #32
    1f70:	00001ecc 	andeq	r1, r0, ip, asr #29
    1f74:	00000021 	andeq	r0, r0, r1, lsr #32
    1f78:	00000008 	andeq	r0, r0, r8
    1f7c:	00000019 	andeq	r0, r0, r9, lsl r0
    1f80:	00001ed4 	ldrdeq	r1, [r0], -r4
    1f84:	0000001b 	andeq	r0, r0, fp, lsl r0
    1f88:	00000008 	andeq	r0, r0, r8
    1f8c:	0000001a 	andeq	r0, r0, sl, lsl r0
    1f90:	00001edc 	ldrdeq	r1, [r0], -ip
    1f94:	0000001c 	andeq	r0, r0, ip, lsl r0
    1f98:	00000008 	andeq	r0, r0, r8
    1f9c:	0000001e 	andeq	r0, r0, lr, lsl r0
    1fa0:	00000008 	andeq	r0, r0, r8
    1fa4:	6ffffffb 	svcvs	0x00fffffb
    1fa8:	00000001 	andeq	r0, r0, r1
	...

Disassembly of section .got:

00001fdc <_GLOBAL_OFFSET_TABLE_-0x10>:
    1fdc:	00001ecc 	andeq	r1, r0, ip, asr #29
    1fe0:	00001ed4 	ldrdeq	r1, [r0], -r4
    1fe4:	00001edc 	ldrdeq	r1, [r0], -ip
    1fe8:	000003e1 	andeq	r0, r0, r1, ror #7

00001fec <_GLOBAL_OFFSET_TABLE_>:
	...
    1ff8:	00000280 	andeq	r0, r0, r0, lsl #5
    1ffc:	00000280 	andeq	r0, r0, r0, lsl #5

Disassembly of section .bss:

00002000 <__dso_handle>:
    2000:	00000000 	andeq	r0, r0, r0

Disassembly of section .comment:

00000000 <.comment>:
   0:	43434700 	movtmi	r4, #14080	; 0x3700
   4:	4728203a 			; <UNDEFINED> instruction: 0x4728203a
   8:	2029554e 	eorcs	r5, r9, lr, asr #10
   c:	00382e34 	eorseq	r2, r8, r4, lsr lr

Disassembly of section .debug_info:

00000000 <.debug_info>:
   0:	00000172 	andeq	r0, r0, r2, ror r1
   4:	00000004 	andeq	r0, r0, r4
   8:	01040000 	mrseq	r0, (UNDEF: 4)
   c:	0000001b 	andeq	r0, r0, fp, lsl r0
  10:	00021101 	andeq	r1, r2, r1, lsl #2
  14:	00024500 	andeq	r4, r2, r0, lsl #10
	...
  24:	05040200 	streq	r0, [r4, #-512]	; 0xfffffe00
  28:	00746e69 	rsbseq	r6, r4, r9, ror #28
  2c:	0e070403 	cdpeq	4, 0, cr0, cr7, cr3, {0}
  30:	03000000 	movweq	r0, #0
  34:	02960601 	addseq	r0, r6, #1048576	; 0x100000
  38:	01030000 	mrseq	r0, (UNDEF: 3)
  3c:	00023208 	andeq	r3, r2, r8, lsl #4
  40:	05020300 	streq	r0, [r2, #-768]	; 0xfffffd00
  44:	000002ac 	andeq	r0, r0, ip, lsr #5
  48:	83070203 	movwhi	r0, #29187	; 0x7203
  4c:	03000002 	movweq	r0, #2
  50:	00000508 	andeq	r0, r0, r8, lsl #10
  54:	08030000 	stmdaeq	r3, {}	; <UNPREDICTABLE>
  58:	0001fa07 	andeq	pc, r1, r7, lsl #20
  5c:	07040300 	streq	r0, [r4, -r0, lsl #6]
  60:	000002b6 			; <UNDEFINED> instruction: 0x000002b6
  64:	e8070403 	stmda	r7, {r0, r1, sl}
  68:	03000001 	movweq	r0, #1
  6c:	02750504 	rsbseq	r0, r5, #4, 10	; 0x1000000
  70:	04040000 	streq	r0, [r4], #-0
  74:	00000078 	andeq	r0, r0, r8, ror r0
  78:	40080103 	andmi	r0, r8, r3, lsl #2
  7c:	05000002 	streq	r0, [r0, #-2]
  80:	000001e2 	andeq	r0, r0, r2, ror #3
  84:	00250601 	eoreq	r0, r5, r1, lsl #12
  88:	03980000 	orrseq	r0, r8, #0
  8c:	00200000 	eoreq	r0, r0, r0
  90:	9c010000 	stcls	0, cr0, [r1], {-0}
  94:	000000c9 	andeq	r0, r0, r9, asr #1
  98:	01007806 	tsteq	r0, r6, lsl #16
  9c:	00002506 	andeq	r2, r0, r6, lsl #10
  a0:	74910200 	ldrvc	r0, [r1], #512	; 0x200
  a4:	01007906 	tsteq	r0, r6, lsl #18
  a8:	00002506 	andeq	r2, r0, r6, lsl #10
  ac:	70910200 	addsvc	r0, r1, r0, lsl #4
  b0:	01007a06 	tsteq	r0, r6, lsl #20
  b4:	00002506 	andeq	r2, r0, r6, lsl #10
  b8:	6c910200 	lfmvs	f0, 4, [r1], {0}
  bc:	01007207 	tsteq	r0, r7, lsl #4
  c0:	00002508 	andeq	r2, r0, r8, lsl #10
  c4:	7c910200 	lfmvc	f0, 4, [r1], {0}
  c8:	01dc0800 	bicseq	r0, ip, r0, lsl #16
  cc:	10010000 	andne	r0, r1, r0
  d0:	00000025 	andeq	r0, r0, r5, lsr #32
  d4:	000003b8 			; <UNDEFINED> instruction: 0x000003b8
  d8:	00000026 	andeq	r0, r0, r6, lsr #32
  dc:	01159c01 	tsteq	r5, r1, lsl #24
  e0:	69060000 	stmdbvs	r6, {}	; <UNPREDICTABLE>
  e4:	25100100 	ldrcs	r0, [r0, #-256]	; 0xffffff00
  e8:	02000000 	andeq	r0, r0, #0
  ec:	6a066c91 	bvs	19b338 <_end+0x199334>
  f0:	25100100 	ldrcs	r0, [r0, #-256]	; 0xffffff00
  f4:	02000000 	andeq	r0, r0, #0
  f8:	74076891 	strvc	r6, [r7], #-2193	; 0xfffff76f
  fc:	0100706d 	tsteq	r0, sp, rrx
 100:	00002512 	andeq	r2, r0, r2, lsl r5
 104:	70910200 	addsvc	r0, r1, r0, lsl #4
 108:	01006b07 	tsteq	r0, r7, lsl #22
 10c:	00002513 	andeq	r2, r0, r3, lsl r5
 110:	74910200 	ldrvc	r0, [r1], #512	; 0x200
 114:	02a20900 	adceq	r0, r2, #0, 18
 118:	18010000 	stmdane	r1, {}	; <UNPREDICTABLE>
 11c:	00000025 	andeq	r0, r0, r5, lsr #32
 120:	000003e0 	andeq	r0, r0, r0, ror #7
 124:	00000028 	andeq	r0, r0, r8, lsr #32
 128:	016f9c01 	cmneq	pc, r1, lsl #24
 12c:	7e0a0000 	cdpvc	0, 0, cr0, cr10, cr0, {0}
 130:	01000002 	tsteq	r0, r2
 134:	00002518 	andeq	r2, r0, r8, lsl r5
 138:	64910200 	ldrvs	r0, [r1], #512	; 0x200
 13c:	0002a70a 	andeq	sl, r2, sl, lsl #14
 140:	6f180100 	svcvs	0x00180100
 144:	02000001 	andeq	r0, r0, #1
 148:	69076091 	stmdbvs	r7, {r0, r4, r7, sp, lr}
 14c:	251a0100 	ldrcs	r0, [sl, #-256]	; 0xffffff00
 150:	02000000 	andeq	r0, r0, #0
 154:	6a076c91 	bvs	1db3a0 <_end+0x1d939c>
 158:	251b0100 	ldrcs	r0, [fp, #-256]	; 0xffffff00
 15c:	02000000 	andeq	r0, r0, #0
 160:	6b077091 	blvs	1dc3ac <_end+0x1da3a8>
 164:	251c0100 	ldrcs	r0, [ip, #-256]	; 0xffffff00
 168:	02000000 	andeq	r0, r0, #0
 16c:	04007491 	streq	r7, [r0], #-1169	; 0xfffffb6f
 170:	00007204 	andeq	r7, r0, r4, lsl #4
	...

Disassembly of section .debug_abbrev:

00000000 <.debug_abbrev>:
   0:	25011101 	strcs	r1, [r1, #-257]	; 0xfffffeff
   4:	030b130e 	movweq	r1, #45838	; 0xb30e
   8:	550e1b0e 	strpl	r1, [lr, #-2830]	; 0xfffff4f2
   c:	10011117 	andne	r1, r1, r7, lsl r1
  10:	02000017 	andeq	r0, r0, #23
  14:	0b0b0024 	bleq	2c00ac <_end+0x2be0a8>
  18:	08030b3e 	stmdaeq	r3, {r1, r2, r3, r4, r5, r8, r9, fp}
  1c:	24030000 	strcs	r0, [r3], #-0
  20:	3e0b0b00 	vmlacc.f64	d0, d11, d0
  24:	000e030b 	andeq	r0, lr, fp, lsl #6
  28:	000f0400 	andeq	r0, pc, r0, lsl #8
  2c:	13490b0b 	movtne	r0, #39691	; 0x9b0b
  30:	2e050000 	cdpcs	0, 0, cr0, cr5, cr0, {0}
  34:	3a0e0301 	bcc	380c40 <_end+0x37ec3c>
  38:	270b3b0b 	strcs	r3, [fp, -fp, lsl #22]
  3c:	11134919 	tstne	r3, r9, lsl r9
  40:	40061201 	andmi	r1, r6, r1, lsl #4
  44:	19429718 	stmdbne	r2, {r3, r4, r8, r9, sl, ip, pc}^
  48:	00001301 	andeq	r1, r0, r1, lsl #6
  4c:	03000506 	movweq	r0, #1286	; 0x506
  50:	3b0b3a08 	blcc	2ce878 <_end+0x2cc874>
  54:	0213490b 	andseq	r4, r3, #180224	; 0x2c000
  58:	07000018 	smladeq	r0, r8, r0, r0
  5c:	08030034 	stmdaeq	r3, {r2, r4, r5}
  60:	0b3b0b3a 	bleq	ec2d50 <_end+0xec0d4c>
  64:	18021349 	stmdane	r2, {r0, r3, r6, r8, r9, ip}
  68:	2e080000 	cdpcs	0, 0, cr0, cr8, cr0, {0}
  6c:	3a0e0301 	bcc	380c78 <_end+0x37ec74>
  70:	270b3b0b 	strcs	r3, [fp, -fp, lsl #22]
  74:	11134919 	tstne	r3, r9, lsl r9
  78:	40061201 	andmi	r1, r6, r1, lsl #4
  7c:	19429618 	stmdbne	r2, {r3, r4, r9, sl, ip, pc}^
  80:	00001301 	andeq	r1, r0, r1, lsl #6
  84:	3f012e09 	svccc	0x00012e09
  88:	3a0e0319 	bcc	380cf4 <_end+0x37ecf0>
  8c:	270b3b0b 	strcs	r3, [fp, -fp, lsl #22]
  90:	11134919 	tstne	r3, r9, lsl r9
  94:	40061201 	andmi	r1, r6, r1, lsl #4
  98:	19429618 	stmdbne	r2, {r3, r4, r9, sl, ip, pc}^
  9c:	00001301 	andeq	r1, r0, r1, lsl #6
  a0:	0300050a 	movweq	r0, #1290	; 0x50a
  a4:	3b0b3a0e 	blcc	2ce8e4 <_end+0x2cc8e0>
  a8:	0213490b 	andseq	r4, r3, #180224	; 0x2c000
  ac:	00000018 	andeq	r0, r0, r8, lsl r0

Disassembly of section .debug_aranges:

00000000 <.debug_aranges>:
   0:	0000002c 	andeq	r0, r0, ip, lsr #32
   4:	00000002 	andeq	r0, r0, r2
   8:	00040000 	andeq	r0, r4, r0
   c:	00000000 	andeq	r0, r0, r0
  10:	00000398 	muleq	r0, r8, r3
  14:	00000020 	andeq	r0, r0, r0, lsr #32
  18:	000003b8 			; <UNDEFINED> instruction: 0x000003b8
  1c:	00000026 	andeq	r0, r0, r6, lsr #32
  20:	000003e0 	andeq	r0, r0, r0, ror #7
  24:	00000028 	andeq	r0, r0, r8, lsr #32
	...

Disassembly of section .debug_ranges:

00000000 <.debug_ranges>:
   0:	00000398 	muleq	r0, r8, r3
   4:	000003b8 			; <UNDEFINED> instruction: 0x000003b8
   8:	000003b8 			; <UNDEFINED> instruction: 0x000003b8
   c:	000003de 	ldrdeq	r0, [r0], -lr
  10:	000003e0 	andeq	r0, r0, r0, ror #7
  14:	00000408 	andeq	r0, r0, r8, lsl #8
	...

Disassembly of section .debug_line:

00000000 <.debug_line>:
   0:	00000077 	andeq	r0, r0, r7, ror r0
   4:	00370002 	eorseq	r0, r7, r2
   8:	01020000 	mrseq	r0, (UNDEF: 2)
   c:	000d0efb 	strdeq	r0, [sp], -fp
  10:	01010101 	tsteq	r1, r1, lsl #2
  14:	01000000 	mrseq	r0, (UNDEF: 0)
  18:	66010000 	strvs	r0, [r1], -r0
  1c:	656d6172 	strbvs	r6, [sp, #-370]!	; 0xfffffe8e
  20:	6b726f77 	blvs	1c9be04 <_end+0x1c99e00>
  24:	61622f73 	smcvs	8947	; 0x22f3
  28:	632f6573 	teqvs	pc, #482344960	; 0x1cc00000
  2c:	2f73646d 	svccs	0x0073646d
  30:	74736574 	ldrbtvc	r6, [r3], #-1396	; 0xfffffa8c
  34:	65740000 	ldrbvs	r0, [r4, #-0]!
  38:	632e7473 	teqvs	lr, #1929379840	; 0x73000000
  3c:	00000100 	andeq	r0, r0, r0, lsl #2
  40:	02050000 	andeq	r0, r5, #0
  44:	00000398 	muleq	r0, r8, r3
  48:	68304b18 	ldmdavs	r0!, {r3, r4, r8, r9, fp, lr}
  4c:	00030221 	andeq	r0, r3, r1, lsr #4
  50:	05000101 	streq	r0, [r0, #-257]	; 0xfffffeff
  54:	0003b802 	andeq	fp, r3, r2, lsl #16
  58:	01100300 	tsteq	r0, r0, lsl #6
  5c:	672f2f4b 	strvs	r2, [pc, -fp, asr #30]!
  60:	00040221 	andeq	r0, r4, r1, lsr #4
  64:	05000101 	streq	r0, [r0, #-257]	; 0xfffffeff
  68:	0003e002 	andeq	lr, r3, r2
  6c:	01180300 	tsteq	r8, r0, lsl #6
  70:	302f2f4b 	eorcc	r2, pc, fp, asr #30
  74:	0402215a 	streq	r2, [r2], #-346	; 0xfffffea6
  78:	Address 0x0000000000000078 is out of bounds.


Disassembly of section .debug_str:

00000000 <.debug_str>:
   0:	676e6f6c 	strbvs	r6, [lr, -ip, ror #30]!
   4:	6e6f6c20 	cdpvs	12, 6, cr6, cr15, cr0, {1}
   8:	6e692067 	cdpvs	0, 6, cr2, cr9, cr7, {3}
   c:	6e750074 	mrcvs	0, 3, r0, cr5, cr4, {3}
  10:	6e676973 	mcrvs	9, 3, r6, cr7, cr3, {3}
  14:	69206465 	stmdbvs	r0!, {r0, r2, r5, r6, sl, sp, lr}
  18:	4700746e 	strmi	r7, [r0, -lr, ror #8]
  1c:	4320554e 	teqmi	r0, #327155712	; 0x13800000
  20:	382e3420 	stmdacc	lr!, {r5, sl, ip, sp}
  24:	626d2d20 	rsbvs	r2, sp, #32, 26	; 0x800
  28:	696e6f69 	stmdbvs	lr!, {r0, r3, r5, r6, r8, r9, sl, fp, sp, lr}^
  2c:	6d2d2063 	stcvs	0, cr2, [sp, #-396]!	; 0xfffffe74
  30:	616f6c66 	cmnvs	pc, r6, ror #24
  34:	62612d74 	rsbvs	r2, r1, #116, 26	; 0x1d00
  38:	6f733d69 	svcvs	0x00733d69
  3c:	2d207466 	cfstrscs	mvf7, [r0, #-408]!	; 0xfffffe68
  40:	6372616d 	cmnvs	r2, #1073741851	; 0x4000001b
  44:	72613d68 	rsbvc	r3, r1, #104, 26	; 0x1a00
  48:	2d37766d 	ldccs	6, cr7, [r7, #-436]!	; 0xfffffe4c
  4c:	6d2d2061 	stcvs	0, cr2, [sp, #-388]!	; 0xfffffe7c
  50:	616f6c66 	cmnvs	pc, r6, ror #24
  54:	62612d74 	rsbvs	r2, r1, #116, 26	; 0x1d00
  58:	6f733d69 	svcvs	0x00733d69
  5c:	70667466 	rsbvc	r7, r6, r6, ror #8
  60:	666d2d20 	strbtvs	r2, [sp], -r0, lsr #26
  64:	6e3d7570 	mrcvs	5, 1, r7, cr13, cr0, {3}
  68:	206e6f65 	rsbcs	r6, lr, r5, ror #30
  6c:	68746d2d 	ldmdavs	r4!, {r0, r2, r3, r5, r8, sl, fp, sp, lr}^
  70:	2d626d75 	stclcs	13, cr6, [r2, #-468]!	; 0xfffffe2c
  74:	65746e69 	ldrbvs	r6, [r4, #-3689]!	; 0xfffff197
  78:	726f7772 	rsbvc	r7, pc, #29884416	; 0x1c80000
  7c:	6d2d206b 	stcvs	0, cr2, [sp, #-428]!	; 0xfffffe54
  80:	6d756874 	ldclvs	8, cr6, [r5, #-464]!	; 0xfffffe30
  84:	6d2d2062 	stcvs	0, cr2, [sp, #-392]!	; 0xfffffe78
  88:	2d736c74 	ldclcs	12, cr6, [r3, #-464]!	; 0xfffffe30
  8c:	6c616964 	stclvs	9, cr6, [r1], #-400	; 0xfffffe70
  90:	3d746365 	ldclcc	3, cr6, [r4, #-404]!	; 0xfffffe6c
  94:	20756e67 	rsbscs	r6, r5, r7, ror #28
  98:	2d20672d 	stccs	7, cr6, [r0, #-180]!	; 0xffffff4c
  9c:	4f2d2067 	svcmi	0x002d2067
  a0:	4f2d2073 	svcmi	0x002d2073
  a4:	662d2030 			; <UNDEFINED> instruction: 0x662d2030
  a8:	652d6f6e 	strvs	r6, [sp, #-3950]!	; 0xfffff092
  ac:	70656378 	rsbvc	r6, r5, r8, ror r3
  b0:	6e6f6974 	mcrvs	9, 3, r6, cr15, cr4, {3}
  b4:	662d2073 			; <UNDEFINED> instruction: 0x662d2073
  b8:	636e7566 	cmnvs	lr, #427819008	; 0x19800000
  bc:	6e6f6974 	mcrvs	9, 3, r6, cr15, cr4, {3}
  c0:	6365732d 	cmnvs	r5, #-1275068416	; 0xb4000000
  c4:	6e6f6974 	mcrvs	9, 3, r6, cr15, cr4, {3}
  c8:	662d2073 			; <UNDEFINED> instruction: 0x662d2073
  cc:	61746164 	cmnvs	r4, r4, ror #2
  d0:	6365732d 	cmnvs	r5, #-1275068416	; 0xb4000000
  d4:	6e6f6974 	mcrvs	9, 3, r6, cr15, cr4, {3}
  d8:	662d2073 			; <UNDEFINED> instruction: 0x662d2073
  dc:	69776e75 	ldmdbvs	r7!, {r0, r2, r4, r5, r6, r9, sl, fp, sp, lr}^
  e0:	742d646e 	strtvc	r6, [sp], #-1134	; 0xfffffb92
  e4:	656c6261 	strbvs	r6, [ip, #-609]!	; 0xfffffd9f
  e8:	662d2073 			; <UNDEFINED> instruction: 0x662d2073
  ec:	63617473 	cmnvs	r1, #1929379840	; 0x73000000
  f0:	72702d6b 	rsbsvc	r2, r0, #6848	; 0x1ac0
  f4:	6365746f 	cmnvs	r5, #1862270976	; 0x6f000000
  f8:	20726f74 	rsbscs	r6, r2, r4, ror pc
  fc:	6f6e662d 	svcvs	0x006e662d
 100:	6f68732d 	svcvs	0x0068732d
 104:	652d7472 	strvs	r7, [sp, #-1138]!	; 0xfffffb8e
 108:	736d756e 	cmnvc	sp, #461373440	; 0x1b800000
 10c:	6e662d20 	cdpvs	13, 6, cr2, cr6, cr0, {1}
 110:	61632d6f 	cmnvs	r3, pc, ror #26
 114:	696e6f6e 	stmdbvs	lr!, {r1, r2, r3, r5, r6, r8, r9, sl, fp, sp, lr}^
 118:	2d6c6163 	stfcse	f6, [ip, #-396]!	; 0xfffffe74
 11c:	74737973 	ldrbtvc	r7, [r3], #-2419	; 0xfffff68d
 120:	682d6d65 	stmdavs	sp!, {r0, r2, r5, r6, r8, sl, fp, sp, lr}
 124:	65646165 	strbvs	r6, [r4, #-357]!	; 0xfffffe9b
 128:	2d207372 	stccs	3, cr7, [r0, #-456]!	; 0xfffffe38
 12c:	2d6f6e66 	stclcs	14, cr6, [pc, #-408]!	; ffffff9c <_end+0xffffdf98>
 130:	6c697562 	cfstr64vs	mvdx7, [r9], #-392	; 0xfffffe78
 134:	2d6e6974 	stclcs	9, cr6, [lr, #-464]!	; 0xfffffe30
 138:	206e6973 	rsbcs	r6, lr, r3, ror r9
 13c:	6f6e662d 	svcvs	0x006e662d
 140:	7274732d 	rsbsvc	r7, r4, #-1275068416	; 0xb4000000
 144:	2d746369 	ldclcs	3, cr6, [r4, #-420]!	; 0xfffffe5c
 148:	616c6f76 	smcvs	50934	; 0xc6f6
 14c:	656c6974 	strbvs	r6, [ip, #-2420]!	; 0xfffff68c
 150:	7469622d 	strbtvc	r6, [r9], #-557	; 0xfffffdd3
 154:	6c656966 	stclvs	9, cr6, [r5], #-408	; 0xfffffe68
 158:	2d207364 	stccs	3, cr7, [r0, #-400]!	; 0xfffffe70
 15c:	73656d66 	cmnvc	r5, #6528	; 0x1980
 160:	65676173 	strbvs	r6, [r7, #-371]!	; 0xfffffe8d
 164:	6e656c2d 	cdpvs	12, 6, cr6, cr5, cr13, {1}
 168:	3d687467 	cfstrdcc	mvd7, [r8, #-412]!	; 0xfffffe64
 16c:	662d2030 			; <UNDEFINED> instruction: 0x662d2030
 170:	65736367 	ldrbvs	r6, [r3, #-871]!	; 0xfffffc99
 174:	7466612d 	strbtvc	r6, [r6], #-301	; 0xfffffed3
 178:	722d7265 	eorvc	r7, sp, #1342177286	; 0x50000006
 17c:	616f6c65 	cmnvs	pc, r5, ror #24
 180:	662d2064 	strtvs	r2, [sp], -r4, rrx
 184:	75726572 	ldrbvc	r6, [r2, #-1394]!	; 0xfffffa8e
 188:	73632d6e 	cmnvc	r3, #7040	; 0x1b80
 18c:	66612d65 	strbtvs	r2, [r1], -r5, ror #26
 190:	2d726574 	cfldr64cs	mvdx6, [r2, #-464]!	; 0xfffffe30
 194:	706f6f6c 	rsbvc	r6, pc, ip, ror #30
 198:	72662d20 	rsbvc	r2, r6, #32, 26	; 0x800
 19c:	6d616e65 	stclvs	14, cr6, [r1, #-404]!	; 0xfffffe6c
 1a0:	65722d65 	ldrbvs	r2, [r2, #-3429]!	; 0xfffff29b
 1a4:	74736967 	ldrbtvc	r6, [r3], #-2407	; 0xfffff699
 1a8:	20737265 	rsbscs	r7, r3, r5, ror #4
 1ac:	6d6f662d 	stclvs	6, cr6, [pc, #-180]!	; 100 <__libc_init@plt-0x194>
 1b0:	662d7469 	strtvs	r7, [sp], -r9, ror #8
 1b4:	656d6172 	strbvs	r6, [sp, #-370]!	; 0xfffffe8e
 1b8:	696f702d 	stmdbvs	pc!, {r0, r2, r3, r5, ip, sp, lr}^	; <UNPREDICTABLE>
 1bc:	7265746e 	rsbvc	r7, r5, #1845493760	; 0x6e000000
 1c0:	6e662d20 	cdpvs	13, 6, cr2, cr6, cr0, {1}
 1c4:	74732d6f 	ldrbtvc	r2, [r3], #-3439	; 0xfffff291
 1c8:	74636972 	strbtvc	r6, [r3], #-2418	; 0xfffff68e
 1cc:	696c612d 	stmdbvs	ip!, {r0, r2, r3, r5, r8, sp, lr}^
 1d0:	6e697361 	cdpvs	3, 6, cr7, cr9, cr1, {3}
 1d4:	662d2067 	strtvs	r2, [sp], -r7, rrx
 1d8:	00656970 	rsbeq	r6, r5, r0, ror r9
 1dc:	636e7566 	cmnvs	lr, #427819008	; 0x19800000
 1e0:	75660031 	strbvc	r0, [r6, #-49]!	; 0xffffffcf
 1e4:	0032636e 	eorseq	r6, r2, lr, ror #6
 1e8:	676e6f6c 	strbvs	r6, [lr, -ip, ror #30]!
 1ec:	736e7520 	cmnvc	lr, #32, 10	; 0x8000000
 1f0:	656e6769 	strbvs	r6, [lr, #-1897]!	; 0xfffff897
 1f4:	6e692064 	cdpvs	0, 6, cr2, cr9, cr4, {3}
 1f8:	6f6c0074 	svcvs	0x006c0074
 1fc:	6c20676e 	stcvs	7, cr6, [r0], #-440	; 0xfffffe48
 200:	20676e6f 	rsbcs	r6, r7, pc, ror #28
 204:	69736e75 	ldmdbvs	r3!, {r0, r2, r4, r5, r6, r9, sl, fp, sp, lr}^
 208:	64656e67 	strbtvs	r6, [r5], #-3687	; 0xfffff199
 20c:	746e6920 	strbtvc	r6, [lr], #-2336	; 0xfffff6e0
 210:	61726600 	cmnvs	r2, r0, lsl #12
 214:	6f77656d 	svcvs	0x0077656d
 218:	2f736b72 	svccs	0x00736b72
 21c:	65736162 	ldrbvs	r6, [r3, #-354]!	; 0xfffffe9e
 220:	646d632f 	strbtvs	r6, [sp], #-815	; 0xfffffcd1
 224:	65742f73 	ldrbvs	r2, [r4, #-3955]!	; 0xfffff08d
 228:	742f7473 	strtvc	r7, [pc], #-1139	; 230 <__libc_init@plt-0x64>
 22c:	2e747365 	cdpcs	3, 7, cr7, cr4, cr5, {3}
 230:	6e750063 	cdpvs	0, 7, cr0, cr5, cr3, {3}
 234:	6e676973 	mcrvs	9, 3, r6, cr7, cr3, {3}
 238:	63206465 	teqvs	r0, #1694498816	; 0x65000000
 23c:	00726168 	rsbseq	r6, r2, r8, ror #2
 240:	72616863 	rsbvc	r6, r1, #6488064	; 0x630000
 244:	6f682f00 	svcvs	0x00682f00
 248:	6c2f656d 	cfstr32vs	mvfx6, [pc], #-436	; 9c <__libc_init@plt-0x1f8>
 24c:	6e696d69 	cdpvs	13, 6, cr6, cr9, cr9, {3}
 250:	6f616867 	svcvs	0x00616867
 254:	6769622f 	strbvs	r6, [r9, -pc, lsr #4]!
 258:	726f772f 	rsbvc	r7, pc, #12320768	; 0xbc0000
 25c:	6170736b 	cmnvs	r0, fp, ror #6
 260:	6d2f6563 	cfstr32vs	mvfx6, [pc, #-396]!	; dc <__libc_init@plt-0x1b8>
 264:	36762f69 	ldrbtcc	r2, [r6], -r9, ror #30
 268:	6c2d6c2d 	stcvs	12, cr6, [sp], #-180	; 0xffffff4c
 26c:	61726269 	cmnvs	r2, r9, ror #4
 270:	7665642d 	strbtvc	r6, [r5], -sp, lsr #8
 274:	6e6f6c00 	cdpvs	12, 6, cr6, cr15, cr0, {0}
 278:	6e692067 	cdpvs	0, 6, cr2, cr9, cr7, {3}
 27c:	72610074 	rsbvc	r0, r1, #116	; 0x74
 280:	73006367 	movwvc	r6, #871	; 0x367
 284:	74726f68 	ldrbtvc	r6, [r2], #-3944	; 0xfffff098
 288:	736e7520 	cmnvc	lr, #32, 10	; 0x8000000
 28c:	656e6769 	strbvs	r6, [lr, #-1897]!	; 0xfffff897
 290:	6e692064 	cdpvs	0, 6, cr2, cr9, cr4, {3}
 294:	69730074 	ldmdbvs	r3!, {r2, r4, r5, r6}^
 298:	64656e67 	strbtvs	r6, [r5], #-3687	; 0xfffff199
 29c:	61686320 	cmnvs	r8, r0, lsr #6
 2a0:	616d0072 	smcvs	53250	; 0xd002
 2a4:	61006e69 	tstvs	r0, r9, ror #28
 2a8:	00766772 	rsbseq	r6, r6, r2, ror r7
 2ac:	726f6873 	rsbvc	r6, pc, #7536640	; 0x730000
 2b0:	6e692074 	mcrvs	0, 3, r2, cr9, cr4, {3}
 2b4:	69730074 	ldmdbvs	r3!, {r2, r4, r5, r6}^
 2b8:	7974657a 	ldmdbvc	r4!, {r1, r3, r4, r5, r6, r8, sl, sp, lr}^
 2bc:	Address 0x00000000000002bc is out of bounds.


Disassembly of section .debug_frame:

00000000 <.debug_frame>:
   0:	0000000c 	andeq	r0, r0, ip
   4:	ffffffff 			; <UNDEFINED> instruction: 0xffffffff
   8:	7c020001 	stcvc	0, cr0, [r2], {1}
   c:	000d0c0e 	andeq	r0, sp, lr, lsl #24
  10:	00000010 	andeq	r0, r0, r0, lsl r0
  14:	00000000 	andeq	r0, r0, r0
  18:	00000398 	muleq	r0, r8, r3
  1c:	00000020 	andeq	r0, r0, r0, lsr #32
  20:	00180e41 	andseq	r0, r8, r1, asr #28
  24:	00000014 	andeq	r0, r0, r4, lsl r0
  28:	00000000 	andeq	r0, r0, r0
  2c:	000003b8 			; <UNDEFINED> instruction: 0x000003b8
  30:	00000026 	andeq	r0, r0, r6, lsr #32
  34:	8e040e41 	cdphi	14, 0, cr0, cr4, cr1, {2}
  38:	180e4101 	stmdane	lr, {r0, r8, lr}
  3c:	00000014 	andeq	r0, r0, r4, lsl r0
  40:	00000000 	andeq	r0, r0, r0
  44:	000003e0 	andeq	r0, r0, r0, ror #7
  48:	00000028 	andeq	r0, r0, r8, lsr #32
  4c:	8e040e41 	cdphi	14, 0, cr0, cr4, cr1, {2}
  50:	200e4101 	andcs	r4, lr, r1, lsl #2

Disassembly of section .note.gnu.gold-version:

00000000 <.note.gnu.gold-version>:
   0:	00000004 	andeq	r0, r0, r4
   4:	00000009 	andeq	r0, r0, r9
   8:	00000004 	andeq	r0, r0, r4
   c:	00554e47 	subseq	r4, r5, r7, asr #28
  10:	646c6f67 	strbtvs	r6, [ip], #-3943	; 0xfffff099
  14:	312e3120 	teqcc	lr, r0, lsr #2
  18:	00000031 	andeq	r0, r0, r1, lsr r0

Disassembly of section .ARM.attributes:

00000000 <.ARM.attributes>:
   0:	00003941 	andeq	r3, r0, r1, asr #18
   4:	61656100 	cmnvs	r5, r0, lsl #2
   8:	01006962 	tsteq	r0, r2, ror #18
   c:	0000002f 	andeq	r0, r0, pc, lsr #32
  10:	4d524105 	ldfmie	f4, [r2, #-20]	; 0xffffffec
  14:	00377620 	eorseq	r7, r7, r0, lsr #12
  18:	41070a06 	tstmi	r7, r6, lsl #20
  1c:	02090108 	andeq	r0, r9, #8, 2
  20:	010c030a 	tsteq	ip, sl, lsl #6
  24:	04120211 	ldreq	r0, [r2], #-529	; 0xfffffdef
  28:	01150114 	tsteq	r5, r4, lsl r1
  2c:	01180317 	tsteq	r8, r7, lsl r3
  30:	031b021a 	tsteq	fp, #-1610612735	; 0xa0000001
  34:	0122061e 	teqeq	r2, lr, lsl r6
  38:	Address 0x0000000000000038 is out of bounds.

