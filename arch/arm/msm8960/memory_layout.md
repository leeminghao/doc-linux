Memory Layout
========================================

在我们的实验系统中，加载完HLOS之后，MSM8960各个模块内存布局如下:

存储空间布局
----------------------------------------

```
|-----------------------------| 0xffffffff (4G)
|                             |
|          ......             |
|                             |
|-----------------------------| 0xc0000000 (3G)
|                             |
|          ......             |
|                             |
|-----------------------------|
|          sbl3               | DDR
|-----------------------------| 0x8ff00000
|        lk (APPSBL)          | DDR
|-----------------------------| 0x88f00000
|                             |
|-----------------------------| 0x88000000
|         ramdisk             | DDR
|-----------------------------| 0x82200000
|        kernel (HLOS)        | DDR
|-----------------------------| 0x80208000
|           tags              | DDR
|-----------------------------| 0x80200100
|          ......             |
|-----------------------------| 0x80000000 (2G)
|                             |
|          ......             |
|                             |
|-----------------------------| 0x40000000 (1G)
|          ......             |
|-----------------------------| 0x30000000
|            sbl2             | MIMEM/GMEM
|-----------------------------| 0x2e000000
|           ......            |
|-----------------------------| 0x2c000000
|        sbl1 --> tz          | System IMEM
|-----------------------------| 0x2a000000
|           ......            |
|-----------------------------| 0x00048000
|         RPM firmware        | RPM Code RAM
|-----------------------------| 0x00020000
|           ......            |
|-----------------------------| 0x00018000
|           RPM PBL           | RPM Code ROM
|-----------------------------| 0x00000000
```

为了验证我们内存分布是否正确，我们在LK加载完kernel和ramdisk之后打印
了个模块起始地址处的10条指令同对应模块反汇编得到的指令进行比较:

实验验证
----------------------------------------

### RPM firmware

#### 0x00020000

```
[940] rpm 20000: ea000006
[940] rpm 20004: ea00001e
[940] rpm 20008: ea00002c
[940] rpm 2000c: ea000039
[940] rpm 20010: ea000046
[940] rpm 20014: ea000053
[940] rpm 20018: ea000057
[940] rpm 2001c: ea000058
[940] rpm 20020: e321f0d3
[940] rpm 20024: e59f0160
```

#### Disassembler

```
00020000 <__main>:
   20000:	ea000006 	b	20020 <__main+0x20>
   20004:	ea00001e 	b	20084 <__main+0x84>
   20008:	ea00002c 	b	200c0 <__main+0xc0>
   2000c:	ea000039 	b	200f8 <__main+0xf8>
   20010:	ea000046 	b	20130 <__main+0x130>
   20014:	ea000053 	b	20168 <__main+0x168>
   20018:	ea000057 	b	2017c <__main+0x17c>
   2001c:	ea000058 	b	20184 <__main+0x184>
   20020:	e321f0d3 	msr	CPSR_c, #211	; 0xd3
   20024:	e59f0160 	ldr	r0, [pc, #352]	; 2018c <__main+0x18c>
```

### SBL1 VS TZ

SBL1加载SBL2之后，SBL2会加载TZ模块覆盖SBL1所在的存储区域IMEM.

#### 0x2a000000

```
[940] sbl1 2a000000: 0
[940] sbl1 2a000004: 0
[940] sbl1 2a000008: 0
[940] sbl1 2a00000c: 0
[940] sbl1 2a000010: 0
[940] sbl1 2a000014: 0
[940] sbl1 2a000018: 0
[940] sbl1 2a00001c: 0
[940] sbl1 2a000020: 0
[940] sbl1 2a000024: 0
```

### SBL2

#### 0x2e000000

```
[940] sbl2 2e000000: ea000012
[940] sbl2 2e000004: ea00005f
[940] sbl2 2e000008: ea000062
[940] sbl2 2e00000c: ea000065
[940] sbl2 2e000010: ea000068
[940] sbl2 2e000014: ea00006b
[940] sbl2 2e000018: ea00006e
[940] sbl2 2e00001c: ea000071
[940] sbl2 2e000020: 0
[940] sbl2 2e000024: 2e000240
```

#### Disassembler

```
2e000000 <RST_VEC>:
2e000000:	ea000012 	b	2e000050 <sbl2_reset_handler>
2e000004:	ea00005f 	b	2e000188 <sbl2_undefined_instruction_bridge_handler>
2e000008:	ea000062 	b	2e000198 <sbl2_swi_bridge_handler>
2e00000c:	ea000065 	b	2e0001a8 <sbl2_prefetch_abort_bridge_handler>
2e000010:	ea000068 	b	2e0001b8 <sbl2_data_abort_bridge_handler>
2e000014:	ea00006b 	b	2e0001c8 <sbl2_reserved_bridge_handler>
2e000018:	ea00006e 	b	2e0001d8 <sbl2_irq_bridge_handler>
2e00001c:	ea000071 	b	2e0001e8 <sbl2_fiq_bridge_handler>

Disassembly of section SBL2_IND_VEC_TBL:

2e000020 <undefined_instruction_vector-0x4>:
2e000020:	00000000 	.word	0x00000000

2e000024 <undefined_instruction_vector>:
2e000024:	2e000240                                @...
```

### SBL3

#### 0x8ff00000

```
[940] sbl3 8ff00000: e321f0d3
[940] sbl3 8ff00004: e321f0d3
[940] sbl3 8ff00008: e1a07000
[940] sbl3 8ff0000c: e3a00209
[940] sbl3 8ff00010: e1a0d000
[940] sbl3 8ff00014: e321f0db
[940] sbl3 8ff00018: e1a0d000
[940] sbl3 8ff0001c: e321f0d7
[940] sbl3 8ff00020: e1a0d000
[940] sbl3 8ff00024: e321f0df
```

#### Disassembler

```
8ff00000:	e321f0d3 	msr	CPSR_c, #211	; 0xd3
    ; -----------------------------------------------------------------------
    ; Set-up stack for all processor modes.
    ; -----------------------------------------------------------------------
    ;Change to Supervisor Mode
    msr     CPSR_c, #Mode_SVC:OR:I_Bit:OR:F_Bit
8ff00004:	e321f0d3 	msr	CPSR_c, #211	; 0xd3
    ; Save the passing parameter from SBL1
    mov     r7, r0
8ff00008:	e1a07000 	mov	r7, r0
    ; Setup the supervisor mode stack
    ldr     r0, =(0x8FF00000+0x0100000)
8ff0000c:	e3a00209 	mov	r0, #-1879048192	; 0x90000000
    mov     r13, r0
8ff00010:	e1a0d000 	mov	sp, r0
    ; Switch to undefined mode and setup the undefined mode stack
    msr     CPSR_c, #Mode_UND:OR:I_Bit:OR:F_Bit
8ff00014:	e321f0db 	msr	CPSR_c, #219	; 0xdb
    mov     r13, r0
8ff00018:	e1a0d000 	mov	sp, r0
    ; Switch to abort mode and setup the abort mode stack
    msr     CPSR_c, #Mode_ABT:OR:I_Bit:OR:F_Bit
8ff0001c:	e321f0d7 	msr	CPSR_c, #215	; 0xd7
    mov     r13, r0
8ff00020:	e1a0d000 	mov	sp, r0
    ; Switch to system mode and setup the stack
    msr     CPSR_c, #Mode_SYS:OR:I_Bit:OR:F_Bit
8ff00024:	e321f0df 	msr	CPSR_c, #223	; 0xdf
    mov     r13, r0
```

### lk

#### 0x88f00000

```
[940] lk 88f00000: ea000006
[940] lk 88f00004: ea0040ff
[940] lk 88f00008: ea004105
[940] lk 88f0000c: ea00410b
[940] lk 88f00010: ea004111
[940] lk 88f00014: ea004117
[940] lk 88f00018: ea004117
[940] lk 88f0001c: ea00412e
[940] lk 88f00020: ee110f10
[940] lk 88f00024: e3c00a0b
```

#### Disassembler

```
_start:
	b	reset
88f00000:	ea000006 	b	88f00020 <reset>
	b	arm_undefined
88f00004:	ea0040ff 	b	88f10408 <arm_undefined>
	b	arm_syscall
88f00008:	ea004105 	b	88f10424 <arm_syscall>
	b	arm_prefetch_abort
88f0000c:	ea00410b 	b	88f10440 <arm_prefetch_abort>
	b	arm_data_abort
88f00010:	ea004111 	b	88f1045c <arm_data_abort>
	b	arm_reserved
88f00014:	ea004117 	b	88f10478 <arm_reserved>
	b	arm_irq
88f00018:	ea004117 	b	88f1047c <arm_irq>
	b	arm_fiq
88f0001c:	ea00412e 	b	88f104dc <arm_fiq>

88f00020 <reset>:
	ldr r7, =_binary_tzbsp_tzbsp_bin_start
#endif
	/* do some cpu setup */
#if ARM_WITH_CP15
        /* Read SCTLR */
	mrc		p15, 0, r0, c1, c0, 0
88f00020:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
		/* XXX this is currently for arm926, revist with armv6 cores */
		/* new thumb behavior, low exception vectors, i/d cache disable, mmu disabled */
	bic		r0, r0, #(1<<15| 1<<13 | 1<<12)
88f00024:	e3c00a0b 	bic	r0, r0, #45056	; 0xb000
	bic		r0, r0, #(1<<2 | 1<<0)
```

### kernel

#### 0x80208000

```
[940] kernel 80208000: e1a00000
[940] kernel 80208004: e1a00000
[940] kernel 80208008: e1a00000
[940] kernel 8020800c: e1a00000
[940] kernel 80208010: e1a00000
[940] kernel 80208014: e1a00000
[940] kernel 80208018: e1a00000
[940] kernel 8020801c: e1a00000
[940] kernel 80208020: ea000002
[940] kernel 80208024: 16f2818
```

#### Disassembler

```
00000000 <start>:
#endif
		.endm

		.macro	debug_reloc_end
#ifdef DEBUG
		kphex	r5, 8		/* end of kernel */
       0:	e1a00000 	nop			; (mov r0, r0)
       4:	e1a00000 	nop			; (mov r0, r0)
       8:	e1a00000 	nop			; (mov r0, r0)
       c:	e1a00000 	nop			; (mov r0, r0)
      10:	e1a00000 	nop			; (mov r0, r0)
      14:	e1a00000 	nop			; (mov r0, r0)
      18:	e1a00000 	nop			; (mov r0, r0)
		kputc	#'\n'
      1c:	e1a00000 	nop			; (mov r0, r0)
		mov	r0, r4
      20:	ea000002 	b	30 <start+0x30>
      24:	016f2818 	.word	0x016f2818
```

综上对比发现对应内存位置上的指令跟反汇编出来的完全一致.
