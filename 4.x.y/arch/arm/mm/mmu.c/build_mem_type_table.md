build_mem_type_table
========================================

path: arch/arm/mm/mmu.c
```
/*
 * Adjust the PMD section entries according to the CPU in use.
 */
static void __init build_mem_type_table(void)
{
    struct cachepolicy *cp;
    unsigned int cr = get_cr();
    pteval_t user_pgprot, kern_pgprot, vecs_pgprot;
    pteval_t hyp_device_pgprot, s2_pgprot, s2_device_pgprot;
    int cpu_arch = cpu_architecture();
    int i;

    if (cpu_arch < CPU_ARCH_ARMv6) {
#if defined(CONFIG_CPU_DCACHE_DISABLE)
        if (cachepolicy > CPOLICY_BUFFERED)
            cachepolicy = CPOLICY_BUFFERED;
#elif defined(CONFIG_CPU_DCACHE_WRITETHROUGH)
        if (cachepolicy > CPOLICY_WRITETHROUGH)
            cachepolicy = CPOLICY_WRITETHROUGH;
#endif
    }
    if (cpu_arch < CPU_ARCH_ARMv5) {
        if (cachepolicy >= CPOLICY_WRITEALLOC)
            cachepolicy = CPOLICY_WRITEBACK;
        ecc_mask = 0;
    }

    if (is_smp()) {
        if (cachepolicy != CPOLICY_WRITEALLOC) {
            pr_warn("Forcing write-allocate cache policy for SMP\n");
            cachepolicy = CPOLICY_WRITEALLOC;
        }
        if (!(initial_pmd_value & PMD_SECT_S)) {
            pr_warn("Forcing shared mappings for SMP\n");
            initial_pmd_value |= PMD_SECT_S;
        }
    }

    /*
     * Strip out features not present on earlier architectures.
     * Pre-ARMv5 CPUs don't have TEX bits.  Pre-ARMv6 CPUs or those
     * without extended page tables don't have the 'Shared' bit.
     */
    if (cpu_arch < CPU_ARCH_ARMv5)
        for (i = 0; i < ARRAY_SIZE(mem_types); i++)
            mem_types[i].prot_sect &= ~PMD_SECT_TEX(7);
    if ((cpu_arch < CPU_ARCH_ARMv6 || !(cr & CR_XP)) && !cpu_is_xsc3())
        for (i = 0; i < ARRAY_SIZE(mem_types); i++)
            mem_types[i].prot_sect &= ~PMD_SECT_S;

    /*
     * ARMv5 and lower, bit 4 must be set for page tables (was: cache
     * "update-able on write" bit on ARM610).  However, Xscale and
     * Xscale3 require this bit to be cleared.
     */
    if (cpu_is_xscale() || cpu_is_xsc3()) {
        for (i = 0; i < ARRAY_SIZE(mem_types); i++) {
            mem_types[i].prot_sect &= ~PMD_BIT4;
            mem_types[i].prot_l1 &= ~PMD_BIT4;
        }
    } else if (cpu_arch < CPU_ARCH_ARMv6) {
        for (i = 0; i < ARRAY_SIZE(mem_types); i++) {
            if (mem_types[i].prot_l1)
                mem_types[i].prot_l1 |= PMD_BIT4;
            if (mem_types[i].prot_sect)
                mem_types[i].prot_sect |= PMD_BIT4;
        }
    }

    /*
     * Mark the device areas according to the CPU/architecture.
     */
    if (cpu_is_xsc3() || (cpu_arch >= CPU_ARCH_ARMv6 && (cr & CR_XP))) {
        if (!cpu_is_xsc3()) {
            /*
             * Mark device regions on ARMv6+ as execute-never
             * to prevent speculative instruction fetches.
             */
            mem_types[MT_DEVICE].prot_sect |= PMD_SECT_XN;
            mem_types[MT_DEVICE_NONSHARED].prot_sect |= PMD_SECT_XN;
            mem_types[MT_DEVICE_CACHED].prot_sect |= PMD_SECT_XN;
            mem_types[MT_DEVICE_WC].prot_sect |= PMD_SECT_XN;

            /* Also setup NX memory mapping */
            mem_types[MT_MEMORY_RW].prot_sect |= PMD_SECT_XN;
        }
        if (cpu_arch >= CPU_ARCH_ARMv7 && (cr & CR_TRE)) {
            /*
             * For ARMv7 with TEX remapping,
             * - shared device is SXCB=1100
             * - nonshared device is SXCB=0100
             * - write combine device mem is SXCB=0001
             * (Uncached Normal memory)
             */
            mem_types[MT_DEVICE].prot_sect |= PMD_SECT_TEX(1);
            mem_types[MT_DEVICE_NONSHARED].prot_sect |= PMD_SECT_TEX(1);
            mem_types[MT_DEVICE_WC].prot_sect |= PMD_SECT_BUFFERABLE;
        } else if (cpu_is_xsc3()) {
            /*
             * For Xscale3,
             * - shared device is TEXCB=00101
             * - nonshared device is TEXCB=01000
             * - write combine device mem is TEXCB=00100
             * (Inner/Outer Uncacheable in xsc3 parlance)
             */
            mem_types[MT_DEVICE].prot_sect |= PMD_SECT_TEX(1) | PMD_SECT_BUFFERED;
            mem_types[MT_DEVICE_NONSHARED].prot_sect |= PMD_SECT_TEX(2);
            mem_types[MT_DEVICE_WC].prot_sect |= PMD_SECT_TEX(1);
        } else {
            /*
             * For ARMv6 and ARMv7 without TEX remapping,
             * - shared device is TEXCB=00001
             * - nonshared device is TEXCB=01000
             * - write combine device mem is TEXCB=00100
             * (Uncached Normal in ARMv6 parlance).
             */
            mem_types[MT_DEVICE].prot_sect |= PMD_SECT_BUFFERED;
            mem_types[MT_DEVICE_NONSHARED].prot_sect |= PMD_SECT_TEX(2);
            mem_types[MT_DEVICE_WC].prot_sect |= PMD_SECT_TEX(1);
        }
    } else {
        /*
         * On others, write combining is "Uncached/Buffered"
         */
        mem_types[MT_DEVICE_WC].prot_sect |= PMD_SECT_BUFFERABLE;
    }

    /*
     * Now deal with the memory-type mappings
     */
    cp = &cache_policies[cachepolicy];
    vecs_pgprot = kern_pgprot = user_pgprot = cp->pte;
    s2_pgprot = cp->pte_s2;
    hyp_device_pgprot = mem_types[MT_DEVICE].prot_pte;
    s2_device_pgprot = mem_types[MT_DEVICE].prot_pte_s2;

#ifndef CONFIG_ARM_LPAE
    /*
     * We don't use domains on ARMv6 (since this causes problems with
     * v6/v7 kernels), so we must use a separate memory type for user
     * r/o, kernel r/w to map the vectors page.
     */
    if (cpu_arch == CPU_ARCH_ARMv6)
        vecs_pgprot |= L_PTE_MT_VECTORS;

    /*
     * Check is it with support for the PXN bit
     * in the Short-descriptor translation table format descriptors.
     */
    if (cpu_arch == CPU_ARCH_ARMv7 &&
        (read_cpuid_ext(CPUID_EXT_MMFR0) & 0xF) == 4) {
        user_pmd_table |= PMD_PXNTABLE;
    }
#endif

    /*
     * ARMv6 and above have extended page tables.
     */
    if (cpu_arch >= CPU_ARCH_ARMv6 && (cr & CR_XP)) {
#ifndef CONFIG_ARM_LPAE
        /*
         * Mark cache clean areas and XIP ROM read only
         * from SVC mode and no access from userspace.
         */
        mem_types[MT_ROM].prot_sect |= PMD_SECT_APX|PMD_SECT_AP_WRITE;
        mem_types[MT_MINICLEAN].prot_sect |= PMD_SECT_APX|PMD_SECT_AP_WRITE;
        mem_types[MT_CACHECLEAN].prot_sect |= PMD_SECT_APX|PMD_SECT_AP_WRITE;
#endif

        /*
         * If the initial page tables were created with the S bit
         * set, then we need to do the same here for the same
         * reasons given in early_cachepolicy().
         */
        if (initial_pmd_value & PMD_SECT_S) {
            user_pgprot |= L_PTE_SHARED;
            kern_pgprot |= L_PTE_SHARED;
            vecs_pgprot |= L_PTE_SHARED;
            s2_pgprot |= L_PTE_SHARED;
            mem_types[MT_DEVICE_WC].prot_sect |= PMD_SECT_S;
            mem_types[MT_DEVICE_WC].prot_pte |= L_PTE_SHARED;
            mem_types[MT_DEVICE_CACHED].prot_sect |= PMD_SECT_S;
            mem_types[MT_DEVICE_CACHED].prot_pte |= L_PTE_SHARED;
            mem_types[MT_MEMORY_RWX].prot_sect |= PMD_SECT_S;
            mem_types[MT_MEMORY_RWX].prot_pte |= L_PTE_SHARED;
            mem_types[MT_MEMORY_RW].prot_sect |= PMD_SECT_S;
            mem_types[MT_MEMORY_RW].prot_pte |= L_PTE_SHARED;
            mem_types[MT_MEMORY_DMA_READY].prot_pte |= L_PTE_SHARED;
            mem_types[MT_MEMORY_RWX_NONCACHED].prot_sect |= PMD_SECT_S;
            mem_types[MT_MEMORY_RWX_NONCACHED].prot_pte |= L_PTE_SHARED;
        }
    }

    /*
     * Non-cacheable Normal - intended for memory areas that must
     * not cause dirty cache line writebacks when used
     */
    if (cpu_arch >= CPU_ARCH_ARMv6) {
        if (cpu_arch >= CPU_ARCH_ARMv7 && (cr & CR_TRE)) {
            /* Non-cacheable Normal is XCB = 001 */
            mem_types[MT_MEMORY_RWX_NONCACHED].prot_sect |=
                PMD_SECT_BUFFERED;
        } else {
            /* For both ARMv6 and non-TEX-remapping ARMv7 */
            mem_types[MT_MEMORY_RWX_NONCACHED].prot_sect |=
                PMD_SECT_TEX(1);
        }
    } else {
        mem_types[MT_MEMORY_RWX_NONCACHED].prot_sect |= PMD_SECT_BUFFERABLE;
    }

#ifdef CONFIG_ARM_LPAE
    /*
     * Do not generate access flag faults for the kernel mappings.
     */
    for (i = 0; i < ARRAY_SIZE(mem_types); i++) {
        mem_types[i].prot_pte |= PTE_EXT_AF;
        if (mem_types[i].prot_sect)
            mem_types[i].prot_sect |= PMD_SECT_AF;
    }
    kern_pgprot |= PTE_EXT_AF;
    vecs_pgprot |= PTE_EXT_AF;

    /*
     * Set PXN for user mappings
     */
    user_pgprot |= PTE_EXT_PXN;
#endif

    for (i = 0; i < 16; i++) {
        pteval_t v = pgprot_val(protection_map[i]);
        protection_map[i] = __pgprot(v | user_pgprot);
    }

    mem_types[MT_LOW_VECTORS].prot_pte |= vecs_pgprot;
    mem_types[MT_HIGH_VECTORS].prot_pte |= vecs_pgprot;

    pgprot_user   = __pgprot(L_PTE_PRESENT | L_PTE_YOUNG | user_pgprot);
    pgprot_kernel = __pgprot(L_PTE_PRESENT | L_PTE_YOUNG |
                 L_PTE_DIRTY | kern_pgprot);
    pgprot_s2  = __pgprot(L_PTE_PRESENT | L_PTE_YOUNG | s2_pgprot);
    pgprot_s2_device  = __pgprot(s2_device_pgprot);
    pgprot_hyp_device  = __pgprot(hyp_device_pgprot);

    mem_types[MT_LOW_VECTORS].prot_l1 |= ecc_mask;
    mem_types[MT_HIGH_VECTORS].prot_l1 |= ecc_mask;
    mem_types[MT_MEMORY_RWX].prot_sect |= ecc_mask | cp->pmd;
    mem_types[MT_MEMORY_RWX].prot_pte |= kern_pgprot;
    mem_types[MT_MEMORY_RW].prot_sect |= ecc_mask | cp->pmd;
    mem_types[MT_MEMORY_RW].prot_pte |= kern_pgprot;
    mem_types[MT_MEMORY_DMA_READY].prot_pte |= kern_pgprot;
    mem_types[MT_MEMORY_RWX_NONCACHED].prot_sect |= ecc_mask;
    mem_types[MT_ROM].prot_sect |= cp->pmd;

    switch (cp->pmd) {
    case PMD_SECT_WT:
        mem_types[MT_CACHECLEAN].prot_sect |= PMD_SECT_WT;
        break;
    case PMD_SECT_WB:
    case PMD_SECT_WBWA:
        mem_types[MT_CACHECLEAN].prot_sect |= PMD_SECT_WB;
        break;
    }
    pr_info("Memory policy: %sData cache %s\n",
        ecc_mask ? "ECC enabled, " : "", cp->policy);

    for (i = 0; i < ARRAY_SIZE(mem_types); i++) {
        struct mem_type *t = &mem_types[i];
        if (t->prot_l1)
            t->prot_l1 |= PMD_DOMAIN(t->domain);
        if (t->prot_sect)
            t->prot_sect |= PMD_DOMAIN(t->domain);
    }
}
```