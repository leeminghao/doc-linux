alloc_init_pud
========================================

path: arch/arm/mm/mmu.c
```
static void __init alloc_init_pud(pgd_t *pgd, unsigned long addr,
                  unsigned long end, phys_addr_t phys,
                  const struct mem_type *type)
{
    pud_t *pud = pud_offset(pgd, addr);
    unsigned long next;

    do {
        next = pud_addr_end(addr, end);
        alloc_init_pmd(pud, addr, next, phys, type);
        phys += next - addr;
    } while (pud++, addr = next, addr != end);
}
```

pud_addr_end
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/include/asm-generic/pgtable.h/pud_addr_end.md

alloc_init_pmd
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/mm/mmu.c/alloc_init_pmd.md
