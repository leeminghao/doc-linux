paging_inig
========================================

在那linux刚启动时，系统创建了一个临时页表，那个是临时的，既然正式的要上场了，临时的当然要退休了.

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/kernel/head.S/__create_page_tables.md

build_mem_type_table
----------------------------------------

build_mem_type_table主要是用来建立各种类型的页表选项(比如内存是MEMORY类型，设备是DEVICE，
中断向量表是HIGH_VECTORS)。

path: arch/arm/mm/mmu.c
```
/*
 * paging_init() sets up the page tables, initialises the zone memory
 * maps, and sets up the zero page, bad page and bad page tables.
 */
void __init paging_init(const struct machine_desc *mdesc)
{
    void *zero_page;

    build_mem_type_table();
```

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/mm/mmu.c/build_mem_type_table.md

prepare_page_table
----------------------------------------

prepare_page_table则用于初始化页表.

```
    prepare_page_table();
```

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/mm/mmu.c/prepare_page_table.md

map_lowmem
----------------------------------------

```
    map_lowmem();
```

devicemaps_init
----------------------------------------

为设备IO内存创建映射.

```
    dma_contiguous_remap();
    devicemaps_init(mdesc);
```

kmap_init
----------------------------------------

```
    kmap_init();
    tcm_init();

    top_pmd = pmd_off_k(0xffff0000);

    /* allocate the zero page. */
    zero_page = early_alloc(PAGE_SIZE);
```

bootmem_init
----------------------------------------

为主内存创建映射.

```
    bootmem_init();

    empty_zero_page = virt_to_page(zero_page);
    __flush_dcache_page(NULL, empty_zero_page);
}
```
