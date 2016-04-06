swapper_pg_dir
========================================

path: arch/arm/kernel/head.S
```
/*
 * swapper_pg_dir is the virtual address of the initial page table.
 * We place the page tables 16K below KERNEL_RAM_VADDR.  Therefore, we must
 * make sure that KERNEL_RAM_VADDR is correctly set.  Currently, we expect
 * the least significant 16 bits to be 0x8000, but we could probably
 * relax this restriction to KERNEL_RAM_VADDR >= PAGE_OFFSET + 0x4000.
 */
#define KERNEL_RAM_VADDR    (PAGE_OFFSET + TEXT_OFFSET)
#if (KERNEL_RAM_VADDR & 0xffff) != 0x8000
#error KERNEL_RAM_VADDR must start at 0xXXXX8000
#endif

#ifdef CONFIG_ARM_LPAE
    /* LPAE requires an additional page for the PGD */
#define PG_DIR_SIZE  0x5000
#define PMD_ORDER    3
#else
#define PG_DIR_SIZE  0x4000
#define PMD_ORDER    2
#endif

    .globl  swapper_pg_dir
    .equ    swapper_pg_dir, KERNEL_RAM_VADDR - PG_DIR_SIZE
```

经过上述计算得到swapper_pg_dir的虚拟地址为0xc0004000.