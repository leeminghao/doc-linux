zone_sizes_init
========================================

path: arch/arm/mm/init.c
```
static void __init zone_sizes_init(unsigned long min, unsigned long max_low,
    unsigned long max_high)
{
    unsigned long zone_size[MAX_NR_ZONES], zhole_size[MAX_NR_ZONES];
    struct memblock_region *reg;

    /*
     * initialise the zones.
     */
    memset(zone_size, 0, sizeof(zone_size));

    /*
     * The memory size has already been determined.  If we need
     * to do anything fancy with the allocation of this memory
     * to the zones, now is the time to do it.
     */
    zone_size[0] = max_low - min;
#ifdef CONFIG_HIGHMEM
    zone_size[ZONE_HIGHMEM] = max_high - max_low;
#endif

    /*
     * Calculate the size of the holes.
     *  holes = node_size - sum(bank_sizes)
     */
    memcpy(zhole_size, zone_size, sizeof(zhole_size));
    for_each_memblock(memory, reg) {
        unsigned long start = memblock_region_memory_base_pfn(reg);
        unsigned long end = memblock_region_memory_end_pfn(reg);

        if (start < max_low) {
            unsigned long low_end = min(end, max_low);
            zhole_size[0] -= low_end - start;
        }
#ifdef CONFIG_HIGHMEM
        if (end > max_low) {
            unsigned long high_start = max(start, max_low);
            zhole_size[ZONE_HIGHMEM] -= end - high_start;
        }
#endif
    }

#ifdef CONFIG_ZONE_DMA
    /*
     * Adjust the sizes according to any special requirements for
     * this machine type.
     */
    if (arm_dma_zone_size)
        arm_adjust_dma_zone(zone_size, zhole_size,
            arm_dma_zone_size >> PAGE_SHIFT);
#endif
```

free_area_init_node
----------------------------------------

```
    free_area_init_node(0, zone_size, min, zhole_size);
}
```

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/mm/page_alloc.c/free_area_init_node.md
