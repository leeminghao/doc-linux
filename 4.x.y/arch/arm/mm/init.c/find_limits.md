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