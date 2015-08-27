boot_linux
========================================

path: lk/app/aboot/aboot.c
```
void boot_linux(void *kernel, unsigned *tags,
        const char *cmdline, unsigned machtype,
        void *ramdisk, unsigned ramdisk_size)
{
    unsigned char *final_cmdline;
#if DEVICE_TREE
    int ret = 0;
#endif

    /* 1.将传递进来的kernel, ramdisk,和tag地址转换成物理地址
     * 这是因为在进入内核代码执行之前要关闭mmu, 所以要将虚拟地址
     * 转换成物理地址才能进行后续的正常工作.
     */
    void (*entry)(unsigned, unsigned, unsigned*) = (entry_func_ptr*)(PA((addr_t)kernel));
    uint32_t tags_phys = PA((addr_t)tags);

    ramdisk = PA(ramdisk);

    final_cmdline = update_cmdline((const char*)cmdline);

#if DEVICE_TREE
    ...
#else
    /* Generating the Atags */
    generate_atags(tags, final_cmdline, ramdisk, ramdisk_size);
#endif

    dprintf(INFO, "booting linux @ %p, ramdisk @ %p (%d)\n",
        entry, ramdisk, ramdisk_size);

    enter_critical_section();
    /* do any platform specific cleanup before kernel entry */
    platform_uninit();
    arch_disable_cache(UCACHE);
    /* NOTE:
     * The value of "entry" is getting corrupted at this point.
     * The value is in R4 and gets pushed to stack on entry into
     * disable_cache(), however, on return it is not the same.
     * Not entirely sure why this dsb() seems to take of this.
     * The stack pop operation on return from disable_cache()
     * should restore R4 properly, but that is not happening.
     * Will need to revisit to find the root cause.
     */
    dsb();
#if ARM_WITH_MMU
    // 2.lk使用了MMU和Cache来支持多线程，所以在跳到内核之前要先disable mmu和cache
    arch_disable_mmu();
#endif

    /* 3.直接跳转到内核执行. */
    entry(0, machtype, (unsigned*)tags_phys);
}
```

各个模块的初始地址如下所示:

* kernel_addr - 0x80208000
* tags_addr - 0x80200100
* ramdisk_addr -  0x82200000

generate_atags
----------------------------------------

改函数将boot_img_hdr头部保存的信息提取出来封装成tag作为参数传递给kernel.

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/generate_atags.md

entry
----------------------------------------

内核入口函数entry, 该函数地址就是kernel加载的地址.接下来跳转到内核去执行内核代码.

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/boot/README.md

内存分布
----------------------------------------

在我们的示例中, 2GB内存映射到了0x80000000 ~ 0xFFFFFF00这个地址段,
在程序执行到此时我们得到大致如下的内存分布图:

```
|-----------------------------| 0xffffffff (4G)
|
|
|
|
|
|
|
|
|-----------------------------| 0xc0000000 (3G)
|
|
|
|
|-----------------------------|
|           lk                |
|-----------------------------| 0x88f00000
|                             |
|-----------------------------| 0x88000000
|         ramdisk             |
|-----------------------------| 0x82200000
|          kernel             |
|-----------------------------| 0x80208000
|           tags              |
|-----------------------------| 0x80200100
|
|-----------------------------| 0x80000000 (2G)
|
|
|
|
|
|
|
|
|-----------------------------| 0x40000000 (1G)
|
|
|
|
|
|
|
|
|-----------------------------| 0x00000000
```

为了验证我们内存分布是否正确，我们在加载完kernel和ramdisk之后分别打印
从kernel起始地址0x80208000和lk起始地址0x88f00000开始的10条指令同
kernel和lk反汇编的指令进行比较,如下所示:

### lk

0x88f00000开始的10条指令如下所示:

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
