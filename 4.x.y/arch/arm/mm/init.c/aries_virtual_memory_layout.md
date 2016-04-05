Virtual kernel memory layout
========================================

kmsg
----------------------------------------

```
[    0.000000] Memory: 140MB 74MB 4MB 7MB 255MB 88MB 1433MB = 2001MB total
[    0.000000] Memory: 1859388k/1859388k available, 207040k reserved, 1297404K highmem
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
[    0.000000]     timers  : 0xfffef000 - 0xffff0000   (   4 kB)
[    0.000000]     fixmap  : 0xfff00000 - 0xfffe0000   ( 896 kB)
[    0.000000]     vmalloc : 0xf0000000 - 0xff000000   ( 240 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xef800000   ( 760 MB)
[    0.000000]     pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
[    0.000000]     modules : 0xbf000000 - 0xbfe00000   (  14 MB)
[    0.000000]       .text : 0xc0008000 - 0xc0e07f80   (14336 kB)
[    0.000000]       .init : 0xc0f00000 - 0xc101df40   (1144 kB)
[    0.000000]       .data : 0xc101e000 - 0xc121aac0   (2035 kB)
[    0.000000]        .bss : 0xc121aae4 - 0xc1a4e2e4   (8398 kB)
```

table
----------------------------------------

```
|--------------------------------------| 0xffffffff (4G)
|
|--------------------------------------| 0xff000000 <-- VMALLOC_END
|
|--------------------------------------| (high_memory + VMALLOC_OFFSET(8MB)) <-- VMALLOC_START
|
|--------------------------------------| 0xef000000 <--(high_memory arm_lowmem_limit)
|
|--------------------------------------| 0xc0000000 (3G) <-- PAGE_OFFSET
|
|--------------------------------------| (PAGE_OFFSET - PMD_SIZE(2MB)) <-- MODULES_END
|
|--------------------------------------| (PAGE_OFFSET - SZ_16M) <-- MODULES_VADDR
|
|--------------------------------------| 0x00000000 (0)
```

几个重要的宏定义
----------------------------------------

* PMD_SIZE

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/include/asm/pgtable-2level.h/PMD_SIZE.md

* MODULES_VADDR

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/include/asm/memory.h/MODULES_VADDR.md

* PAGE_OFFSET

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/include/asm/memory.h/PAGE_OFFSET.md

* VMALLOC_START

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/include/asm/pgtable.h/VMALLOC.md