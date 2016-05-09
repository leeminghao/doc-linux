find_limits
========================================

path: arch/arm/mm/init.c
```
static void __init find_limits(unsigned long *min, unsigned long *max_low,
                   unsigned long *max_high)
{
    *max_low = PFN_DOWN(memblock_get_current_limit());
    *min = PFN_UP(memblock_start_of_DRAM());
    *max_high = PFN_DOWN(memblock_end_of_DRAM());
}
```

memblock_get_current_limit
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/mm/memblock.c/memblock_get_current_limit.md

memblock_start_of_DRAM
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/mm/memblock.c/memblock_start_of_DRAM.md

memblock_end_of_DRAM
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/mm/memblock.c/memblock_end_of_DRAM.md

PFN_XXX
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/include/linux/pfn.h/PFN_XXX.md
