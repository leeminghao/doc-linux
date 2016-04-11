alloc_init_pte
========================================

path: arch/arm/mm/mmu.c
```
static void __init alloc_init_pte(pmd_t *pmd, unsigned long addr,
                  unsigned long end, unsigned long pfn,
                  const struct mem_type *type)
{
    pte_t *pte = early_pte_alloc(pmd, addr, type->prot_l1);
    do {
        // 设置L2页表中addr所定位到的页表项(即pte), 主要工作就是填充对应物理页的物理地址,
        // 以供mmu硬件来实现地址的翻译。
        set_pte_ext(pte, pfn_pte(pfn, __pgprot(type->prot_pte)), 0);
        pfn++;
    // 循环填充完两个hwpte页表，完成一个2M物理内存的映射表的建立。
    } while (pte++, addr += PAGE_SIZE, addr != end);
}
```

early_pte_alloc
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/mm/mmu.c/early_pte_alloc.md
