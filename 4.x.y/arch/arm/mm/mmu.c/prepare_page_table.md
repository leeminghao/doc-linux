prepare_page_table
========================================

几个重要的宏定义:

* PMD_SIZE

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/include/asm/pgtable-2level.h/PMD_SIZE.md

* MODULES_VADDR

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/include/asm/memory.h/MODULES_VADDR.md

* PAGE_OFFSET

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/include/asm/memory.h/PAGE_OFFSET.md

* VMALLOC_START

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/include/asm/pgtable.h/VMALLOC.md

prepare_page_table
----------------------------------------

path: arch/arm/mm/mmu.c
```
static inline void prepare_page_table(void)
{
    unsigned long addr;
    phys_addr_t end;

    /*
     * Clear out all the mappings below the kernel image.
     */
     /*1.清除0~MODULES_VADDR区间的内存映射关系*/
    for (addr = 0; addr < MODULES_VADDR; addr += PMD_SIZE)
        pmd_clear(pmd_off_k(addr));

#ifdef CONFIG_XIP_KERNEL
    /* The XIP kernel is mapped in the module area -- skip over it */
    addr = ((unsigned long)_etext + PMD_SIZE - 1) & PMD_MASK;
#endif
    /* 2.清除MODULES_VADDR ~ PAGE_OFFSET区间的内存映射关系 */
    for ( ; addr < PAGE_OFFSET; addr += PMD_SIZE)
        pmd_clear(pmd_off_k(addr));

    /*
     * Find the end of the first block of lowmem.
     */
     // regions[0].base和regions[0].size分别记录第一个内存regions的起始物理地址和大小
    end = memblock.memory.regions[0].base + memblock.memory.regions[0].size;
    if (end >= arm_lowmem_limit)
        end = arm_lowmem_limit;

    /*
     * Clear out all the kernel space mappings, except for the first
     * memory bank, up to the vmalloc region.
     */
    for (addr = __phys_to_virt(end);
         addr < VMALLOC_START; addr += PMD_SIZE)
             pmd_clear(pmd_off_k(addr));
}
```

pmd_off_k
----------------------------------------

pmd_clear
----------------------------------------

Virutal kernel memory layout (aries)
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/mm/init.c/aries_virtual_memory_layout.md
