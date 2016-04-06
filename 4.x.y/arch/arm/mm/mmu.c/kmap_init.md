kmap_init
========================================

path: arch/arm/mm/mmu.c
```
static void __init kmap_init(void)
{
#ifdef CONFIG_HIGHMEM
    pkmap_page_table = early_pte_alloc(pmd_off_k(PKMAP_BASE),
        PKMAP_BASE, _PAGE_KERNEL_TABLE);
#endif

    early_pte_alloc(pmd_off_k(FIXADDR_START), FIXADDR_START,
            _PAGE_KERNEL_TABLE);
}
```