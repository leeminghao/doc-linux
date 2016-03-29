mem_types
========================================

struct mem_types
----------------------------------------

path: arch/arm/mm/mm.h
```
struct mem_type {
    pteval_t prot_pte;
    pteval_t prot_pte_s2;
    pmdval_t prot_l1;
    pmdval_t prot_sect;
    unsigned int domain;
};
```

mem_types
----------------------------------------

path: arch/arm/mm/mmu.c
```
static struct mem_type mem_types[] = {
    [MT_DEVICE] = {          /* Strongly ordered / ARMv6 shared device */
        .prot_pte    = PROT_PTE_DEVICE | L_PTE_MT_DEV_SHARED |
                       L_PTE_SHARED,
        .prot_pte_s2 = s2_policy(PROT_PTE_S2_DEVICE) |
                       s2_policy(L_PTE_S2_MT_DEV_SHARED) |
                       L_PTE_SHARED,
        .prot_l1    = PMD_TYPE_TABLE,
        .prot_sect    = PROT_SECT_DEVICE | PMD_SECT_S,
        .domain        = DOMAIN_IO,
    },
    [MT_DEVICE_NONSHARED] = { /* ARMv6 non-shared device */
        .prot_pte    = PROT_PTE_DEVICE | L_PTE_MT_DEV_NONSHARED,
        .prot_l1    = PMD_TYPE_TABLE,
        .prot_sect    = PROT_SECT_DEVICE,
        .domain        = DOMAIN_IO,
    },
    [MT_DEVICE_CACHED] = {      /* ioremap_cached */
        .prot_pte    = PROT_PTE_DEVICE | L_PTE_MT_DEV_CACHED,
        .prot_l1    = PMD_TYPE_TABLE,
        .prot_sect    = PROT_SECT_DEVICE | PMD_SECT_WB,
        .domain        = DOMAIN_IO,
    },
    [MT_DEVICE_WC] = {    /* ioremap_wc */
        .prot_pte    = PROT_PTE_DEVICE | L_PTE_MT_DEV_WC,
        .prot_l1    = PMD_TYPE_TABLE,
        .prot_sect    = PROT_SECT_DEVICE,
        .domain        = DOMAIN_IO,
    },
    [MT_UNCACHED] = {
        .prot_pte    = PROT_PTE_DEVICE,
        .prot_l1    = PMD_TYPE_TABLE,
        .prot_sect    = PMD_TYPE_SECT | PMD_SECT_XN,
        .domain        = DOMAIN_IO,
    },
    [MT_CACHECLEAN] = {
        .prot_sect = PMD_TYPE_SECT | PMD_SECT_XN,
        .domain    = DOMAIN_KERNEL,
    },
#ifndef CONFIG_ARM_LPAE
    [MT_MINICLEAN] = {
        .prot_sect = PMD_TYPE_SECT | PMD_SECT_XN | PMD_SECT_MINICACHE,
        .domain    = DOMAIN_KERNEL,
    },
#endif
    [MT_LOW_VECTORS] = {
        .prot_pte  = L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY |
                L_PTE_RDONLY,
        .prot_l1   = PMD_TYPE_TABLE,
        .domain    = DOMAIN_USER,
    },
    [MT_HIGH_VECTORS] = {
        .prot_pte  = L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY |
                L_PTE_USER | L_PTE_RDONLY,
        .prot_l1   = PMD_TYPE_TABLE,
        .domain    = DOMAIN_USER,
    },
    [MT_MEMORY_RWX] = {
        .prot_pte  = L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY,
        .prot_l1   = PMD_TYPE_TABLE,
        .prot_sect = PMD_TYPE_SECT | PMD_SECT_AP_WRITE,
        .domain    = DOMAIN_KERNEL,
    },
    [MT_MEMORY_RW] = {
        .prot_pte  = L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY |
                 L_PTE_XN,
        .prot_l1   = PMD_TYPE_TABLE,
        .prot_sect = PMD_TYPE_SECT | PMD_SECT_AP_WRITE,
        .domain    = DOMAIN_KERNEL,
    },
    [MT_ROM] = {
        .prot_sect = PMD_TYPE_SECT,
        .domain    = DOMAIN_KERNEL,
    },
    [MT_MEMORY_RWX_NONCACHED] = {
        .prot_pte  = L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY |
                L_PTE_MT_BUFFERABLE,
        .prot_l1   = PMD_TYPE_TABLE,
        .prot_sect = PMD_TYPE_SECT | PMD_SECT_AP_WRITE,
        .domain    = DOMAIN_KERNEL,
    },
    [MT_MEMORY_RW_DTCM] = {
        .prot_pte  = L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY |
                L_PTE_XN,
        .prot_l1   = PMD_TYPE_TABLE,
        .prot_sect = PMD_TYPE_SECT | PMD_SECT_XN,
        .domain    = DOMAIN_KERNEL,
    },
    [MT_MEMORY_RWX_ITCM] = {
        .prot_pte  = L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY,
        .prot_l1   = PMD_TYPE_TABLE,
        .domain    = DOMAIN_KERNEL,
    },
    [MT_MEMORY_RW_SO] = {
        .prot_pte  = L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY |
                L_PTE_MT_UNCACHED | L_PTE_XN,
        .prot_l1   = PMD_TYPE_TABLE,
        .prot_sect = PMD_TYPE_SECT | PMD_SECT_AP_WRITE | PMD_SECT_S |
                PMD_SECT_UNCACHED | PMD_SECT_XN,
        .domain    = DOMAIN_KERNEL,
    },
    [MT_MEMORY_DMA_READY] = {
        .prot_pte  = L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY |
                L_PTE_XN,
        .prot_l1   = PMD_TYPE_TABLE,
        .domain    = DOMAIN_KERNEL,
    },
};
```