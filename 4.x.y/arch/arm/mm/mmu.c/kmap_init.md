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

CONFIG_HIGHMEM
----------------------------------------

### aries

```
CONFIG_HIGHMEM=y
```

PKMAP_BASE
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/include/asm/highmem.h/PKMAP_BASE.md

FIXADDR_START
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/include/asm/fixmap.h/FIXADDR_XXX.md

_PAGE_KERNEL_TABLE
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/include/asm/pgalloc.h/_PAGE_KERNEL_TABLE.md

early_pte_alloc
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/mm/mmu.c/early_pte_alloc.md