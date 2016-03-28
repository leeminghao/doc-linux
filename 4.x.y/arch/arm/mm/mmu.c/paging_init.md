paging_inig
========================================

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


```
    prepare_page_table();
    map_lowmem();
    dma_contiguous_remap();
    devicemaps_init(mdesc);
    kmap_init();
    tcm_init();

    top_pmd = pmd_off_k(0xffff0000);

    /* allocate the zero page. */
    zero_page = early_alloc(PAGE_SIZE);

    bootmem_init();

    empty_zero_page = virt_to_page(zero_page);
    __flush_dcache_page(NULL, empty_zero_page);
}
```
