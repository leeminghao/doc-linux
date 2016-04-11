alloc_init_pmd
========================================

path: arch/arm/mm/mmu.c
```
static void __init alloc_init_pmd(pud_t *pud, unsigned long addr,
                      unsigned long end, phys_addr_t phys,
                      const struct mem_type *type)
{
    pmd_t *pmd = pmd_offset(pud, addr);
    unsigned long next;

    do {
        /*
         * With LPAE, we must loop over to map
         * all the pmds for the given range.
         */
        next = pmd_addr_end(addr, end);

        /*
         * Try a section mapping - addr, next and phys must all be
         * aligned to a section boundary.
         */
        if (type->prot_sect &&
                ((addr | next | phys) & ~SECTION_MASK) == 0) {
            __map_init_section(pmd, addr, next, phys, type);
        } else {
            alloc_init_pte(pmd, addr, next,
                        __phys_to_pfn(phys), type);
        }

        phys += next - addr;

    } while (pmd++, addr = next, addr != end);
}
```

pmd_addr_end
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/include/asm-generic/pgtable.h/pmd_addr_end.md

alloc_init_pte
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/mm/mmu.c/alloc_init_pte.md
