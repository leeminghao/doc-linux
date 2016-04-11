__pmd_populate
========================================

path: arch/arm/include/asm/pgalloc.h
```
static inline void __pmd_populate(pmd_t *pmdp, phys_addr_t pte,
                  pmdval_t prot)
{
    pmdval_t pmdval = (pte + PTE_HWTABLE_OFF) | prot;
    pmdp[0] = __pmd(pmdval); // 将头4个字节指向hwpte0页表
#ifndef CONFIG_ARM_LPAE
    // 将后4个字节指向hwpte1页表，至此L1 --> L2页表的关联已经建立
    pmdp[1] = __pmd(pmdval + 256 * sizeof(pte_t));
#endif
    // 是刷新TLB缓冲，使系统的cpu都可以看见该映射的变化
    flush_pmd_entry(pmdp);
}
```