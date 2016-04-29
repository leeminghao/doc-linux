setup_per_cpu_areas
========================================

在SMP系统上，setup_per_cpu_areas初始化源代码中（使用per_cpu宏）定义的静态per-cpu变量，
这种变量对系统中的每个CPU都有一个独立的副本。此类变量保存在内核二进制映像的一个独立的段中。
setup_per_cpu_areas的目的是为系统的各个CPU分别创建一份这些数据的副本。在非SMP系统上该函数
是一个空操作。

path: kernel/percpu.c
```
#ifdef CONFIG_SMP

...

#ifndef    CONFIG_HAVE_SETUP_PER_CPU_AREA
/*
 * Generic SMP percpu area setup.
 *
 * The embedding helper is used because its behavior closely resembles
 * the original non-dynamic generic percpu area setup.  This is
 * important because many archs have addressing restrictions and might
 * fail if the percpu area is located far away from the previous
 * location.  As an added bonus, in non-NUMA cases, embedding is
 * generally a good idea TLB-wise because percpu area can piggy back
 * on the physical linear memory mapping which uses large page
 * mappings on applicable archs.
 */
unsigned long __per_cpu_offset[NR_CPUS] __read_mostly;
EXPORT_SYMBOL(__per_cpu_offset);

static void * __init pcpu_dfl_fc_alloc(unsigned int cpu, size_t size,
                       size_t align)
{
    return  memblock_virt_alloc_from_nopanic(
            size, align, __pa(MAX_DMA_ADDRESS));
}

static void __init pcpu_dfl_fc_free(void *ptr, size_t size)
{
    memblock_free_early(__pa(ptr), size);
}

void __init setup_per_cpu_areas(void)
{
    unsigned long delta;
    unsigned int cpu;
    int rc;

    /*
     * Always reserve area for module percpu variables.  That's
     * what the legacy allocator did.
     */
    rc = pcpu_embed_first_chunk(PERCPU_MODULE_RESERVE,
                    PERCPU_DYNAMIC_RESERVE, PAGE_SIZE, NULL,
                    pcpu_dfl_fc_alloc, pcpu_dfl_fc_free);
    if (rc < 0)
        panic("Failed to initialize percpu areas.");

    delta = (unsigned long)pcpu_base_addr - (unsigned long)__per_cpu_start;
    for_each_possible_cpu(cpu)
        __per_cpu_offset[cpu] = delta + pcpu_unit_offsets[cpu];
}
#endif    /* CONFIG_HAVE_SETUP_PER_CPU_AREA */


...

#else    /* CONFIG_SMP */

/*
 * UP percpu area setup.
 *
 * UP always uses km-based percpu allocator with identity mapping.
 * Static percpu variables are indistinguishable from the usual static
 * variables and don't require any special preparation.
 */
void __init setup_per_cpu_areas(void)
{
    const size_t unit_size =
        roundup_pow_of_two(max_t(size_t, PCPU_MIN_UNIT_SIZE,
                     PERCPU_DYNAMIC_RESERVE));
    struct pcpu_alloc_info *ai;
    void *fc;

    ai = pcpu_alloc_alloc_info(1, 1);
    fc = memblock_virt_alloc_from_nopanic(unit_size,
                          PAGE_SIZE,
                          __pa(MAX_DMA_ADDRESS));
    if (!ai || !fc)
        panic("Failed to allocate memory for percpu areas.");
    /* kmemleak tracks the percpu allocations separately */
    kmemleak_free(fc);

    ai->dyn_size = unit_size;
    ai->unit_size = unit_size;
    ai->atom_size = unit_size;
    ai->alloc_size = unit_size;
    ai->groups[0].nr_units = 1;
    ai->groups[0].cpu_map[0] = 0;

    if (pcpu_setup_first_chunk(ai, fc) < 0)
        panic("Failed to initialize percpu areas.");
}

#endif    /* CONFIG_SMP */
```

aries
----------------------------------------

```
CONFIG_SMP=y
```