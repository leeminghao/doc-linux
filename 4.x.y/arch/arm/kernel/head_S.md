head.S 内核启动
========================================

zImage由其头部的解压程序将真正的内核代码解压到zreladdr地址处后，将跳转到改地址执行
真正的内核代码, 相应的解压过程如下所示:

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/boot/compressed/head_S.md

入口
----------------------------------------

内核入口定义如下所示:

path: arch/arm/kernel/vmlinux.ld.S
```
OUTPUT_ARCH(arm)
ENTRY(stext)

#ifndef __ARMEB__
jiffies = jiffies_64;
#else
jiffies = jiffies_64 + 4;
#endif

SECTIONS
{
#ifdef CONFIG_XIP_KERNEL
	. = XIP_VIRT_ADDR(CONFIG_XIP_PHYS_ADDR);
#else
	. = PAGE_OFFSET + TEXT_OFFSET; /* 0xC0008000 */
#endif
	.head.text : {
		_text = .;
		HEAD_TEXT
	}
#ifdef CONFIG_STRICT_MEMORY_RWX
	. = ALIGN(1<<SECTION_SHIFT);
#endif

	.text : {			/* Real text segment		*/
		_stext = .;		/* Text and read-only data	*/
                ...
	}

        ...

	_etext = .;			/* End of text and rodata section */
        ...
```

内核的入口是stext, 这里的ENTRY(stext) 表示程序的入口是在符号stext.
而符号stext是在arch/arm/kernel/head.S中定义的.

有关linker script的详细解释如下:

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/kernel/vmlinux.lds.S.md

```
/*
 * Kernel startup entry point.
 * ---------------------------
 *
 * This is normally called from the decompressor code.  The requirements
 * are: MMU = off, D-cache = off, I-cache = dont care, r0 = 0,
 * r1 = machine nr, r2 = atags or dtb pointer.
 *
 * This code is mostly position independent, so if you link the kernel at
 * 0xc0008000, you call this at __pa(0xc0008000).
 *
 * See linux/arch/arm/tools/mach-types for the complete list of machine
 * numbers for r1.
 *
 * We're trying to keep crap to a minimum; DO NOT add any machine specific
 * crap here - that's what the boot loader (or in extreme, well justified
 * circumstances, zImage) is for.
 */
	.arm

	__HEAD
ENTRY(stext)
```

相关地址值
----------------------------------------

https://github.com/torvalds/linux/blob/bdec41963890f8ed9ad89f8b418959ab3cdc2aa3/Documentation/arm/Porting

* PHYS_OFFSET
        Physical start address of the first bank of RAM.

path: arch/arm/include/asm/memory.h
```
#define PHYS_OFFSET   UL(CONFIG_PHYS_OFFSET)
```

```
CONFIG_PHYS_OFFSET=0x80200000
```

* PAGE_OFFSET
        Virtual start address of the first bank of RAM.  During the kernel
        boot phase, virtual address PAGE_OFFSET will be mapped to physical
        address PHYS_OFFSET, along with any other mappings you supply.
        This should be the same value as TASK_SIZE.

path: arch/arm/include/asm/memory.h
```
#define PAGE_OFFSET             UL(CONFIG_PAGE_OFFSET)
```

在对应的配置文件arch/arm/configs/aries_xxxxdefconfig中:

```
CONFIG_PAGE_OFFSET=0xC0000000
```

* TEXT_OFFSET
  The byte offset of the kernel image in RAM from the start of RAM.

path: arch/arm/Makefile
```
# The byte offset of the kernel image in RAM from the start of RAM.
textofs-y	:= 0x00008000
...
TEXT_OFFSET := $(textofs-y)
```

* TEXTADDR
        Virtual start address of kernel, normally PAGE_OFFSET + 0x8000.
        This is where the kernel image ends up.  With the latest kernels,
        it must be located at 32768 bytes into a 128MB region.  Previous
        kernels placed a restriction of 256MB here.

流程
----------------------------------------
