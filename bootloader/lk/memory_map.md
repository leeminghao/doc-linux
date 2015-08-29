Memory Map
========================================

MSM8960存储系统映射如下所示:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/memory.md

在这个存储系统中，我们实验平台只有2GB DDR内存，其被映射到了
0x80000000 ~ 0xFFFFFF00这个地址段. 由secure boot将lk加载到DDR内存,
过程如下所示:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/boot.md

lk又将linux内核和ramdisk加载到了DDR内存指定位置.我们得到如下的存储空间布局:

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

### lk

#### 0x88f00000

起始地址0x88f00000开始的10条指令如下所示:

```
[2970] lk: ea000006
[2970] lk: ea004137
[2970] lk: ea00413d
[2970] lk: ea004143
[2970] lk: ea004149
[2970] lk: ea00414f
[2970] lk: ea00414f
[2970] lk: ea004166
[2970] lk: ee110f10
[2970] lk: e3c00a0b
```

#### Disassembler

对应lk elf格式的二进制文件的反汇编指令如下所示:

```
_start:
	b	reset
88f00000:	ea000006 	b	88f00020 <reset>
	b	arm_undefined
88f00004:	ea004137 	b	88f104e8 <arm_undefined>
	b	arm_syscall
88f00008:	ea00413d 	b	88f10504 <arm_syscall>
	b	arm_prefetch_abort
88f0000c:	ea004143 	b	88f10520 <arm_prefetch_abort>
	b	arm_data_abort
88f00010:	ea004149 	b	88f1053c <arm_data_abort>
	b	arm_reserved
88f00014:	ea00414f 	b	88f10558 <arm_reserved>
	b	arm_irq
88f00018:	ea00414f 	b	88f1055c <arm_irq>
	b	arm_fiq
88f0001c:	ea004166 	b	88f105bc <arm_fiq>
```

完整的反汇编指令如下所示:

https://github.com/leeminghao/doc-linux/blob/master/bootloader/lk/binary/lk.S

### kernel

#### 0x80208000

0x80208000开始的10条指令

```
[2970] kernel: e1a00000
[2970] kernel: e1a00000
[2970] kernel: e1a00000
[2970] kernel: e1a00000
[2970] kernel: e1a00000
[2970] kernel: e1a00000
[2970] kernel: e1a00000
[2970] kernel: e1a00000
[2970] kernel: ea000002
[2970] kernel: 16f2818
```

#### Disassembler

对应内核vmlinux elf格式二进制文件反汇编指令如下所示:

```
00000000 <start>:
       0:	e1a00000 	nop			; (mov r0, r0)
       4:	e1a00000 	nop			; (mov r0, r0)
       8:	e1a00000 	nop			; (mov r0, r0)
       c:	e1a00000 	nop			; (mov r0, r0)
      10:	e1a00000 	nop			; (mov r0, r0)
      14:	e1a00000 	nop			; (mov r0, r0)
      18:	e1a00000 	nop			; (mov r0, r0)
      1c:	e1a00000 	nop			; (mov r0, r0)
      20:	ea000003 	b	34 <start+0x34>
      24:	016f2818 	.word	0x016f2818
```

完整的反汇编指令如下所示:

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/kbuild/binary/arch/arm/boot/compressed/vmlinux.S

综上对比发现对应内存位置上的指令跟反汇编出来的完全一致.
