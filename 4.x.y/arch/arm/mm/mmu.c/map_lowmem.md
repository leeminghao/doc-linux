map_lowmem
========================================

path: arch/arm/mm/mmu.c
```
static void __init map_lowmem(void)
{
    struct memblock_region *reg;
    unsigned long kernel_x_start = round_down(__pa(_stext), SECTION_SIZE);
    unsigned long kernel_x_end = round_up(__pa(__init_end), SECTION_SIZE);

    /* Map all the lowmem memory banks. */
    for_each_memblock(memory, reg) {
        phys_addr_t start = reg->base;
        phys_addr_t end = start + reg->size;
        struct map_desc map;

        if (end > arm_lowmem_limit)
            end = arm_lowmem_limit;
        if (start >= end)
            break;

        if (end < kernel_x_start) {
            map.pfn = __phys_to_pfn(start);
            map.virtual = __phys_to_virt(start);
            map.length = end - start;
            map.type = MT_MEMORY_RWX;

            create_mapping(&map);
        } else if (start >= kernel_x_end) {
            map.pfn = __phys_to_pfn(start);
            map.virtual = __phys_to_virt(start);
            map.length = end - start;
            map.type = MT_MEMORY_RW;

            create_mapping(&map);
        } else {
            /* This better cover the entire kernel */
            if (start < kernel_x_start) {
                map.pfn = __phys_to_pfn(start);
                map.virtual = __phys_to_virt(start);
                map.length = kernel_x_start - start;
                map.type = MT_MEMORY_RW;

                create_mapping(&map);
            }

            map.pfn = __phys_to_pfn(kernel_x_start);
            map.virtual = __phys_to_virt(kernel_x_start);
            map.length = kernel_x_end - kernel_x_start;
            map.type = MT_MEMORY_RWX;

            create_mapping(&map);

            if (kernel_x_end < end) {
                map.pfn = __phys_to_pfn(kernel_x_end);
                map.virtual = __phys_to_virt(kernel_x_end);
                map.length = end - kernel_x_end;
                map.type = MT_MEMORY_RW;

                create_mapping(&map);
            }
        }
    }
}
```