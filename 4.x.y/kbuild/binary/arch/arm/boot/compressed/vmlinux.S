
vmlinux:     file format elf32-littlearm


Disassembly of section .text:

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

00000058 <not_angel>:
not_angel():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:147
      58:	e10f0000 	mrs	r0, CPSR
      5c:	e220001a 	eor	r0, r0, #26
      60:	e310001f 	tst	r0, #31
      64:	e3c0001f 	bic	r0, r0, #31
      68:	e38000d3 	orr	r0, r0, #211	; 0xd3
      6c:	1a000004 	bne	84 <not_angel+0x2c>
      70:	e3800c01 	orr	r0, r0, #256	; 0x100
      74:	e28fe00c 	add	lr, pc, #12
      78:	e16ff000 	msr	SPSR_fsxc, r0
$d():
      7c:	e12ef30e 	.word	0xe12ef30e
      80:	e160006e 	.word	0xe160006e
$a():
      84:	e121f000 	msr	CPSR_c, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:148
      88:	e16ff009 	msr	SPSR_fsxc, r9
	...
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:198
      a0:	e1a0400f 	mov	r4, pc
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:199
      a4:	e204433e 	and	r4, r4, #-134217728	; 0xf8000000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:201
      a8:	e2844902 	add	r4, r4, #32768	; 0x8000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:212
      ac:	e1a0000f 	mov	r0, pc
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:213
      b0:	e1500004 	cmp	r0, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:214
      b4:	359f01ac 	ldrcc	r0, [pc, #428]	; 268 <LC0+0x20>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:215
      b8:	3080000f 	addcc	r0, r0, pc
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:216
      bc:	31540000 	cmpcc	r4, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:217
      c0:	33844001 	orrcc	r4, r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:218
      c4:	2b00006d 	blcs	280 <cache_on>

000000c8 <restart>:
restart():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:220
      c8:	e28f0f5e 	add	r0, pc, #376	; 0x178
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:221
      cc:	e8901c4e 	ldm	r0, {r1, r2, r3, r6, sl, fp, ip}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:222
      d0:	e590d01c 	ldr	sp, [r0, #28]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:228
      d4:	e0400001 	sub	r0, r0, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:229
      d8:	e0866000 	add	r6, r6, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:230
      dc:	e08aa000 	add	sl, sl, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:237
      e0:	e5da9000 	ldrb	r9, [sl]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:238
      e4:	e5dae001 	ldrb	lr, [sl, #1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:239
      e8:	e189940e 	orr	r9, r9, lr, lsl #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:240
      ec:	e5dae002 	ldrb	lr, [sl, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:241
      f0:	e5daa003 	ldrb	sl, [sl, #3]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:242
      f4:	e189980e 	orr	r9, r9, lr, lsl #16
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:243
      f8:	e1899c0a 	orr	r9, r9, sl, lsl #24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:247
      fc:	e08dd000 	add	sp, sp, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:248
     100:	e28da801 	add	sl, sp, #65536	; 0x10000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:258
     104:	e3a05000 	mov	r5, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:388
     108:	e28aa901 	add	sl, sl, #16384	; 0x4000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:389
     10c:	e154000a 	cmp	r4, sl
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:390
     110:	2a00001e 	bcs	190 <wont_overwrite>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:391
     114:	e084a009 	add	sl, r4, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:392
     118:	e28f9070 	add	r9, pc, #112	; 0x70
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:393
     11c:	e15a0009 	cmp	sl, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:394
     120:	9a00001a 	bls	190 <wont_overwrite>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:408
     124:	e28aac09 	add	sl, sl, #2304	; 0x900
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:409
     128:	e3caa0ff 	bic	sl, sl, #255	; 0xff
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:412
     12c:	e24f506c 	sub	r5, pc, #108	; 0x6c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:413
     130:	e3c5501f 	bic	r5, r5, #31
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:417
     134:	e14f0000 	mrs	r0, SPSR
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:418
     138:	e200001f 	and	r0, r0, #31
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:419
     13c:	e350001a 	cmp	r0, #26
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:420
     140:	1a000003 	bne	154 <restart+0x8c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:422
     144:	eb000dd2 	bl	3894 <__hyp_get_vectors>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:423
     148:	e0400005 	sub	r0, r0, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:424
     14c:	e080000a 	add	r0, r0, sl
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:425
     150:	eb000dd0 	bl	3898 <__hyp_set_vectors>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:429
     154:	e0469005 	sub	r9, r6, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:430
     158:	e289901f 	add	r9, r9, #31
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:431
     15c:	e3c9901f 	bic	r9, r9, #31
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:432
     160:	e0896005 	add	r6, r9, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:433
     164:	e089900a 	add	r9, r9, sl
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:435
     168:	e9365c0f 	ldmdb	r6!, {r0, r1, r2, r3, sl, fp, ip, lr}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:436
     16c:	e1560005 	cmp	r6, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:437
     170:	e9295c0f 	stmdb	r9!, {r0, r1, r2, r3, sl, fp, ip, lr}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:438
     174:	8afffffb 	bhi	168 <restart+0xa0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:441
     178:	e0496006 	sub	r6, r9, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:445
     17c:	e08dd006 	add	sp, sp, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:448
     180:	eb00015e 	bl	700 <cache_clean_flush>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:450
     184:	e24f00c4 	sub	r0, pc, #196	; 0xc4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:451
     188:	e0800006 	add	r0, r0, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:452
     18c:	e1a0f000 	mov	pc, r0

00000190 <wont_overwrite>:
wont_overwrite():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:468
     190:	e1901005 	orrs	r1, r0, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:469
     194:	0a00000d 	beq	1d0 <not_relocated>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:471
     198:	e08bb000 	add	fp, fp, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:472
     19c:	e08cc000 	add	ip, ip, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:480
     1a0:	e0822000 	add	r2, r2, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:481
     1a4:	e0833000 	add	r3, r3, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:487
     1a8:	e59b1000 	ldr	r1, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:488
     1ac:	e0811000 	add	r1, r1, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:489
     1b0:	e1510002 	cmp	r1, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:490
     1b4:	21530001 	cmpcs	r3, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:491
     1b8:	80811005 	addhi	r1, r1, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:492
     1bc:	e48b1004 	str	r1, [fp], #4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:493
     1c0:	e15b000c 	cmp	fp, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:494
     1c4:	3afffff7 	bcc	1a8 <wont_overwrite+0x18>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:497
     1c8:	e0822005 	add	r2, r2, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:498
     1cc:	e0833005 	add	r3, r3, r5

000001d0 <not_relocated>:
not_relocated():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:515
     1d0:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:516
     1d4:	e4820004 	str	r0, [r2], #4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:517
     1d8:	e4820004 	str	r0, [r2], #4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:518
     1dc:	e4820004 	str	r0, [r2], #4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:519
     1e0:	e4820004 	str	r0, [r2], #4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:520
     1e4:	e1520003 	cmp	r2, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:521
     1e8:	3afffff9 	bcc	1d4 <not_relocated+0x4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:528
     1ec:	e3140001 	tst	r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:529
     1f0:	e3c44001 	bic	r4, r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:530
     1f4:	1b000021 	blne	280 <cache_on>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:539
     1f8:	e1a00004 	mov	r0, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:540
     1fc:	e1a0100d 	mov	r1, sp
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:541
     200:	e28d2801 	add	r2, sp, #65536	; 0x10000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:542
     204:	e1a03007 	mov	r3, r7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:543
     208:	eb0001f0 	bl	9d0 <decompress_kernel>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:544
     20c:	eb00013b 	bl	700 <cache_clean_flush>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:545
     210:	eb000112 	bl	660 <cache_off>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:546
     214:	e1a01007 	mov	r1, r7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:547
     218:	e1a02008 	mov	r2, r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:550
     21c:	e14f0000 	mrs	r0, SPSR
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:551
     220:	e200001f 	and	r0, r0, #31
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:552
     224:	e350001a 	cmp	r0, #26
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:553
     228:	1a0001bc 	bne	920 <__enter_kernel>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:555
     22c:	e28fc010 	add	ip, pc, #16
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:556
     230:	e59c0000 	ldr	r0, [ip]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:557
     234:	e080000c 	add	r0, r0, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:559
     238:	eb000d96 	bl	3898 <__hyp_set_vectors>
$d():
     23c:	e1400070 	.word	0xe1400070
$a():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:562
     240:	eafffffe 	b	240 <not_relocated+0x70>
$d():
     244:	000006bc 	.word	0x000006bc

00000248 <LC0>:
     248:	00000248 0034a288 0034a2a4 0034a288     H.....4...4...4.
     258:	0034a24c 0034a25c 0034a284 0034b2a8     L.4.\.4...4...4.
     268:	0044e1dc e320f000 e320f000 e320f000     ..D... ... ... .
$a():
     278:	e320f000 e320f000                       .. ... .

00000280 <cache_on>:
cache_on():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:609
     280:	e3a03008 	mov	r3, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:610
     284:	ea000088 	b	4ac <call_cache_fn>

00000288 <__armv4_mpu_cache_on>:
__armv4_mpu_cache_on():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:617
     288:	e3a0003f 	mov	r0, #63	; 0x3f
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:618
     28c:	ee060f17 	mcr	15, 0, r0, cr6, cr7, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:619
     290:	ee060f37 	mcr	15, 0, r0, cr6, cr7, {1}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:621
     294:	e3a00080 	mov	r0, #128	; 0x80
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:622
     298:	ee020f10 	mcr	15, 0, r0, cr2, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:623
     29c:	ee020f30 	mcr	15, 0, r0, cr2, cr0, {1}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:624
     2a0:	ee030f10 	mcr	15, 0, r0, cr3, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:626
     2a4:	e3a00903 	mov	r0, #49152	; 0xc000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:627
     2a8:	ee050f30 	mcr	15, 0, r0, cr5, cr0, {1}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:628
     2ac:	ee050f10 	mcr	15, 0, r0, cr5, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:630
     2b0:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:631
     2b4:	ee070f9a 	mcr	15, 0, r0, cr7, cr10, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:632
     2b8:	ee070f15 	mcr	15, 0, r0, cr7, cr5, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:633
     2bc:	ee070f16 	mcr	15, 0, r0, cr7, cr6, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:634
     2c0:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:636
     2c4:	e380002d 	orr	r0, r0, #45	; 0x2d
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:637
     2c8:	e3800a01 	orr	r0, r0, #4096	; 0x1000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:639
     2cc:	ee010f10 	mcr	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:641
     2d0:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:642
     2d4:	ee070f15 	mcr	15, 0, r0, cr7, cr5, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:643
     2d8:	ee070f16 	mcr	15, 0, r0, cr7, cr6, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:644
     2dc:	e1a0f00e 	mov	pc, lr

000002e0 <__armv3_mpu_cache_on>:
__armv3_mpu_cache_on():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:647
     2e0:	e3a0003f 	mov	r0, #63	; 0x3f
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:648
     2e4:	ee060f17 	mcr	15, 0, r0, cr6, cr7, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:650
     2e8:	e3a00080 	mov	r0, #128	; 0x80
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:651
     2ec:	ee020f10 	mcr	15, 0, r0, cr2, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:652
     2f0:	ee030f10 	mcr	15, 0, r0, cr3, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:654
     2f4:	e3a00903 	mov	r0, #49152	; 0xc000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:655
     2f8:	ee050f10 	mcr	15, 0, r0, cr5, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:657
     2fc:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:658
     300:	ee070f10 	mcr	15, 0, r0, cr7, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:663
     304:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:665
     308:	e380000d 	orr	r0, r0, #13
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:667
     30c:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:668
     310:	ee010f10 	mcr	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:671
     314:	ee070f10 	mcr	15, 0, r0, cr7, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:672
     318:	e1a0f00e 	mov	pc, lr

0000031c <__setup_mmu>:
__setup_mmu():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:680
     31c:	e2443901 	sub	r3, r4, #16384	; 0x4000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:681
     320:	e3c330ff 	bic	r3, r3, #255	; 0xff
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:682
     324:	e3c33c3f 	bic	r3, r3, #16128	; 0x3f00
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:687
     328:	e1a00003 	mov	r0, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:688
     32c:	e1a09920 	lsr	r9, r0, #18
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:689
     330:	e1a09909 	lsl	r9, r9, #18
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:690
     334:	e289a201 	add	sl, r9, #268435456	; 0x10000000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:691
     338:	e3a01012 	mov	r1, #18
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:692
     33c:	e3811b03 	orr	r1, r1, #3072	; 0xc00
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:693
     340:	e2832901 	add	r2, r3, #16384	; 0x4000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:694
     344:	e1510009 	cmp	r1, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:695
     348:	215a0001 	cmpcs	sl, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:696
     34c:	e3c1101c 	bic	r1, r1, #28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:697
     350:	33811010 	orrcc	r1, r1, #16
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:698
     354:	21811006 	orrcs	r1, r1, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:699
     358:	e4801004 	str	r1, [r0], #4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:700
     35c:	e2811601 	add	r1, r1, #1048576	; 0x100000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:701
     360:	e1300002 	teq	r0, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:702
     364:	1afffff6 	bne	344 <__setup_mmu+0x28>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:709
     368:	e3861004 	orr	r1, r6, #4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:710
     36c:	e3811b03 	orr	r1, r1, #3072	; 0xc00
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:711
     370:	e1a0200f 	mov	r2, pc
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:712
     374:	e1a02a22 	lsr	r2, r2, #20
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:713
     378:	e1811a02 	orr	r1, r1, r2, lsl #20
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:714
     37c:	e0830102 	add	r0, r3, r2, lsl #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:715
     380:	e4801004 	str	r1, [r0], #4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:716
     384:	e2811601 	add	r1, r1, #1048576	; 0x100000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:717
     388:	e5801000 	str	r1, [r0]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:718
     38c:	e1a0f00e 	mov	pc, lr

00000390 <__armv6_mmu_cache_on>:
__armv6_mmu_cache_on():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:724
     390:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:725
     394:	e3c00002 	bic	r0, r0, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:726
     398:	e3800501 	orr	r0, r0, #4194304	; 0x400000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:727
     39c:	ee010f10 	mcr	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:728
     3a0:	eaffffff 	b	3a4 <__arm926ejs_mmu_cache_on>

000003a4 <__arm926ejs_mmu_cache_on>:
__armv4_mmu_cache_on():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:737
     3a4:	e1a0c00e 	mov	ip, lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:739
     3a8:	e3a0601e 	mov	r6, #30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:740
     3ac:	ebffffda 	bl	31c <__setup_mmu>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:741
     3b0:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:742
     3b4:	ee070f9a 	mcr	15, 0, r0, cr7, cr10, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:743
     3b8:	ee080f17 	mcr	15, 0, r0, cr8, cr7, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:744
     3bc:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:745
     3c0:	e3800a05 	orr	r0, r0, #20480	; 0x5000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:746
     3c4:	e3800030 	orr	r0, r0, #48	; 0x30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:748
     3c8:	eb00002c 	bl	480 <__common_mmu_cache_on>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:749
     3cc:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:750
     3d0:	ee080f17 	mcr	15, 0, r0, cr8, cr7, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:752
     3d4:	e1a0f00c 	mov	pc, ip

000003d8 <__armv7_mmu_cache_on>:
__armv7_mmu_cache_on():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:755
     3d8:	e1a0c00e 	mov	ip, lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:757
     3dc:	ee10bf91 	mrc	15, 0, fp, cr0, cr1, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:758
     3e0:	e31b000f 	tst	fp, #15
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:759
     3e4:	13a0600e 	movne	r6, #14
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:760
     3e8:	1bffffcb 	blne	31c <__setup_mmu>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:761
     3ec:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:762
     3f0:	ee070f9a 	mcr	15, 0, r0, cr7, cr10, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:763
     3f4:	e31b000f 	tst	fp, #15
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:764
     3f8:	1e080f17 	mcrne	15, 0, r0, cr8, cr7, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:766
     3fc:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:767
     400:	e3c00201 	bic	r0, r0, #268435456	; 0x10000000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:768
     404:	e3800a05 	orr	r0, r0, #20480	; 0x5000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:769
     408:	e380003c 	orr	r0, r0, #60	; 0x3c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:770
     40c:	e3c00002 	bic	r0, r0, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:771
     410:	e3800501 	orr	r0, r0, #4194304	; 0x400000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:775
     414:	1e126f50 	mrcne	15, 0, r6, cr2, cr0, {2}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:776
     418:	13800001 	orrne	r0, r0, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:777
     41c:	13e01002 	mvnne	r1, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:778
     420:	e3c66102 	bic	r6, r6, #-2147483648	; 0x80000000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:779
     424:	e3c66003 	bic	r6, r6, #3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:780
     428:	1e023f10 	mcrne	15, 0, r3, cr2, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:781
     42c:	1e031f10 	mcrne	15, 0, r1, cr3, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:782
     430:	1e026f50 	mcrne	15, 0, r6, cr2, cr0, {2}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:784
     434:	ee070f95 	mcr	15, 0, r0, cr7, cr5, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:785
     438:	ee010f10 	mcr	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:786
     43c:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:787
     440:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:788
     444:	ee070f95 	mcr	15, 0, r0, cr7, cr5, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:789
     448:	e1a0f00c 	mov	pc, ip

0000044c <__fa526_cache_on>:
__fa526_cache_on():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:792
     44c:	e1a0c00e 	mov	ip, lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:793
     450:	e3a0601e 	mov	r6, #30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:794
     454:	ebffffb0 	bl	31c <__setup_mmu>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:795
     458:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:796
     45c:	ee070f17 	mcr	15, 0, r0, cr7, cr7, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:797
     460:	ee070f9a 	mcr	15, 0, r0, cr7, cr10, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:798
     464:	ee080f17 	mcr	15, 0, r0, cr8, cr7, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:799
     468:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:800
     46c:	e3800a01 	orr	r0, r0, #4096	; 0x1000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:801
     470:	eb000002 	bl	480 <__common_mmu_cache_on>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:802
     474:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:803
     478:	ee080f17 	mcr	15, 0, r0, cr8, cr7, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:804
     47c:	e1a0f00c 	mov	pc, ip

00000480 <__common_mmu_cache_on>:
__common_mmu_cache_on():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:809
     480:	e380000d 	orr	r0, r0, #13
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:811
     484:	e3e01000 	mvn	r1, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:812
     488:	ee023f10 	mcr	15, 0, r3, cr2, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:813
     48c:	ee031f10 	mcr	15, 0, r1, cr3, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:814
     490:	ea000002 	b	4a0 <__common_mmu_cache_on+0x20>
     494:	e320f000 	nop	{0}
     498:	e320f000 	nop	{0}
     49c:	e320f000 	nop	{0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:816
     4a0:	ee010f10 	mcr	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:817
     4a4:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:818
     4a8:	e04ef020 	sub	pc, lr, r0, lsr #32

000004ac <call_cache_fn>:
call_cache_fn():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:837
     4ac:	e28fc01c 	add	ip, pc, #28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:839
     4b0:	ee109f10 	mrc	15, 0, r9, cr0, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:853
     4b4:	e59c1000 	ldr	r1, [ip]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:854
     4b8:	e59c2004 	ldr	r2, [ip, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:855
     4bc:	e0211009 	eor	r1, r1, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:856
     4c0:	e1110002 	tst	r1, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:857
     4c4:	008cf003 	addeq	pc, ip, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:860
     4c8:	e28cc014 	add	ip, ip, #20
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:861
     4cc:	eafffff8 	b	4b4 <call_cache_fn+0x8>

000004d0 <proc_types>:
$d():
     4d0:	41000000 ff00f000 e1a0f00e e1a0f00e     ...A............
$a():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:886
     4e0:	e1a0f00e 41007000 fff8fe00 e1a0f00e     .....p.A........
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:893
     4f0:	e1a0f00e e1a0f00e 41807200 ffffff00     .........r.A....
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:900
     500:	eaffffa7 ea000065 e1a0f00e 41007400     ....e........t.A
$d():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:902
     510:	ff00ff00 eaffff71 ea00005a ea0000ea     ....q...Z.......
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:909
     520:	41009400 ff00ff00 eaffff56 ea00004d     ...A....V...M...
$a():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:915
     530:	ea000074 41069260 ff0ffff0 eaffff98     t...`..A........
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:920
     540:	ea000056 ea0000be 00007000 0000f000     V........p......
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:925
     550:	e1a0f00e e1a0f00e e1a0f00e 4401a100     ...............D
$d():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:929
     560:	ffffffe0 eaffff8e ea00004c ea0000bb     ........L.......
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:938
     570:	6901b110 fffffff0 eaffff89 ea000047     ...i........G...
$a():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:944
     580:	ea0000b6 56056900 ffffff00 eaffff84     .....i.V........
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:949
     590:	ea000042 ea0000b1 56158000 fffff000     B..........V....
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:954
     5a0:	eaffff7f ea00003d ea0000a5 56050000     ....=..........V
$d():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:956
     5b0:	ff0f0000 eaffff7a ea000038 ea0000a0     ....z...8.......
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:962
     5c0:	66015261 ff01fff1 eaffff9f ea000033     aR.f........3...
$a():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:977
     5d0:	ea00005c 00020000 000f0000 eaffff70     \...........p...
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:984
     5e0:	ea00002e ea00009d 00050000 000f0000     ................
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:989
     5f0:	eaffff6b ea000029 ea000098 00060000     k...)...........
$d():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:991
     600:	000f0000 eaffff66 ea000024 ea00008c     ....f...$.......
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:997
     610:	0007b000 000ff000 eaffff5c ea00001f     ........\.......
$a():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1003
     620:	ea00004f 000f0000 000f0000 eaffff69     O...........i...
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1008
     630:	ea000021 ea000051 00000000 00000000     !...Q...........
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1013
     640:	e1a0f00e e1a0f00e e1a0f00e e320f000     .............. .
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1017
     650:	e320f000 e320f000 e320f000 e320f000     .. ... ... ... .

00000660 <cache_off>:
cache_off():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1042
     660:	e3a0300c 	mov	r3, #12
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1043
     664:	eaffff90 	b	4ac <call_cache_fn>

00000668 <__armv4_mpu_cache_off>:
__armv4_mpu_cache_off():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1046
     668:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1047
     66c:	e3c0000d 	bic	r0, r0, #13
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1048
     670:	ee010f10 	mcr	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1049
     674:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1050
     678:	ee070f9a 	mcr	15, 0, r0, cr7, cr10, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1051
     67c:	ee070f16 	mcr	15, 0, r0, cr7, cr6, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1052
     680:	ee070f15 	mcr	15, 0, r0, cr7, cr5, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1053
     684:	e1a0f00e 	mov	pc, lr

00000688 <__armv3_mpu_cache_off>:
__armv3_mpu_cache_off():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1056
     688:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1057
     68c:	e3c0000d 	bic	r0, r0, #13
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1058
     690:	ee010f10 	mcr	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1059
     694:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1060
     698:	ee070f10 	mcr	15, 0, r0, cr7, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1061
     69c:	e1a0f00e 	mov	pc, lr

000006a0 <__armv4_mmu_cache_off>:
__armv4_mmu_cache_off():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1065
     6a0:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1066
     6a4:	e3c0000d 	bic	r0, r0, #13
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1067
     6a8:	ee010f10 	mcr	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1068
     6ac:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1069
     6b0:	ee070f17 	mcr	15, 0, r0, cr7, cr7, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1070
     6b4:	ee080f17 	mcr	15, 0, r0, cr8, cr7, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1072
     6b8:	e1a0f00e 	mov	pc, lr

000006bc <__armv7_mmu_cache_off>:
__armv7_mmu_cache_off():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1075
     6bc:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1077
     6c0:	e3c0000d 	bic	r0, r0, #13
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1081
     6c4:	ee010f10 	mcr	15, 0, r0, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1082
     6c8:	e1a0c00e 	mov	ip, lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1083
     6cc:	eb00002b 	bl	780 <__armv7_mmu_cache_flush>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1084
     6d0:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1086
     6d4:	ee080f17 	mcr	15, 0, r0, cr8, cr7, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1088
     6d8:	ee070fd5 	mcr	15, 0, r0, cr7, cr5, {6}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1089
     6dc:	ee070f9a 	mcr	15, 0, r0, cr7, cr10, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1090
     6e0:	ee070f95 	mcr	15, 0, r0, cr7, cr5, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1091
     6e4:	e1a0f00c 	mov	pc, ip
     6e8:	e320f000 	nop	{0}
     6ec:	e320f000 	nop	{0}
     6f0:	e320f000 	nop	{0}
     6f4:	e320f000 	nop	{0}
     6f8:	e320f000 	nop	{0}
     6fc:	e320f000 	nop	{0}

00000700 <cache_clean_flush>:
cache_clean_flush():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1103
     700:	e3a03010 	mov	r3, #16
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1104
     704:	eaffff68 	b	4ac <call_cache_fn>

00000708 <__armv4_mpu_cache_flush>:
__armv4_mpu_cache_flush():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1107
     708:	e3140001 	tst	r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1108
     70c:	11a0f00e 	movne	pc, lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1109
     710:	e3a02001 	mov	r2, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1110
     714:	e3a03000 	mov	r3, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1111
     718:	ee07cf16 	mcr	15, 0, ip, cr7, cr6, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1112
     71c:	e3a010e0 	mov	r1, #224	; 0xe0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1113
     720:	e381333f 	orr	r3, r1, #-67108864	; 0xfc000000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1114
     724:	ee073f5e 	mcr	15, 0, r3, cr7, cr14, {2}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1115
     728:	e2533301 	subs	r3, r3, #67108864	; 0x4000000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1116
     72c:	2afffffc 	bcs	724 <__armv4_mpu_cache_flush+0x1c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1117
     730:	e2511020 	subs	r1, r1, #32
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1118
     734:	2afffff9 	bcs	720 <__armv4_mpu_cache_flush+0x18>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1120
     738:	e3320000 	teq	r2, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1121
     73c:	1e07cf15 	mcrne	15, 0, ip, cr7, cr5, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1122
     740:	ee07cf9a 	mcr	15, 0, ip, cr7, cr10, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1123
     744:	e1a0f00e 	mov	pc, lr

00000748 <__fa526_cache_flush>:
__fa526_cache_flush():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1126
     748:	e3140001 	tst	r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1127
     74c:	11a0f00e 	movne	pc, lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1128
     750:	e3a01000 	mov	r1, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1129
     754:	ee071f1e 	mcr	15, 0, r1, cr7, cr14, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1130
     758:	ee071f15 	mcr	15, 0, r1, cr7, cr5, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1131
     75c:	ee071f9a 	mcr	15, 0, r1, cr7, cr10, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1132
     760:	e1a0f00e 	mov	pc, lr

00000764 <__armv6_mmu_cache_flush>:
__armv6_mmu_cache_flush():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1135
     764:	e3a01000 	mov	r1, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1136
     768:	e3140001 	tst	r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1137
     76c:	0e071f1e 	mcreq	15, 0, r1, cr7, cr14, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1138
     770:	ee071f15 	mcr	15, 0, r1, cr7, cr5, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1139
     774:	0e071f1f 	mcreq	15, 0, r1, cr7, cr15, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1140
     778:	ee071f9a 	mcr	15, 0, r1, cr7, cr10, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1141
     77c:	e1a0f00e 	mov	pc, lr

00000780 <__armv7_mmu_cache_flush>:
__armv7_mmu_cache_flush():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1144
     780:	e3140001 	tst	r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1145
     784:	1a000029 	bne	830 <iflush>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1146
     788:	ee10afb1 	mrc	15, 0, sl, cr0, cr1, {5}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1147
     78c:	e31a080f 	tst	sl, #983040	; 0xf0000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1148
     790:	e3a0a000 	mov	sl, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1149
     794:	0a000001 	beq	7a0 <hierarchical>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1150
     798:	ee07af1e 	mcr	15, 0, sl, cr7, cr14, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1151
     79c:	ea000023 	b	830 <iflush>

000007a0 <hierarchical>:
hierarchical():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1153
     7a0:	ee07afba 	mcr	15, 0, sl, cr7, cr10, {5}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1154
     7a4:	e92d0eff 	push	{r0, r1, r2, r3, r4, r5, r6, r7, r9, sl, fp}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1155
     7a8:	ee300f30 	mrc	15, 1, r0, cr0, cr0, {1}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1156
     7ac:	e2103407 	ands	r3, r0, #117440512	; 0x7000000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1157
     7b0:	e1a03ba3 	lsr	r3, r3, #23
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1158
     7b4:	0a00001a 	beq	824 <finished>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1159
     7b8:	e3a0a000 	mov	sl, #0

000007bc <loop1>:
loop1():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1161
     7bc:	e08a20aa 	add	r2, sl, sl, lsr #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1162
     7c0:	e1a01230 	lsr	r1, r0, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1163
     7c4:	e2011007 	and	r1, r1, #7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1164
     7c8:	e3510002 	cmp	r1, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1165
     7cc:	ba000011 	blt	818 <skip>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1166
     7d0:	ee40af10 	mcr	15, 2, sl, cr0, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1167
     7d4:	ee07af95 	mcr	15, 0, sl, cr7, cr5, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1168
     7d8:	ee301f10 	mrc	15, 1, r1, cr0, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1169
     7dc:	e2012007 	and	r2, r1, #7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1170
     7e0:	e2822004 	add	r2, r2, #4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1171
     7e4:	e59f40f4 	ldr	r4, [pc, #244]	; 8e0 <__armv3_mmu_cache_flush+0x14>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1172
     7e8:	e01441a1 	ands	r4, r4, r1, lsr #3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1173
     7ec:	e16f5f14 	clz	r5, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1174
     7f0:	e59f70ec 	ldr	r7, [pc, #236]	; 8e4 <__armv3_mmu_cache_flush+0x18>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1175
     7f4:	e01776a1 	ands	r7, r7, r1, lsr #13

000007f8 <loop2>:
loop2():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1177
     7f8:	e1a09004 	mov	r9, r4

000007fc <loop3>:
loop3():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1179
     7fc:	e18ab519 	orr	fp, sl, r9, lsl r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1180
     800:	e18bb217 	orr	fp, fp, r7, lsl r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1185
     804:	ee07bf5e 	mcr	15, 0, fp, cr7, cr14, {2}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1186
     808:	e2599001 	subs	r9, r9, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1187
     80c:	aafffffa 	bge	7fc <loop3>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1188
     810:	e2577001 	subs	r7, r7, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1189
     814:	aafffff7 	bge	7f8 <loop2>

00000818 <skip>:
skip():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1191
     818:	e28aa002 	add	sl, sl, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1192
     81c:	e153000a 	cmp	r3, sl
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1193
     820:	caffffe5 	bgt	7bc <loop1>

00000824 <finished>:
finished():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1195
     824:	e8bd0eff 	pop	{r0, r1, r2, r3, r4, r5, r6, r7, r9, sl, fp}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1196
     828:	e3a0a000 	mov	sl, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1197
     82c:	ee40af10 	mcr	15, 2, sl, cr0, cr0, {0}

00000830 <iflush>:
iflush():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1199
     830:	ee07af9a 	mcr	15, 0, sl, cr7, cr10, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1200
     834:	ee07af15 	mcr	15, 0, sl, cr7, cr5, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1201
     838:	ee07af9a 	mcr	15, 0, sl, cr7, cr10, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1202
     83c:	ee07af95 	mcr	15, 0, sl, cr7, cr5, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1203
     840:	e1a0f00e 	mov	pc, lr

00000844 <__armv5tej_mmu_cache_flush>:
__armv5tej_mmu_cache_flush():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1206
     844:	e3140001 	tst	r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1207
     848:	11a0f00e 	movne	pc, lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1208
     84c:	ee17ff7e 	mrc	15, 0, APSR_nzcv, cr7, cr14, {3}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1209
     850:	1afffffd 	bne	84c <__armv5tej_mmu_cache_flush+0x8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1210
     854:	ee070f15 	mcr	15, 0, r0, cr7, cr5, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1211
     858:	ee070f9a 	mcr	15, 0, r0, cr7, cr10, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1212
     85c:	e1a0f00e 	mov	pc, lr

00000860 <__armv4_mmu_cache_flush>:
__armv4_mmu_cache_flush():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1215
     860:	e3140001 	tst	r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1216
     864:	11a0f00e 	movne	pc, lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1217
     868:	e3a02801 	mov	r2, #65536	; 0x10000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1218
     86c:	e3a0b020 	mov	fp, #32
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1219
     870:	ee103f30 	mrc	15, 0, r3, cr0, cr0, {1}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1220
     874:	e1330009 	teq	r3, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1221
     878:	0a000009 	beq	8a4 <no_cache_id>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1222
     87c:	e1a01923 	lsr	r1, r3, #18
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1223
     880:	e2011007 	and	r1, r1, #7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1224
     884:	e3a02b01 	mov	r2, #1024	; 0x400
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1225
     888:	e1a02112 	lsl	r2, r2, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1226
     88c:	e3130901 	tst	r3, #16384	; 0x4000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1227
     890:	108220a2 	addne	r2, r2, r2, lsr #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1228
     894:	e1a03623 	lsr	r3, r3, #12
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1229
     898:	e2033003 	and	r3, r3, #3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1230
     89c:	e3a0b008 	mov	fp, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1231
     8a0:	e1a0b31b 	lsl	fp, fp, r3

000008a4 <no_cache_id>:
no_cache_id():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1233
     8a4:	e1a0100f 	mov	r1, pc
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1234
     8a8:	e3c1103f 	bic	r1, r1, #63	; 0x3f
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1235
     8ac:	e0812002 	add	r2, r1, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1237
     8b0:	e691300b 	ldr	r3, [r1], fp
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1240
     8b4:	e1310002 	teq	r1, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1241
     8b8:	1afffffc 	bne	8b0 <no_cache_id+0xc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1243
     8bc:	ee071f15 	mcr	15, 0, r1, cr7, cr5, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1244
     8c0:	ee071f16 	mcr	15, 0, r1, cr7, cr6, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1245
     8c4:	ee071f9a 	mcr	15, 0, r1, cr7, cr10, {4}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1246
     8c8:	e1a0f00e 	mov	pc, lr

000008cc <__armv3_mmu_cache_flush>:
__armv3_mpu_cache_flush():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1250
     8cc:	e3140001 	tst	r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1251
     8d0:	11a0f00e 	movne	pc, lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1252
     8d4:	e3a01000 	mov	r1, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1253
     8d8:	ee071f10 	mcr	15, 0, r1, cr7, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1254
     8dc:	e1a0f00e 	mov	pc, lr
$d():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1171
     8e0:	000003ff 	.word	0x000003ff
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1174
     8e4:	00007fff 	.word	0x00007fff
$a():
     8e8:	e320f000 	nop	{0}
     8ec:	e320f000 	nop	{0}
     8f0:	e320f000 	nop	{0}
     8f4:	e320f000 	nop	{0}
     8f8:	e320f000 	nop	{0}
     8fc:	e320f000 	nop	{0}

00000900 <__hyp_reentry_vectors>:
__hyp_reentry_vectors():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1338
     900:	eafffffe 	b	900 <__hyp_reentry_vectors>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1339
     904:	eafffffe 	b	904 <__hyp_reentry_vectors+0x4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1340
     908:	eafffffe 	b	908 <__hyp_reentry_vectors+0x8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1341
     90c:	eafffffe 	b	90c <__hyp_reentry_vectors+0xc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1342
     910:	eafffffe 	b	910 <__hyp_reentry_vectors+0x10>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1343
     914:	ea000001 	b	920 <__enter_kernel>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1344
     918:	eafffffe 	b	918 <__hyp_reentry_vectors+0x18>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1345
     91c:	eafffffe 	b	91c <__hyp_reentry_vectors+0x1c>

00000920 <__enter_kernel>:
__enter_kernel():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1349
     920:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/head.S:1350
     924:	e1a0f004 	mov	pc, r4

00000928 <reloc_code_end>:
reloc_code_end():
     928:	e320f000 	nop	{0}
     92c:	e320f000 	nop	{0}
     930:	e320f000 	nop	{0}
     934:	e320f000 	nop	{0}
     938:	e320f000 	nop	{0}
     93c:	e320f000 	nop	{0}

00000940 <error>:
error():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:115
     940:	e59f3038 	ldr	r3, [pc, #56]	; 980 <error+0x40>
     944:	e08f3003 	add	r3, pc, r3
     948:	e2433001 	sub	r3, r3, #1
putstr():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:90
     94c:	e5f32001 	ldrb	r2, [r3, #1]!
     950:	e3520000 	cmp	r2, #0
     954:	1afffffc 	bne	94c <error+0xc>
     958:	e4d03001 	ldrb	r3, [r0], #1
     95c:	e3530000 	cmp	r3, #0
     960:	1afffffc 	bne	958 <error+0x18>
     964:	e59f3018 	ldr	r3, [pc, #24]	; 984 <error+0x44>
     968:	e08f3003 	add	r3, pc, r3
     96c:	e2433001 	sub	r3, r3, #1
     970:	e5f32001 	ldrb	r2, [r3, #1]!
     974:	e3520000 	cmp	r2, #0
     978:	1afffffc 	bne	970 <error+0x30>
     97c:	eafffffe 	b	97c <error+0x3c>
     980:	00003c50 	.word	0x00003c50
     984:	00003c30 	.word	0x00003c30

00000988 <__div0>:
__div0():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:127
     988:	e59f0004 	ldr	r0, [pc, #4]	; 994 <__div0+0xc>
     98c:	e08f0000 	add	r0, pc, r0
     990:	eaffffea 	b	940 <error>
     994:	00003c20 	.word	0x00003c20

00000998 <__stack_chk_guard_setup>:
__stack_chk_guard_setup():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:133
     998:	e59f2018 	ldr	r2, [pc, #24]	; 9b8 <__stack_chk_guard_setup+0x20>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:134
     99c:	e3003dff 	movw	r3, #3583	; 0xdff
     9a0:	e59f1014 	ldr	r1, [pc, #20]	; 9bc <__stack_chk_guard_setup+0x24>
     9a4:	e340300a 	movt	r3, #10
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:133
     9a8:	e08f2002 	add	r2, pc, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:134
     9ac:	e7922001 	ldr	r2, [r2, r1]
     9b0:	e5823000 	str	r3, [r2]
     9b4:	e12fff1e 	bx	lr
     9b8:	003498ac 	.word	0x003498ac
     9bc:	00000000 	.word	0x00000000

000009c0 <__stack_chk_fail>:
__stack_chk_fail():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:139
     9c0:	e59f0004 	ldr	r0, [pc, #4]	; 9cc <__stack_chk_fail+0xc>
     9c4:	e08f0000 	add	r0, pc, r0
     9c8:	eaffffdc 	b	940 <error>
     9cc:	00003c04 	.word	0x00003c04

000009d0 <decompress_kernel>:
decompress_kernel():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:149
     9d0:	e92d41f0 	push	{r4, r5, r6, r7, r8, lr}
     9d4:	e1a08003 	mov	r8, r3
     9d8:	e59f40b0 	ldr	r4, [pc, #176]	; a90 <decompress_kernel+0xc0>
     9dc:	e1a05000 	mov	r5, r0
     9e0:	e1a06001 	mov	r6, r1
     9e4:	e1a07002 	mov	r7, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:152
     9e8:	ebffffea 	bl	998 <__stack_chk_guard_setup>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:154
     9ec:	e59f30a0 	ldr	r3, [pc, #160]	; a94 <decompress_kernel+0xc4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:149
     9f0:	e08f4004 	add	r4, pc, r4
     9f4:	e59fc09c 	ldr	ip, [pc, #156]	; a98 <decompress_kernel+0xc8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:154
     9f8:	e7943003 	ldr	r3, [r4, r3]
     9fc:	e08fc00c 	add	ip, pc, ip
     a00:	e24cc001 	sub	ip, ip, #1
     a04:	e5835000 	str	r5, [r3]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:155
     a08:	e59f308c 	ldr	r3, [pc, #140]	; a9c <decompress_kernel+0xcc>
     a0c:	e7943003 	ldr	r3, [r4, r3]
     a10:	e5836000 	str	r6, [r3]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:156
     a14:	e59f3084 	ldr	r3, [pc, #132]	; aa0 <decompress_kernel+0xd0>
     a18:	e7943003 	ldr	r3, [r4, r3]
     a1c:	e5837000 	str	r7, [r3]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:157
     a20:	e59f307c 	ldr	r3, [pc, #124]	; aa4 <decompress_kernel+0xd4>
     a24:	e7943003 	ldr	r3, [r4, r3]
     a28:	e5838000 	str	r8, [r3]
putstr():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:90
     a2c:	e5fc3001 	ldrb	r3, [ip, #1]!
     a30:	e3530000 	cmp	r3, #0
     a34:	1afffffc 	bne	a2c <decompress_kernel+0x5c>
decompress_kernel():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:162
     a38:	e59f3068 	ldr	r3, [pc, #104]	; aa8 <decompress_kernel+0xd8>
     a3c:	e1a02005 	mov	r2, r5
     a40:	e59f1064 	ldr	r1, [pc, #100]	; aac <decompress_kernel+0xdc>
     a44:	e7940003 	ldr	r0, [r4, r3]
     a48:	e59f3060 	ldr	r3, [pc, #96]	; ab0 <decompress_kernel+0xe0>
     a4c:	e7941001 	ldr	r1, [r4, r1]
     a50:	e7943003 	ldr	r3, [r4, r3]
     a54:	e0601001 	rsb	r1, r0, r1
     a58:	eb000a2c 	bl	3310 <do_decompress>
     a5c:	e59f3050 	ldr	r3, [pc, #80]	; ab4 <decompress_kernel+0xe4>
     a60:	e08f3003 	add	r3, pc, r3
     a64:	e2433001 	sub	r3, r3, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:164
     a68:	e3500000 	cmp	r0, #0
     a6c:	1a000003 	bne	a80 <decompress_kernel+0xb0>
putstr():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:90
     a70:	e5f32001 	ldrb	r2, [r3, #1]!
     a74:	e3520000 	cmp	r2, #0
     a78:	1afffffc 	bne	a70 <decompress_kernel+0xa0>
decompress_kernel():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:168
     a7c:	e8bd81f0 	pop	{r4, r5, r6, r7, r8, pc}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:165
     a80:	e59f0030 	ldr	r0, [pc, #48]	; ab8 <decompress_kernel+0xe8>
     a84:	e08f0000 	add	r0, pc, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:168
     a88:	e8bd41f0 	pop	{r4, r5, r6, r7, r8, lr}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/misc.c:165
     a8c:	eaffffab 	b	940 <error>
     a90:	00349864 	.word	0x00349864
     a94:	0000001c 	.word	0x0000001c
     a98:	00003bf8 	.word	0x00003bf8
     a9c:	00000024 	.word	0x00000024
     aa0:	00000014 	.word	0x00000014
     aa4:	00000020 	.word	0x00000020
     aa8:	0000000c 	.word	0x0000000c
     aac:	00000004 	.word	0x00000004
     ab0:	00000018 	.word	0x00000018
     ab4:	00003bcc 	.word	0x00003bcc
     ab8:	00003b88 	.word	0x00003b88

00000abc <malloc>:
malloc():
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:37
     abc:	e250c000 	subs	ip, r0, #0
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:34
     ac0:	e59f306c 	ldr	r3, [pc, #108]	; b34 <malloc+0x78>
     ac4:	e08f3003 	add	r3, pc, r3
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:37
     ac8:	ba000017 	blt	b2c <malloc+0x70>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:39
     acc:	e59f2064 	ldr	r2, [pc, #100]	; b38 <malloc+0x7c>
     ad0:	e7931002 	ldr	r1, [r3, r2]
     ad4:	e5912000 	ldr	r2, [r1]
     ad8:	e3520000 	cmp	r2, #0
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:40
     adc:	059f2058 	ldreq	r2, [pc, #88]	; b3c <malloc+0x80>
     ae0:	07932002 	ldreq	r2, [r3, r2]
     ae4:	05922000 	ldreq	r2, [r2]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:42
     ae8:	e2822003 	add	r2, r2, #3
     aec:	e3c20003 	bic	r0, r2, #3
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:47
     af0:	e59f2048 	ldr	r2, [pc, #72]	; b40 <malloc+0x84>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:45
     af4:	e080c00c 	add	ip, r0, ip
     af8:	e581c000 	str	ip, [r1]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:47
     afc:	e7932002 	ldr	r2, [r3, r2]
     b00:	e5922000 	ldr	r2, [r2]
     b04:	e3520000 	cmp	r2, #0
     b08:	0a000001 	beq	b14 <malloc+0x58>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:47 (discriminator 1)
     b0c:	e15c0002 	cmp	ip, r2
     b10:	2a000005 	bcs	b2c <malloc+0x70>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:50
     b14:	e59f2028 	ldr	r2, [pc, #40]	; b44 <malloc+0x88>
     b18:	e7933002 	ldr	r3, [r3, r2]
     b1c:	e5932000 	ldr	r2, [r3]
     b20:	e2822001 	add	r2, r2, #1
     b24:	e5832000 	str	r2, [r3]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:52
     b28:	e12fff1e 	bx	lr
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:38
     b2c:	e3a00000 	mov	r0, #0
     b30:	e12fff1e 	bx	lr
     b34:	00349790 	.word	0x00349790
     b38:	00000008 	.word	0x00000008
     b3c:	00000024 	.word	0x00000024
     b40:	00000014 	.word	0x00000014
     b44:	00000010 	.word	0x00000010

00000b48 <nofill>:
nofill():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:33
     b48:	e3e00000 	mvn	r0, #0
     b4c:	e12fff1e 	bx	lr

00000b50 <zlib_updatewindow>:
zlib_updatewindow():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:102
     b50:	e92d40f8 	push	{r3, r4, r5, r6, r7, lr}
     b54:	e1a07000 	mov	r7, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:106
     b58:	e590401c 	ldr	r4, [r0, #28]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:109
     b5c:	e5905010 	ldr	r5, [r0, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:110
     b60:	e5946024 	ldr	r6, [r4, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:109
     b64:	e0655001 	rsb	r5, r5, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:110
     b68:	e1550006 	cmp	r5, r6
     b6c:	2a000016 	bcs	bcc <zlib_updatewindow+0x7c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:116
     b70:	e594302c 	ldr	r3, [r4, #44]	; 0x2c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:118
     b74:	e5940030 	ldr	r0, [r4, #48]	; 0x30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:116
     b78:	e0636006 	rsb	r6, r3, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:118
     b7c:	e597100c 	ldr	r1, [r7, #12]
     b80:	e1550006 	cmp	r5, r6
     b84:	31a06005 	movcc	r6, r5
     b88:	e0800003 	add	r0, r0, r3
     b8c:	e0651001 	rsb	r1, r5, r1
     b90:	e1a02006 	mov	r2, r6
     b94:	eb000a9e 	bl	3614 <memcpy>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:120
     b98:	e0555006 	subs	r5, r5, r6
     b9c:	1a000014 	bne	bf4 <zlib_updatewindow+0xa4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:126
     ba0:	e594102c 	ldr	r1, [r4, #44]	; 0x2c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:128
     ba4:	e5942028 	ldr	r2, [r4, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:127
     ba8:	e5943024 	ldr	r3, [r4, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:126
     bac:	e0861001 	add	r1, r6, r1
     bb0:	e584102c 	str	r1, [r4, #44]	; 0x2c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:127
     bb4:	e1510003 	cmp	r1, r3
     bb8:	0584502c 	streq	r5, [r4, #44]	; 0x2c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:128
     bbc:	e1530002 	cmp	r3, r2
     bc0:	80866002 	addhi	r6, r6, r2
     bc4:	85846028 	strhi	r6, [r4, #40]	; 0x28
     bc8:	e8bd80f8 	pop	{r3, r4, r5, r6, r7, pc}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:111
     bcc:	e590100c 	ldr	r1, [r0, #12]
     bd0:	e1a02006 	mov	r2, r6
     bd4:	e5940030 	ldr	r0, [r4, #48]	; 0x30
     bd8:	e0661001 	rsb	r1, r6, r1
     bdc:	eb000a8c 	bl	3614 <memcpy>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:113
     be0:	e5943024 	ldr	r3, [r4, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:112
     be4:	e3a02000 	mov	r2, #0
     be8:	e584202c 	str	r2, [r4, #44]	; 0x2c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:113
     bec:	e5843028 	str	r3, [r4, #40]	; 0x28
     bf0:	e8bd80f8 	pop	{r3, r4, r5, r6, r7, pc}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:121
     bf4:	e597100c 	ldr	r1, [r7, #12]
     bf8:	e1a02005 	mov	r2, r5
     bfc:	e5940030 	ldr	r0, [r4, #48]	; 0x30
     c00:	e0651001 	rsb	r1, r5, r1
     c04:	eb000a82 	bl	3614 <memcpy>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:123
     c08:	e5943024 	ldr	r3, [r4, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:122
     c0c:	e584502c 	str	r5, [r4, #44]	; 0x2c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:123
     c10:	e5843028 	str	r3, [r4, #40]	; 0x28
     c14:	e8bd80f8 	pop	{r3, r4, r5, r6, r7, pc}

00000c18 <zlib_inflate_table>:
zlib_inflate_table():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:25
     c18:	e92d0ff0 	push	{r4, r5, r6, r7, r8, r9, sl, fp}
     c1c:	e24dd078 	sub	sp, sp, #120	; 0x78
     c20:	e28d5036 	add	r5, sp, #54	; 0x36
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:23
     c24:	e28d4056 	add	r4, sp, #86	; 0x56
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:25
     c28:	e59dc09c 	ldr	ip, [sp, #156]	; 0x9c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:23
     c2c:	e28d7038 	add	r7, sp, #56	; 0x38
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:25
     c30:	e58d3014 	str	r3, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:94
     c34:	e3a03000 	mov	r3, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:25
     c38:	e58d1020 	str	r1, [sp, #32]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:94 (discriminator 2)
     c3c:	e1e530b2 	strh	r3, [r5, #2]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:93 (discriminator 2)
     c40:	e1550004 	cmp	r5, r4
     c44:	1afffffc 	bne	c3c <zlib_inflate_table+0x24>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:95 (discriminator 1)
     c48:	e3520000 	cmp	r2, #0
     c4c:	0a00000a 	beq	c7c <zlib_inflate_table+0x64>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:23
     c50:	e59d1020 	ldr	r1, [sp, #32]
     c54:	e0816082 	add	r6, r1, r2, lsl #1
     c58:	e1a03001 	mov	r3, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:96 (discriminator 2)
     c5c:	e0d310b2 	ldrh	r1, [r3], #2
     c60:	e28d5078 	add	r5, sp, #120	; 0x78
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:95 (discriminator 2)
     c64:	e1530006 	cmp	r3, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:96 (discriminator 2)
     c68:	e0851081 	add	r1, r5, r1, lsl #1
     c6c:	e15154b0 	ldrh	r5, [r1, #-64]	; 0xffffffc0
     c70:	e2855001 	add	r5, r5, #1
     c74:	e14154b0 	strh	r5, [r1, #-64]	; 0xffffffc0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:95 (discriminator 2)
     c78:	1afffff7 	bne	c5c <zlib_inflate_table+0x44>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:99
     c7c:	e59d5098 	ldr	r5, [sp, #152]	; 0x98
     c80:	e28d3058 	add	r3, sp, #88	; 0x58
     c84:	e5956000 	ldr	r6, [r5]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:100
     c88:	e3a0500f 	mov	r5, #15
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:101
     c8c:	e17310b2 	ldrh	r1, [r3, #-2]!
     c90:	e3510000 	cmp	r1, #0
     c94:	1a000014 	bne	cec <zlib_inflate_table+0xd4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:100
     c98:	e2555001 	subs	r5, r5, #1
     c9c:	1afffffa 	bne	c8c <zlib_inflate_table+0x74>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:107
     ca0:	e59d6014 	ldr	r6, [sp, #20]
     ca4:	e3a01000 	mov	r1, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:109
     ca8:	e59d7098 	ldr	r7, [sp, #152]	; 0x98
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:110
     cac:	e1a00001 	mov	r0, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:107
     cb0:	e3a02001 	mov	r2, #1
     cb4:	e3a0c040 	mov	ip, #64	; 0x40
     cb8:	e5963000 	ldr	r3, [r6]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:108
     cbc:	e2834008 	add	r4, r3, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:107
     cc0:	e5c3c000 	strb	ip, [r3]
     cc4:	e5c32001 	strb	r2, [r3, #1]
     cc8:	e1c310b2 	strh	r1, [r3, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:108
     ccc:	e5c3c004 	strb	ip, [r3, #4]
     cd0:	e5c32005 	strb	r2, [r3, #5]
     cd4:	e1c310b6 	strh	r1, [r3, #6]
     cd8:	e5864000 	str	r4, [r6]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:109
     cdc:	e5872000 	str	r2, [r7]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:315
     ce0:	e28dd078 	add	sp, sp, #120	; 0x78
     ce4:	e8bd0ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp}
     ce8:	e12fff1e 	bx	lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:103
     cec:	e3550000 	cmp	r5, #0
     cf0:	128d3038 	addne	r3, sp, #56	; 0x38
     cf4:	13a09001 	movne	r9, #1
     cf8:	0affffe8 	beq	ca0 <zlib_inflate_table+0x88>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:113
     cfc:	e1f310b2 	ldrh	r1, [r3, #2]!
     d00:	e3510000 	cmp	r1, #0
     d04:	1a0000d8 	bne	106c <zlib_inflate_table+0x454>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:112
     d08:	e2899001 	add	r9, r9, #1
     d0c:	e3590010 	cmp	r9, #16
     d10:	1afffff9 	bne	cfc <zlib_inflate_table+0xe4>
     d14:	e58d900c 	str	r9, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:114
     d18:	e28d1038 	add	r1, sp, #56	; 0x38
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:117
     d1c:	e3a03001 	mov	r3, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:120
     d20:	e1f160b2 	ldrh	r6, [r1, #2]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:121
     d24:	e0763083 	rsbs	r3, r6, r3, lsl #1
     d28:	4a0000cd 	bmi	1064 <zlib_inflate_table+0x44c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:118
     d2c:	e1510004 	cmp	r1, r4
     d30:	1afffffa 	bne	d20 <zlib_inflate_table+0x108>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:123
     d34:	e3530000 	cmp	r3, #0
     d38:	0a000005 	beq	d54 <zlib_inflate_table+0x13c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:123 (discriminator 1)
     d3c:	e2703001 	rsbs	r3, r0, #1
     d40:	33a03000 	movcc	r3, #0
     d44:	e3550001 	cmp	r5, #1
     d48:	13833001 	orrne	r3, r3, #1
     d4c:	e3530000 	cmp	r3, #0
     d50:	1a0000c3 	bne	1064 <zlib_inflate_table+0x44c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:127
     d54:	e3a04000 	mov	r4, #0
     d58:	e28d1078 	add	r1, sp, #120	; 0x78
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:23
     d5c:	e28d6054 	add	r6, sp, #84	; 0x54
     d60:	e1a03004 	mov	r3, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:127
     d64:	e16141be 	strh	r4, [r1, #-30]!	; 0xffffffe2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:129 (discriminator 2)
     d68:	e1f740b2 	ldrh	r4, [r7, #2]!
     d6c:	e0833004 	add	r3, r3, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:128 (discriminator 2)
     d70:	e1570006 	cmp	r7, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:129 (discriminator 2)
     d74:	e6ff3073 	uxth	r3, r3
     d78:	e1e130b2 	strh	r3, [r1, #2]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:128 (discriminator 2)
     d7c:	1afffff9 	bne	d68 <zlib_inflate_table+0x150>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:132 (discriminator 1)
     d80:	e3520000 	cmp	r2, #0
     d84:	0a00000e 	beq	dc4 <zlib_inflate_table+0x1ac>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:23
     d88:	e59d4020 	ldr	r4, [sp, #32]
     d8c:	e3a03000 	mov	r3, #0
     d90:	e2441002 	sub	r1, r4, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:133
     d94:	e1f140b2 	ldrh	r4, [r1, #2]!
     d98:	e28d6078 	add	r6, sp, #120	; 0x78
     d9c:	e3540000 	cmp	r4, #0
     da0:	e0864084 	add	r4, r6, r4, lsl #1
     da4:	115462b0 	ldrhne	r6, [r4, #-32]	; 0xffffffe0
     da8:	12867001 	addne	r7, r6, #1
     dac:	114472b0 	strhne	r7, [r4, #-32]	; 0xffffffe0
     db0:	11a06086 	lslne	r6, r6, #1
     db4:	118c30b6 	strhne	r3, [ip, r6]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:132
     db8:	e2833001 	add	r3, r3, #1
     dbc:	e1530002 	cmp	r3, r2
     dc0:	1afffff3 	bne	d94 <zlib_inflate_table+0x17c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:168
     dc4:	e3500000 	cmp	r0, #0
     dc8:	0a0000ad 	beq	1084 <zlib_inflate_table+0x46c>
     dcc:	e3500001 	cmp	r0, #1
     dd0:	0a0000e6 	beq	1170 <zlib_inflate_table+0x558>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:182
     dd4:	e59f33c0 	ldr	r3, [pc, #960]	; 119c <zlib_inflate_table+0x584>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:183
     dd8:	e3e07000 	mvn	r7, #0
     ddc:	e58d701c 	str	r7, [sp, #28]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:182
     de0:	e08f3003 	add	r3, pc, r3
     de4:	e2831080 	add	r1, r3, #128	; 0x80
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:181
     de8:	e28330c0 	add	r3, r3, #192	; 0xc0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:182
     dec:	e58d1034 	str	r1, [sp, #52]	; 0x34
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:181
     df0:	e58d3030 	str	r3, [sp, #48]	; 0x30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:194
     df4:	e3a02001 	mov	r2, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:198
     df8:	e0503002 	subs	r3, r0, r2
     dfc:	e2730000 	rsbs	r0, r3, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:190
     e00:	e59d6014 	ldr	r6, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:198
     e04:	e0b00003 	adcs	r0, r0, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:194
     e08:	e59d300c 	ldr	r3, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:198
     e0c:	e58d002c 	str	r0, [sp, #44]	; 0x2c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:194
     e10:	e1a03312 	lsl	r3, r2, r3
     e14:	e58d3018 	str	r3, [sp, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:198
     e18:	e59d4018 	ldr	r4, [sp, #24]
     e1c:	e30035af 	movw	r3, #1455	; 0x5af
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:190
     e20:	e5966000 	ldr	r6, [r6]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:198
     e24:	e1540003 	cmp	r4, r3
     e28:	93a00000 	movls	r0, #0
     e2c:	82000001 	andhi	r0, r0, #1
     e30:	e3500000 	cmp	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:190
     e34:	e58d6010 	str	r6, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:198
     e38:	1a000098 	bne	10a0 <zlib_inflate_table+0x488>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:23
     e3c:	e24cc002 	sub	ip, ip, #2
     e40:	e58dc008 	str	ip, [sp, #8]
     e44:	e59dc00c 	ldr	ip, [sp, #12]
     e48:	e3e01000 	mvn	r1, #0
     e4c:	e1a0a000 	mov	sl, r0
     e50:	e58d1024 	str	r1, [sp, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:219
     e54:	e1a0b002 	mov	fp, r2
     e58:	e1a01009 	mov	r1, r9
     e5c:	e1a08005 	mov	r8, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:195
     e60:	e2447001 	sub	r7, r4, #1
     e64:	e58d7028 	str	r7, [sp, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:205
     e68:	e59d2008 	ldr	r2, [sp, #8]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:204
     e6c:	e1a06001 	mov	r6, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:205
     e70:	e59d301c 	ldr	r3, [sp, #28]
     e74:	e1f240b2 	ldrh	r4, [r2, #2]!
     e78:	e1530004 	cmp	r3, r4
     e7c:	e58d2008 	str	r2, [sp, #8]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:206
     e80:	c3a02000 	movgt	r2, #0
     e84:	c58d2000 	strgt	r2, [sp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:205
     e88:	ca000008 	bgt	eb0 <zlib_inflate_table+0x298>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:210
     e8c:	b59d5034 	ldrlt	r5, [sp, #52]	; 0x34
     e90:	b1a04084 	lsllt	r4, r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:211
     e94:	b59d7030 	ldrlt	r7, [sp, #48]	; 0x30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:215
     e98:	a3a04000 	movge	r4, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:214
     e9c:	a3a03060 	movge	r3, #96	; 0x60
     ea0:	a58d3000 	strge	r3, [sp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:210
     ea4:	b7d55004 	ldrblt	r5, [r5, r4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:211
     ea8:	b19740b4 	ldrhlt	r4, [r7, r4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:210
     eac:	b58d5000 	strlt	r5, [sp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:220
     eb0:	e1a05c1b 	lsl	r5, fp, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:219
     eb4:	e1a0111b 	lsl	r1, fp, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:224
     eb8:	e0853a30 	add	r3, r5, r0, lsr sl
     ebc:	e59d7010 	ldr	r7, [sp, #16]
     ec0:	e0613003 	rsb	r3, r1, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:220
     ec4:	e58d5004 	str	r5, [sp, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:23
     ec8:	e0615f01 	rsb	r5, r1, r1, lsl #30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:220
     ecc:	e59d2004 	ldr	r2, [sp, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:224
     ed0:	e0873103 	add	r3, r7, r3, lsl #2
     ed4:	e59d7000 	ldr	r7, [sp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:23
     ed8:	e1a05105 	lsl	r5, r5, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:225 (discriminator 1)
     edc:	e0522001 	subs	r2, r2, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:224 (discriminator 1)
     ee0:	e5c37000 	strb	r7, [r3]
     ee4:	e5c36001 	strb	r6, [r3, #1]
     ee8:	e1c340b2 	strh	r4, [r3, #2]
     eec:	e0833005 	add	r3, r3, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:225 (discriminator 1)
     ef0:	1afffff9 	bne	edc <zlib_inflate_table+0x2c4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:228
     ef4:	e2492001 	sub	r2, r9, #1
     ef8:	e1a0321b 	lsl	r3, fp, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:229
     efc:	e1130000 	tst	r3, r0
     f00:	0a000002 	beq	f10 <zlib_inflate_table+0x2f8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:230
     f04:	e1a030a3 	lsr	r3, r3, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:229
     f08:	e1100003 	tst	r0, r3
     f0c:	1afffffc 	bne	f04 <zlib_inflate_table+0x2ec>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:231
     f10:	e3530000 	cmp	r3, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:232
     f14:	12431001 	subne	r1, r3, #1
     f18:	10010000 	andne	r0, r1, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:236
     f1c:	01a00003 	moveq	r0, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:233
     f20:	10800003 	addne	r0, r0, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:240
     f24:	e28d3078 	add	r3, sp, #120	; 0x78
     f28:	e0831089 	add	r1, r3, r9, lsl #1
     f2c:	e15134b0 	ldrh	r3, [r1, #-64]	; 0xffffffc0
     f30:	e2433001 	sub	r3, r3, #1
     f34:	e6ff3073 	uxth	r3, r3
     f38:	e14134b0 	strh	r3, [r1, #-64]	; 0xffffffc0
     f3c:	e3530000 	cmp	r3, #0
     f40:	1a000006 	bne	f60 <zlib_inflate_table+0x348>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:241
     f44:	e1590008 	cmp	r9, r8
     f48:	0a000056 	beq	10a8 <zlib_inflate_table+0x490>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:242
     f4c:	e59d1008 	ldr	r1, [sp, #8]
     f50:	e59d4020 	ldr	r4, [sp, #32]
     f54:	e1d130b2 	ldrh	r3, [r1, #2]
     f58:	e1a03083 	lsl	r3, r3, #1
     f5c:	e19490b3 	ldrh	r9, [r4, r3]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:246
     f60:	e59d500c 	ldr	r5, [sp, #12]
     f64:	e1590005 	cmp	r9, r5
     f68:	9a00004a 	bls	1098 <zlib_inflate_table+0x480>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:246 (discriminator 1)
     f6c:	e59d6028 	ldr	r6, [sp, #40]	; 0x28
     f70:	e59d7024 	ldr	r7, [sp, #36]	; 0x24
     f74:	e0004006 	and	r4, r0, r6
     f78:	e1540007 	cmp	r4, r7
     f7c:	0a000045 	beq	1098 <zlib_inflate_table+0x480>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:248
     f80:	e59dc00c 	ldr	ip, [sp, #12]
     f84:	e35a0000 	cmp	sl, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:252
     f88:	e59d2004 	ldr	r2, [sp, #4]
     f8c:	e59d1010 	ldr	r1, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:248
     f90:	01a0a00c 	moveq	sl, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:257
     f94:	e1590008 	cmp	r9, r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:255
     f98:	e06ac009 	rsb	ip, sl, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:252
     f9c:	e0811102 	add	r1, r1, r2, lsl #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:256
     fa0:	e1a03c1b 	lsl	r3, fp, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:252
     fa4:	e58d1010 	str	r1, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:255
     fa8:	e1a0100c 	mov	r1, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:257
     fac:	2a000012 	bcs	ffc <zlib_inflate_table+0x3e4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:258
     fb0:	e1a05089 	lsl	r5, r9, #1
     fb4:	e28d6078 	add	r6, sp, #120	; 0x78
     fb8:	e0862005 	add	r2, r6, r5
     fbc:	e15224b0 	ldrh	r2, [r2, #-64]	; 0xffffffc0
     fc0:	e0623003 	rsb	r3, r2, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:259
     fc4:	e3530000 	cmp	r3, #0
     fc8:	da00000b 	ble	ffc <zlib_inflate_table+0x3e4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:23
     fcc:	e28d7038 	add	r7, sp, #56	; 0x38
     fd0:	e0875005 	add	r5, r7, r5
     fd4:	ea000003 	b	fe8 <zlib_inflate_table+0x3d0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:258
     fd8:	e1f520b2 	ldrh	r2, [r5, #2]!
     fdc:	e0623003 	rsb	r3, r2, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:259
     fe0:	e3530000 	cmp	r3, #0
     fe4:	da000004 	ble	ffc <zlib_inflate_table+0x3e4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:260
     fe8:	e28cc001 	add	ip, ip, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:261
     fec:	e1a03083 	lsl	r3, r3, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:257
     ff0:	e08a200c 	add	r2, sl, ip
     ff4:	e1520008 	cmp	r2, r8
     ff8:	3afffff6 	bcc	fd8 <zlib_inflate_table+0x3c0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:265
     ffc:	e59d2018 	ldr	r2, [sp, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:266
    1000:	e30055af 	movw	r5, #1455	; 0x5af
    1004:	e59d302c 	ldr	r3, [sp, #44]	; 0x2c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:265
    1008:	e0822c1b 	add	r2, r2, fp, lsl ip
    100c:	e58d2018 	str	r2, [sp, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:266
    1010:	e1520005 	cmp	r2, r5
    1014:	93a03000 	movls	r3, #0
    1018:	82033001 	andhi	r3, r3, #1
    101c:	e3530000 	cmp	r3, #0
    1020:	1a00001e 	bne	10a0 <zlib_inflate_table+0x488>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:271
    1024:	e59d6014 	ldr	r6, [sp, #20]
    1028:	e1a03104 	lsl	r3, r4, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:272
    102c:	e59d700c 	ldr	r7, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:273
    1030:	e58d4024 	str	r4, [sp, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:271
    1034:	e5962000 	ldr	r2, [r6]
    1038:	e7c2c104 	strb	ip, [r2, r4, lsl #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:272
    103c:	e5962000 	ldr	r2, [r6]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:273
    1040:	e59d4010 	ldr	r4, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:272
    1044:	e0822003 	add	r2, r2, r3
    1048:	e5c27001 	strb	r7, [r2, #1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:273
    104c:	e5962000 	ldr	r2, [r6]
    1050:	e0823003 	add	r3, r2, r3
    1054:	e0622004 	rsb	r2, r2, r4
    1058:	e1a02142 	asr	r2, r2, #2
    105c:	e1c320b2 	strh	r2, [r3, #2]
    1060:	eaffff80 	b	e68 <zlib_inflate_table+0x250>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:121
    1064:	e3e00000 	mvn	r0, #0
    1068:	eaffff1c 	b	ce0 <zlib_inflate_table+0xc8>
    106c:	e1550006 	cmp	r5, r6
    1070:	31a06005 	movcc	r6, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:114
    1074:	e1560009 	cmp	r6, r9
    1078:	31a06009 	movcc	r6, r9
    107c:	e58d600c 	str	r6, [sp, #12]
    1080:	eaffff24 	b	d18 <zlib_inflate_table+0x100>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:171
    1084:	e3a02013 	mov	r2, #19
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:170
    1088:	e58dc034 	str	ip, [sp, #52]	; 0x34
    108c:	e58dc030 	str	ip, [sp, #48]	; 0x30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:171
    1090:	e58d201c 	str	r2, [sp, #28]
    1094:	eaffff56 	b	df4 <zlib_inflate_table+0x1dc>
    1098:	e06a1009 	rsb	r1, sl, r9
    109c:	eaffff71 	b	e68 <zlib_inflate_table+0x250>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:199
    10a0:	e3a00001 	mov	r0, #1
    10a4:	eaffff0d 	b	ce0 <zlib_inflate_table+0xc8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:287 (discriminator 1)
    10a8:	e3500000 	cmp	r0, #0
    10ac:	0a000023 	beq	1140 <zlib_inflate_table+0x528>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:293
    10b0:	e59d500c 	ldr	r5, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:297
    10b4:	e3a07040 	mov	r7, #64	; 0x40
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:300
    10b8:	e59d9010 	ldr	r9, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:293
    10bc:	e6ef8075 	uxtb	r8, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:300
    10c0:	e3a05001 	mov	r5, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:289
    10c4:	e35a0000 	cmp	sl, #0
    10c8:	0a000026 	beq	1168 <zlib_inflate_table+0x550>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:289 (discriminator 1)
    10cc:	e59dc028 	ldr	ip, [sp, #40]	; 0x28
    10d0:	e59d4024 	ldr	r4, [sp, #36]	; 0x24
    10d4:	e000100c 	and	r1, r0, ip
    10d8:	e1540001 	cmp	r4, r1
    10dc:	0a000021 	beq	1168 <zlib_inflate_table+0x550>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:292
    10e0:	e59d6014 	ldr	r6, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:293
    10e4:	e3a0a000 	mov	sl, #0
    10e8:	e59dc00c 	ldr	ip, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:290
    10ec:	e1a0400a 	mov	r4, sl
    10f0:	e24c2001 	sub	r2, ip, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:292
    10f4:	e5969000 	ldr	r9, [r6]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:293
    10f8:	e1a06008 	mov	r6, r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:297
    10fc:	e1a04430 	lsr	r4, r0, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:300
    1100:	e1a01215 	lsl	r1, r5, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:301
    1104:	e1110000 	tst	r1, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:297
    1108:	e089c104 	add	ip, r9, r4, lsl #2
    110c:	e7c97104 	strb	r7, [r9, r4, lsl #2]
    1110:	e5cc6001 	strb	r6, [ip, #1]
    1114:	e1cc30b2 	strh	r3, [ip, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:301
    1118:	0a000002 	beq	1128 <zlib_inflate_table+0x510>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:302
    111c:	e1a010a1 	lsr	r1, r1, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:301
    1120:	e1100001 	tst	r0, r1
    1124:	1afffffc 	bne	111c <zlib_inflate_table+0x504>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:303
    1128:	e3510000 	cmp	r1, #0
    112c:	0a000003 	beq	1140 <zlib_inflate_table+0x528>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:304
    1130:	e241c001 	sub	ip, r1, #1
    1134:	e00c0000 	and	r0, ip, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:287
    1138:	e0900001 	adds	r0, r0, r1
    113c:	1affffe0 	bne	10c4 <zlib_inflate_table+0x4ac>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:312
    1140:	e59d4014 	ldr	r4, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:314
    1144:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:312
    1148:	e59d5018 	ldr	r5, [sp, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:313
    114c:	e59d600c 	ldr	r6, [sp, #12]
    1150:	e59d7098 	ldr	r7, [sp, #152]	; 0x98
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:312
    1154:	e5943000 	ldr	r3, [r4]
    1158:	e0833105 	add	r3, r3, r5, lsl #2
    115c:	e5843000 	str	r3, [r4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:313
    1160:	e5876000 	str	r6, [r7]
    1164:	eafffedd 	b	ce0 <zlib_inflate_table+0xc8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:289
    1168:	e1a0400a 	mov	r4, sl
    116c:	eaffffe2 	b	10fc <zlib_inflate_table+0x4e4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:176
    1170:	e59f3028 	ldr	r3, [pc, #40]	; 11a0 <zlib_inflate_table+0x588>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:178
    1174:	e3a02c01 	mov	r2, #256	; 0x100
    1178:	e58d201c 	str	r2, [sp, #28]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:176
    117c:	e08f3003 	add	r3, pc, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:177
    1180:	e2432c02 	sub	r2, r3, #512	; 0x200
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:175
    1184:	e2433d07 	sub	r3, r3, #448	; 0x1c0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:177
    1188:	e2422002 	sub	r2, r2, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:175
    118c:	e2433002 	sub	r3, r3, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:177
    1190:	e58d2034 	str	r2, [sp, #52]	; 0x34
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inftrees.c:175
    1194:	e58d3030 	str	r3, [sp, #48]	; 0x30
    1198:	eaffff15 	b	df4 <zlib_inflate_table+0x1dc>
    119c:	00002e0c 	.word	0x00002e0c
    11a0:	00002a70 	.word	0x00002a70

000011a4 <inflate_fast>:
inflate_fast():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:89
    11a4:	e92d0ff0 	push	{r4, r5, r6, r7, r8, r9, sl, fp}
    11a8:	e24dd038 	sub	sp, sp, #56	; 0x38
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:117
    11ac:	e590b01c 	ldr	fp, [r0, #28]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:134
    11b0:	e3a04001 	mov	r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:89
    11b4:	e58d0000 	str	r0, [sp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:190
    11b8:	e1a00004 	mov	r0, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:121
    11bc:	e59d2000 	ldr	r2, [sp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:120
    11c0:	e59d5000 	ldr	r5, [sp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:126
    11c4:	e59ba024 	ldr	sl, [fp, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:121
    11c8:	e5927010 	ldr	r7, [r2, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:118
    11cc:	e5923000 	ldr	r3, [r2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:122
    11d0:	e2476c01 	sub	r6, r7, #256	; 0x100
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:121
    11d4:	e0611007 	rsb	r1, r1, r7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:128
    11d8:	e59b702c 	ldr	r7, [fp, #44]	; 0x2c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:118
    11dc:	e2438001 	sub	r8, r3, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:120
    11e0:	e595c00c 	ldr	ip, [r5, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:122
    11e4:	e2466001 	sub	r6, r6, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:135
    11e8:	e59b3054 	ldr	r3, [fp, #84]	; 0x54
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:134
    11ec:	e59b5050 	ldr	r5, [fp, #80]	; 0x50
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:120
    11f0:	e24cc001 	sub	ip, ip, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:119
    11f4:	e5922004 	ldr	r2, [r2, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:121
    11f8:	e08c1001 	add	r1, ip, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:126
    11fc:	e58da014 	str	sl, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:134
    1200:	e1a05514 	lsl	r5, r4, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:128
    1204:	e58d7010 	str	r7, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:135
    1208:	e1a04314 	lsl	r4, r4, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:127
    120c:	e59ba028 	ldr	sl, [fp, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:134
    1210:	e2455001 	sub	r5, r5, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:129
    1214:	e59b7030 	ldr	r7, [fp, #48]	; 0x30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:135
    1218:	e2444001 	sub	r4, r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:119
    121c:	e2422005 	sub	r2, r2, #5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:134
    1220:	e58d500c 	str	r5, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:135
    1224:	e58d401c 	str	r4, [sp, #28]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:119
    1228:	e0882002 	add	r2, r8, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:220
    122c:	e59d4010 	ldr	r4, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:122
    1230:	e08c6006 	add	r6, ip, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:220
    1234:	e59d5014 	ldr	r5, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:208
    1238:	e2477001 	sub	r7, r7, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:130
    123c:	e59b3034 	ldr	r3, [fp, #52]	; 0x34
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:119
    1240:	e58d2008 	str	r2, [sp, #8]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:220
    1244:	e0844005 	add	r4, r4, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:131
    1248:	e59b2038 	ldr	r2, [fp, #56]	; 0x38
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:121
    124c:	e58d1020 	str	r1, [sp, #32]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:133
    1250:	e59b904c 	ldr	r9, [fp, #76]	; 0x4c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:132
    1254:	e59b1048 	ldr	r1, [fp, #72]	; 0x48
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:220
    1258:	e58db018 	str	fp, [sp, #24]
    125c:	e1a0b008 	mov	fp, r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:127
    1260:	e58da024 	str	sl, [sp, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:122
    1264:	e58d6004 	str	r6, [sp, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:208
    1268:	e58d7028 	str	r7, [sp, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:220
    126c:	e58d402c 	str	r4, [sp, #44]	; 0x2c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:140
    1270:	e352000e 	cmp	r2, #14
    1274:	8a000007 	bhi	1298 <inflate_fast+0xf4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:143
    1278:	e5db6002 	ldrb	r6, [fp, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:142
    127c:	e2824008 	add	r4, r2, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:141
    1280:	e5db5001 	ldrb	r5, [fp, #1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:143
    1284:	e28bb002 	add	fp, fp, #2
    1288:	e1a04416 	lsl	r4, r6, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:141
    128c:	e0844215 	add	r4, r4, r5, lsl r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:143
    1290:	e2822010 	add	r2, r2, #16
    1294:	e0833004 	add	r3, r3, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:146
    1298:	e59d600c 	ldr	r6, [sp, #12]
    129c:	e0034006 	and	r4, r3, r6
    12a0:	e0816104 	add	r6, r1, r4, lsl #2
    12a4:	e7d14104 	ldrb	r4, [r1, r4, lsl #2]
    12a8:	e5d65001 	ldrb	r5, [r6, #1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:152
    12ac:	e3540000 	cmp	r4, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:146
    12b0:	e1d660b2 	ldrh	r6, [r6, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:149
    12b4:	e1a03533 	lsr	r3, r3, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:150
    12b8:	e0652002 	rsb	r2, r5, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:152
    12bc:	0a00001c 	beq	1334 <inflate_fast+0x190>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:155
    12c0:	e2045010 	and	r5, r4, #16
    12c4:	e6ef5075 	uxtb	r5, r5
    12c8:	e3550000 	cmp	r5, #0
    12cc:	1a00003d 	bne	13c8 <inflate_fast+0x224>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:317
    12d0:	e2045040 	and	r5, r4, #64	; 0x40
    12d4:	e6ef5075 	uxtb	r5, r5
    12d8:	e3550000 	cmp	r5, #0
    12dc:	0a000004 	beq	12f4 <inflate_fast+0x150>
    12e0:	ea0000b3 	b	15b4 <inflate_fast+0x410>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:155
    12e4:	e3580000 	cmp	r8, #0
    12e8:	1a000036 	bne	13c8 <inflate_fast+0x224>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:317
    12ec:	e3570000 	cmp	r7, #0
    12f0:	1a0000af 	bne	15b4 <inflate_fast+0x410>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:318
    12f4:	e1a04410 	lsl	r4, r0, r4
    12f8:	e2444001 	sub	r4, r4, #1
    12fc:	e0034004 	and	r4, r3, r4
    1300:	e0846006 	add	r6, r4, r6
    1304:	e7d14106 	ldrb	r4, [r1, r6, lsl #2]
    1308:	e0816106 	add	r6, r1, r6, lsl #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:155
    130c:	e2048010 	and	r8, r4, #16
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:318
    1310:	e5d65001 	ldrb	r5, [r6, #1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:317
    1314:	e2047040 	and	r7, r4, #64	; 0x40
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:152
    1318:	e3540000 	cmp	r4, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:155
    131c:	e6ef8078 	uxtb	r8, r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:318
    1320:	e1d660b2 	ldrh	r6, [r6, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:317
    1324:	e6ef7077 	uxtb	r7, r7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:149
    1328:	e1a03533 	lsr	r3, r3, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:150
    132c:	e0652002 	rsb	r2, r5, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:152
    1330:	1affffeb 	bne	12e4 <inflate_fast+0x140>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:153
    1334:	e5cc6001 	strb	r6, [ip, #1]
    1338:	e28cc001 	add	ip, ip, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:330
    133c:	e99d0500 	ldmib	sp, {r8, sl}
    1340:	e15c0008 	cmp	ip, r8
    1344:	315b000a 	cmpcc	fp, sl
    1348:	3affffc8 	bcc	1270 <inflate_fast+0xcc>
    134c:	e1a0800b 	mov	r8, fp
    1350:	e59db018 	ldr	fp, [sp, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:342
    1354:	e59d1004 	ldr	r1, [sp, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:333
    1358:	e1a001a2 	lsr	r0, r2, #3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:341
    135c:	e59d4008 	ldr	r4, [sp, #8]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:336
    1360:	e3e05000 	mvn	r5, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:342
    1364:	e15c0001 	cmp	ip, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:335
    1368:	e0422180 	sub	r2, r2, r0, lsl #3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:334
    136c:	e0601008 	rsb	r1, r0, r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:342
    1370:	e59d8000 	ldr	r8, [sp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:343
    1374:	359d6004 	ldrcc	r6, [sp, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:336
    1378:	e1c33215 	bic	r3, r3, r5, lsl r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:343
    137c:	259d7004 	ldrcs	r7, [sp, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:341
    1380:	e0610004 	rsb	r0, r1, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:339
    1384:	e59d5000 	ldr	r5, [sp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:340
    1388:	e28c4001 	add	r4, ip, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:343
    138c:	306cc006 	rsbcc	ip, ip, r6
    1390:	206cc007 	rsbcs	ip, ip, r7
    1394:	e28ccc01 	add	ip, ip, #256	; 0x100
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:339
    1398:	e2811001 	add	r1, r1, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:340
    139c:	e585400c 	str	r4, [r5, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:341
    13a0:	e2800005 	add	r0, r0, #5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:339
    13a4:	e5851000 	str	r1, [r5]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:343
    13a8:	e28cc001 	add	ip, ip, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:341
    13ac:	e5850004 	str	r0, [r5, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:342
    13b0:	e588c010 	str	ip, [r8, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:344
    13b4:	e58b3034 	str	r3, [fp, #52]	; 0x34
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:345
    13b8:	e58b2038 	str	r2, [fp, #56]	; 0x38
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:347
    13bc:	e28dd038 	add	sp, sp, #56	; 0x38
    13c0:	e8bd0ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp}
    13c4:	e12fff1e 	bx	lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:158
    13c8:	e214400f 	ands	r4, r4, #15
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:156
    13cc:	e1a0a006 	mov	sl, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:158
    13d0:	0a00000a 	beq	1400 <inflate_fast+0x25c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:159
    13d4:	e1540002 	cmp	r4, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:160
    13d8:	85db5001 	ldrbhi	r5, [fp, #1]
    13dc:	828bb001 	addhi	fp, fp, #1
    13e0:	80833215 	addhi	r3, r3, r5, lsl r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:163
    13e4:	e1a05410 	lsl	r5, r0, r4
    13e8:	e2455001 	sub	r5, r5, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:161
    13ec:	82822008 	addhi	r2, r2, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:163
    13f0:	e0035005 	and	r5, r3, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:165
    13f4:	e0642002 	rsb	r2, r4, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:164
    13f8:	e1a03433 	lsr	r3, r3, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:163
    13fc:	e086a005 	add	sl, r6, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:167
    1400:	e352000e 	cmp	r2, #14
    1404:	9a000079 	bls	15f0 <inflate_fast+0x44c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:173
    1408:	e59d801c 	ldr	r8, [sp, #28]
    140c:	e0037008 	and	r7, r3, r8
    1410:	e7d95107 	ldrb	r5, [r9, r7, lsl #2]
    1414:	e0897107 	add	r7, r9, r7, lsl #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:179
    1418:	e2056010 	and	r6, r5, #16
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:173
    141c:	e5d74001 	ldrb	r4, [r7, #1]
    1420:	e1d770b2 	ldrh	r7, [r7, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:179
    1424:	e6ef6076 	uxtb	r6, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:176
    1428:	e1a03433 	lsr	r3, r3, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:179
    142c:	e3560000 	cmp	r6, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:177
    1430:	e0642002 	rsb	r2, r4, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:179
    1434:	1a000016 	bne	1494 <inflate_fast+0x2f0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:307
    1438:	e2054040 	and	r4, r5, #64	; 0x40
    143c:	e6ef4074 	uxtb	r4, r4
    1440:	e3540000 	cmp	r4, #0
    1444:	0a000002 	beq	1454 <inflate_fast+0x2b0>
    1448:	ea000071 	b	1614 <inflate_fast+0x470>
    144c:	e3580000 	cmp	r8, #0
    1450:	1a00006f 	bne	1614 <inflate_fast+0x470>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:308
    1454:	e1a06510 	lsl	r6, r0, r5
    1458:	e2466001 	sub	r6, r6, #1
    145c:	e0036006 	and	r6, r3, r6
    1460:	e0866007 	add	r6, r6, r7
    1464:	e7d95106 	ldrb	r5, [r9, r6, lsl #2]
    1468:	e0896106 	add	r6, r9, r6, lsl #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:179
    146c:	e2057010 	and	r7, r5, #16
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:308
    1470:	e5d64001 	ldrb	r4, [r6, #1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:307
    1474:	e2058040 	and	r8, r5, #64	; 0x40
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:179
    1478:	e6ef7077 	uxtb	r7, r7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:176
    147c:	e1a03433 	lsr	r3, r3, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:179
    1480:	e3570000 	cmp	r7, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:307
    1484:	e6ef8078 	uxtb	r8, r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:308
    1488:	e1d670b2 	ldrh	r7, [r6, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:177
    148c:	e0642002 	rsb	r2, r4, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:179
    1490:	0affffed 	beq	144c <inflate_fast+0x2a8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:181
    1494:	e205500f 	and	r5, r5, #15
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:182
    1498:	e1550002 	cmp	r5, r2
    149c:	9a000009 	bls	14c8 <inflate_fast+0x324>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:183
    14a0:	e5db6001 	ldrb	r6, [fp, #1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:184
    14a4:	e2824008 	add	r4, r2, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:185
    14a8:	e1550004 	cmp	r5, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:183
    14ac:	928bb001 	addls	fp, fp, #1
    14b0:	e0833216 	add	r3, r3, r6, lsl r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:186
    14b4:	85db6002 	ldrbhi	r6, [fp, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:187
    14b8:	82822010 	addhi	r2, r2, #16
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:186
    14bc:	828bb002 	addhi	fp, fp, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:183
    14c0:	91a02004 	movls	r2, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:186
    14c4:	80833416 	addhi	r3, r3, r6, lsl r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:190
    14c8:	e1a04510 	lsl	r4, r0, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:200
    14cc:	e59d8020 	ldr	r8, [sp, #32]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:190
    14d0:	e2444001 	sub	r4, r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:199
    14d4:	e0652002 	rsb	r2, r5, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:190
    14d8:	e0034004 	and	r4, r3, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:200
    14dc:	e068600c 	rsb	r6, r8, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:190
    14e0:	e0844007 	add	r4, r4, r7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:198
    14e4:	e1a03533 	lsr	r3, r3, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:201
    14e8:	e1540006 	cmp	r4, r6
    14ec:	9a000051 	bls	1638 <inflate_fast+0x494>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:203
    14f0:	e59d5024 	ldr	r5, [sp, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:202
    14f4:	e0668004 	rsb	r8, r6, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:203
    14f8:	e1550008 	cmp	r5, r8
    14fc:	3a0000bb 	bcc	17f0 <inflate_fast+0x64c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:209
    1500:	e59d7010 	ldr	r7, [sp, #16]
    1504:	e3570000 	cmp	r7, #0
    1508:	1a000076 	bne	16e8 <inflate_fast+0x544>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:210
    150c:	e59d6014 	ldr	r6, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:211
    1510:	e15a0008 	cmp	sl, r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:210
    1514:	e59d7028 	ldr	r7, [sp, #40]	; 0x28
    1518:	e0685006 	rsb	r5, r8, r6
    151c:	e0876005 	add	r6, r7, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:211
    1520:	8a0000a5 	bhi	17bc <inflate_fast+0x618>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:240
    1524:	e1a0700c 	mov	r7, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:248 (discriminator 1)
    1528:	e35a0002 	cmp	sl, #2
    152c:	e1a04006 	mov	r4, r6
    1530:	e1a0c007 	mov	ip, r7
    1534:	9a000014 	bls	158c <inflate_fast+0x3e8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:248
    1538:	e58db030 	str	fp, [sp, #48]	; 0x30
    153c:	e3a05000 	mov	r5, #0
    1540:	e1a08006 	mov	r8, r6
    1544:	e1a0b007 	mov	fp, r7
    1548:	e58d1034 	str	r1, [sp, #52]	; 0x34
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:249
    154c:	e5d47001 	ldrb	r7, [r4, #1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:88
    1550:	e28cc003 	add	ip, ip, #3
    1554:	e2844003 	add	r4, r4, #3
    1558:	e0886005 	add	r6, r8, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:252
    155c:	e24aa003 	sub	sl, sl, #3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:88
    1560:	e08b1005 	add	r1, fp, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:249
    1564:	e54c7002 	strb	r7, [ip, #-2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:248
    1568:	e35a0002 	cmp	sl, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:250
    156c:	e5547001 	ldrb	r7, [r4, #-1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:251
    1570:	e2855003 	add	r5, r5, #3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:250
    1574:	e54c7001 	strb	r7, [ip, #-1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:251
    1578:	e5d66003 	ldrb	r6, [r6, #3]
    157c:	e5c16003 	strb	r6, [r1, #3]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:248
    1580:	8afffff1 	bhi	154c <inflate_fast+0x3a8>
    1584:	e59db030 	ldr	fp, [sp, #48]	; 0x30
    1588:	e59d1034 	ldr	r1, [sp, #52]	; 0x34
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:254
    158c:	e35a0000 	cmp	sl, #0
    1590:	0affff69 	beq	133c <inflate_fast+0x198>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:255
    1594:	e5d45001 	ldrb	r5, [r4, #1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:256
    1598:	e35a0002 	cmp	sl, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:255
    159c:	e5cc5001 	strb	r5, [ip, #1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:257
    15a0:	028cc002 	addeq	ip, ip, #2
    15a4:	05d44002 	ldrbeq	r4, [r4, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:255
    15a8:	128cc001 	addne	ip, ip, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:257
    15ac:	05cc4000 	strbeq	r4, [ip]
    15b0:	eaffff61 	b	133c <inflate_fast+0x198>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:321
    15b4:	e2044020 	and	r4, r4, #32
    15b8:	e1a0800b 	mov	r8, fp
    15bc:	e59db018 	ldr	fp, [sp, #24]
    15c0:	e6ef4074 	uxtb	r4, r4
    15c4:	e3540000 	cmp	r4, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:322
    15c8:	13a0100b 	movne	r1, #11
    15cc:	158b1000 	strne	r1, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:321
    15d0:	1affff5f 	bne	1354 <inflate_fast+0x1b0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:326
    15d4:	e59d7000 	ldr	r7, [sp]
    15d8:	e59f1234 	ldr	r1, [pc, #564]	; 1814 <inflate_fast+0x670>
    15dc:	e08f1001 	add	r1, pc, r1
    15e0:	e5871018 	str	r1, [r7, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:327
    15e4:	e3a0101b 	mov	r1, #27
    15e8:	e58b1000 	str	r1, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:328
    15ec:	eaffff58 	b	1354 <inflate_fast+0x1b0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:170
    15f0:	e5db6002 	ldrb	r6, [fp, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:169
    15f4:	e2824008 	add	r4, r2, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:168
    15f8:	e5db5001 	ldrb	r5, [fp, #1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:170
    15fc:	e28bb002 	add	fp, fp, #2
    1600:	e1a04416 	lsl	r4, r6, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:168
    1604:	e0844215 	add	r4, r4, r5, lsl r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:170
    1608:	e2822010 	add	r2, r2, #16
    160c:	e0833004 	add	r3, r3, r4
    1610:	eaffff7c 	b	1408 <inflate_fast+0x264>
    1614:	e1a0800b 	mov	r8, fp
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:312
    1618:	e59d6000 	ldr	r6, [sp]
    161c:	e59db018 	ldr	fp, [sp, #24]
    1620:	e59f11f0 	ldr	r1, [pc, #496]	; 1818 <inflate_fast+0x674>
    1624:	e08f1001 	add	r1, pc, r1
    1628:	e5861018 	str	r1, [r6, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:313
    162c:	e3a0101b 	mov	r1, #27
    1630:	e58b1000 	str	r1, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:314
    1634:	eaffff46 	b	1354 <inflate_fast+0x1b0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:267
    1638:	e31c0001 	tst	ip, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:264
    163c:	e064800c 	rsb	r8, r4, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:268
    1640:	028cc001 	addeq	ip, ip, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:269
    1644:	024aa001 	subeq	sl, sl, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:268
    1648:	05d85001 	ldrbeq	r5, [r8, #1]
    164c:	02888001 	addeq	r8, r8, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:271
    1650:	e24c7001 	sub	r7, ip, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:268
    1654:	05cc5000 	strbeq	r5, [ip]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:272
    1658:	e3540002 	cmp	r4, #2
    165c:	9a000013 	bls	16b0 <inflate_fast+0x50c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:275
    1660:	e2488001 	sub	r8, r8, #1
    1664:	e1a05007 	mov	r5, r7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:276
    1668:	e1a0c0aa 	lsr	ip, sl, #1
    166c:	e58dc030 	str	ip, [sp, #48]	; 0x30
    1670:	e1a04008 	mov	r4, r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:279 (discriminator 1)
    1674:	e1f460b2 	ldrh	r6, [r4, #2]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:283 (discriminator 1)
    1678:	e25cc001 	subs	ip, ip, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:279 (discriminator 1)
    167c:	e1e560b2 	strh	r6, [r5, #2]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:283 (discriminator 1)
    1680:	1afffffb 	bne	1674 <inflate_fast+0x4d0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:88
    1684:	e59d5030 	ldr	r5, [sp, #48]	; 0x30
    1688:	e1a04085 	lsl	r4, r5, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:284
    168c:	e087c004 	add	ip, r7, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:285
    1690:	e0888004 	add	r8, r8, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:284
    1694:	e28cc001 	add	ip, ip, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:285
    1698:	e2888001 	add	r8, r8, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:303
    169c:	e31a0001 	tst	sl, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:304
    16a0:	15d84001 	ldrbne	r4, [r8, #1]
    16a4:	128cc001 	addne	ip, ip, #1
    16a8:	15cc4000 	strbne	r4, [ip]
    16ac:	eaffff22 	b	133c <inflate_fast+0x198>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:289
    16b0:	e15c50b1 	ldrh	r5, [ip, #-1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:290
    16b4:	e3540001 	cmp	r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:297
    16b8:	e1a060aa 	lsr	r6, sl, #1
    16bc:	e1a04007 	mov	r4, r7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:294
    16c0:	01a0c425 	lsreq	ip, r5, #8
    16c4:	07c7501c 	bfieq	r5, ip, #0, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:297
    16c8:	e1a0c006 	mov	ip, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:295
    16cc:	06ff5075 	uxtheq	r5, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:300 (discriminator 1)
    16d0:	e25cc001 	subs	ip, ip, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:299 (discriminator 1)
    16d4:	e1e450b2 	strh	r5, [r4, #2]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:300 (discriminator 1)
    16d8:	1afffffc 	bne	16d0 <inflate_fast+0x52c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:301
    16dc:	e087c086 	add	ip, r7, r6, lsl #1
    16e0:	e28cc001 	add	ip, ip, #1
    16e4:	eaffffec 	b	169c <inflate_fast+0x4f8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:219
    16e8:	e59d5010 	ldr	r5, [sp, #16]
    16ec:	e1550008 	cmp	r5, r8
    16f0:	2a00001d 	bcs	176c <inflate_fast+0x5c8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:220
    16f4:	e59d702c 	ldr	r7, [sp, #44]	; 0x2c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:221
    16f8:	e0656008 	rsb	r6, r5, r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:222
    16fc:	e15a0006 	cmp	sl, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:221
    1700:	e58d6030 	str	r6, [sp, #48]	; 0x30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:220
    1704:	e0685007 	rsb	r5, r8, r7
    1708:	e59d8028 	ldr	r8, [sp, #40]	; 0x28
    170c:	e0886005 	add	r6, r8, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:222
    1710:	9affff83 	bls	1524 <inflate_fast+0x380>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:223
    1714:	e59d5030 	ldr	r5, [sp, #48]	; 0x30
    1718:	e1a08006 	mov	r8, r6
    171c:	e065a00a 	rsb	sl, r5, sl
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:88
    1720:	e0867005 	add	r7, r6, r5
    1724:	e1a0500c 	mov	r5, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:225 (discriminator 1)
    1728:	e5f86001 	ldrb	r6, [r8, #1]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:226 (discriminator 1)
    172c:	e1580007 	cmp	r8, r7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:225 (discriminator 1)
    1730:	e5e56001 	strb	r6, [r5, #1]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:226 (discriminator 1)
    1734:	1afffffb 	bne	1728 <inflate_fast+0x584>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:228
    1738:	e59d6010 	ldr	r6, [sp, #16]
    173c:	e59d8030 	ldr	r8, [sp, #48]	; 0x30
    1740:	e156000a 	cmp	r6, sl
    1744:	e08c7008 	add	r7, ip, r8
    1748:	2a000026 	bcs	17e8 <inflate_fast+0x644>
    174c:	e59dc028 	ldr	ip, [sp, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:230
    1750:	e066a00a 	rsb	sl, r6, sl
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:88
    1754:	e0876006 	add	r6, r7, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:232 (discriminator 1)
    1758:	e5fc5001 	ldrb	r5, [ip, #1]!
    175c:	e5e75001 	strb	r5, [r7, #1]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:233 (discriminator 1)
    1760:	e1570006 	cmp	r7, r6
    1764:	1afffffb 	bne	1758 <inflate_fast+0x5b4>
    1768:	ea000011 	b	17b4 <inflate_fast+0x610>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:239
    176c:	e59d6010 	ldr	r6, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:240
    1770:	e15a0008 	cmp	sl, r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:239
    1774:	e59d7028 	ldr	r7, [sp, #40]	; 0x28
    1778:	e0685006 	rsb	r5, r8, r6
    177c:	e0876005 	add	r6, r7, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:240
    1780:	9affff67 	bls	1524 <inflate_fast+0x380>
    1784:	e1a07006 	mov	r7, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:88
    1788:	e0866008 	add	r6, r6, r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:241
    178c:	e068a00a 	rsb	sl, r8, sl
    1790:	e58db030 	str	fp, [sp, #48]	; 0x30
    1794:	e1a0500c 	mov	r5, ip
    1798:	e1a0b006 	mov	fp, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:243 (discriminator 1)
    179c:	e5f76001 	ldrb	r6, [r7, #1]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:244 (discriminator 1)
    17a0:	e157000b 	cmp	r7, fp
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:243 (discriminator 1)
    17a4:	e5e56001 	strb	r6, [r5, #1]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:244 (discriminator 1)
    17a8:	1afffffb 	bne	179c <inflate_fast+0x5f8>
    17ac:	e59db030 	ldr	fp, [sp, #48]	; 0x30
    17b0:	e08c7008 	add	r7, ip, r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:245
    17b4:	e0646007 	rsb	r6, r4, r7
    17b8:	eaffff5a 	b	1528 <inflate_fast+0x384>
    17bc:	e1a07006 	mov	r7, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:88
    17c0:	e0866008 	add	r6, r6, r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:212
    17c4:	e068a00a 	rsb	sl, r8, sl
    17c8:	e58db030 	str	fp, [sp, #48]	; 0x30
    17cc:	e1a0500c 	mov	r5, ip
    17d0:	e1a0b006 	mov	fp, r6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:214 (discriminator 1)
    17d4:	e5f76001 	ldrb	r6, [r7, #1]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:215 (discriminator 1)
    17d8:	e157000b 	cmp	r7, fp
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:214 (discriminator 1)
    17dc:	e5e56001 	strb	r6, [r5, #1]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:215 (discriminator 1)
    17e0:	1afffffb 	bne	17d4 <inflate_fast+0x630>
    17e4:	eafffff0 	b	17ac <inflate_fast+0x608>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:227
    17e8:	e59d6028 	ldr	r6, [sp, #40]	; 0x28
    17ec:	eaffff4d 	b	1528 <inflate_fast+0x384>
    17f0:	e1a0800b 	mov	r8, fp
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:204
    17f4:	e59d6000 	ldr	r6, [sp]
    17f8:	e59db018 	ldr	fp, [sp, #24]
    17fc:	e59f1018 	ldr	r1, [pc, #24]	; 181c <inflate_fast+0x678>
    1800:	e08f1001 	add	r1, pc, r1
    1804:	e5861018 	str	r1, [r6, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:205
    1808:	e3a0101b 	mov	r1, #27
    180c:	e58b1000 	str	r1, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inffast.c:206
    1810:	eafffecf 	b	1354 <inflate_fast+0x1b0>
    1814:	000030a4 	.word	0x000030a4
    1818:	00003044 	.word	0x00003044
    181c:	00002e48 	.word	0x00002e48

00001820 <zlib_inflate_workspacesize>:
zlib_inflate_workspacesize():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:21
    1820:	e30a052c 	movw	r0, #42284	; 0xa52c
    1824:	e12fff1e 	bx	lr

00001828 <zlib_inflateReset>:
zlib_inflateReset():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:27
    1828:	e2501000 	subs	r1, r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:24
    182c:	e52d4004 	push	{r4}		; (str r4, [sp, #-4]!)
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:27
    1830:	0a00001d 	beq	18ac <zlib_inflateReset+0x84>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:27 (discriminator 2)
    1834:	e591301c 	ldr	r3, [r1, #28]
    1838:	e3530000 	cmp	r3, #0
    183c:	0a00001a 	beq	18ac <zlib_inflateReset+0x84>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:29
    1840:	e3a02000 	mov	r2, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:31
    1844:	e3a04001 	mov	r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:29
    1848:	e583201c 	str	r2, [r3, #28]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:38
    184c:	e283ce52 	add	ip, r3, #1312	; 0x520
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:31
    1850:	e5814028 	str	r4, [r1, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:45
    1854:	e1a00002 	mov	r0, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:29
    1858:	e5812014 	str	r2, [r1, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:38
    185c:	e28cc00c 	add	ip, ip, #12
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:29
    1860:	e5812008 	str	r2, [r1, #8]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:30
    1864:	e5812018 	str	r2, [r1, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:41
    1868:	e5931020 	ldr	r1, [r3, #32]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:32
    186c:	e5832000 	str	r2, [r3]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:41
    1870:	e1a04114 	lsl	r4, r4, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:33
    1874:	e5832004 	str	r2, [r3, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:35
    1878:	e3a01902 	mov	r1, #32768	; 0x8000
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:34
    187c:	e583200c 	str	r2, [r3, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:35
    1880:	e5831014 	str	r1, [r3, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:36
    1884:	e5832034 	str	r2, [r3, #52]	; 0x34
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:37
    1888:	e5832038 	str	r2, [r3, #56]	; 0x38
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:38
    188c:	e583c068 	str	ip, [r3, #104]	; 0x68
    1890:	e583c04c 	str	ip, [r3, #76]	; 0x4c
    1894:	e583c048 	str	ip, [r3, #72]	; 0x48
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:41
    1898:	e5834024 	str	r4, [r3, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:42
    189c:	e583202c 	str	r2, [r3, #44]	; 0x2c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:43
    18a0:	e5832028 	str	r2, [r3, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:46
    18a4:	e8bd0010 	ldmfd	sp!, {r4}
    18a8:	e12fff1e 	bx	lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:27
    18ac:	e3e00001 	mvn	r0, #1
    18b0:	eafffffb 	b	18a4 <zlib_inflateReset+0x7c>

000018b4 <zlib_inflateInit2>:
zlib_inflateInit2():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:52
    18b4:	e2503000 	subs	r3, r0, #0
    18b8:	0a000013 	beq	190c <zlib_inflateInit2+0x58>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:55
    18bc:	e5932020 	ldr	r2, [r3, #32]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:58
    18c0:	e3510000 	cmp	r1, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:53
    18c4:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:60
    18c8:	b2611000 	rsblt	r1, r1, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:53
    18cc:	e5830018 	str	r0, [r3, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:63
    18d0:	a1a00241 	asrge	r0, r1, #4
    18d4:	a2800001 	addge	r0, r0, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:56
    18d8:	e583201c 	str	r2, [r3, #28]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:59
    18dc:	b5820008 	strlt	r0, [r2, #8]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:63
    18e0:	a5820008 	strge	r0, [r2, #8]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:65
    18e4:	e2410008 	sub	r0, r1, #8
    18e8:	e3500007 	cmp	r0, #7
    18ec:	8a000006 	bhi	190c <zlib_inflateInit2+0x58>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:68
    18f0:	e5821020 	str	r1, [r2, #32]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:71
    18f4:	e1a00003 	mov	r0, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:69
    18f8:	e5933020 	ldr	r3, [r3, #32]
    18fc:	e2833c25 	add	r3, r3, #9472	; 0x2500
    1900:	e283302c 	add	r3, r3, #44	; 0x2c
    1904:	e5823030 	str	r3, [r2, #48]	; 0x30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:71
    1908:	eaffffc6 	b	1828 <zlib_inflateReset>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:72
    190c:	e3e00001 	mvn	r0, #1
    1910:	e12fff1e 	bx	lr

00001914 <zlib_inflate>:
zlib_inflate():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:318
    1914:	e92d4ff0 	push	{r4, r5, r6, r7, r8, r9, sl, fp, lr}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:338
    1918:	e250b000 	subs	fp, r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:318
    191c:	e24dd04c 	sub	sp, sp, #76	; 0x4c
    1920:	e58d102c 	str	r1, [sp, #44]	; 0x2c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:338
    1924:	0a00044e 	beq	2a64 <zlib_inflate+0x1150>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:338 (discriminator 1)
    1928:	e59ba01c 	ldr	sl, [fp, #28]
    192c:	e35a0000 	cmp	sl, #0
    1930:	0a00044b 	beq	2a64 <zlib_inflate+0x1150>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:339 (discriminator 1)
    1934:	e59b5000 	ldr	r5, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:338 (discriminator 1)
    1938:	e3550000 	cmp	r5, #0
    193c:	0a000445 	beq	2a58 <zlib_inflate+0x1144>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:344
    1940:	e59a3000 	ldr	r3, [sl]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:348
    1944:	e3a0c000 	mov	ip, #0
    1948:	e58dc010 	str	ip, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:344
    194c:	e353000b 	cmp	r3, #11
zlib_fixedtables():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:81
    1950:	e59fcdc4 	ldr	ip, [pc, #3524]	; 271c <zlib_inflate+0xe08>
zlib_inflate():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317
    1954:	e59f2dc4 	ldr	r2, [pc, #3524]	; 2720 <zlib_inflate+0xe0c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:344
    1958:	03a0300c 	moveq	r3, #12
    195c:	058a3000 	streq	r3, [sl]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:345
    1960:	e59b4010 	ldr	r4, [fp, #16]
zlib_fixedtables():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:81
    1964:	e08fc00c 	add	ip, pc, ip
    1968:	e58dc018 	str	ip, [sp, #24]
zlib_inflate():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317
    196c:	e08f2002 	add	r2, pc, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:345
    1970:	e59bc00c 	ldr	ip, [fp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317
    1974:	e2822d26 	add	r2, r2, #2432	; 0x980
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:345
    1978:	e58d400c 	str	r4, [sp, #12]
    197c:	e59b4004 	ldr	r4, [fp, #4]
    1980:	059b5000 	ldreq	r5, [fp]
    1984:	e58dc028 	str	ip, [sp, #40]	; 0x28
    1988:	e58d4024 	str	r4, [sp, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:347
    198c:	e59d400c 	ldr	r4, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:345
    1990:	e59d8024 	ldr	r8, [sp, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:457
    1994:	e59fcd88 	ldr	ip, [pc, #3464]	; 2724 <zlib_inflate+0xe10>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:347
    1998:	e58d4020 	str	r4, [sp, #32]
zlib_fixedtables():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:81
    199c:	e59d4018 	ldr	r4, [sp, #24]
zlib_inflate():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:457
    19a0:	e08fc00c 	add	ip, pc, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:345
    19a4:	e59a7034 	ldr	r7, [sl, #52]	; 0x34
    19a8:	e59a9038 	ldr	r9, [sl, #56]	; 0x38
zlib_fixedtables():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:81
    19ac:	e2844c01 	add	r4, r4, #256	; 0x100
    19b0:	e58db014 	str	fp, [sp, #20]
    19b4:	e1a0b00a 	mov	fp, sl
    19b8:	e1a0a005 	mov	sl, r5
    19bc:	e58d4034 	str	r4, [sp, #52]	; 0x34
zlib_inflate():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317
    19c0:	e58d201c 	str	r2, [sp, #28]
    19c4:	e2824024 	add	r4, r2, #36	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:457
    19c8:	e58dc030 	str	ip, [sp, #48]	; 0x30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317
    19cc:	e58d4038 	str	r4, [sp, #56]	; 0x38
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:350
    19d0:	e353001c 	cmp	r3, #28
    19d4:	908ff103 	addls	pc, pc, r3, lsl #2
    19d8:	ea0001b5 	b	20b4 <zlib_inflate+0x7a0>
    19dc:	ea0001b9 	b	20c8 <zlib_inflate+0x7b4>
    19e0:	ea0001b3 	b	20b4 <zlib_inflate+0x7a0>
    19e4:	ea0001b2 	b	20b4 <zlib_inflate+0x7a0>
    19e8:	ea0001b1 	b	20b4 <zlib_inflate+0x7a0>
    19ec:	ea0001b0 	b	20b4 <zlib_inflate+0x7a0>
    19f0:	ea0001af 	b	20b4 <zlib_inflate+0x7a0>
    19f4:	ea0001ae 	b	20b4 <zlib_inflate+0x7a0>
    19f8:	ea0001ad 	b	20b4 <zlib_inflate+0x7a0>
    19fc:	ea0001ac 	b	20b4 <zlib_inflate+0x7a0>
    1a00:	ea000012 	b	1a50 <zlib_inflate+0x13c>
    1a04:	ea00002e 	b	1ac4 <zlib_inflate+0x1b0>
    1a08:	ea000036 	b	1ae8 <zlib_inflate+0x1d4>
    1a0c:	ea000038 	b	1af4 <zlib_inflate+0x1e0>
    1a10:	ea000104 	b	1e28 <zlib_inflate+0x514>
    1a14:	ea000123 	b	1ea8 <zlib_inflate+0x594>
    1a18:	ea00013d 	b	1f14 <zlib_inflate+0x600>
    1a1c:	ea000161 	b	1fa8 <zlib_inflate+0x694>
    1a20:	ea0002a2 	b	24b0 <zlib_inflate+0xb9c>
    1a24:	ea0002d1 	b	2570 <zlib_inflate+0xc5c>
    1a28:	ea000051 	b	1b74 <zlib_inflate+0x260>
    1a2c:	ea00006b 	b	1be0 <zlib_inflate+0x2cc>
    1a30:	ea0000c3 	b	1d44 <zlib_inflate+0x430>
    1a34:	ea0000cf 	b	1d78 <zlib_inflate+0x464>
    1a38:	ea00028e 	b	2478 <zlib_inflate+0xb64>
    1a3c:	ea00032d 	b	26f8 <zlib_inflate+0xde4>
    1a40:	ea00019b 	b	20b4 <zlib_inflate+0x7a0>
    1a44:	ea0001c5 	b	2160 <zlib_inflate+0x84c>
    1a48:	ea000281 	b	2454 <zlib_inflate+0xb40>
    1a4c:	ea000326 	b	26ec <zlib_inflate+0xdd8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:381 (discriminator 1)
    1a50:	e359001f 	cmp	r9, #31
    1a54:	8a00000c 	bhi	1a8c <zlib_inflate+0x178>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:381
    1a58:	e3580000 	cmp	r8, #0
    1a5c:	0a0003f0 	beq	2a24 <zlib_inflate+0x1110>
    1a60:	e1a0300a 	mov	r3, sl
    1a64:	ea000001 	b	1a70 <zlib_inflate+0x15c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:381 (discriminator 3)
    1a68:	e3580000 	cmp	r8, #0
    1a6c:	0a0003d2 	beq	29bc <zlib_inflate+0x10a8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:381 (discriminator 2)
    1a70:	e4d32001 	ldrb	r2, [r3], #1
    1a74:	e2488001 	sub	r8, r8, #1
    1a78:	e0877912 	add	r7, r7, r2, lsl r9
    1a7c:	e2899008 	add	r9, r9, #8
    1a80:	e359001f 	cmp	r9, #31
    1a84:	e1a0a003 	mov	sl, r3
    1a88:	9afffff6 	bls	1a68 <zlib_inflate+0x154>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:382
    1a8c:	e1a01c27 	lsr	r1, r7, #24
    1a90:	e1a03427 	lsr	r3, r7, #8
    1a94:	e59dc014 	ldr	ip, [sp, #20]
    1a98:	e0811c07 	add	r1, r1, r7, lsl #24
    1a9c:	e2072cff 	and	r2, r7, #65280	; 0xff00
    1aa0:	e2033cff 	and	r3, r3, #65280	; 0xff00
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:383
    1aa4:	e3a07000 	mov	r7, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:382
    1aa8:	e0813003 	add	r3, r1, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:383
    1aac:	e1a09007 	mov	r9, r7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:382
    1ab0:	e0833402 	add	r3, r3, r2, lsl #8
    1ab4:	e58b3018 	str	r3, [fp, #24]
    1ab8:	e58c3028 	str	r3, [ip, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:384
    1abc:	e3a0300a 	mov	r3, #10
    1ac0:	e58b3000 	str	r3, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:386
    1ac4:	e59b300c 	ldr	r3, [fp, #12]
    1ac8:	e3530000 	cmp	r3, #0
    1acc:	0a000531 	beq	2f98 <zlib_inflate+0x1684>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:390
    1ad0:	e59dc014 	ldr	ip, [sp, #20]
    1ad4:	e3a03001 	mov	r3, #1
    1ad8:	e58b3018 	str	r3, [fp, #24]
    1adc:	e58c3028 	str	r3, [ip, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:391
    1ae0:	e3a0300b 	mov	r3, #11
    1ae4:	e58b3000 	str	r3, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:393
    1ae8:	e59d402c 	ldr	r4, [sp, #44]	; 0x2c
    1aec:	e3540006 	cmp	r4, #6
    1af0:	0a000416 	beq	2b50 <zlib_inflate+0x123c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:395
    1af4:	e59b3004 	ldr	r3, [fp, #4]
    1af8:	e3530000 	cmp	r3, #0
    1afc:	1a000016 	bne	1b5c <zlib_inflate+0x248>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:400 (discriminator 1)
    1b00:	e3590002 	cmp	r9, #2
    1b04:	8a000005 	bhi	1b20 <zlib_inflate+0x20c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:400
    1b08:	e3580000 	cmp	r8, #0
    1b0c:	0a0004ac 	beq	2dc4 <zlib_inflate+0x14b0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:400 (discriminator 2)
    1b10:	e4da3001 	ldrb	r3, [sl], #1
    1b14:	e2488001 	sub	r8, r8, #1
    1b18:	e0877913 	add	r7, r7, r3, lsl r9
    1b1c:	e2899008 	add	r9, r9, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:402
    1b20:	e1a020a7 	lsr	r2, r7, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:401
    1b24:	e2077001 	and	r7, r7, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:403
    1b28:	e2023003 	and	r3, r2, #3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:401
    1b2c:	e58b7004 	str	r7, [fp, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:403
    1b30:	e3530002 	cmp	r3, #2
    1b34:	0a00046f 	beq	2cf8 <zlib_inflate+0x13e4>
    1b38:	e3530003 	cmp	r3, #3
    1b3c:	0a0003fb 	beq	2b30 <zlib_inflate+0x121c>
    1b40:	e3530001 	cmp	r3, #1
    1b44:	0a000458 	beq	2cac <zlib_inflate+0x1398>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:405
    1b48:	e3a0300d 	mov	r3, #13
    1b4c:	e58b3000 	str	r3, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:418
    1b50:	e1a07122 	lsr	r7, r2, #2
    1b54:	e2499003 	sub	r9, r9, #3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:419
    1b58:	eaffff9c 	b	19d0 <zlib_inflate+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:396
    1b5c:	e2092007 	and	r2, r9, #7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:397
    1b60:	e3a03018 	mov	r3, #24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:396
    1b64:	e1a07237 	lsr	r7, r7, r2
    1b68:	e3c99007 	bic	r9, r9, #7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:397
    1b6c:	e58b3000 	str	r3, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:398
    1b70:	eaffff96 	b	19d0 <zlib_inflate+0xbc>
    1b74:	e59b1044 	ldr	r1, [fp, #68]	; 0x44
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:597
    1b78:	e3510000 	cmp	r1, #0
    1b7c:	0a000015 	beq	1bd8 <zlib_inflate+0x2c4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:598 (discriminator 1)
    1b80:	e1590001 	cmp	r9, r1
    1b84:	2a00000c 	bcs	1bbc <zlib_inflate+0x2a8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:598
    1b88:	e3580000 	cmp	r8, #0
    1b8c:	0a00038a 	beq	29bc <zlib_inflate+0x10a8>
    1b90:	e1a0300a 	mov	r3, sl
    1b94:	ea000001 	b	1ba0 <zlib_inflate+0x28c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:598 (discriminator 3)
    1b98:	e3580000 	cmp	r8, #0
    1b9c:	0a0003a0 	beq	2a24 <zlib_inflate+0x1110>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:598 (discriminator 2)
    1ba0:	e4d32001 	ldrb	r2, [r3], #1
    1ba4:	e2488001 	sub	r8, r8, #1
    1ba8:	e0877912 	add	r7, r7, r2, lsl r9
    1bac:	e2899008 	add	r9, r9, #8
    1bb0:	e1590001 	cmp	r9, r1
    1bb4:	e1a0a003 	mov	sl, r3
    1bb8:	3afffff6 	bcc	1b98 <zlib_inflate+0x284>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:599
    1bbc:	e3e03000 	mvn	r3, #0
    1bc0:	e59b203c 	ldr	r2, [fp, #60]	; 0x3c
    1bc4:	e1c73113 	bic	r3, r7, r3, lsl r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:600
    1bc8:	e0619009 	rsb	r9, r1, r9
    1bcc:	e1a07137 	lsr	r7, r7, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:599
    1bd0:	e0823003 	add	r3, r2, r3
    1bd4:	e58b303c 	str	r3, [fp, #60]	; 0x3c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:602
    1bd8:	e3a03014 	mov	r3, #20
    1bdc:	e58b3000 	str	r3, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:605
    1be0:	e59b3054 	ldr	r3, [fp, #84]	; 0x54
    1be4:	e3e05000 	mvn	r5, #0
    1be8:	e59b204c 	ldr	r2, [fp, #76]	; 0x4c
    1bec:	e1e05315 	mvn	r5, r5, lsl r3
    1bf0:	e0073005 	and	r3, r7, r5
    1bf4:	e0820103 	add	r0, r2, r3, lsl #2
    1bf8:	e7d21103 	ldrb	r1, [r2, r3, lsl #2]
    1bfc:	e5d03001 	ldrb	r3, [r0, #1]
    1c00:	e1d000b2 	ldrh	r0, [r0, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:606
    1c04:	e1590003 	cmp	r9, r3
    1c08:	e1a0c003 	mov	ip, r3
    1c0c:	2a000012 	bcs	1c5c <zlib_inflate+0x348>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:607
    1c10:	e3580000 	cmp	r8, #0
    1c14:	0a000382 	beq	2a24 <zlib_inflate+0x1110>
    1c18:	e1a0400a 	mov	r4, sl
    1c1c:	ea000001 	b	1c28 <zlib_inflate+0x314>
    1c20:	e3580000 	cmp	r8, #0
    1c24:	0a00037e 	beq	2a24 <zlib_inflate+0x1110>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:607 (discriminator 1)
    1c28:	e4d43001 	ldrb	r3, [r4], #1
    1c2c:	e2488001 	sub	r8, r8, #1
    1c30:	e0877913 	add	r7, r7, r3, lsl r9
    1c34:	e2899008 	add	r9, r9, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:605 (discriminator 1)
    1c38:	e0073005 	and	r3, r7, r5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:607 (discriminator 1)
    1c3c:	e1a0a004 	mov	sl, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:605 (discriminator 1)
    1c40:	e0820103 	add	r0, r2, r3, lsl #2
    1c44:	e7d21103 	ldrb	r1, [r2, r3, lsl #2]
    1c48:	e5d03001 	ldrb	r3, [r0, #1]
    1c4c:	e1d000b2 	ldrh	r0, [r0, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:606 (discriminator 1)
    1c50:	e1530009 	cmp	r3, r9
    1c54:	e1a0c003 	mov	ip, r3
    1c58:	8afffff0 	bhi	1c20 <zlib_inflate+0x30c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:609
    1c5c:	e31100f0 	tst	r1, #240	; 0xf0
    1c60:	1a000029 	bne	1d0c <zlib_inflate+0x3f8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:613
    1c64:	e0831001 	add	r1, r3, r1
    1c68:	e1a05003 	mov	r5, r3
    1c6c:	e3e03000 	mvn	r3, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:612
    1c70:	e1a06000 	mov	r6, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:613
    1c74:	e1e03113 	mvn	r3, r3, lsl r1
    1c78:	e58d303c 	str	r3, [sp, #60]	; 0x3c
    1c7c:	e0033007 	and	r3, r3, r7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:612
    1c80:	e0803533 	add	r3, r0, r3, lsr r5
    1c84:	e0820103 	add	r0, r2, r3, lsl #2
    1c88:	e7d21103 	ldrb	r1, [r2, r3, lsl #2]
    1c8c:	e5d03001 	ldrb	r3, [r0, #1]
    1c90:	e1d000b2 	ldrh	r0, [r0, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:614
    1c94:	e0854003 	add	r4, r5, r3
    1c98:	e1590004 	cmp	r9, r4
    1c9c:	2a000018 	bcs	1d04 <zlib_inflate+0x3f0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:615
    1ca0:	e3580000 	cmp	r8, #0
    1ca4:	0a00035e 	beq	2a24 <zlib_inflate+0x1110>
    1ca8:	e58db040 	str	fp, [sp, #64]	; 0x40
    1cac:	e1a0400a 	mov	r4, sl
    1cb0:	e58dc044 	str	ip, [sp, #68]	; 0x44
    1cb4:	e59db03c 	ldr	fp, [sp, #60]	; 0x3c
    1cb8:	ea000001 	b	1cc4 <zlib_inflate+0x3b0>
    1cbc:	e3580000 	cmp	r8, #0
    1cc0:	0a0003f6 	beq	2ca0 <zlib_inflate+0x138c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:615 (discriminator 1)
    1cc4:	e4d43001 	ldrb	r3, [r4], #1
    1cc8:	e2488001 	sub	r8, r8, #1
    1ccc:	e0877913 	add	r7, r7, r3, lsl r9
    1cd0:	e2899008 	add	r9, r9, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:613 (discriminator 1)
    1cd4:	e007300b 	and	r3, r7, fp
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:615 (discriminator 1)
    1cd8:	e1a0a004 	mov	sl, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:612 (discriminator 1)
    1cdc:	e0863533 	add	r3, r6, r3, lsr r5
    1ce0:	e0820103 	add	r0, r2, r3, lsl #2
    1ce4:	e7d21103 	ldrb	r1, [r2, r3, lsl #2]
    1ce8:	e5d03001 	ldrb	r3, [r0, #1]
    1cec:	e1d000b2 	ldrh	r0, [r0, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:614 (discriminator 1)
    1cf0:	e083c005 	add	ip, r3, r5
    1cf4:	e15c0009 	cmp	ip, r9
    1cf8:	8affffef 	bhi	1cbc <zlib_inflate+0x3a8>
    1cfc:	e59db040 	ldr	fp, [sp, #64]	; 0x40
    1d00:	e59dc044 	ldr	ip, [sp, #68]	; 0x44
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:617
    1d04:	e1a07537 	lsr	r7, r7, r5
    1d08:	e06c9009 	rsb	r9, ip, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:620
    1d0c:	e2012040 	and	r2, r1, #64	; 0x40
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:619
    1d10:	e1a07337 	lsr	r7, r7, r3
    1d14:	e0639009 	rsb	r9, r3, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:620
    1d18:	e6ef3072 	uxtb	r3, r2
    1d1c:	e3530000 	cmp	r3, #0
    1d20:	0a00037c 	beq	2b18 <zlib_inflate+0x1204>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:621
    1d24:	e59dc014 	ldr	ip, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:622
    1d28:	e3a0201b 	mov	r2, #27
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:621
    1d2c:	e59f19f4 	ldr	r1, [pc, #2548]	; 2728 <zlib_inflate+0xe14>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:623
    1d30:	e1a03002 	mov	r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:621
    1d34:	e08f1001 	add	r1, pc, r1
    1d38:	e58c1018 	str	r1, [ip, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:622
    1d3c:	e58b2000 	str	r2, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:623
    1d40:	eaffff22 	b	19d0 <zlib_inflate+0xbc>
    1d44:	e59b1044 	ldr	r1, [fp, #68]	; 0x44
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:629
    1d48:	e3510000 	cmp	r1, #0
    1d4c:	1a00034f 	bne	2a90 <zlib_inflate+0x117c>
    1d50:	e59b3040 	ldr	r3, [fp, #64]	; 0x40
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:641
    1d54:	e59b2028 	ldr	r2, [fp, #40]	; 0x28
    1d58:	e59dc020 	ldr	ip, [sp, #32]
    1d5c:	e59d400c 	ldr	r4, [sp, #12]
    1d60:	e08c2002 	add	r2, ip, r2
    1d64:	e0642002 	rsb	r2, r4, r2
    1d68:	e1520003 	cmp	r2, r3
    1d6c:	3a00035e 	bcc	2aec <zlib_inflate+0x11d8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:646
    1d70:	e3a03016 	mov	r3, #22
    1d74:	e58b3000 	str	r3, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:648
    1d78:	e59d400c 	ldr	r4, [sp, #12]
    1d7c:	e3540000 	cmp	r4, #0
    1d80:	0a000327 	beq	2a24 <zlib_inflate+0x1110>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:649
    1d84:	e59dc020 	ldr	ip, [sp, #32]
    1d88:	e59d400c 	ldr	r4, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:650
    1d8c:	e59b3040 	ldr	r3, [fp, #64]	; 0x40
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:649
    1d90:	e064200c 	rsb	r2, r4, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:650
    1d94:	e1520003 	cmp	r2, r3
    1d98:	2a000334 	bcs	2a70 <zlib_inflate+0x115c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:652
    1d9c:	e59b102c 	ldr	r1, [fp, #44]	; 0x2c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:651
    1da0:	e0622003 	rsb	r2, r2, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:658
    1da4:	e59b003c 	ldr	r0, [fp, #60]	; 0x3c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:652
    1da8:	e1520001 	cmp	r2, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:653
    1dac:	80612002 	rsbhi	r2, r1, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:657
    1db0:	90621001 	rsbls	r1, r2, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:654
    1db4:	859b3024 	ldrhi	r3, [fp, #36]	; 0x24
    1db8:	859b1030 	ldrhi	r1, [fp, #48]	; 0x30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:657
    1dbc:	959b3030 	ldrls	r3, [fp, #48]	; 0x30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:654
    1dc0:	80623003 	rsbhi	r3, r2, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:658
    1dc4:	e1520000 	cmp	r2, r0
    1dc8:	21a02000 	movcs	r2, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:657
    1dcc:	e0833001 	add	r3, r3, r1
    1dd0:	e59d400c 	ldr	r4, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317
    1dd4:	e2433001 	sub	r3, r3, #1
    1dd8:	e59dc028 	ldr	ip, [sp, #40]	; 0x28
    1ddc:	e1520004 	cmp	r2, r4
    1de0:	21a02004 	movcs	r2, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:665
    1de4:	e0624004 	rsb	r4, r2, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317
    1de8:	e08c1002 	add	r1, ip, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:666
    1dec:	e0622000 	rsb	r2, r2, r0
    1df0:	e58b203c 	str	r2, [fp, #60]	; 0x3c
    1df4:	e1a0200c 	mov	r2, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:665
    1df8:	e58d400c 	str	r4, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:668 (discriminator 1)
    1dfc:	e5f30001 	ldrb	r0, [r3, #1]!
    1e00:	e4c20001 	strb	r0, [r2], #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:669 (discriminator 1)
    1e04:	e1520001 	cmp	r2, r1
    1e08:	1afffffb 	bne	1dfc <zlib_inflate+0x4e8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:670
    1e0c:	e59b303c 	ldr	r3, [fp, #60]	; 0x3c
    1e10:	e58d2028 	str	r2, [sp, #40]	; 0x28
    1e14:	e3530000 	cmp	r3, #0
    1e18:	03a03012 	moveq	r3, #18
    1e1c:	159b3000 	ldrne	r3, [fp]
    1e20:	058b3000 	streq	r3, [fp]
    1e24:	eafffee9 	b	19d0 <zlib_inflate+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:421
    1e28:	e2093007 	and	r3, r9, #7
    1e2c:	e3c99007 	bic	r9, r9, #7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:422
    1e30:	e359001f 	cmp	r9, #31
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:421
    1e34:	e1a07337 	lsr	r7, r7, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:422
    1e38:	8a00000c 	bhi	1e70 <zlib_inflate+0x55c>
    1e3c:	e3580000 	cmp	r8, #0
    1e40:	0a0002dd 	beq	29bc <zlib_inflate+0x10a8>
    1e44:	e1a0300a 	mov	r3, sl
    1e48:	ea000001 	b	1e54 <zlib_inflate+0x540>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:422 (discriminator 3)
    1e4c:	e3580000 	cmp	r8, #0
    1e50:	0a0002f3 	beq	2a24 <zlib_inflate+0x1110>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:422 (discriminator 2)
    1e54:	e4d32001 	ldrb	r2, [r3], #1
    1e58:	e2488001 	sub	r8, r8, #1
    1e5c:	e0877912 	add	r7, r7, r2, lsl r9
    1e60:	e2899008 	add	r9, r9, #8
    1e64:	e359001f 	cmp	r9, #31
    1e68:	e1a0a003 	mov	sl, r3
    1e6c:	9afffff6 	bls	1e4c <zlib_inflate+0x538>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:423
    1e70:	e1a02827 	lsr	r2, r7, #16
    1e74:	e6ff3077 	uxth	r3, r7
    1e78:	e2222cff 	eor	r2, r2, #65280	; 0xff00
    1e7c:	e22220ff 	eor	r2, r2, #255	; 0xff
    1e80:	e1530002 	cmp	r3, r2
    1e84:	0a00039e 	beq	2d04 <zlib_inflate+0x13f0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:424
    1e88:	e59dc014 	ldr	ip, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:425
    1e8c:	e3a0201b 	mov	r2, #27
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:424
    1e90:	e59f1894 	ldr	r1, [pc, #2196]	; 272c <zlib_inflate+0xe18>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:426
    1e94:	e1a03002 	mov	r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:424
    1e98:	e08f1001 	add	r1, pc, r1
    1e9c:	e58c1018 	str	r1, [ip, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:425
    1ea0:	e58b2000 	str	r2, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:426
    1ea4:	eafffec9 	b	19d0 <zlib_inflate+0xbc>
    1ea8:	e59b303c 	ldr	r3, [fp, #60]	; 0x3c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:433
    1eac:	e3530000 	cmp	r3, #0
    1eb0:	0a0002f3 	beq	2a84 <zlib_inflate+0x1170>
    1eb4:	e59d400c 	ldr	r4, [sp, #12]
    1eb8:	e1580003 	cmp	r8, r3
    1ebc:	31a03008 	movcc	r3, r8
    1ec0:	e1530004 	cmp	r3, r4
    1ec4:	31a04003 	movcc	r4, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:436
    1ec8:	e3540000 	cmp	r4, #0
    1ecc:	0a0002ba 	beq	29bc <zlib_inflate+0x10a8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:437
    1ed0:	e1a0100a 	mov	r1, sl
    1ed4:	e59d0028 	ldr	r0, [sp, #40]	; 0x28
    1ed8:	e1a02004 	mov	r2, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:438
    1edc:	e0648008 	rsb	r8, r4, r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:437
    1ee0:	eb0005cb 	bl	3614 <memcpy>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:440
    1ee4:	e59dc00c 	ldr	ip, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:442
    1ee8:	e59b303c 	ldr	r3, [fp, #60]	; 0x3c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:439
    1eec:	e08aa004 	add	sl, sl, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:440
    1ef0:	e064c00c 	rsb	ip, r4, ip
    1ef4:	e58dc00c 	str	ip, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:441
    1ef8:	e59dc028 	ldr	ip, [sp, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:442
    1efc:	e0643003 	rsb	r3, r4, r3
    1f00:	e58b303c 	str	r3, [fp, #60]	; 0x3c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:441
    1f04:	e08cc004 	add	ip, ip, r4
    1f08:	e59b3000 	ldr	r3, [fp]
    1f0c:	e58dc028 	str	ip, [sp, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:443
    1f10:	eafffeae 	b	19d0 <zlib_inflate+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:448 (discriminator 1)
    1f14:	e359000d 	cmp	r9, #13
    1f18:	8a00000c 	bhi	1f50 <zlib_inflate+0x63c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:448
    1f1c:	e3580000 	cmp	r8, #0
    1f20:	0a0002a5 	beq	29bc <zlib_inflate+0x10a8>
    1f24:	e1a0300a 	mov	r3, sl
    1f28:	ea000001 	b	1f34 <zlib_inflate+0x620>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:448 (discriminator 3)
    1f2c:	e3580000 	cmp	r8, #0
    1f30:	0a0002a1 	beq	29bc <zlib_inflate+0x10a8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:448 (discriminator 2)
    1f34:	e4d32001 	ldrb	r2, [r3], #1
    1f38:	e2488001 	sub	r8, r8, #1
    1f3c:	e0877912 	add	r7, r7, r2, lsl r9
    1f40:	e2899008 	add	r9, r9, #8
    1f44:	e359000d 	cmp	r9, #13
    1f48:	e1a0a003 	mov	sl, r3
    1f4c:	9afffff6 	bls	1f2c <zlib_inflate+0x618>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:449
    1f50:	e207301f 	and	r3, r7, #31
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:456
    1f54:	e300011e 	movw	r0, #286	; 0x11e
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:449
    1f58:	e2833c01 	add	r3, r3, #256	; 0x100
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:451
    1f5c:	e7e422d7 	ubfx	r2, r7, #5, #5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:449
    1f60:	e2833001 	add	r3, r3, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:453
    1f64:	e7e31557 	ubfx	r1, r7, #10, #4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:456
    1f68:	e1530000 	cmp	r3, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:451
    1f6c:	e2822001 	add	r2, r2, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:453
    1f70:	e2811004 	add	r1, r1, #4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:449
    1f74:	e58b305c 	str	r3, [fp, #92]	; 0x5c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:451
    1f78:	e58b2060 	str	r2, [fp, #96]	; 0x60
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:454
    1f7c:	e1a07727 	lsr	r7, r7, #14
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:453
    1f80:	e58b1058 	str	r1, [fp, #88]	; 0x58
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:454
    1f84:	e249900e 	sub	r9, r9, #14
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:456
    1f88:	8a0002fa 	bhi	2b78 <zlib_inflate+0x1264>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:456 (discriminator 1)
    1f8c:	e352001e 	cmp	r2, #30
    1f90:	8a0002f8 	bhi	2b78 <zlib_inflate+0x1264>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:462
    1f94:	e3a03000 	mov	r3, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:463
    1f98:	e3a02010 	mov	r2, #16
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:462
    1f9c:	e58b3064 	str	r3, [fp, #100]	; 0x64
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:463
    1fa0:	e58b2000 	str	r2, [fp]
    1fa4:	ea000003 	b	1fb8 <zlib_inflate+0x6a4>
    1fa8:	e59b1058 	ldr	r1, [fp, #88]	; 0x58
    1fac:	e59b3064 	ldr	r3, [fp, #100]	; 0x64
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:465
    1fb0:	e1510003 	cmp	r1, r3
    1fb4:	9a000016 	bls	2014 <zlib_inflate+0x700>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317 (discriminator 1)
    1fb8:	e59f2770 	ldr	r2, [pc, #1904]	; 2730 <zlib_inflate+0xe1c>
    1fbc:	e08f2002 	add	r2, pc, r2
    1fc0:	e0822083 	add	r2, r2, r3, lsl #1
    1fc4:	e2822e97 	add	r2, r2, #2416	; 0x970
    1fc8:	e282200e 	add	r2, r2, #14
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:466 (discriminator 1)
    1fcc:	e3590002 	cmp	r9, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:467 (discriminator 1)
    1fd0:	e2833001 	add	r3, r3, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:466 (discriminator 1)
    1fd4:	8a000005 	bhi	1ff0 <zlib_inflate+0x6dc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:466
    1fd8:	e3580000 	cmp	r8, #0
    1fdc:	0a000290 	beq	2a24 <zlib_inflate+0x1110>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:466 (discriminator 2)
    1fe0:	e4da0001 	ldrb	r0, [sl], #1
    1fe4:	e2488001 	sub	r8, r8, #1
    1fe8:	e0877910 	add	r7, r7, r0, lsl r9
    1fec:	e2899008 	add	r9, r9, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:467
    1ff0:	e1f200b2 	ldrh	r0, [r2, #2]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:465
    1ff4:	e1530001 	cmp	r3, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:467
    1ff8:	e207c007 	and	ip, r7, #7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:468
    1ffc:	e2499003 	sub	r9, r9, #3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:467
    2000:	e1a071a7 	lsr	r7, r7, #3
    2004:	e08b0080 	add	r0, fp, r0, lsl #1
    2008:	e1c0c6bc 	strh	ip, [r0, #108]	; 0x6c
    200c:	e58b3064 	str	r3, [fp, #100]	; 0x64
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:465
    2010:	3affffed 	bcc	1fcc <zlib_inflate+0x6b8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:470 (discriminator 1)
    2014:	e3530012 	cmp	r3, #18
    2018:	8a00000c 	bhi	2050 <zlib_inflate+0x73c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317
    201c:	e2433001 	sub	r3, r3, #1
    2020:	e59dc01c 	ldr	ip, [sp, #28]
    2024:	e59d0038 	ldr	r0, [sp, #56]	; 0x38
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:471
    2028:	e3a01000 	mov	r1, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317
    202c:	e08c3083 	add	r3, ip, r3, lsl #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:471
    2030:	e1f320b2 	ldrh	r2, [r3, #2]!
    2034:	e2822034 	add	r2, r2, #52	; 0x34
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:470
    2038:	e1530000 	cmp	r3, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:471
    203c:	e08b2082 	add	r2, fp, r2, lsl #1
    2040:	e1c210b4 	strh	r1, [r2, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:470
    2044:	1afffff9 	bne	2030 <zlib_inflate+0x71c>
    2048:	e3a03013 	mov	r3, #19
    204c:	e58b3064 	str	r3, [fp, #100]	; 0x64
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:472
    2050:	e28b3e52 	add	r3, fp, #1312	; 0x520
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:474
    2054:	e3a02007 	mov	r2, #7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:472
    2058:	e283300c 	add	r3, r3, #12
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:474
    205c:	e58b2050 	str	r2, [fp, #80]	; 0x50
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:472
    2060:	e58b3068 	str	r3, [fp, #104]	; 0x68
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:475
    2064:	e28b2050 	add	r2, fp, #80	; 0x50
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:473
    2068:	e58b3048 	str	r3, [fp, #72]	; 0x48
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:475
    206c:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:476
    2070:	e28b3fbb 	add	r3, fp, #748	; 0x2ec
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:475
    2074:	e88d000c 	stm	sp, {r2, r3}
    2078:	e28b106c 	add	r1, fp, #108	; 0x6c
    207c:	e3a02013 	mov	r2, #19
    2080:	e28b3068 	add	r3, fp, #104	; 0x68
    2084:	ebfffae3 	bl	c18 <zlib_inflate_table>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:477
    2088:	e3500000 	cmp	r0, #0
    208c:	e58d0010 	str	r0, [sp, #16]
    2090:	0a000386 	beq	2eb0 <zlib_inflate+0x159c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:478
    2094:	e59d4014 	ldr	r4, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:479
    2098:	e3a0201b 	mov	r2, #27
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:478
    209c:	e59f1690 	ldr	r1, [pc, #1680]	; 2734 <zlib_inflate+0xe20>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:480
    20a0:	e1a03002 	mov	r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:478
    20a4:	e08f1001 	add	r1, pc, r1
    20a8:	e5841018 	str	r1, [r4, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:479
    20ac:	e58b2000 	str	r2, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:480
    20b0:	eafffe46 	b	19d0 <zlib_inflate+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:707
    20b4:	e3e04001 	mvn	r4, #1
    20b8:	e58d4010 	str	r4, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:740
    20bc:	e59d0010 	ldr	r0, [sp, #16]
    20c0:	e28dd04c 	add	sp, sp, #76	; 0x4c
    20c4:	e8bd8ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp, pc}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:352
    20c8:	e59b3008 	ldr	r3, [fp, #8]
    20cc:	e3530000 	cmp	r3, #0
    20d0:	0a00028d 	beq	2b0c <zlib_inflate+0x11f8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:356 (discriminator 1)
    20d4:	e359000f 	cmp	r9, #15
    20d8:	8a00000c 	bhi	2110 <zlib_inflate+0x7fc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:356
    20dc:	e3580000 	cmp	r8, #0
    20e0:	0a00024f 	beq	2a24 <zlib_inflate+0x1110>
    20e4:	e1a0300a 	mov	r3, sl
    20e8:	ea000001 	b	20f4 <zlib_inflate+0x7e0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:356 (discriminator 3)
    20ec:	e3580000 	cmp	r8, #0
    20f0:	0a00024b 	beq	2a24 <zlib_inflate+0x1110>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:356 (discriminator 2)
    20f4:	e4d32001 	ldrb	r2, [r3], #1
    20f8:	e2488001 	sub	r8, r8, #1
    20fc:	e0877912 	add	r7, r7, r2, lsl r9
    2100:	e2899008 	add	r9, r9, #8
    2104:	e359000f 	cmp	r9, #15
    2108:	e1a0a003 	mov	sl, r3
    210c:	9afffff6 	bls	20ec <zlib_inflate+0x7d8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:358
    2110:	e1a01c07 	lsl	r1, r7, #24
    2114:	e1a03427 	lsr	r3, r7, #8
    2118:	e3012085 	movw	r2, #4229	; 0x1085
    211c:	e3402842 	movt	r2, #2114	; 0x842
    2120:	e0833821 	add	r3, r3, r1, lsr #16
    2124:	e082c392 	umull	ip, r2, r2, r3
    2128:	e0621003 	rsb	r1, r2, r3
    212c:	e08220a1 	add	r2, r2, r1, lsr #1
    2130:	e1a02222 	lsr	r2, r2, #4
    2134:	e0622282 	rsb	r2, r2, r2, lsl #5
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:357
    2138:	e0533002 	subs	r3, r3, r2
    213c:	0a0002f6 	beq	2d1c <zlib_inflate+0x1408>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:359
    2140:	e59d4014 	ldr	r4, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:360
    2144:	e3a0201b 	mov	r2, #27
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:359
    2148:	e59f15e8 	ldr	r1, [pc, #1512]	; 2738 <zlib_inflate+0xe24>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:361
    214c:	e1a03002 	mov	r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:359
    2150:	e08f1001 	add	r1, pc, r1
    2154:	e5841018 	str	r1, [r4, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:360
    2158:	e58b2000 	str	r2, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:361
    215c:	eafffe1b 	b	19d0 <zlib_inflate+0xbc>
    2160:	e1a0500a 	mov	r5, sl
    2164:	e1a0a00b 	mov	sl, fp
    2168:	e59db014 	ldr	fp, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:350
    216c:	e3a02000 	mov	r2, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:698
    2170:	e3a03001 	mov	r3, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:350
    2174:	e58d201c 	str	r2, [sp, #28]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:698
    2178:	e58d3010 	str	r3, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:350
    217c:	e58d2018 	str	r2, [sp, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:716
    2180:	e59d4028 	ldr	r4, [sp, #40]	; 0x28
    2184:	e59dc00c 	ldr	ip, [sp, #12]
    2188:	e88b0120 	stm	fp, {r5, r8}
    218c:	e58b400c 	str	r4, [fp, #12]
    2190:	e58bc010 	str	ip, [fp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:717
    2194:	e59a3024 	ldr	r3, [sl, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:716
    2198:	e58a7034 	str	r7, [sl, #52]	; 0x34
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:717
    219c:	e3530000 	cmp	r3, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:716
    21a0:	e58a9038 	str	r9, [sl, #56]	; 0x38
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:717
    21a4:	1a000006 	bne	21c4 <zlib_inflate+0x8b0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:717 (discriminator 1)
    21a8:	e59a2000 	ldr	r2, [sl]
    21ac:	e3520017 	cmp	r2, #23
    21b0:	8a000006 	bhi	21d0 <zlib_inflate+0x8bc>
    21b4:	e59b2010 	ldr	r2, [fp, #16]
    21b8:	e59d4020 	ldr	r4, [sp, #32]
    21bc:	e1520004 	cmp	r2, r4
    21c0:	0a0003a1 	beq	304c <zlib_inflate+0x1738>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:718
    21c4:	e1a0000b 	mov	r0, fp
    21c8:	e59d1020 	ldr	r1, [sp, #32]
    21cc:	ebfffa5f 	bl	b50 <zlib_updatewindow>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:720
    21d0:	e59b3004 	ldr	r3, [fp, #4]
    21d4:	e59dc024 	ldr	ip, [sp, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:721
    21d8:	e59b1010 	ldr	r1, [fp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:720
    21dc:	e063300c 	rsb	r3, r3, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:721
    21e0:	e59d4020 	ldr	r4, [sp, #32]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:720
    21e4:	e58d3014 	str	r3, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:722
    21e8:	e59b2008 	ldr	r2, [fp, #8]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:721
    21ec:	e0611004 	rsb	r1, r1, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:723
    21f0:	e59b3014 	ldr	r3, [fp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:722
    21f4:	e59dc014 	ldr	ip, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:723
    21f8:	e0833001 	add	r3, r3, r1
    21fc:	e58b3014 	str	r3, [fp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:722
    2200:	e082200c 	add	r2, r2, ip
    2204:	e58b2008 	str	r2, [fp, #8]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:725
    2208:	e59a2008 	ldr	r2, [sl, #8]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:724
    220c:	e59a301c 	ldr	r3, [sl, #28]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:725
    2210:	e3520000 	cmp	r2, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:721
    2214:	e58d100c 	str	r1, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:724
    2218:	e0833001 	add	r3, r3, r1
    221c:	e58a301c 	str	r3, [sl, #28]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:725
    2220:	0a000067 	beq	23c4 <zlib_inflate+0xab0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:725 (discriminator 1)
    2224:	e3510000 	cmp	r1, #0
    2228:	0a000065 	beq	23c4 <zlib_inflate+0xab0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:727
    222c:	e59b700c 	ldr	r7, [fp, #12]
zlib_adler32():
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:86
    2230:	e59d000c 	ldr	r0, [sp, #12]
zlib_inflate():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:727
    2234:	e59a1018 	ldr	r1, [sl, #24]
zlib_adler32():
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:86
    2238:	e0577000 	subs	r7, r7, r0
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:82
    223c:	e6ff4071 	uxth	r4, r1
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:83
    2240:	e1a01821 	lsr	r1, r1, #16
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:86
    2244:	03a01001 	moveq	r1, #1
    2248:	0a00005b 	beq	23bc <zlib_inflate+0xaa8>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:100
    224c:	e3083071 	movw	r3, #32881	; 0x8071
    2250:	e3483007 	movt	r3, #32775	; 0x8007
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:89
    2254:	e58da020 	str	sl, [sp, #32]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:86
    2258:	e1a09000 	mov	r9, r0
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:89
    225c:	e1a0a003 	mov	sl, r3
    2260:	e30185b0 	movw	r8, #5552	; 0x15b0
    2264:	e1590008 	cmp	r9, r8
    2268:	31a08009 	movcc	r8, r9
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:91
    226c:	e358000f 	cmp	r8, #15
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:90
    2270:	e0689009 	rsb	r9, r8, r9
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:89
    2274:	e1a02008 	mov	r2, r8
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:91
    2278:	da000039 	ble	2364 <zlib_inflate+0xa50>
    227c:	e1a03007 	mov	r3, r7
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:92
    2280:	e5d30000 	ldrb	r0, [r3]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:94
    2284:	e2422010 	sub	r2, r2, #16
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:92
    2288:	e5d3c001 	ldrb	ip, [r3, #1]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:91
    228c:	e352000f 	cmp	r2, #15
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:92
    2290:	e0844000 	add	r4, r4, r0
    2294:	e5d30002 	ldrb	r0, [r3, #2]
    2298:	e084c00c 	add	ip, r4, ip
    229c:	e5d36003 	ldrb	r6, [r3, #3]
    22a0:	e08c0000 	add	r0, ip, r0
    22a4:	e5d35004 	ldrb	r5, [r3, #4]
    22a8:	e08c4004 	add	r4, ip, r4
    22ac:	e0806006 	add	r6, r0, r6
    22b0:	e0844000 	add	r4, r4, r0
    22b4:	e5d3c005 	ldrb	ip, [r3, #5]
    22b8:	e0865005 	add	r5, r6, r5
    22bc:	e5d30006 	ldrb	r0, [r3, #6]
    22c0:	e0846006 	add	r6, r4, r6
    22c4:	e085c00c 	add	ip, r5, ip
    22c8:	e5d34007 	ldrb	r4, [r3, #7]
    22cc:	e0866005 	add	r6, r6, r5
    22d0:	e08c0000 	add	r0, ip, r0
    22d4:	e5d35008 	ldrb	r5, [r3, #8]
    22d8:	e086600c 	add	r6, r6, ip
    22dc:	e0804004 	add	r4, r0, r4
    22e0:	e5d3c009 	ldrb	ip, [r3, #9]
    22e4:	e0866000 	add	r6, r6, r0
    22e8:	e0845005 	add	r5, r4, r5
    22ec:	e5d3000a 	ldrb	r0, [r3, #10]
    22f0:	e0866004 	add	r6, r6, r4
    22f4:	e085c00c 	add	ip, r5, ip
    22f8:	e5d3400b 	ldrb	r4, [r3, #11]
    22fc:	e0866005 	add	r6, r6, r5
    2300:	e08c0000 	add	r0, ip, r0
    2304:	e5d3500c 	ldrb	r5, [r3, #12]
    2308:	e086600c 	add	r6, r6, ip
    230c:	e0804004 	add	r4, r0, r4
    2310:	e0866000 	add	r6, r6, r0
    2314:	e5d3c00d 	ldrb	ip, [r3, #13]
    2318:	e0845005 	add	r5, r4, r5
    231c:	e5d3000e 	ldrb	r0, [r3, #14]
    2320:	e0864004 	add	r4, r6, r4
    2324:	e085c00c 	add	ip, r5, ip
    2328:	e5d3600f 	ldrb	r6, [r3, #15]
    232c:	e0844005 	add	r4, r4, r5
    2330:	e08c0000 	add	r0, ip, r0
    2334:	e084c00c 	add	ip, r4, ip
    2338:	e0804006 	add	r4, r0, r6
    233c:	e08c0000 	add	r0, ip, r0
    2340:	e0800004 	add	r0, r0, r4
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:93
    2344:	e2833010 	add	r3, r3, #16
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:92
    2348:	e0811000 	add	r1, r1, r0
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:91
    234c:	caffffcb 	bgt	2280 <zlib_inflate+0x96c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317
    2350:	e2482010 	sub	r2, r8, #16
    2354:	e1a03222 	lsr	r3, r2, #4
    2358:	e2830001 	add	r0, r3, #1
    235c:	e0422203 	sub	r2, r2, r3, lsl #4
    2360:	e0877200 	add	r7, r7, r0, lsl #4
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:96
    2364:	e3520000 	cmp	r2, #0
    2368:	0a000005 	beq	2384 <zlib_inflate+0xa70>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317
    236c:	e0872002 	add	r2, r7, r2
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:97
    2370:	e4d73001 	ldrb	r3, [r7], #1
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:99
    2374:	e1570002 	cmp	r7, r2
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:97
    2378:	e0844003 	add	r4, r4, r3
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:98
    237c:	e0811004 	add	r1, r1, r4
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:99
    2380:	1afffffa 	bne	2370 <zlib_inflate+0xa5c>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:100
    2384:	e082349a 	umull	r3, r2, sl, r4
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:88
    2388:	e3590000 	cmp	r9, #0
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:101
    238c:	e083c19a 	umull	ip, r3, sl, r1
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:100
    2390:	e1a027a2 	lsr	r2, r2, #15
    2394:	e0620602 	rsb	r0, r2, r2, lsl #12
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:101
    2398:	e1a037a3 	lsr	r3, r3, #15
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:100
    239c:	e0822200 	add	r2, r2, r0, lsl #4
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:101
    23a0:	e0630603 	rsb	r0, r3, r3, lsl #12
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:100
    23a4:	e0624004 	rsb	r4, r2, r4
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:101
    23a8:	e0833200 	add	r3, r3, r0, lsl #4
    23ac:	e0631001 	rsb	r1, r3, r1
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:88
    23b0:	1affffaa 	bne	2260 <zlib_inflate+0x94c>
    23b4:	e59da020 	ldr	sl, [sp, #32]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:103
    23b8:	e1841801 	orr	r1, r4, r1, lsl #16
zlib_inflate():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:726
    23bc:	e58a1018 	str	r1, [sl, #24]
    23c0:	e58b1028 	str	r1, [fp, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:729
    23c4:	e89a000c 	ldm	sl, {r2, r3}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:732
    23c8:	e59d401c 	ldr	r4, [sp, #28]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:729
    23cc:	e3530000 	cmp	r3, #0
    23d0:	e59a1038 	ldr	r1, [sl, #56]	; 0x38
    23d4:	13a03040 	movne	r3, #64	; 0x40
    23d8:	03a03000 	moveq	r3, #0
    23dc:	e352000b 	cmp	r2, #11
    23e0:	e0833001 	add	r3, r3, r1
    23e4:	03a02080 	moveq	r2, #128	; 0x80
    23e8:	13a02000 	movne	r2, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:732
    23ec:	e3540000 	cmp	r4, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:729
    23f0:	e0833002 	add	r3, r3, r2
    23f4:	e58b3024 	str	r3, [fp, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:732
    23f8:	0a00017c 	beq	29f0 <zlib_inflate+0x10dc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:732 (discriminator 1)
    23fc:	e59b3010 	ldr	r3, [fp, #16]
    2400:	e3530000 	cmp	r3, #0
    2404:	0a000179 	beq	29f0 <zlib_inflate+0x10dc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:733
    2408:	e59b3004 	ldr	r3, [fp, #4]
    240c:	e3530000 	cmp	r3, #0
    2410:	1a000176 	bne	29f0 <zlib_inflate+0x10dc>
zlib_inflateSyncPacket():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:150
    2414:	e59b301c 	ldr	r3, [fp, #28]
    2418:	e3530000 	cmp	r3, #0
    241c:	0a000190 	beq	2a64 <zlib_inflate+0x1150>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:153
    2420:	e5932000 	ldr	r2, [r3]
    2424:	e352000d 	cmp	r2, #13
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:157
    2428:	13e0c002 	mvnne	ip, #2
    242c:	158dc010 	strne	ip, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:153
    2430:	1affff21 	bne	20bc <zlib_inflate+0x7a8>
    2434:	e5932038 	ldr	r2, [r3, #56]	; 0x38
    2438:	e3520000 	cmp	r2, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:157
    243c:	13e03002 	mvnne	r3, #2
    2440:	158d3010 	strne	r3, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:155
    2444:	058d2010 	streq	r2, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:154
    2448:	03a0200b 	moveq	r2, #11
    244c:	05832000 	streq	r2, [r3]
    2450:	eaffff19 	b	20bc <zlib_inflate+0x7a8>
zlib_inflate():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:350
    2454:	e3a04000 	mov	r4, #0
    2458:	e1a0500a 	mov	r5, sl
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:701
    245c:	e3e0c002 	mvn	ip, #2
    2460:	e1a0a00b 	mov	sl, fp
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:350
    2464:	e58d401c 	str	r4, [sp, #28]
    2468:	e59db014 	ldr	fp, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:701
    246c:	e58dc010 	str	ip, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:350
    2470:	e58d4018 	str	r4, [sp, #24]
    2474:	eaffff41 	b	2180 <zlib_inflate+0x86c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:673
    2478:	e59d400c 	ldr	r4, [sp, #12]
    247c:	e3540000 	cmp	r4, #0
    2480:	0a000167 	beq	2a24 <zlib_inflate+0x1110>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:674
    2484:	e59d4028 	ldr	r4, [sp, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:676
    2488:	e3a02012 	mov	r2, #18
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:674
    248c:	e59b103c 	ldr	r1, [fp, #60]	; 0x3c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:677
    2490:	e1a03002 	mov	r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:675
    2494:	e59dc00c 	ldr	ip, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:674
    2498:	e4c41001 	strb	r1, [r4], #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:675
    249c:	e24cc001 	sub	ip, ip, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:674
    24a0:	e58d4028 	str	r4, [sp, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:675
    24a4:	e58dc00c 	str	ip, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:676
    24a8:	e58b2000 	str	r2, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:677
    24ac:	eafffd47 	b	19d0 <zlib_inflate+0xbc>
    24b0:	e59b4064 	ldr	r4, [fp, #100]	; 0x64
    24b4:	e59bc05c 	ldr	ip, [fp, #92]	; 0x5c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:487 (discriminator 1)
    24b8:	e3a06001 	mov	r6, #1
    24bc:	e59b5060 	ldr	r5, [fp, #96]	; 0x60
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317 (discriminator 1)
    24c0:	e28b006a 	add	r0, fp, #106	; 0x6a
    24c4:	e58d0040 	str	r0, [sp, #64]	; 0x40
    24c8:	e08c5005 	add	r5, ip, r5
    24cc:	e58dc03c 	str	ip, [sp, #60]	; 0x3c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:485 (discriminator 1)
    24d0:	e1540005 	cmp	r4, r5
    24d4:	2a000292 	bcs	2f24 <zlib_inflate+0x1610>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:487
    24d8:	e59bc050 	ldr	ip, [fp, #80]	; 0x50
    24dc:	e59b0048 	ldr	r0, [fp, #72]	; 0x48
    24e0:	e1a0cc16 	lsl	ip, r6, ip
    24e4:	e24cc001 	sub	ip, ip, #1
    24e8:	e007300c 	and	r3, r7, ip
    24ec:	e0803103 	add	r3, r0, r3, lsl #2
    24f0:	e5d31001 	ldrb	r1, [r3, #1]
    24f4:	e1d320b2 	ldrh	r2, [r3, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:488
    24f8:	e1590001 	cmp	r9, r1
    24fc:	2a000010 	bcs	2544 <zlib_inflate+0xc30>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:489
    2500:	e3580000 	cmp	r8, #0
    2504:	0a00012c 	beq	29bc <zlib_inflate+0x10a8>
    2508:	e1a0300a 	mov	r3, sl
    250c:	ea000001 	b	2518 <zlib_inflate+0xc04>
    2510:	e3580000 	cmp	r8, #0
    2514:	0a000142 	beq	2a24 <zlib_inflate+0x1110>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:489 (discriminator 1)
    2518:	e4d32001 	ldrb	r2, [r3], #1
    251c:	e2488001 	sub	r8, r8, #1
    2520:	e0877912 	add	r7, r7, r2, lsl r9
    2524:	e2899008 	add	r9, r9, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:487 (discriminator 1)
    2528:	e007200c 	and	r2, r7, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:489 (discriminator 1)
    252c:	e1a0a003 	mov	sl, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:487 (discriminator 1)
    2530:	e0802102 	add	r2, r0, r2, lsl #2
    2534:	e5d21001 	ldrb	r1, [r2, #1]
    2538:	e1d220b2 	ldrh	r2, [r2, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:488 (discriminator 1)
    253c:	e1510009 	cmp	r1, r9
    2540:	8afffff2 	bhi	2510 <zlib_inflate+0xbfc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:491
    2544:	e352000f 	cmp	r2, #15
    2548:	8a000191 	bhi	2b94 <zlib_inflate+0x1280>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:494
    254c:	e08b3084 	add	r3, fp, r4, lsl #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:493
    2550:	e1a07137 	lsr	r7, r7, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:494
    2554:	e2844001 	add	r4, r4, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:493
    2558:	e0619009 	rsb	r9, r1, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:494
    255c:	e1c326bc 	strh	r2, [r3, #108]	; 0x6c
    2560:	e58b4064 	str	r4, [fp, #100]	; 0x64
    2564:	eaffffd9 	b	24d0 <zlib_inflate+0xbbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:556
    2568:	e3a03012 	mov	r3, #18
    256c:	e58b3000 	str	r3, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:558
    2570:	e59dc00c 	ldr	ip, [sp, #12]
    2574:	e3003101 	movw	r3, #257	; 0x101
    2578:	e3580005 	cmp	r8, #5
    257c:	815c0003 	cmphi	ip, r3
    2580:	8a0001ad 	bhi	2c3c <zlib_inflate+0x1328>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:565
    2584:	e59b3050 	ldr	r3, [fp, #80]	; 0x50
    2588:	e3e04000 	mvn	r4, #0
    258c:	e59b2048 	ldr	r2, [fp, #72]	; 0x48
    2590:	e1e04314 	mvn	r4, r4, lsl r3
    2594:	e0073004 	and	r3, r7, r4
    2598:	e0820103 	add	r0, r2, r3, lsl #2
    259c:	e7d21103 	ldrb	r1, [r2, r3, lsl #2]
    25a0:	e5d03001 	ldrb	r3, [r0, #1]
    25a4:	e1d000b2 	ldrh	r0, [r0, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:566
    25a8:	e1590003 	cmp	r9, r3
    25ac:	2a000011 	bcs	25f8 <zlib_inflate+0xce4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:567
    25b0:	e3580000 	cmp	r8, #0
    25b4:	0a000100 	beq	29bc <zlib_inflate+0x10a8>
    25b8:	e1a0c00a 	mov	ip, sl
    25bc:	ea000001 	b	25c8 <zlib_inflate+0xcb4>
    25c0:	e3580000 	cmp	r8, #0
    25c4:	0a000116 	beq	2a24 <zlib_inflate+0x1110>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:567 (discriminator 1)
    25c8:	e4dc3001 	ldrb	r3, [ip], #1
    25cc:	e2488001 	sub	r8, r8, #1
    25d0:	e0877913 	add	r7, r7, r3, lsl r9
    25d4:	e2899008 	add	r9, r9, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:565 (discriminator 1)
    25d8:	e0073004 	and	r3, r7, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:567 (discriminator 1)
    25dc:	e1a0a00c 	mov	sl, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:565 (discriminator 1)
    25e0:	e0820103 	add	r0, r2, r3, lsl #2
    25e4:	e7d21103 	ldrb	r1, [r2, r3, lsl #2]
    25e8:	e5d03001 	ldrb	r3, [r0, #1]
    25ec:	e1d000b2 	ldrh	r0, [r0, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:566 (discriminator 1)
    25f0:	e1530009 	cmp	r3, r9
    25f4:	8afffff1 	bhi	25c0 <zlib_inflate+0xcac>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:569
    25f8:	e3510000 	cmp	r1, #0
    25fc:	0a0001b7 	beq	2ce0 <zlib_inflate+0x13cc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:569 (discriminator 1)
    2600:	e31100f0 	tst	r1, #240	; 0xf0
    2604:	1a0001ea 	bne	2db4 <zlib_inflate+0x14a0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:573
    2608:	e0831001 	add	r1, r3, r1
    260c:	e3e0c000 	mvn	ip, #0
    2610:	e1e0c11c 	mvn	ip, ip, lsl r1
    2614:	e00c1007 	and	r1, ip, r7
    2618:	e58dc03c 	str	ip, [sp, #60]	; 0x3c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:572
    261c:	e0801331 	add	r1, r0, r1, lsr r3
    2620:	e082c101 	add	ip, r2, r1, lsl #2
    2624:	e7d21101 	ldrb	r1, [r2, r1, lsl #2]
    2628:	e5dc4001 	ldrb	r4, [ip, #1]
    262c:	e1dc60b2 	ldrh	r6, [ip, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:574
    2630:	e083c004 	add	ip, r3, r4
    2634:	e159000c 	cmp	r9, ip
    2638:	2a000014 	bcs	2690 <zlib_inflate+0xd7c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:575
    263c:	e3580000 	cmp	r8, #0
    2640:	0a0000f7 	beq	2a24 <zlib_inflate+0x1110>
    2644:	e1a0c00a 	mov	ip, sl
    2648:	ea000001 	b	2654 <zlib_inflate+0xd40>
    264c:	e3580000 	cmp	r8, #0
    2650:	0a0000f3 	beq	2a24 <zlib_inflate+0x1110>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:575 (discriminator 1)
    2654:	e4dc1001 	ldrb	r1, [ip], #1
    2658:	e2488001 	sub	r8, r8, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:573 (discriminator 1)
    265c:	e59d403c 	ldr	r4, [sp, #60]	; 0x3c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:575 (discriminator 1)
    2660:	e0877911 	add	r7, r7, r1, lsl r9
    2664:	e2899008 	add	r9, r9, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:573 (discriminator 1)
    2668:	e0071004 	and	r1, r7, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:575 (discriminator 1)
    266c:	e1a0a00c 	mov	sl, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:572 (discriminator 1)
    2670:	e0801331 	add	r1, r0, r1, lsr r3
    2674:	e0825101 	add	r5, r2, r1, lsl #2
    2678:	e7d21101 	ldrb	r1, [r2, r1, lsl #2]
    267c:	e5d54001 	ldrb	r4, [r5, #1]
    2680:	e1d560b2 	ldrh	r6, [r5, #2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:574 (discriminator 1)
    2684:	e0845003 	add	r5, r4, r3
    2688:	e1550009 	cmp	r5, r9
    268c:	8affffee 	bhi	264c <zlib_inflate+0xd38>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:577
    2690:	e1a07337 	lsr	r7, r7, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:581
    2694:	e3510000 	cmp	r1, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:577
    2698:	e0639009 	rsb	r9, r3, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:580
    269c:	e58b603c 	str	r6, [fp, #60]	; 0x3c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:579
    26a0:	e1a07437 	lsr	r7, r7, r4
    26a4:	e0649009 	rsb	r9, r4, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:581
    26a8:	0a00018f 	beq	2cec <zlib_inflate+0x13d8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:585
    26ac:	e2013020 	and	r3, r1, #32
    26b0:	e6ef3073 	uxtb	r3, r3
    26b4:	e3530000 	cmp	r3, #0
    26b8:	1a0000f1 	bne	2a84 <zlib_inflate+0x1170>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:589
    26bc:	e2013040 	and	r3, r1, #64	; 0x40
    26c0:	e6ef3073 	uxtb	r3, r3
    26c4:	e3530000 	cmp	r3, #0
    26c8:	0a0001f3 	beq	2e9c <zlib_inflate+0x1588>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:590
    26cc:	e59dc014 	ldr	ip, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:591
    26d0:	e3a0201b 	mov	r2, #27
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:590
    26d4:	e59f1060 	ldr	r1, [pc, #96]	; 273c <zlib_inflate+0xe28>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:592
    26d8:	e1a03002 	mov	r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:590
    26dc:	e08f1001 	add	r1, pc, r1
    26e0:	e58c1018 	str	r1, [ip, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:591
    26e4:	e58b2000 	str	r2, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:592
    26e8:	eafffcb8 	b	19d0 <zlib_inflate+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:704
    26ec:	e3e0c003 	mvn	ip, #3
    26f0:	e58dc010 	str	ip, [sp, #16]
    26f4:	eafffe70 	b	20bc <zlib_inflate+0x7a8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:679
    26f8:	e59b3008 	ldr	r3, [fp, #8]
    26fc:	e3530000 	cmp	r3, #0
    2700:	0a0001fc 	beq	2ef8 <zlib_inflate+0x15e4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:680 (discriminator 1)
    2704:	e359001f 	cmp	r9, #31
    2708:	8a00001e 	bhi	2788 <zlib_inflate+0xe74>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:680
    270c:	e3580000 	cmp	r8, #0
    2710:	0a0000c3 	beq	2a24 <zlib_inflate+0x1110>
    2714:	e1a0300a 	mov	r3, sl
    2718:	ea000013 	b	276c <zlib_inflate+0xe58>
    271c:	00002288 	.word	0x00002288
    2720:	00002280 	.word	0x00002280
    2724:	00002d78 	.word	0x00002d78
    2728:	00002934 	.word	0x00002934
    272c:	00002860 	.word	0x00002860
    2730:	00001c30 	.word	0x00001c30
    2734:	00002698 	.word	0x00002698
    2738:	0000254c 	.word	0x0000254c
    273c:	00001fa4 	.word	0x00001fa4
    2740:	00001dfc 	.word	0x00001dfc
    2744:	00001b4c 	.word	0x00001b4c
    2748:	00001ba4 	.word	0x00001ba4
    274c:	0000197c 	.word	0x0000197c
    2750:	00001844 	.word	0x00001844
    2754:	000017ec 	.word	0x000017ec
    2758:	00001774 	.word	0x00001774
    275c:	000016e0 	.word	0x000016e0
    2760:	000016c0 	.word	0x000016c0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:680 (discriminator 3)
    2764:	e3580000 	cmp	r8, #0
    2768:	0a0000ad 	beq	2a24 <zlib_inflate+0x1110>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:680 (discriminator 2)
    276c:	e4d32001 	ldrb	r2, [r3], #1
    2770:	e2488001 	sub	r8, r8, #1
    2774:	e0877912 	add	r7, r7, r2, lsl r9
    2778:	e2899008 	add	r9, r9, #8
    277c:	e359001f 	cmp	r9, #31
    2780:	e1a0a003 	mov	sl, r3
    2784:	9afffff6 	bls	2764 <zlib_inflate+0xe50>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:682
    2788:	e59dc014 	ldr	ip, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:681
    278c:	e59d4020 	ldr	r4, [sp, #32]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:682
    2790:	e59c3014 	ldr	r3, [ip, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:681
    2794:	e59dc00c 	ldr	ip, [sp, #12]
    2798:	e06c2004 	rsb	r2, ip, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:682
    279c:	e59d4014 	ldr	r4, [sp, #20]
    27a0:	e0833002 	add	r3, r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:684
    27a4:	e3520000 	cmp	r2, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:682
    27a8:	e5843014 	str	r3, [r4, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:683
    27ac:	e59b301c 	ldr	r3, [fp, #28]
    27b0:	e0833002 	add	r3, r3, r2
    27b4:	e58b301c 	str	r3, [fp, #28]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:684
    27b8:	0a00006b 	beq	296c <zlib_inflate+0x1058>
zlib_adler32():
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:86
    27bc:	e59dc028 	ldr	ip, [sp, #40]	; 0x28
zlib_inflate():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:686
    27c0:	e59b5018 	ldr	r5, [fp, #24]
zlib_adler32():
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:86
    27c4:	e05c1002 	subs	r1, ip, r2
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:82
    27c8:	e6ffc075 	uxth	ip, r5
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:83
    27cc:	e1a05825 	lsr	r5, r5, #16
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:86
    27d0:	03a0c001 	moveq	ip, #1
    27d4:	0a000061 	beq	2960 <zlib_inflate+0x104c>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:100
    27d8:	e3083071 	movw	r3, #32881	; 0x8071
    27dc:	e3483007 	movt	r3, #32775	; 0x8007
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:89
    27e0:	e58d703c 	str	r7, [sp, #60]	; 0x3c
    27e4:	e1a07001 	mov	r7, r1
    27e8:	e58d9040 	str	r9, [sp, #64]	; 0x40
    27ec:	e1a09002 	mov	r9, r2
    27f0:	e58db044 	str	fp, [sp, #68]	; 0x44
    27f4:	e1a0b003 	mov	fp, r3
    27f8:	e58d8020 	str	r8, [sp, #32]
    27fc:	e30185b0 	movw	r8, #5552	; 0x15b0
    2800:	e1590008 	cmp	r9, r8
    2804:	31a08009 	movcc	r8, r9
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:91
    2808:	e358000f 	cmp	r8, #15
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:90
    280c:	e0689009 	rsb	r9, r8, r9
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:89
    2810:	e1a02008 	mov	r2, r8
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:91
    2814:	da000039 	ble	2900 <zlib_inflate+0xfec>
    2818:	e1a03007 	mov	r3, r7
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:92
    281c:	e5d31000 	ldrb	r1, [r3]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:94
    2820:	e2422010 	sub	r2, r2, #16
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:92
    2824:	e5d30001 	ldrb	r0, [r3, #1]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:91
    2828:	e352000f 	cmp	r2, #15
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:92
    282c:	e08cc001 	add	ip, ip, r1
    2830:	e5d31002 	ldrb	r1, [r3, #2]
    2834:	e08c0000 	add	r0, ip, r0
    2838:	e5d36003 	ldrb	r6, [r3, #3]
    283c:	e0801001 	add	r1, r0, r1
    2840:	e5d34004 	ldrb	r4, [r3, #4]
    2844:	e080c00c 	add	ip, r0, ip
    2848:	e0816006 	add	r6, r1, r6
    284c:	e08cc001 	add	ip, ip, r1
    2850:	e5d30005 	ldrb	r0, [r3, #5]
    2854:	e0864004 	add	r4, r6, r4
    2858:	e5d31006 	ldrb	r1, [r3, #6]
    285c:	e08c6006 	add	r6, ip, r6
    2860:	e0840000 	add	r0, r4, r0
    2864:	e5d3c007 	ldrb	ip, [r3, #7]
    2868:	e0866004 	add	r6, r6, r4
    286c:	e0801001 	add	r1, r0, r1
    2870:	e5d34008 	ldrb	r4, [r3, #8]
    2874:	e0866000 	add	r6, r6, r0
    2878:	e081c00c 	add	ip, r1, ip
    287c:	e5d30009 	ldrb	r0, [r3, #9]
    2880:	e0866001 	add	r6, r6, r1
    2884:	e08c4004 	add	r4, ip, r4
    2888:	e5d3100a 	ldrb	r1, [r3, #10]
    288c:	e086600c 	add	r6, r6, ip
    2890:	e0840000 	add	r0, r4, r0
    2894:	e5d3c00b 	ldrb	ip, [r3, #11]
    2898:	e0866004 	add	r6, r6, r4
    289c:	e0801001 	add	r1, r0, r1
    28a0:	e5d3400c 	ldrb	r4, [r3, #12]
    28a4:	e0866000 	add	r6, r6, r0
    28a8:	e081c00c 	add	ip, r1, ip
    28ac:	e0866001 	add	r6, r6, r1
    28b0:	e5d3000d 	ldrb	r0, [r3, #13]
    28b4:	e08c4004 	add	r4, ip, r4
    28b8:	e5d3100e 	ldrb	r1, [r3, #14]
    28bc:	e086c00c 	add	ip, r6, ip
    28c0:	e0840000 	add	r0, r4, r0
    28c4:	e5d3600f 	ldrb	r6, [r3, #15]
    28c8:	e08cc004 	add	ip, ip, r4
    28cc:	e0801001 	add	r1, r0, r1
    28d0:	e08c0000 	add	r0, ip, r0
    28d4:	e081c006 	add	ip, r1, r6
    28d8:	e0801001 	add	r1, r0, r1
    28dc:	e081100c 	add	r1, r1, ip
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:93
    28e0:	e2833010 	add	r3, r3, #16
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:92
    28e4:	e0855001 	add	r5, r5, r1
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:91
    28e8:	caffffcb 	bgt	281c <zlib_inflate+0xf08>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317
    28ec:	e2482010 	sub	r2, r8, #16
    28f0:	e1a03222 	lsr	r3, r2, #4
    28f4:	e2831001 	add	r1, r3, #1
    28f8:	e0422203 	sub	r2, r2, r3, lsl #4
    28fc:	e0877201 	add	r7, r7, r1, lsl #4
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:96
    2900:	e3520000 	cmp	r2, #0
    2904:	0a000005 	beq	2920 <zlib_inflate+0x100c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317
    2908:	e0872002 	add	r2, r7, r2
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:97
    290c:	e4d73001 	ldrb	r3, [r7], #1
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:99
    2910:	e1570002 	cmp	r7, r2
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:97
    2914:	e08cc003 	add	ip, ip, r3
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:98
    2918:	e085500c 	add	r5, r5, ip
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:99
    291c:	1afffffa 	bne	290c <zlib_inflate+0xff8>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:100
    2920:	e0820c9b 	umull	r0, r2, fp, ip
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:88
    2924:	e3590000 	cmp	r9, #0
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:101
    2928:	e083159b 	umull	r1, r3, fp, r5
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:100
    292c:	e1a027a2 	lsr	r2, r2, #15
    2930:	e0621602 	rsb	r1, r2, r2, lsl #12
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:101
    2934:	e1a037a3 	lsr	r3, r3, #15
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:100
    2938:	e0822201 	add	r2, r2, r1, lsl #4
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:101
    293c:	e0631603 	rsb	r1, r3, r3, lsl #12
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:100
    2940:	e062c00c 	rsb	ip, r2, ip
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:101
    2944:	e0833201 	add	r3, r3, r1, lsl #4
    2948:	e0635005 	rsb	r5, r3, r5
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:88
    294c:	1affffaa 	bne	27fc <zlib_inflate+0xee8>
    2950:	e28d703c 	add	r7, sp, #60	; 0x3c
    2954:	e59d8020 	ldr	r8, [sp, #32]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:103
    2958:	e18cc805 	orr	ip, ip, r5, lsl #16
    295c:	e8970a80 	ldm	r7, {r7, r9, fp}
zlib_inflate():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:685
    2960:	e59d4014 	ldr	r4, [sp, #20]
    2964:	e58bc018 	str	ip, [fp, #24]
    2968:	e584c028 	str	ip, [r4, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:689
    296c:	e1a01c27 	lsr	r1, r7, #24
    2970:	e1a03427 	lsr	r3, r7, #8
    2974:	e2033cff 	and	r3, r3, #65280	; 0xff00
    2978:	e0811c07 	add	r1, r1, r7, lsl #24
    297c:	e2072cff 	and	r2, r7, #65280	; 0xff00
    2980:	e0811003 	add	r1, r1, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:688
    2984:	e59b3018 	ldr	r3, [fp, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:689
    2988:	e0812402 	add	r2, r1, r2, lsl #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:688
    298c:	e1520003 	cmp	r2, r3
    2990:	0a0001a5 	beq	302c <zlib_inflate+0x1718>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:692
    2994:	e59dc00c 	ldr	ip, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:691
    2998:	e3a0201b 	mov	r2, #27
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:690
    299c:	e59d4014 	ldr	r4, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:692
    29a0:	e1a03002 	mov	r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:690
    29a4:	e51f126c 	ldr	r1, [pc, #-620]	; 2740 <zlib_inflate+0xe2c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:692
    29a8:	e58dc020 	str	ip, [sp, #32]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:690
    29ac:	e08f1001 	add	r1, pc, r1
    29b0:	e5841018 	str	r1, [r4, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:691
    29b4:	e58b2000 	str	r2, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:692
    29b8:	eafffc04 	b	19d0 <zlib_inflate+0xbc>
    29bc:	e59d2010 	ldr	r2, [sp, #16]
    29c0:	e1a0500a 	mov	r5, sl
    29c4:	e59d402c 	ldr	r4, [sp, #44]	; 0x2c
    29c8:	e1a0a00b 	mov	sl, fp
    29cc:	e2722001 	rsbs	r2, r2, #1
    29d0:	e59db014 	ldr	fp, [sp, #20]
    29d4:	33a02000 	movcc	r2, #0
    29d8:	e58d2018 	str	r2, [sp, #24]
    29dc:	e3540002 	cmp	r4, #2
    29e0:	13a02000 	movne	r2, #0
    29e4:	02022001 	andeq	r2, r2, #1
    29e8:	e58d201c 	str	r2, [sp, #28]
    29ec:	eafffde3 	b	2180 <zlib_inflate+0x86c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:736
    29f0:	e59dc014 	ldr	ip, [sp, #20]
    29f4:	e59d000c 	ldr	r0, [sp, #12]
    29f8:	e19cc000 	orrs	ip, ip, r0
    29fc:	0a000002 	beq	2a0c <zlib_inflate+0x10f8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:736 (discriminator 2)
    2a00:	e59d402c 	ldr	r4, [sp, #44]	; 0x2c
    2a04:	e3540005 	cmp	r4, #5
    2a08:	1afffdab 	bne	20bc <zlib_inflate+0x7a8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:737 (discriminator 1)
    2a0c:	e59dc018 	ldr	ip, [sp, #24]
    2a10:	e59d3010 	ldr	r3, [sp, #16]
    2a14:	e35c0000 	cmp	ip, #0
    2a18:	13e03004 	mvnne	r3, #4
    2a1c:	e58d3010 	str	r3, [sp, #16]
    2a20:	eafffda5 	b	20bc <zlib_inflate+0x7a8>
    2a24:	e1a0500a 	mov	r5, sl
    2a28:	e1a0a00b 	mov	sl, fp
    2a2c:	e59dc010 	ldr	ip, [sp, #16]
    2a30:	e59d402c 	ldr	r4, [sp, #44]	; 0x2c
    2a34:	e27cc001 	rsbs	ip, ip, #1
    2a38:	e59db014 	ldr	fp, [sp, #20]
    2a3c:	33a0c000 	movcc	ip, #0
    2a40:	e58dc018 	str	ip, [sp, #24]
    2a44:	e3540002 	cmp	r4, #2
    2a48:	13a0c000 	movne	ip, #0
    2a4c:	020cc001 	andeq	ip, ip, #1
    2a50:	e58dc01c 	str	ip, [sp, #28]
    2a54:	eafffdc9 	b	2180 <zlib_inflate+0x86c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:339
    2a58:	e59b3004 	ldr	r3, [fp, #4]
    2a5c:	e3530000 	cmp	r3, #0
    2a60:	0afffbb6 	beq	1940 <zlib_inflate+0x2c>
zlib_inflateSyncPacket():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:340
    2a64:	e3e03001 	mvn	r3, #1
    2a68:	e58d3010 	str	r3, [sp, #16]
    2a6c:	eafffd92 	b	20bc <zlib_inflate+0x7a8>
zlib_inflate():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:662
    2a70:	e59b203c 	ldr	r2, [fp, #60]	; 0x3c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:661
    2a74:	e59dc028 	ldr	ip, [sp, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:662
    2a78:	e1a00002 	mov	r0, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:661
    2a7c:	e063300c 	rsb	r3, r3, ip
    2a80:	eafffcd2 	b	1dd0 <zlib_inflate+0x4bc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:586
    2a84:	e3a0300b 	mov	r3, #11
    2a88:	e58b3000 	str	r3, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:587
    2a8c:	eafffbcf 	b	19d0 <zlib_inflate+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:630 (discriminator 1)
    2a90:	e1590001 	cmp	r9, r1
    2a94:	2a00000c 	bcs	2acc <zlib_inflate+0x11b8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:630
    2a98:	e3580000 	cmp	r8, #0
    2a9c:	0affffc6 	beq	29bc <zlib_inflate+0x10a8>
    2aa0:	e1a0300a 	mov	r3, sl
    2aa4:	ea000001 	b	2ab0 <zlib_inflate+0x119c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:630 (discriminator 3)
    2aa8:	e3580000 	cmp	r8, #0
    2aac:	0affffdc 	beq	2a24 <zlib_inflate+0x1110>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:630 (discriminator 2)
    2ab0:	e4d32001 	ldrb	r2, [r3], #1
    2ab4:	e2488001 	sub	r8, r8, #1
    2ab8:	e0877912 	add	r7, r7, r2, lsl r9
    2abc:	e2899008 	add	r9, r9, #8
    2ac0:	e1590001 	cmp	r9, r1
    2ac4:	e1a0a003 	mov	sl, r3
    2ac8:	3afffff6 	bcc	2aa8 <zlib_inflate+0x1194>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:631
    2acc:	e59b3040 	ldr	r3, [fp, #64]	; 0x40
    2ad0:	e3e02000 	mvn	r2, #0
    2ad4:	e1c72112 	bic	r2, r7, r2, lsl r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:632
    2ad8:	e0619009 	rsb	r9, r1, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:631
    2adc:	e0823003 	add	r3, r2, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:632
    2ae0:	e1a07137 	lsr	r7, r7, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:631
    2ae4:	e58b3040 	str	r3, [fp, #64]	; 0x40
    2ae8:	eafffc99 	b	1d54 <zlib_inflate+0x440>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:642
    2aec:	e59dc014 	ldr	ip, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:643
    2af0:	e3a0201b 	mov	r2, #27
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:642
    2af4:	e51f13b8 	ldr	r1, [pc, #-952]	; 2744 <zlib_inflate+0xe30>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:644
    2af8:	e1a03002 	mov	r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:642
    2afc:	e08f1001 	add	r1, pc, r1
    2b00:	e58c1018 	str	r1, [ip, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:643
    2b04:	e58b2000 	str	r2, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:644
    2b08:	eafffbb0 	b	19d0 <zlib_inflate+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:353
    2b0c:	e3a0300c 	mov	r3, #12
    2b10:	e58b3000 	str	r3, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:354
    2b14:	eafffbad 	b	19d0 <zlib_inflate+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:626
    2b18:	e201100f 	and	r1, r1, #15
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:627
    2b1c:	e3a03015 	mov	r3, #21
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:625
    2b20:	e58b0040 	str	r0, [fp, #64]	; 0x40
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:626
    2b24:	e58b1044 	str	r1, [fp, #68]	; 0x44
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:627
    2b28:	e58b3000 	str	r3, [fp]
    2b2c:	eafffc85 	b	1d48 <zlib_inflate+0x434>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:415
    2b30:	e59dc014 	ldr	ip, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:416
    2b34:	e3a0101b 	mov	r1, #27
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:415
    2b38:	e51f03f8 	ldr	r0, [pc, #-1016]	; 2748 <zlib_inflate+0xe34>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:416
    2b3c:	e1a03001 	mov	r3, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:415
    2b40:	e08f0000 	add	r0, pc, r0
    2b44:	e58c0018 	str	r0, [ip, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:416
    2b48:	e58b1000 	str	r1, [fp]
    2b4c:	eafffbff 	b	1b50 <zlib_inflate+0x23c>
    2b50:	e59dc010 	ldr	ip, [sp, #16]
    2b54:	e1a0500a 	mov	r5, sl
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:393
    2b58:	e3a02000 	mov	r2, #0
    2b5c:	e1a0a00b 	mov	sl, fp
    2b60:	e27cc001 	rsbs	ip, ip, #1
    2b64:	e59db014 	ldr	fp, [sp, #20]
    2b68:	e58d201c 	str	r2, [sp, #28]
    2b6c:	33a0c000 	movcc	ip, #0
    2b70:	e58dc018 	str	ip, [sp, #24]
    2b74:	eafffd81 	b	2180 <zlib_inflate+0x86c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:457
    2b78:	e59dc030 	ldr	ip, [sp, #48]	; 0x30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:458
    2b7c:	e3a0201b 	mov	r2, #27
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:457
    2b80:	e59d4014 	ldr	r4, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:459
    2b84:	e1a03002 	mov	r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:457
    2b88:	e584c018 	str	ip, [r4, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:458
    2b8c:	e58b2000 	str	r2, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:459
    2b90:	eafffb8e 	b	19d0 <zlib_inflate+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:497
    2b94:	e3520010 	cmp	r2, #16
    2b98:	0a00006a 	beq	2d48 <zlib_inflate+0x1434>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:509
    2b9c:	e3520011 	cmp	r2, #17
    2ba0:	0a000094 	beq	2df8 <zlib_inflate+0x14e4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:517 (discriminator 1)
    2ba4:	e2810007 	add	r0, r1, #7
    2ba8:	e1590000 	cmp	r9, r0
    2bac:	2a00000c 	bcs	2be4 <zlib_inflate+0x12d0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:517
    2bb0:	e3580000 	cmp	r8, #0
    2bb4:	0affff80 	beq	29bc <zlib_inflate+0x10a8>
    2bb8:	e1a0300a 	mov	r3, sl
    2bbc:	ea000001 	b	2bc8 <zlib_inflate+0x12b4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:517 (discriminator 3)
    2bc0:	e3580000 	cmp	r8, #0
    2bc4:	0affff96 	beq	2a24 <zlib_inflate+0x1110>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:517 (discriminator 2)
    2bc8:	e4d32001 	ldrb	r2, [r3], #1
    2bcc:	e2488001 	sub	r8, r8, #1
    2bd0:	e0877912 	add	r7, r7, r2, lsl r9
    2bd4:	e2899008 	add	r9, r9, #8
    2bd8:	e1590000 	cmp	r9, r0
    2bdc:	e1a0a003 	mov	sl, r3
    2be0:	3afffff6 	bcc	2bc0 <zlib_inflate+0x12ac>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:518
    2be4:	e1a07137 	lsr	r7, r7, r1
    2be8:	e30f3ff9 	movw	r3, #65529	; 0xfff9
    2bec:	e34f3fff 	movt	r3, #65535	; 0xffff
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:520
    2bf0:	e207007f 	and	r0, r7, #127	; 0x7f
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:518
    2bf4:	e0613003 	rsb	r3, r1, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:520
    2bf8:	e280000b 	add	r0, r0, #11
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:521
    2bfc:	e1a073a7 	lsr	r7, r7, #7
    2c00:	e0899003 	add	r9, r9, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:519
    2c04:	e3a01000 	mov	r1, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:523
    2c08:	e0800004 	add	r0, r0, r4
    2c0c:	e1500005 	cmp	r0, r5
    2c10:	8a000116 	bhi	3070 <zlib_inflate+0x175c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:317 (discriminator 1)
    2c14:	e59dc040 	ldr	ip, [sp, #64]	; 0x40
    2c18:	e08b3084 	add	r3, fp, r4, lsl #1
    2c1c:	e283306a 	add	r3, r3, #106	; 0x6a
    2c20:	e08c2080 	add	r2, ip, r0, lsl #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:529
    2c24:	e1e310b2 	strh	r1, [r3, #2]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:528
    2c28:	e1530002 	cmp	r3, r2
    2c2c:	1afffffc 	bne	2c24 <zlib_inflate+0x1310>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:529
    2c30:	e1a04000 	mov	r4, r0
    2c34:	e58b0064 	str	r0, [fp, #100]	; 0x64
    2c38:	eafffe24 	b	24d0 <zlib_inflate+0xbbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:559
    2c3c:	e59dc014 	ldr	ip, [sp, #20]
    2c40:	e59d4028 	ldr	r4, [sp, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:560
    2c44:	e59d1020 	ldr	r1, [sp, #32]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:559
    2c48:	e58ca000 	str	sl, [ip]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:560
    2c4c:	e1a0000c 	mov	r0, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:559
    2c50:	e58c400c 	str	r4, [ip, #12]
    2c54:	e59d400c 	ldr	r4, [sp, #12]
    2c58:	e58c8004 	str	r8, [ip, #4]
    2c5c:	e58c4010 	str	r4, [ip, #16]
    2c60:	e58b7034 	str	r7, [fp, #52]	; 0x34
    2c64:	e58b9038 	str	r9, [fp, #56]	; 0x38
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:560
    2c68:	ebfff94d 	bl	11a4 <inflate_fast>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:561
    2c6c:	e59dc014 	ldr	ip, [sp, #20]
    2c70:	e59d4014 	ldr	r4, [sp, #20]
    2c74:	e59b7034 	ldr	r7, [fp, #52]	; 0x34
    2c78:	e59cc00c 	ldr	ip, [ip, #12]
    2c7c:	e5944010 	ldr	r4, [r4, #16]
    2c80:	e59b9038 	ldr	r9, [fp, #56]	; 0x38
    2c84:	e58dc028 	str	ip, [sp, #40]	; 0x28
    2c88:	e59dc014 	ldr	ip, [sp, #20]
    2c8c:	e58d400c 	str	r4, [sp, #12]
    2c90:	e59b3000 	ldr	r3, [fp]
    2c94:	e59ca000 	ldr	sl, [ip]
    2c98:	e59c8004 	ldr	r8, [ip, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:562
    2c9c:	eafffb4b 	b	19d0 <zlib_inflate+0xbc>
    2ca0:	e1a0500a 	mov	r5, sl
    2ca4:	e59da040 	ldr	sl, [sp, #64]	; 0x40
    2ca8:	eaffff5f 	b	2a2c <zlib_inflate+0x1118>
zlib_fixedtables():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:81
    2cac:	e59d4034 	ldr	r4, [sp, #52]	; 0x34
zlib_inflate():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:409
    2cb0:	e3a01012 	mov	r1, #18
zlib_fixedtables():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:83
    2cb4:	e59dc018 	ldr	ip, [sp, #24]
zlib_inflate():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:410
    2cb8:	e1a03001 	mov	r3, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:409
    2cbc:	e58b1000 	str	r1, [fp]
zlib_fixedtables():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:83
    2cc0:	e28c0c09 	add	r0, ip, #2304	; 0x900
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:81
    2cc4:	e58b4048 	str	r4, [fp, #72]	; 0x48
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:82
    2cc8:	e3a0c009 	mov	ip, #9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:83
    2ccc:	e58b004c 	str	r0, [fp, #76]	; 0x4c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:82
    2cd0:	e58bc050 	str	ip, [fp, #80]	; 0x50
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:84
    2cd4:	e3a00005 	mov	r0, #5
    2cd8:	e58b0054 	str	r0, [fp, #84]	; 0x54
zlib_inflate():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:410
    2cdc:	eafffb9b 	b	1b50 <zlib_inflate+0x23c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:579
    2ce0:	e1a07337 	lsr	r7, r7, r3
    2ce4:	e0639009 	rsb	r9, r3, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:580
    2ce8:	e58b003c 	str	r0, [fp, #60]	; 0x3c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:582
    2cec:	e3a03017 	mov	r3, #23
    2cf0:	e58b3000 	str	r3, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:583
    2cf4:	eafffb35 	b	19d0 <zlib_inflate+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:412
    2cf8:	e3a0300f 	mov	r3, #15
    2cfc:	e58b3000 	str	r3, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:413
    2d00:	eafffb92 	b	1b50 <zlib_inflate+0x23c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:429
    2d04:	e3a09000 	mov	r9, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:430
    2d08:	e3a0200e 	mov	r2, #14
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:429
    2d0c:	e1a07009 	mov	r7, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:428
    2d10:	e58b303c 	str	r3, [fp, #60]	; 0x3c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:430
    2d14:	e58b2000 	str	r2, [fp]
    2d18:	eafffc63 	b	1eac <zlib_inflate+0x598>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:363
    2d1c:	e207200f 	and	r2, r7, #15
    2d20:	e3520008 	cmp	r2, #8
    2d24:	0a00004d 	beq	2e60 <zlib_inflate+0x154c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:364
    2d28:	e59dc014 	ldr	ip, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:365
    2d2c:	e3a0201b 	mov	r2, #27
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:364
    2d30:	e51f15ec 	ldr	r1, [pc, #-1516]	; 274c <zlib_inflate+0xe38>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:366
    2d34:	e1a03002 	mov	r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:364
    2d38:	e08f1001 	add	r1, pc, r1
    2d3c:	e58c1018 	str	r1, [ip, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:365
    2d40:	e58b2000 	str	r2, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:366
    2d44:	eafffb21 	b	19d0 <zlib_inflate+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:498 (discriminator 1)
    2d48:	e2810002 	add	r0, r1, #2
    2d4c:	e1590000 	cmp	r9, r0
    2d50:	2a00000c 	bcs	2d88 <zlib_inflate+0x1474>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:498
    2d54:	e3580000 	cmp	r8, #0
    2d58:	0affff31 	beq	2a24 <zlib_inflate+0x1110>
    2d5c:	e1a0300a 	mov	r3, sl
    2d60:	ea000001 	b	2d6c <zlib_inflate+0x1458>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:498 (discriminator 3)
    2d64:	e3580000 	cmp	r8, #0
    2d68:	0affff2d 	beq	2a24 <zlib_inflate+0x1110>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:498 (discriminator 2)
    2d6c:	e4d32001 	ldrb	r2, [r3], #1
    2d70:	e2488001 	sub	r8, r8, #1
    2d74:	e0877912 	add	r7, r7, r2, lsl r9
    2d78:	e2899008 	add	r9, r9, #8
    2d7c:	e1590000 	cmp	r9, r0
    2d80:	e1a0a003 	mov	sl, r3
    2d84:	3afffff6 	bcc	2d64 <zlib_inflate+0x1450>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:500
    2d88:	e3540000 	cmp	r4, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:499
    2d8c:	e1a07137 	lsr	r7, r7, r1
    2d90:	e0619009 	rsb	r9, r1, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:500
    2d94:	0a0000bd 	beq	3090 <zlib_inflate+0x177c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:505
    2d98:	e08b3084 	add	r3, fp, r4, lsl #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:506
    2d9c:	e2070003 	and	r0, r7, #3
    2da0:	e2800003 	add	r0, r0, #3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:507
    2da4:	e1a07127 	lsr	r7, r7, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:505
    2da8:	e1d316ba 	ldrh	r1, [r3, #106]	; 0x6a
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:507
    2dac:	e2499002 	sub	r9, r9, #2
    2db0:	eaffff94 	b	2c08 <zlib_inflate+0x12f4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:579
    2db4:	e1a07337 	lsr	r7, r7, r3
    2db8:	e0639009 	rsb	r9, r3, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:580
    2dbc:	e58b003c 	str	r0, [fp, #60]	; 0x3c
    2dc0:	eafffe39 	b	26ac <zlib_inflate+0xd98>
    2dc4:	e59d3010 	ldr	r3, [sp, #16]
    2dc8:	e1a0500a 	mov	r5, sl
    2dcc:	e59d402c 	ldr	r4, [sp, #44]	; 0x2c
    2dd0:	e1a0a00b 	mov	sl, fp
    2dd4:	e2733001 	rsbs	r3, r3, #1
    2dd8:	e59db014 	ldr	fp, [sp, #20]
    2ddc:	33a03000 	movcc	r3, #0
    2de0:	e58d3018 	str	r3, [sp, #24]
    2de4:	e3540002 	cmp	r4, #2
    2de8:	13a03000 	movne	r3, #0
    2dec:	02033001 	andeq	r3, r3, #1
    2df0:	e58d301c 	str	r3, [sp, #28]
    2df4:	eafffce1 	b	2180 <zlib_inflate+0x86c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:510 (discriminator 1)
    2df8:	e2810003 	add	r0, r1, #3
    2dfc:	e1590000 	cmp	r9, r0
    2e00:	2a00000c 	bcs	2e38 <zlib_inflate+0x1524>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:510
    2e04:	e3580000 	cmp	r8, #0
    2e08:	0affff05 	beq	2a24 <zlib_inflate+0x1110>
    2e0c:	e1a0300a 	mov	r3, sl
    2e10:	ea000001 	b	2e1c <zlib_inflate+0x1508>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:510 (discriminator 3)
    2e14:	e3580000 	cmp	r8, #0
    2e18:	0affff01 	beq	2a24 <zlib_inflate+0x1110>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:510 (discriminator 2)
    2e1c:	e4d32001 	ldrb	r2, [r3], #1
    2e20:	e2488001 	sub	r8, r8, #1
    2e24:	e0877912 	add	r7, r7, r2, lsl r9
    2e28:	e2899008 	add	r9, r9, #8
    2e2c:	e1590000 	cmp	r9, r0
    2e30:	e1a0a003 	mov	sl, r3
    2e34:	3afffff6 	bcc	2e14 <zlib_inflate+0x1500>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:511
    2e38:	e1a07137 	lsr	r7, r7, r1
    2e3c:	e30f3ffd 	movw	r3, #65533	; 0xfffd
    2e40:	e34f3fff 	movt	r3, #65535	; 0xffff
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:513
    2e44:	e2070007 	and	r0, r7, #7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:511
    2e48:	e0613003 	rsb	r3, r1, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:513
    2e4c:	e2800003 	add	r0, r0, #3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:514
    2e50:	e1a071a7 	lsr	r7, r7, #3
    2e54:	e0899003 	add	r9, r9, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:512
    2e58:	e3a01000 	mov	r1, #0
    2e5c:	eaffff69 	b	2c08 <zlib_inflate+0x12f4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:368
    2e60:	e1a07227 	lsr	r7, r7, #4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:370
    2e64:	e59b2020 	ldr	r2, [fp, #32]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:369
    2e68:	e207100f 	and	r1, r7, #15
    2e6c:	e2811008 	add	r1, r1, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:370
    2e70:	e1510002 	cmp	r1, r2
    2e74:	9a000012 	bls	2ec4 <zlib_inflate+0x15b0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:371
    2e78:	e59d4014 	ldr	r4, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:372
    2e7c:	e3a0201b 	mov	r2, #27
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:371
    2e80:	e51f1738 	ldr	r1, [pc, #-1848]	; 2750 <zlib_inflate+0xe3c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:368
    2e84:	e2499004 	sub	r9, r9, #4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:373
    2e88:	e1a03002 	mov	r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:371
    2e8c:	e08f1001 	add	r1, pc, r1
    2e90:	e5841018 	str	r1, [r4, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:372
    2e94:	e58b2000 	str	r2, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:373
    2e98:	eafffacc 	b	19d0 <zlib_inflate+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:594
    2e9c:	e201100f 	and	r1, r1, #15
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:595
    2ea0:	e3a03013 	mov	r3, #19
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:594
    2ea4:	e58b1044 	str	r1, [fp, #68]	; 0x44
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:595
    2ea8:	e58b3000 	str	r3, [fp]
    2eac:	eafffb31 	b	1b78 <zlib_inflate+0x264>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:483
    2eb0:	e59d4010 	ldr	r4, [sp, #16]
    2eb4:	e3a03011 	mov	r3, #17
    2eb8:	e58b3000 	str	r3, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:482
    2ebc:	e58b4064 	str	r4, [fp, #100]	; 0x64
    2ec0:	eafffd7b 	b	24b4 <zlib_inflate+0xba0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:376
    2ec4:	e59dc014 	ldr	ip, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:377
    2ec8:	e3170c02 	tst	r7, #512	; 0x200
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:375
    2ecc:	e3a02001 	mov	r2, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:378
    2ed0:	e1a09003 	mov	r9, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:375
    2ed4:	e1a01112 	lsl	r1, r2, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:376
    2ed8:	e58b2018 	str	r2, [fp, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:377
    2edc:	03a0300b 	moveq	r3, #11
    2ee0:	13a03009 	movne	r3, #9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:375
    2ee4:	e58b1014 	str	r1, [fp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:378
    2ee8:	e1a07009 	mov	r7, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:376
    2eec:	e58c2028 	str	r2, [ip, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:377
    2ef0:	e58b3000 	str	r3, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:379
    2ef4:	eafffab5 	b	19d0 <zlib_inflate+0xbc>
    2ef8:	e1a0500a 	mov	r5, sl
    2efc:	e1a0a00b 	mov	sl, fp
    2f00:	e59db014 	ldr	fp, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:696
    2f04:	e3a02000 	mov	r2, #0
    2f08:	e3a0301a 	mov	r3, #26
    2f0c:	e58d201c 	str	r2, [sp, #28]
    2f10:	e58a3000 	str	r3, [sl]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:698
    2f14:	e3a03001 	mov	r3, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:696
    2f18:	e58d2018 	str	r2, [sp, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:698
    2f1c:	e58d3010 	str	r3, [sp, #16]
    2f20:	eafffc96 	b	2180 <zlib_inflate+0x86c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:534
    2f24:	e59b3000 	ldr	r3, [fp]
    2f28:	e353001b 	cmp	r3, #27
    2f2c:	0afffaa7 	beq	19d0 <zlib_inflate+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:540
    2f30:	e28b4068 	add	r4, fp, #104	; 0x68
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:537
    2f34:	e28b3e52 	add	r3, fp, #1312	; 0x520
    2f38:	e283300c 	add	r3, r3, #12
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:539
    2f3c:	e3a02009 	mov	r2, #9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:537
    2f40:	e58b3068 	str	r3, [fp, #104]	; 0x68
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:541
    2f44:	e28b5fbb 	add	r5, fp, #748	; 0x2ec
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:538
    2f48:	e58b3048 	str	r3, [fp, #72]	; 0x48
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:540
    2f4c:	e3a00001 	mov	r0, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:539
    2f50:	e58b2050 	str	r2, [fp, #80]	; 0x50
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:540
    2f54:	e28b3050 	add	r3, fp, #80	; 0x50
    2f58:	e28b106c 	add	r1, fp, #108	; 0x6c
    2f5c:	e88d0028 	stm	sp, {r3, r5}
    2f60:	e1a03004 	mov	r3, r4
    2f64:	e59d203c 	ldr	r2, [sp, #60]	; 0x3c
    2f68:	ebfff72a 	bl	c18 <zlib_inflate_table>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:542
    2f6c:	e3500000 	cmp	r0, #0
    2f70:	e58d0010 	str	r0, [sp, #16]
    2f74:	0a000014 	beq	2fcc <zlib_inflate+0x16b8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:543
    2f78:	e59dc014 	ldr	ip, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:544
    2f7c:	e3a0201b 	mov	r2, #27
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:543
    2f80:	e51f1834 	ldr	r1, [pc, #-2100]	; 2754 <zlib_inflate+0xe40>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:545
    2f84:	e1a03002 	mov	r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:543
    2f88:	e08f1001 	add	r1, pc, r1
    2f8c:	e58c1018 	str	r1, [ip, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:544
    2f90:	e58b2000 	str	r2, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:545
    2f94:	eafffa8d 	b	19d0 <zlib_inflate+0xbc>
    2f98:	e1a0500a 	mov	r5, sl
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:387
    2f9c:	e59d4028 	ldr	r4, [sp, #40]	; 0x28
    2fa0:	e1a0a00b 	mov	sl, fp
    2fa4:	e59db014 	ldr	fp, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:388
    2fa8:	e3a0c002 	mov	ip, #2
    2fac:	e58dc010 	str	ip, [sp, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:387
    2fb0:	e58b400c 	str	r4, [fp, #12]
    2fb4:	e59d400c 	ldr	r4, [sp, #12]
    2fb8:	e88b0120 	stm	fp, {r5, r8}
    2fbc:	e58b4010 	str	r4, [fp, #16]
    2fc0:	e58a7034 	str	r7, [sl, #52]	; 0x34
    2fc4:	e58a9038 	str	r9, [sl, #56]	; 0x38
    2fc8:	eafffc3b 	b	20bc <zlib_inflate+0x7a8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:549
    2fcc:	e59b105c 	ldr	r1, [fp, #92]	; 0x5c
    2fd0:	e28b3054 	add	r3, fp, #84	; 0x54
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:547
    2fd4:	e59bc068 	ldr	ip, [fp, #104]	; 0x68
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:548
    2fd8:	e3a0e006 	mov	lr, #6
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:549
    2fdc:	e59b2060 	ldr	r2, [fp, #96]	; 0x60
    2fe0:	e3a00002 	mov	r0, #2
    2fe4:	e08b1081 	add	r1, fp, r1, lsl #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:548
    2fe8:	e58be054 	str	lr, [fp, #84]	; 0x54
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:547
    2fec:	e58bc04c 	str	ip, [fp, #76]	; 0x4c
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:549
    2ff0:	e281106c 	add	r1, r1, #108	; 0x6c
    2ff4:	e88d0028 	stm	sp, {r3, r5}
    2ff8:	e1a03004 	mov	r3, r4
    2ffc:	ebfff705 	bl	c18 <zlib_inflate_table>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:551
    3000:	e3500000 	cmp	r0, #0
    3004:	e58d0010 	str	r0, [sp, #16]
    3008:	0afffd56 	beq	2568 <zlib_inflate+0xc54>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:552
    300c:	e59d4014 	ldr	r4, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:553
    3010:	e3a0201b 	mov	r2, #27
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:552
    3014:	e51f18c4 	ldr	r1, [pc, #-2244]	; 2758 <zlib_inflate+0xe44>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:554
    3018:	e1a03002 	mov	r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:552
    301c:	e08f1001 	add	r1, pc, r1
    3020:	e5841018 	str	r1, [r4, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:553
    3024:	e58b2000 	str	r2, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:554
    3028:	eafffa68 	b	19d0 <zlib_inflate+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:688
    302c:	e59dc00c 	ldr	ip, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:694
    3030:	e3a09000 	mov	r9, #0
    3034:	e1a0500a 	mov	r5, sl
    3038:	e1a07009 	mov	r7, r9
    303c:	e1a0a00b 	mov	sl, fp
    3040:	e59db014 	ldr	fp, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:688
    3044:	e58dc020 	str	ip, [sp, #32]
    3048:	eaffffad 	b	2f04 <zlib_inflate+0x15f0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:720
    304c:	e59b2004 	ldr	r2, [fp, #4]
    3050:	e59d4024 	ldr	r4, [sp, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:721
    3054:	e58d300c 	str	r3, [sp, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:722
    3058:	e59b3008 	ldr	r3, [fp, #8]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:720
    305c:	e0622004 	rsb	r2, r2, r4
    3060:	e58d2014 	str	r2, [sp, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:722
    3064:	e0833002 	add	r3, r3, r2
    3068:	e58b3008 	str	r3, [fp, #8]
    306c:	eafffcd4 	b	23c4 <zlib_inflate+0xab0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:524
    3070:	e59d4014 	ldr	r4, [sp, #20]
    3074:	e51f3920 	ldr	r3, [pc, #-2336]	; 275c <zlib_inflate+0xe48>
    3078:	e08f3003 	add	r3, pc, r3
    307c:	e5843018 	str	r3, [r4, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:525
    3080:	e3a0301b 	mov	r3, #27
    3084:	e58b3000 	str	r3, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:692
    3088:	e3a0301b 	mov	r3, #27
    308c:	eafffa4f 	b	19d0 <zlib_inflate+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:501
    3090:	e59dc014 	ldr	ip, [sp, #20]
    3094:	e51f393c 	ldr	r3, [pc, #-2364]	; 2760 <zlib_inflate+0xe4c>
    3098:	e08f3003 	add	r3, pc, r3
    309c:	e58c3018 	str	r3, [ip, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:502
    30a0:	e3a0301b 	mov	r3, #27
    30a4:	e58b3000 	str	r3, [fp]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:503
    30a8:	eafffff6 	b	3088 <zlib_inflate+0x1774>

000030ac <zlib_inflateEnd>:
zlib_inflateEnd():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:744
    30ac:	e3500000 	cmp	r0, #0
    30b0:	0a000004 	beq	30c8 <zlib_inflateEnd+0x1c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:744 (discriminator 1)
    30b4:	e590301c 	ldr	r3, [r0, #28]
    30b8:	e3530000 	cmp	r3, #0
    30bc:	0a000001 	beq	30c8 <zlib_inflateEnd+0x1c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:746
    30c0:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:747
    30c4:	e12fff1e 	bx	lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:745
    30c8:	e3e00001 	mvn	r0, #1
    30cc:	e12fff1e 	bx	lr

000030d0 <zlib_inflateIncomp>:
zlib_inflateIncomp():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:758
    30d0:	e92d4ff0 	push	{r4, r5, r6, r7, r8, r9, sl, fp, lr}
    30d4:	e24dd00c 	sub	sp, sp, #12
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:759
    30d8:	e590201c 	ldr	r2, [r0, #28]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:758
    30dc:	e1a09000 	mov	r9, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:760
    30e0:	e590400c 	ldr	r4, [r0, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:761
    30e4:	e5905010 	ldr	r5, [r0, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:763
    30e8:	e5923000 	ldr	r3, [r2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:759
    30ec:	e58d2004 	str	r2, [sp, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:763
    30f0:	e3530000 	cmp	r3, #0
    30f4:	1353000b 	cmpne	r3, #11
    30f8:	03a03000 	moveq	r3, #0
    30fc:	13a03001 	movne	r3, #1
    3100:	1a000080 	bne	3308 <zlib_inflateIncomp+0x238>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:768
    3104:	e5901004 	ldr	r1, [r0, #4]
    3108:	e5902000 	ldr	r2, [r0]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:767
    310c:	e5803010 	str	r3, [r0, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:768
    3110:	e0823001 	add	r3, r2, r1
    3114:	e580300c 	str	r3, [r0, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:770
    3118:	ebfff68c 	bl	b50 <zlib_updatewindow>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:777
    311c:	e59d3004 	ldr	r3, [sp, #4]
    3120:	e5998000 	ldr	r8, [r9]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:773
    3124:	e5895010 	str	r5, [r9, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:774
    3128:	e589400c 	str	r4, [r9, #12]
zlib_adler32():
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:86
    312c:	e3580000 	cmp	r8, #0
zlib_inflateIncomp():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:777
    3130:	e5931018 	ldr	r1, [r3, #24]
    3134:	e5990004 	ldr	r0, [r9, #4]
zlib_adler32():
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:82
    3138:	e6ff5071 	uxth	r5, r1
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:83
    313c:	e1a01821 	lsr	r1, r1, #16
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:86
    3140:	03a01001 	moveq	r1, #1
    3144:	0a000059 	beq	32b0 <zlib_inflateIncomp+0x1e0>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:88
    3148:	e3500000 	cmp	r0, #0
    314c:	0a000056 	beq	32ac <zlib_inflateIncomp+0x1dc>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:100
    3150:	e308b071 	movw	fp, #32881	; 0x8071
    3154:	e348b007 	movt	fp, #32775	; 0x8007
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:89
    3158:	e30175b0 	movw	r7, #5552	; 0x15b0
    315c:	e1500007 	cmp	r0, r7
    3160:	31a07000 	movcc	r7, r0
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:91
    3164:	e357000f 	cmp	r7, #15
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:90
    3168:	e0670000 	rsb	r0, r7, r0
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:89
    316c:	e1a02007 	mov	r2, r7
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:91
    3170:	da000039 	ble	325c <zlib_inflateIncomp+0x18c>
    3174:	e1a03008 	mov	r3, r8
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:92
    3178:	e5d3c000 	ldrb	ip, [r3]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:94
    317c:	e2422010 	sub	r2, r2, #16
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:92
    3180:	e5d34001 	ldrb	r4, [r3, #1]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:91
    3184:	e352000f 	cmp	r2, #15
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:92
    3188:	e085500c 	add	r5, r5, ip
    318c:	e5d3c002 	ldrb	ip, [r3, #2]
    3190:	e0854004 	add	r4, r5, r4
    3194:	e5d3a003 	ldrb	sl, [r3, #3]
    3198:	e084c00c 	add	ip, r4, ip
    319c:	e5d36004 	ldrb	r6, [r3, #4]
    31a0:	e0845005 	add	r5, r4, r5
    31a4:	e08ca00a 	add	sl, ip, sl
    31a8:	e085500c 	add	r5, r5, ip
    31ac:	e5d34005 	ldrb	r4, [r3, #5]
    31b0:	e08a6006 	add	r6, sl, r6
    31b4:	e5d3c006 	ldrb	ip, [r3, #6]
    31b8:	e085a00a 	add	sl, r5, sl
    31bc:	e0864004 	add	r4, r6, r4
    31c0:	e5d35007 	ldrb	r5, [r3, #7]
    31c4:	e08aa006 	add	sl, sl, r6
    31c8:	e084c00c 	add	ip, r4, ip
    31cc:	e5d36008 	ldrb	r6, [r3, #8]
    31d0:	e08aa004 	add	sl, sl, r4
    31d4:	e08c5005 	add	r5, ip, r5
    31d8:	e5d34009 	ldrb	r4, [r3, #9]
    31dc:	e08aa00c 	add	sl, sl, ip
    31e0:	e0856006 	add	r6, r5, r6
    31e4:	e5d3c00a 	ldrb	ip, [r3, #10]
    31e8:	e08aa005 	add	sl, sl, r5
    31ec:	e0864004 	add	r4, r6, r4
    31f0:	e5d3500b 	ldrb	r5, [r3, #11]
    31f4:	e08aa006 	add	sl, sl, r6
    31f8:	e084c00c 	add	ip, r4, ip
    31fc:	e5d3600c 	ldrb	r6, [r3, #12]
    3200:	e08aa004 	add	sl, sl, r4
    3204:	e08c5005 	add	r5, ip, r5
    3208:	e08aa00c 	add	sl, sl, ip
    320c:	e5d3400d 	ldrb	r4, [r3, #13]
    3210:	e0856006 	add	r6, r5, r6
    3214:	e5d3c00e 	ldrb	ip, [r3, #14]
    3218:	e08a5005 	add	r5, sl, r5
    321c:	e0864004 	add	r4, r6, r4
    3220:	e5d3a00f 	ldrb	sl, [r3, #15]
    3224:	e0855006 	add	r5, r5, r6
    3228:	e084c00c 	add	ip, r4, ip
    322c:	e0854004 	add	r4, r5, r4
    3230:	e08c500a 	add	r5, ip, sl
    3234:	e084c00c 	add	ip, r4, ip
    3238:	e08cc005 	add	ip, ip, r5
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:93
    323c:	e2833010 	add	r3, r3, #16
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:92
    3240:	e081100c 	add	r1, r1, ip
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:91
    3244:	caffffcb 	bgt	3178 <zlib_inflateIncomp+0xa8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:757
    3248:	e2472010 	sub	r2, r7, #16
    324c:	e1a03222 	lsr	r3, r2, #4
    3250:	e283c001 	add	ip, r3, #1
    3254:	e0422203 	sub	r2, r2, r3, lsl #4
    3258:	e088820c 	add	r8, r8, ip, lsl #4
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:96
    325c:	e3520000 	cmp	r2, #0
    3260:	0a000005 	beq	327c <zlib_inflateIncomp+0x1ac>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:757
    3264:	e0882002 	add	r2, r8, r2
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:97
    3268:	e4d83001 	ldrb	r3, [r8], #1
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:99
    326c:	e1580002 	cmp	r8, r2
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:97
    3270:	e0855003 	add	r5, r5, r3
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:98
    3274:	e0811005 	add	r1, r1, r5
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:99
    3278:	1afffffa 	bne	3268 <zlib_inflateIncomp+0x198>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:100
    327c:	e082c59b 	umull	ip, r2, fp, r5
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:88
    3280:	e3500000 	cmp	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:101
    3284:	e083c19b 	umull	ip, r3, fp, r1
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:100
    3288:	e1a027a2 	lsr	r2, r2, #15
    328c:	e062c602 	rsb	ip, r2, r2, lsl #12
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:101
    3290:	e1a037a3 	lsr	r3, r3, #15
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:100
    3294:	e082220c 	add	r2, r2, ip, lsl #4
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:101
    3298:	e063c603 	rsb	ip, r3, r3, lsl #12
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:100
    329c:	e0625005 	rsb	r5, r2, r5
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:101
    32a0:	e083320c 	add	r3, r3, ip, lsl #4
    32a4:	e0631001 	rsb	r1, r3, r1
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:88
    32a8:	1affffaa 	bne	3158 <zlib_inflateIncomp+0x88>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/zutil.h:103
    32ac:	e1851801 	orr	r1, r5, r1, lsl #16
zlib_inflateIncomp():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:776
    32b0:	e59d2004 	ldr	r2, [sp, #4]
    32b4:	e5821018 	str	r1, [r2, #24]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:783
    32b8:	e3a02000 	mov	r2, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:779
    32bc:	e5993004 	ldr	r3, [r9, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:785
    32c0:	e1a00002 	mov	r0, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:780
    32c4:	e599c008 	ldr	ip, [r9, #8]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:779
    32c8:	e5995014 	ldr	r5, [r9, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:780
    32cc:	e08cc003 	add	ip, ip, r3
    32d0:	e589c008 	str	ip, [r9, #8]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:782
    32d4:	e59dc004 	ldr	ip, [sp, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:779
    32d8:	e0855003 	add	r5, r5, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:781
    32dc:	e5994000 	ldr	r4, [r9]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:776
    32e0:	e5891028 	str	r1, [r9, #40]	; 0x28
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:779
    32e4:	e5895014 	str	r5, [r9, #20]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:781
    32e8:	e0841003 	add	r1, r4, r3
    32ec:	e5891000 	str	r1, [r9]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:782
    32f0:	e59c101c 	ldr	r1, [ip, #28]
    32f4:	e0813003 	add	r3, r1, r3
    32f8:	e58c301c 	str	r3, [ip, #28]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:783
    32fc:	e5892004 	str	r2, [r9, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:786
    3300:	e28dd00c 	add	sp, sp, #12
    3304:	e8bd8ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp, pc}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/zlib_inflate/inflate.c:764
    3308:	e3e00002 	mvn	r0, #2
    330c:	eafffffb 	b	3300 <zlib_inflateIncomp+0x230>

00003310 <do_decompress>:
do_decompress():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/decompress.c:59
    3310:	e92d47f0 	push	{r4, r5, r6, r7, r8, r9, sl, lr}
gunzip():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:54
    3314:	e2529000 	subs	r9, r2, #0
do_decompress():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/decompress.c:59
    3318:	e59f42c4 	ldr	r4, [pc, #708]	; 35e4 <do_decompress+0x2d4>
    331c:	e1a05000 	mov	r5, r0
    3320:	e1a06001 	mov	r6, r1
    3324:	e1a08003 	mov	r8, r3
    3328:	e08f4004 	add	r4, pc, r4
gunzip():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:54
    332c:	0a00009b 	beq	35a0 <do_decompress+0x290>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:59
    3330:	e3500000 	cmp	r0, #0
    3334:	11a0a000 	movne	sl, r0
    3338:	0a000081 	beq	3544 <do_decompress+0x234>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:70
    333c:	e3a00030 	mov	r0, #48	; 0x30
    3340:	ebfff5dd 	bl	abc <malloc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:71
    3344:	e2507000 	subs	r7, r0, #0
    3348:	0a000087 	beq	356c <do_decompress+0x25c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:76
    334c:	e302052c 	movw	r0, #9516	; 0x252c
    3350:	ebfff5d9 	bl	abc <malloc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:78
    3354:	e3500000 	cmp	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:76
    3358:	e5870020 	str	r0, [r7, #32]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:78
    335c:	0a000087 	beq	3580 <do_decompress+0x270>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:86
    3360:	e3560000 	cmp	r6, #0
    3364:	0a000071 	beq	3530 <do_decompress+0x220>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:90
    3368:	e3560009 	cmp	r6, #9
    336c:	ca000030 	bgt	3434 <do_decompress+0x124>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:94
    3370:	e59f0270 	ldr	r0, [pc, #624]	; 35e8 <do_decompress+0x2d8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:47
    3374:	e3e06000 	mvn	r6, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:94
    3378:	e08f0000 	add	r0, pc, r0
    337c:	e12fff38 	blx	r8
free():
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:56
    3380:	e59f3264 	ldr	r3, [pc, #612]	; 35ec <do_decompress+0x2dc>
    3384:	e7943003 	ldr	r3, [r4, r3]
    3388:	e5932000 	ldr	r2, [r3]
    338c:	e2422001 	sub	r2, r2, #1
    3390:	e5832000 	str	r2, [r3]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:57
    3394:	e3520000 	cmp	r2, #0
    3398:	0a00000d 	beq	33d4 <do_decompress+0xc4>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:56
    339c:	e2422001 	sub	r2, r2, #1
    33a0:	e5832000 	str	r2, [r3]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:57
    33a4:	e3520000 	cmp	r2, #0
    33a8:	1a000005 	bne	33c4 <do_decompress+0xb4>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:58
    33ac:	e59f323c 	ldr	r3, [pc, #572]	; 35f0 <do_decompress+0x2e0>
    33b0:	e7942003 	ldr	r2, [r4, r3]
    33b4:	e59f3238 	ldr	r3, [pc, #568]	; 35f4 <do_decompress+0x2e4>
    33b8:	e5922000 	ldr	r2, [r2]
    33bc:	e7943003 	ldr	r3, [r4, r3]
    33c0:	e5832000 	str	r2, [r3]
gunzip():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:175
    33c4:	e3550000 	cmp	r5, #0
    33c8:	0a00000b 	beq	33fc <do_decompress+0xec>
do_decompress():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/decompress.c:61
    33cc:	e1a00006 	mov	r0, r6
    33d0:	e8bd87f0 	pop	{r4, r5, r6, r7, r8, r9, sl, pc}
free():
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:58
    33d4:	e59f2214 	ldr	r2, [pc, #532]	; 35f0 <do_decompress+0x2e0>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:56
    33d8:	e3e00000 	mvn	r0, #0
gunzip():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:175
    33dc:	e3550000 	cmp	r5, #0
free():
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:58
    33e0:	e7941002 	ldr	r1, [r4, r2]
    33e4:	e59f2208 	ldr	r2, [pc, #520]	; 35f4 <do_decompress+0x2e4>
    33e8:	e7942002 	ldr	r2, [r4, r2]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:56
    33ec:	e5830000 	str	r0, [r3]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:58
    33f0:	e5913000 	ldr	r3, [r1]
    33f4:	e5823000 	str	r3, [r2]
gunzip():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:175
    33f8:	1afffff3 	bne	33cc <do_decompress+0xbc>
free():
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:56
    33fc:	e59f31e8 	ldr	r3, [pc, #488]	; 35ec <do_decompress+0x2dc>
    3400:	e7942003 	ldr	r2, [r4, r3]
    3404:	e5923000 	ldr	r3, [r2]
    3408:	e2433001 	sub	r3, r3, #1
    340c:	e5823000 	str	r3, [r2]
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:57
    3410:	e3530000 	cmp	r3, #0
    3414:	1affffec 	bne	33cc <do_decompress+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/include/linux/decompress/mm.h:58
    3418:	e59f31d0 	ldr	r3, [pc, #464]	; 35f0 <do_decompress+0x2e0>
    341c:	e7942003 	ldr	r2, [r4, r3]
    3420:	e59f31cc 	ldr	r3, [pc, #460]	; 35f4 <do_decompress+0x2e4>
    3424:	e5922000 	ldr	r2, [r2]
    3428:	e7943003 	ldr	r3, [r4, r3]
    342c:	e5832000 	str	r2, [r3]
    3430:	eaffffe5 	b	33cc <do_decompress+0xbc>
gunzip():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:90
    3434:	e5da3000 	ldrb	r3, [sl]
    3438:	e353001f 	cmp	r3, #31
    343c:	1affffcb 	bne	3370 <do_decompress+0x60>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:91
    3440:	e5da3001 	ldrb	r3, [sl, #1]
    3444:	e353008b 	cmp	r3, #139	; 0x8b
    3448:	1affffc8 	bne	3370 <do_decompress+0x60>
    344c:	e5da3002 	ldrb	r3, [sl, #2]
    3450:	e3530008 	cmp	r3, #8
    3454:	1affffc5 	bne	3370 <do_decompress+0x60>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:101
    3458:	e28a300a 	add	r3, sl, #10
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:102
    345c:	e246600a 	sub	r6, r6, #10
    3460:	e8870048 	stm	r7, {r3, r6}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:104
    3464:	e5da3003 	ldrb	r3, [sl, #3]
    3468:	e2033008 	and	r3, r3, #8
    346c:	e6ef3073 	uxtb	r3, r3
    3470:	e3530000 	cmp	r3, #0
    3474:	0a000008 	beq	349c <do_decompress+0x18c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:111
    3478:	e3560000 	cmp	r6, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:115
    347c:	e2466001 	sub	r6, r6, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:111
    3480:	0a00004b 	beq	35b4 <do_decompress+0x2a4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:116
    3484:	e5973000 	ldr	r3, [r7]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:115
    3488:	e5876004 	str	r6, [r7, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:116
    348c:	e4d32001 	ldrb	r2, [r3], #1
    3490:	e3520000 	cmp	r2, #0
    3494:	e5873000 	str	r3, [r7]
    3498:	1afffff6 	bne	3478 <do_decompress+0x168>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:119
    349c:	e587900c 	str	r9, [r7, #12]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:122
    34a0:	e1a00007 	mov	r0, r7
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:52
    34a4:	e1e09009 	mvn	r9, r9
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:122
    34a8:	e3e0100e 	mvn	r1, #14
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:120
    34ac:	e5879010 	str	r9, [r7, #16]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:122
    34b0:	ebfff8ff 	bl	18b4 <zlib_inflateInit2>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:125
    34b4:	e5972020 	ldr	r2, [r7, #32]
    34b8:	e3a03000 	mov	r3, #0
    34bc:	e5823024 	str	r3, [r2, #36]	; 0x24
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:126
    34c0:	e5972020 	ldr	r2, [r7, #32]
    34c4:	e5823030 	str	r3, [r2, #48]	; 0x30
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:129
    34c8:	e2506000 	subs	r6, r0, #0
    34cc:	1a000014 	bne	3524 <do_decompress+0x214>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:130
    34d0:	e5973004 	ldr	r3, [r7, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:132
    34d4:	e3a01901 	mov	r1, #16384	; 0x4000
    34d8:	e1a0000a 	mov	r0, sl
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:130
    34dc:	e3530000 	cmp	r3, #0
    34e0:	1a000004 	bne	34f8 <do_decompress+0x1e8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:132
    34e4:	ebfff597 	bl	b48 <nofill>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:133
    34e8:	e3500000 	cmp	r0, #0
    34ec:	ba000035 	blt	35c8 <do_decompress+0x2b8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:138
    34f0:	e587a000 	str	sl, [r7]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:139
    34f4:	e5870004 	str	r0, [r7, #4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:141
    34f8:	e1a00007 	mov	r0, r7
    34fc:	e3a01000 	mov	r1, #0
    3500:	ebfff903 	bl	1914 <zlib_inflate>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:156
    3504:	e3500001 	cmp	r0, #1
    3508:	0a000005 	beq	3524 <do_decompress+0x214>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:159
    350c:	e3500000 	cmp	r0, #0
    3510:	0affffee 	beq	34d0 <do_decompress+0x1c0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:160
    3514:	e59f00dc 	ldr	r0, [pc, #220]	; 35f8 <do_decompress+0x2e8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:161
    3518:	e3e06000 	mvn	r6, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:160
    351c:	e08f0000 	add	r0, pc, r0
    3520:	e12fff38 	blx	r8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:165
    3524:	e1a00007 	mov	r0, r7
    3528:	ebfffedf 	bl	30ac <zlib_inflateEnd>
    352c:	eaffff93 	b	3380 <do_decompress+0x70>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:87
    3530:	e1a0000a 	mov	r0, sl
    3534:	e3a01901 	mov	r1, #16384	; 0x4000
    3538:	ebfff582 	bl	b48 <nofill>
    353c:	e1a06000 	mov	r6, r0
    3540:	eaffff88 	b	3368 <do_decompress+0x58>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:62
    3544:	e3a00901 	mov	r0, #16384	; 0x4000
    3548:	ebfff55b 	bl	abc <malloc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:65
    354c:	e250a000 	subs	sl, r0, #0
    3550:	1a000021 	bne	35dc <do_decompress+0x2cc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:66
    3554:	e59f00a0 	ldr	r0, [pc, #160]	; 35fc <do_decompress+0x2ec>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:47
    3558:	e3e06000 	mvn	r6, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:66
    355c:	e08f0000 	add	r0, pc, r0
    3560:	e12fff38 	blx	r8
do_decompress():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/decompress.c:61
    3564:	e1a00006 	mov	r0, r6
    3568:	e8bd87f0 	pop	{r4, r5, r6, r7, r8, r9, sl, pc}
gunzip():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:72
    356c:	e59f008c 	ldr	r0, [pc, #140]	; 3600 <do_decompress+0x2f0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:47
    3570:	e3e06000 	mvn	r6, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:72
    3574:	e08f0000 	add	r0, pc, r0
    3578:	e12fff38 	blx	r8
    357c:	eaffff90 	b	33c4 <do_decompress+0xb4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:79
    3580:	e59f007c 	ldr	r0, [pc, #124]	; 3604 <do_decompress+0x2f4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:47
    3584:	e3e06000 	mvn	r6, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:79
    3588:	e08f0000 	add	r0, pc, r0
    358c:	e12fff38 	blx	r8
    3590:	e59f3054 	ldr	r3, [pc, #84]	; 35ec <do_decompress+0x2dc>
    3594:	e7943003 	ldr	r3, [r4, r3]
    3598:	e5932000 	ldr	r2, [r3]
    359c:	eaffff7e 	b	339c <do_decompress+0x8c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:55
    35a0:	e59f0060 	ldr	r0, [pc, #96]	; 3608 <do_decompress+0x2f8>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:47
    35a4:	e3e06000 	mvn	r6, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:55
    35a8:	e08f0000 	add	r0, pc, r0
    35ac:	e12fff33 	blx	r3
    35b0:	eaffff85 	b	33cc <do_decompress+0xbc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:112
    35b4:	e59f0050 	ldr	r0, [pc, #80]	; 360c <do_decompress+0x2fc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:47
    35b8:	e3e06000 	mvn	r6, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:112
    35bc:	e08f0000 	add	r0, pc, r0
    35c0:	e12fff38 	blx	r8
    35c4:	eaffff6d 	b	3380 <do_decompress+0x70>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:135
    35c8:	e59f0040 	ldr	r0, [pc, #64]	; 3610 <do_decompress+0x300>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:134
    35cc:	e3e06000 	mvn	r6, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:135
    35d0:	e08f0000 	add	r0, pc, r0
    35d4:	e12fff38 	blx	r8
    35d8:	eaffffd1 	b	3524 <do_decompress+0x214>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:63
    35dc:	e1a06005 	mov	r6, r5
    35e0:	eaffff55 	b	333c <do_decompress+0x2c>
    35e4:	00346f2c 	.word	0x00346f2c
    35e8:	000014f8 	.word	0x000014f8
    35ec:	00000010 	.word	0x00000010
    35f0:	00000024 	.word	0x00000024
    35f4:	00000008 	.word	0x00000008
    35f8:	00001380 	.word	0x00001380
    35fc:	00001294 	.word	0x00001294
    3600:	000012a8 	.word	0x000012a8
    3604:	000012bc 	.word	0x000012bc
    3608:	00001218 	.word	0x00001218
    360c:	000012c4 	.word	0x000012c4
    3610:	000012c0 	.word	0x000012c0

00003614 <memcpy>:
memcpy():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:10
    3614:	e92d4070 	push	{r4, r5, r6, lr}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:14
    3618:	e1a041a2 	lsr	r4, r2, #3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:12
    361c:	e1a0c001 	mov	ip, r1
    3620:	e1a03000 	mov	r3, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:14
    3624:	e1a05004 	mov	r5, r4
    3628:	ea000012 	b	3678 <memcpy+0x64>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:15 (discriminator 2)
    362c:	e5dc6000 	ldrb	r6, [ip]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:9 (discriminator 2)
    3630:	e2833008 	add	r3, r3, #8
    3634:	e28cc008 	add	ip, ip, #8
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:14 (discriminator 2)
    3638:	e2455001 	sub	r5, r5, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:15 (discriminator 2)
    363c:	e5436008 	strb	r6, [r3, #-8]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:16 (discriminator 2)
    3640:	e55c6007 	ldrb	r6, [ip, #-7]
    3644:	e5436007 	strb	r6, [r3, #-7]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:17 (discriminator 2)
    3648:	e55c6006 	ldrb	r6, [ip, #-6]
    364c:	e5436006 	strb	r6, [r3, #-6]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:18 (discriminator 2)
    3650:	e55c6005 	ldrb	r6, [ip, #-5]
    3654:	e5436005 	strb	r6, [r3, #-5]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:19 (discriminator 2)
    3658:	e55c6004 	ldrb	r6, [ip, #-4]
    365c:	e5436004 	strb	r6, [r3, #-4]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:20 (discriminator 2)
    3660:	e55c6003 	ldrb	r6, [ip, #-3]
    3664:	e5436003 	strb	r6, [r3, #-3]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:21 (discriminator 2)
    3668:	e55c6002 	ldrb	r6, [ip, #-2]
    366c:	e5436002 	strb	r6, [r3, #-2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:22 (discriminator 2)
    3670:	e55c6001 	ldrb	r6, [ip, #-1]
    3674:	e5436001 	strb	r6, [r3, #-1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:14 (discriminator 1)
    3678:	e3550000 	cmp	r5, #0
    367c:	caffffea 	bgt	362c <memcpy+0x18>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:9
    3680:	e1c44fc4 	bic	r4, r4, r4, asr #31
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:25
    3684:	e3120004 	tst	r2, #4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:9
    3688:	e1a0c184 	lsl	ip, r4, #3
    368c:	e080300c 	add	r3, r0, ip
    3690:	e081c00c 	add	ip, r1, ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:25
    3694:	0a000009 	beq	36c0 <memcpy+0xac>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:26
    3698:	e7d11184 	ldrb	r1, [r1, r4, lsl #3]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:29
    369c:	e2833004 	add	r3, r3, #4
    36a0:	e28cc004 	add	ip, ip, #4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:26
    36a4:	e7c01184 	strb	r1, [r0, r4, lsl #3]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:27
    36a8:	e55c1003 	ldrb	r1, [ip, #-3]
    36ac:	e5431003 	strb	r1, [r3, #-3]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:28
    36b0:	e55c1002 	ldrb	r1, [ip, #-2]
    36b4:	e5431002 	strb	r1, [r3, #-2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:29
    36b8:	e55c1001 	ldrb	r1, [ip, #-1]
    36bc:	e5431001 	strb	r1, [r3, #-1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:32
    36c0:	e3120002 	tst	r2, #2
    36c4:	0a000005 	beq	36e0 <memcpy+0xcc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:33
    36c8:	e5dc1000 	ldrb	r1, [ip]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:34
    36cc:	e2833002 	add	r3, r3, #2
    36d0:	e28cc002 	add	ip, ip, #2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:33
    36d4:	e5431002 	strb	r1, [r3, #-2]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:34
    36d8:	e55c1001 	ldrb	r1, [ip, #-1]
    36dc:	e5431001 	strb	r1, [r3, #-1]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:37
    36e0:	e3120001 	tst	r2, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:38
    36e4:	15dc2000 	ldrbne	r2, [ip]
    36e8:	15c32000 	strbne	r2, [r3]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:41
    36ec:	e8bd8070 	pop	{r4, r5, r6, pc}

000036f0 <memmove>:
memmove():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:48
    36f0:	e1500001 	cmp	r0, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:44
    36f4:	e1a0c000 	mov	ip, r0
    36f8:	e92d4010 	push	{r4, lr}
    36fc:	e1a03002 	mov	r3, r2
    3700:	e1a04001 	mov	r4, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:48
    3704:	0a000006 	beq	3724 <memmove+0x34>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:51
    3708:	2a000003 	bcs	371c <memmove+0x2c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:57
    370c:	e8bd4010 	pop	{r4, lr}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:52
    3710:	eaffffbf 	b	3614 <memcpy>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:55
    3714:	e7d42003 	ldrb	r2, [r4, r3]
    3718:	e7cc2003 	strb	r2, [ip, r3]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:54 (discriminator 1)
    371c:	e2533001 	subs	r3, r3, #1
    3720:	2afffffb 	bcs	3714 <memmove+0x24>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:57
    3724:	e1a0000c 	mov	r0, ip
    3728:	e8bd8010 	pop	{r4, pc}

0000372c <strlen>:
strlen():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:60
    372c:	e1a03000 	mov	r3, r0
    3730:	e1a02003 	mov	r2, r3
    3734:	e2833001 	add	r3, r3, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:63 (discriminator 1)
    3738:	e5d21000 	ldrb	r1, [r2]
    373c:	e3510000 	cmp	r1, #0
    3740:	1afffffa 	bne	3730 <strlen+0x4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:66
    3744:	e0600002 	rsb	r0, r0, r2
    3748:	e12fff1e 	bx	lr

0000374c <memcmp>:
memcmp():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:70
    374c:	e0802002 	add	r2, r0, r2
    3750:	e1a03000 	mov	r3, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:73
    3754:	ea000004 	b	376c <memcmp+0x20>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:74
    3758:	e5d0c000 	ldrb	ip, [r0]
    375c:	e2833001 	add	r3, r3, #1
    3760:	e4d10001 	ldrb	r0, [r1], #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:75
    3764:	e05c0000 	subs	r0, ip, r0
    3768:	112fff1e 	bxne	lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:73 (discriminator 1)
    376c:	e1530002 	cmp	r3, r2
    3770:	e1a00003 	mov	r0, r3
    3774:	3afffff7 	bcc	3758 <memcmp+0xc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:73
    3778:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:79
    377c:	e12fff1e 	bx	lr

00003780 <strcmp>:
strcmp():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:82
    3780:	e3a03000 	mov	r3, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:87
    3784:	e7d02003 	ldrb	r2, [r0, r3]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:89
    3788:	e7d1c003 	ldrb	ip, [r1, r3]
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:90
    378c:	e052c00c 	subs	ip, r2, ip
    3790:	1a000002 	bne	37a0 <strcmp+0x20>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:92
    3794:	e3520000 	cmp	r2, #0
    3798:	e2833001 	add	r3, r3, #1
    379c:	1afffff8 	bne	3784 <strcmp+0x4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:94
    37a0:	e1a0000c 	mov	r0, ip
    37a4:	e12fff1e 	bx	lr

000037a8 <memchr>:
memchr():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:96
    37a8:	e0802002 	add	r2, r0, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:101
    37ac:	e6ef1071 	uxtb	r1, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:100
    37b0:	ea000004 	b	37c8 <memchr+0x20>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:101
    37b4:	e5d0c000 	ldrb	ip, [r0]
    37b8:	e2803001 	add	r3, r0, #1
    37bc:	e15c0001 	cmp	ip, r1
    37c0:	012fff1e 	bxeq	lr
    37c4:	e1a00003 	mov	r0, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:100 (discriminator 1)
    37c8:	e1500002 	cmp	r0, r2
    37cc:	1afffff8 	bne	37b4 <memchr+0xc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:103
    37d0:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:104
    37d4:	e12fff1e 	bx	lr

000037d8 <strchr>:
strchr():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:108
    37d8:	e6ef1071 	uxtb	r1, r1
    37dc:	ea000001 	b	37e8 <strchr+0x10>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:109
    37e0:	e3520000 	cmp	r2, #0
    37e4:	0a000005 	beq	3800 <strchr+0x28>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:108 (discriminator 1)
    37e8:	e5d02000 	ldrb	r2, [r0]
    37ec:	e1a03000 	mov	r3, r0
    37f0:	e2800001 	add	r0, r0, #1
    37f4:	e1520001 	cmp	r2, r1
    37f8:	1afffff8 	bne	37e0 <strchr+0x8>
    37fc:	ea000000 	b	3804 <strchr+0x2c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:110
    3800:	e1a03002 	mov	r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:112
    3804:	e1a00003 	mov	r0, r3
    3808:	e12fff1e 	bx	lr

0000380c <memset>:
memset():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:116
    380c:	e0802002 	add	r2, r0, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:118
    3810:	e1a03000 	mov	r3, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:119
    3814:	ea000000 	b	381c <memset+0x10>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:120
    3818:	e4c31001 	strb	r1, [r3], #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:119 (discriminator 1)
    381c:	e1530002 	cmp	r3, r2
    3820:	1afffffc 	bne	3818 <memset+0xc>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:122
    3824:	e12fff1e 	bx	lr

00003828 <__memzero>:
__memzero():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:125
    3828:	e1a02001 	mov	r2, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/string.c:126
    382c:	e3a01000 	mov	r1, #0
    3830:	eafffff5 	b	380c <memset>
	...

00003840 <__hyp_stub_install>:
__hyp_stub_install_secondary():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:94
    3840:	e10f4000 	mrs	r4, CPSR
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:95
    3844:	e204401f 	and	r4, r4, #31
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:101
    3848:	e1540004 	cmp	r4, r4
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:102
    384c:	112fff1e 	bxne	lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:113
    3850:	e354001a 	cmp	r4, #26
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:114
    3854:	112fff1e 	bxne	lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:127
    3858:	e28f7040 	add	r7, pc, #64	; 0x40
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:128
    385c:	ee8c7f10 	mcr	15, 4, r7, cr12, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:131
    3860:	e3a07000 	mov	r7, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:132
    3864:	ee817f11 	mcr	15, 4, r7, cr1, cr1, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:133
    3868:	ee817f51 	mcr	15, 4, r7, cr1, cr1, {2}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:134
    386c:	ee817f71 	mcr	15, 4, r7, cr1, cr1, {3}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:138
    3870:	ee817f10 	mcr	15, 4, r7, cr1, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:140
    3874:	ee917f31 	mrc	15, 4, r7, cr1, cr1, {1}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:141
    3878:	e207701f 	and	r7, r7, #31
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:142
    387c:	ee817f31 	mcr	15, 4, r7, cr1, cr1, {1}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:164
    3880:	e12fff1e 	bx	lr

00003884 <__hyp_stub_do_trap>:
__hyp_stub_do_trap():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:168
    3884:	e3700001 	cmn	r0, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:169
    3888:	0e9c0f10 	mrceq	15, 4, r0, cr12, cr0, {0}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:170
    388c:	1e8c0f10 	mcrne	15, 4, r0, cr12, cr0, {0}
    3890:	e160006e 	.word	0xe160006e

00003894 <__hyp_get_vectors>:
__hyp_get_vectors():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:197
    3894:	e3e00000 	mvn	r0, #0

00003898 <__hyp_set_vectors>:
__hyp_set_vectors():
    3898:	e1400070 	.word	0xe1400070
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:202
    389c:	e12fff1e 	bx	lr

000038a0 <__hyp_stub_vectors>:
__hyp_stub_vectors():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:213
    38a0:	eafffffe 	b	38a0 <__hyp_stub_vectors>

000038a4 <__hyp_stub_und>:
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:214
    38a4:	eafffffe 	b	38a4 <__hyp_stub_und>

000038a8 <__hyp_stub_svc>:
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:215
    38a8:	eafffffe 	b	38a8 <__hyp_stub_svc>

000038ac <__hyp_stub_pabort>:
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:216
    38ac:	eafffffe 	b	38ac <__hyp_stub_pabort>

000038b0 <__hyp_stub_dabort>:
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:217
    38b0:	eafffffe 	b	38b0 <__hyp_stub_dabort>

000038b4 <__hyp_stub_trap>:
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:218
    38b4:	eafffff2 	b	3884 <__hyp_stub_do_trap>

000038b8 <__hyp_stub_irq>:
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:219
    38b8:	eafffffe 	b	38b8 <__hyp_stub_irq>

000038bc <__hyp_stub_fiq>:
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/hyp-stub.S:220
    38bc:	eafffffe 	b	38bc <__hyp_stub_fiq>

000038c0 <__aeabi_uidiv>:
__udivsi3():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:134
    38c0:	e2512001 	subs	r2, r1, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:135
    38c4:	012fff1e 	bxeq	lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:136
    38c8:	3a0000b8 	bcc	3bb0 <Ldiv0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:137
    38cc:	e1500001 	cmp	r0, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:138
    38d0:	9a00001a 	bls	3940 <__aeabi_uidiv+0x80>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:139
    38d4:	e1110002 	tst	r1, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:140
    38d8:	0a00001b 	beq	394c <__aeabi_uidiv+0x8c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:142
    38dc:	e16f3f11 	clz	r3, r1
    38e0:	e16f2f10 	clz	r2, r0
    38e4:	e0432002 	sub	r2, r3, r2
    38e8:	e3a03001 	mov	r3, #1
    38ec:	e1a01211 	lsl	r1, r1, r2
    38f0:	e1a03213 	lsl	r3, r3, r2
    38f4:	e3a02000 	mov	r2, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:84
    38f8:	e1500001 	cmp	r0, r1
    38fc:	20400001 	subcs	r0, r0, r1
    3900:	21822003 	orrcs	r2, r2, r3
    3904:	e15000a1 	cmp	r0, r1, lsr #1
    3908:	204000a1 	subcs	r0, r0, r1, lsr #1
    390c:	218220a3 	orrcs	r2, r2, r3, lsr #1
    3910:	e1500121 	cmp	r0, r1, lsr #2
    3914:	20400121 	subcs	r0, r0, r1, lsr #2
    3918:	21822123 	orrcs	r2, r2, r3, lsr #2
    391c:	e15001a1 	cmp	r0, r1, lsr #3
    3920:	204001a1 	subcs	r0, r0, r1, lsr #3
    3924:	218221a3 	orrcs	r2, r2, r3, lsr #3
    3928:	e3500000 	cmp	r0, #0
    392c:	11b03223 	lsrsne	r3, r3, #4
    3930:	11a01221 	lsrne	r1, r1, #4
    3934:	1affffef 	bne	38f8 <__aeabi_uidiv+0x38>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:144
    3938:	e1a00002 	mov	r0, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:145
    393c:	e12fff1e 	bx	lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:147
    3940:	03a00001 	moveq	r0, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:148
    3944:	13a00000 	movne	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:149
    3948:	e12fff1e 	bx	lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:151
    394c:	e16f2f11 	clz	r2, r1
    3950:	e262201f 	rsb	r2, r2, #31
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:153
    3954:	e1a00230 	lsr	r0, r0, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:154
    3958:	e12fff1e 	bx	lr

0000395c <__umodsi3>:
__umodsi3():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:163
    395c:	e2512001 	subs	r2, r1, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:164
    3960:	3a000092 	bcc	3bb0 <Ldiv0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:165
    3964:	11500001 	cmpne	r0, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:166
    3968:	03a00000 	moveq	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:167
    396c:	81110002 	tsthi	r1, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:168
    3970:	00000002 	andeq	r0, r0, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:169
    3974:	912fff1e 	bxls	lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:171
    3978:	e16f2f11 	clz	r2, r1
    397c:	e16f3f10 	clz	r3, r0
    3980:	e0422003 	sub	r2, r2, r3
    3984:	e1a01211 	lsl	r1, r1, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:169
    3988:	e2522003 	subs	r2, r2, #3
    398c:	ba00000e 	blt	39cc <__umodsi3+0x70>
    3990:	e1500001 	cmp	r0, r1
    3994:	20400001 	subcs	r0, r0, r1
    3998:	e15000a1 	cmp	r0, r1, lsr #1
    399c:	204000a1 	subcs	r0, r0, r1, lsr #1
    39a0:	e1500121 	cmp	r0, r1, lsr #2
    39a4:	20400121 	subcs	r0, r0, r1, lsr #2
    39a8:	e15001a1 	cmp	r0, r1, lsr #3
    39ac:	204001a1 	subcs	r0, r0, r1, lsr #3
    39b0:	e3500001 	cmp	r0, #1
    39b4:	e1a01221 	lsr	r1, r1, #4
    39b8:	a2522004 	subsge	r2, r2, #4
    39bc:	aafffff3 	bge	3990 <__umodsi3+0x34>
    39c0:	e3120003 	tst	r2, #3
    39c4:	13300000 	teqne	r0, #0
    39c8:	0a00000a 	beq	39f8 <__umodsi3+0x9c>
    39cc:	e3720002 	cmn	r2, #2
    39d0:	ba000006 	blt	39f0 <__umodsi3+0x94>
    39d4:	0a000002 	beq	39e4 <__umodsi3+0x88>
    39d8:	e1500001 	cmp	r0, r1
    39dc:	20400001 	subcs	r0, r0, r1
    39e0:	e1a010a1 	lsr	r1, r1, #1
    39e4:	e1500001 	cmp	r0, r1
    39e8:	20400001 	subcs	r0, r0, r1
    39ec:	e1a010a1 	lsr	r1, r1, #1
    39f0:	e1500001 	cmp	r0, r1
    39f4:	20400001 	subcs	r0, r0, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:173
    39f8:	e12fff1e 	bx	lr

000039fc <__aeabi_idiv>:
__aeabi_idiv():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:182
    39fc:	e3510000 	cmp	r1, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:183
    3a00:	e020c001 	eor	ip, r0, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:184
    3a04:	0a000069 	beq	3bb0 <Ldiv0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:185
    3a08:	42611000 	rsbmi	r1, r1, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:186
    3a0c:	e2512001 	subs	r2, r1, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:187
    3a10:	0a00001f 	beq	3a94 <__aeabi_idiv+0x98>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:188
    3a14:	e1b03000 	movs	r3, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:189
    3a18:	42603000 	rsbmi	r3, r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:190
    3a1c:	e1530001 	cmp	r3, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:191
    3a20:	9a00001e 	bls	3aa0 <__aeabi_idiv+0xa4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:192
    3a24:	e1110002 	tst	r1, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:193
    3a28:	0a000020 	beq	3ab0 <__aeabi_idiv+0xb4>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:195
    3a2c:	e16f2f11 	clz	r2, r1
    3a30:	e16f0f13 	clz	r0, r3
    3a34:	e0420000 	sub	r0, r2, r0
    3a38:	e3a02001 	mov	r2, #1
    3a3c:	e1a01011 	lsl	r1, r1, r0
    3a40:	e1a02012 	lsl	r2, r2, r0
    3a44:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:84
    3a48:	e1530001 	cmp	r3, r1
    3a4c:	20433001 	subcs	r3, r3, r1
    3a50:	21800002 	orrcs	r0, r0, r2
    3a54:	e15300a1 	cmp	r3, r1, lsr #1
    3a58:	204330a1 	subcs	r3, r3, r1, lsr #1
    3a5c:	218000a2 	orrcs	r0, r0, r2, lsr #1
    3a60:	e1530121 	cmp	r3, r1, lsr #2
    3a64:	20433121 	subcs	r3, r3, r1, lsr #2
    3a68:	21800122 	orrcs	r0, r0, r2, lsr #2
    3a6c:	e15301a1 	cmp	r3, r1, lsr #3
    3a70:	204331a1 	subcs	r3, r3, r1, lsr #3
    3a74:	218001a2 	orrcs	r0, r0, r2, lsr #3
    3a78:	e3530000 	cmp	r3, #0
    3a7c:	11b02222 	lsrsne	r2, r2, #4
    3a80:	11a01221 	lsrne	r1, r1, #4
    3a84:	1affffef 	bne	3a48 <__aeabi_idiv+0x4c>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:197
    3a88:	e35c0000 	cmp	ip, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:198
    3a8c:	42600000 	rsbmi	r0, r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:199
    3a90:	e12fff1e 	bx	lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:201
    3a94:	e13c0000 	teq	ip, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:202
    3a98:	42600000 	rsbmi	r0, r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:203
    3a9c:	e12fff1e 	bx	lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:205
    3aa0:	33a00000 	movcc	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:206
    3aa4:	01a00fcc 	asreq	r0, ip, #31
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:207
    3aa8:	03800001 	orreq	r0, r0, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:208
    3aac:	e12fff1e 	bx	lr
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:210
    3ab0:	e16f2f11 	clz	r2, r1
    3ab4:	e262201f 	rsb	r2, r2, #31
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:212
    3ab8:	e35c0000 	cmp	ip, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:213
    3abc:	e1a00233 	lsr	r0, r3, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:214
    3ac0:	42600000 	rsbmi	r0, r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:215
    3ac4:	e12fff1e 	bx	lr

00003ac8 <__modsi3>:
__modsi3():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:224
    3ac8:	e3510000 	cmp	r1, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:225
    3acc:	0a000037 	beq	3bb0 <Ldiv0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:226
    3ad0:	42611000 	rsbmi	r1, r1, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:227
    3ad4:	e1b0c000 	movs	ip, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:228
    3ad8:	42600000 	rsbmi	r0, r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:229
    3adc:	e2512001 	subs	r2, r1, #1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:230
    3ae0:	11500001 	cmpne	r0, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:231
    3ae4:	03a00000 	moveq	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:232
    3ae8:	81110002 	tsthi	r1, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:233
    3aec:	00000002 	andeq	r0, r0, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:234
    3af0:	9a00001f 	bls	3b74 <__modsi3+0xac>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:236
    3af4:	e16f2f11 	clz	r2, r1
    3af8:	e16f3f10 	clz	r3, r0
    3afc:	e0422003 	sub	r2, r2, r3
    3b00:	e1a01211 	lsl	r1, r1, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:169
    3b04:	e2522003 	subs	r2, r2, #3
    3b08:	ba00000e 	blt	3b48 <__modsi3+0x80>
    3b0c:	e1500001 	cmp	r0, r1
    3b10:	20400001 	subcs	r0, r0, r1
    3b14:	e15000a1 	cmp	r0, r1, lsr #1
    3b18:	204000a1 	subcs	r0, r0, r1, lsr #1
    3b1c:	e1500121 	cmp	r0, r1, lsr #2
    3b20:	20400121 	subcs	r0, r0, r1, lsr #2
    3b24:	e15001a1 	cmp	r0, r1, lsr #3
    3b28:	204001a1 	subcs	r0, r0, r1, lsr #3
    3b2c:	e3500001 	cmp	r0, #1
    3b30:	e1a01221 	lsr	r1, r1, #4
    3b34:	a2522004 	subsge	r2, r2, #4
    3b38:	aafffff3 	bge	3b0c <__modsi3+0x44>
    3b3c:	e3120003 	tst	r2, #3
    3b40:	13300000 	teqne	r0, #0
    3b44:	0a00000a 	beq	3b74 <__modsi3+0xac>
    3b48:	e3720002 	cmn	r2, #2
    3b4c:	ba000006 	blt	3b6c <__modsi3+0xa4>
    3b50:	0a000002 	beq	3b60 <__modsi3+0x98>
    3b54:	e1500001 	cmp	r0, r1
    3b58:	20400001 	subcs	r0, r0, r1
    3b5c:	e1a010a1 	lsr	r1, r1, #1
    3b60:	e1500001 	cmp	r0, r1
    3b64:	20400001 	subcs	r0, r0, r1
    3b68:	e1a010a1 	lsr	r1, r1, #1
    3b6c:	e1500001 	cmp	r0, r1
    3b70:	20400001 	subcs	r0, r0, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:238
    3b74:	e35c0000 	cmp	ip, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:239
    3b78:	42600000 	rsbmi	r0, r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:240
    3b7c:	e12fff1e 	bx	lr

00003b80 <__aeabi_uidivmod>:
__aeabi_uidivmod():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:251
    3b80:	e92d5003 	push	{r0, r1, ip, lr}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:252
    3b84:	ebffff4d 	bl	38c0 <__aeabi_uidiv>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:253
    3b88:	e8bd5006 	pop	{r1, r2, ip, lr}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:254
    3b8c:	e0030290 	mul	r3, r0, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:255
    3b90:	e0411003 	sub	r1, r1, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:256
    3b94:	e12fff1e 	bx	lr

00003b98 <__aeabi_idivmod>:
__aeabi_idivmod():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:264
    3b98:	e92d5003 	push	{r0, r1, ip, lr}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:265
    3b9c:	ebffff96 	bl	39fc <__aeabi_idiv>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:266
    3ba0:	e8bd5006 	pop	{r1, r2, ip, lr}
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:267
    3ba4:	e0030290 	mul	r3, r0, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:268
    3ba8:	e0411003 	sub	r1, r1, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:269
    3bac:	e12fff1e 	bx	lr

00003bb0 <Ldiv0>:
Ldiv0():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:280
    3bb0:	e52de008 	str	lr, [sp, #-8]!
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:281
    3bb4:	ebfff373 	bl	988 <__div0>
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:282
    3bb8:	e3a00000 	mov	r0, #0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/lib1funcs.S:283
    3bbc:	e49df008 	ldr	pc, [sp], #8

00003bc0 <__aeabi_llsl>:
__ashldi3():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/ashldi3.S:43
    3bc0:	e2523020 	subs	r3, r2, #32
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/ashldi3.S:44
    3bc4:	e262c020 	rsb	ip, r2, #32
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/ashldi3.S:45
    3bc8:	41a01211 	lslmi	r1, r1, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/ashldi3.S:46
    3bcc:	51a01310 	lslpl	r1, r0, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/ashldi3.S:47
    3bd0:	41811c30 	orrmi	r1, r1, r0, lsr ip
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/ashldi3.S:50
    3bd4:	e1a00210 	lsl	r0, r0, r2
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/ashldi3.S:51
    3bd8:	e12fff1e 	bx	lr

00003bdc <__bswapsi2>:
__bswapsi2():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/bswapsdi2.S:6
    3bdc:	e6bf0f30 	rev	r0, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/bswapsdi2.S:7
    3be0:	e12fff1e 	bx	lr

00003be4 <__bswapdi2>:
__bswapdi2():
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/bswapsdi2.S:11
    3be4:	e6bf3f30 	rev	r3, r0
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/bswapsdi2.S:12
    3be8:	e6bf0f31 	rev	r0, r1
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/bswapsdi2.S:13
    3bec:	e1a01003 	mov	r1, r3
/home/liminghao/leeminghao/linux-4.1.6/arch/arm/boot/compressed/bswapsdi2.S:14
    3bf0:	e12fff1e 	bx	lr
