__map_init_section
========================================

path: arch/arm/mm/mmu.c
```
static void __init __map_init_section(pmd_t *pmd, unsigned long addr,
            unsigned long end, phys_addr_t phys,
            const struct mem_type *type)
{
    pmd_t *p = pmd;

#ifndef CONFIG_ARM_LPAE
    /*
     * In classic MMU format, puds and pmds are folded in to
     * the pgds. pmd_offset gives the PGD entry. PGDs refer to a
     * group of L1 entries making up one logical pointer to
     * an L2 table (2MB), where as PMDs refer to the individual
     * L1 entries (1MB). Hence increment to get the correct
     * offset for odd 1MB sections.
     * (See arch/arm/include/asm/pgtable-2level.h)
     */
    if (addr & SECTION_SIZE)
        pmd++;
#endif
    do {
        *pmd = __pmd(phys | type->prot_sect);
        phys += SECTION_SIZE;
    } while (pmd++, addr += SECTION_SIZE, addr != end);

    flush_pmd_entry(p);
}
```