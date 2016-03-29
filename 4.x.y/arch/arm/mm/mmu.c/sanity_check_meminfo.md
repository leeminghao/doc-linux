sanity_check_meminfo
========================================

sanity_check_meminfo用于检查meminfo注册的内存bank的有效性，比如大小，是否重叠等，
检测错误的内存bank将被从meminfo中移除。

path: arch/arm/mm/mmu.c
```
phys_addr_t arm_lowmem_limit __initdata = 0;

void __init sanity_check_meminfo(void)
{
    phys_addr_t memblock_limit = 0;
    int highmem = 0;
    phys_addr_t vmalloc_limit = __pa(vmalloc_min - 1) + 1;
    struct memblock_region *reg;

    for_each_memblock(memory, reg) {
        phys_addr_t block_start = reg->base;
        phys_addr_t block_end = reg->base + reg->size;
        phys_addr_t size_limit = reg->size;

        if (reg->base >= vmalloc_limit)
            highmem = 1;
        else
            size_limit = vmalloc_limit - reg->base;


        if (!IS_ENABLED(CONFIG_HIGHMEM) || cache_is_vipt_aliasing()) {

            if (highmem) {
                pr_notice("Ignoring RAM at %pa-%pa (!CONFIG_HIGHMEM)\n",
                      &block_start, &block_end);
                memblock_remove(reg->base, reg->size);
                continue;
            }

            if (reg->size > size_limit) {
                phys_addr_t overlap_size = reg->size - size_limit;

                pr_notice("Truncating RAM at %pa-%pa to -%pa",
                      &block_start, &block_end, &vmalloc_limit);
                memblock_remove(vmalloc_limit, overlap_size);
                block_end = vmalloc_limit;
            }
        }

        if (!highmem) {
            if (block_end > arm_lowmem_limit) {
                if (reg->size > size_limit)
                    arm_lowmem_limit = vmalloc_limit;
                else
                    arm_lowmem_limit = block_end;
            }

            /*
             * Find the first non-section-aligned page, and point
             * memblock_limit at it. This relies on rounding the
             * limit down to be section-aligned, which happens at
             * the end of this function.
             *
             * With this algorithm, the start or end of almost any
             * bank can be non-section-aligned. The only exception
             * is that the start of the bank 0 must be section-
             * aligned, since otherwise memory would need to be
             * allocated when mapping the start of bank 0, which
             * occurs before any free memory is mapped.
             */
            if (!memblock_limit) {
                if (!IS_ALIGNED(block_start, SECTION_SIZE))
                    memblock_limit = block_start;
                else if (!IS_ALIGNED(block_end, SECTION_SIZE))
                    memblock_limit = arm_lowmem_limit;
            }

        }
    }

    high_memory = __va(arm_lowmem_limit - 1) + 1;

    /*
     * Round the memblock limit down to a section size.  This
     * helps to ensure that we will allocate memory from the
     * last full section, which should be mapped.
     */
    if (memblock_limit)
        memblock_limit = round_down(memblock_limit, SECTION_SIZE);
    if (!memblock_limit)
        memblock_limit = arm_lowmem_limit;

    memblock_set_current_limit(memblock_limit);
}
```
