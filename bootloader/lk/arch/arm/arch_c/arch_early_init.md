arch_early_init
========================================

path: lk/arch/arm/arch.c
```
void arch_early_init(void)
{
    /* turn off the cache */
    arch_disable_cache(UCACHE);

    ...

#if ARM_WITH_MMU
    arm_mmu_init();
#endif

    /* turn the cache back on */
    arch_enable_cache(UCACHE);

    ...
}
```