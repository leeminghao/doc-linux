create_mapping
========================================

path: arch/arm/mm/mmu.c
```
/*
 * Create the page directory entries and any necessary
 * page tables for the mapping specified by `md'.  We
 * are able to cope here with varying sizes and address
 * offsets, and we take full advantage of sections and
 * supersections.
 */
static void __init create_mapping(struct map_desc *md)
{
    unsigned long addr, length, end;
    phys_addr_t phys;
    const struct mem_type *type;
    pgd_t *pgd;

    /* 1.参数合法性检查，该函数不为用户空间的虚拟地址建立映射表 */
    if (md->virtual != vectors_base() && md->virtual < TASK_SIZE) {
        pr_warn("BUG: not creating mapping for 0x%08llx at 0x%08lx in user region\n",
            (long long)__pfn_to_phys((u64)md->pfn), md->virtual);
        return;
    }

    /* 如果是iomemory，则映射的虚拟地址范围应属于高端内存区间，由于我们这里是常规的memory，
     * 即type为MT_MEMORY，所以不会进入该分支
     */
    if ((md->type == MT_DEVICE || md->type == MT_ROM) &&
        md->virtual >= PAGE_OFFSET &&
        (md->virtual < VMALLOC_START || md->virtual >= VMALLOC_END)) {
        pr_warn("BUG: mapping for 0x%08llx at 0x%08lx out of vmalloc space\n",
            (long long)__pfn_to_phys((u64)md->pfn), md->virtual);
    }

    type = &mem_types[md->type];

#ifndef CONFIG_ARM_LPAE
    /*
     * Catch 36-bit addresses
     */
    if (md->pfn >= 0x100000) {
        create_36bit_mapping(md, type);
        return;
    }
#endif
```

pgd_offset_k
----------------------------------------

获得该虚拟地址addr属于第一级页表(L1)的哪个表项，详细跟踪pgd_offset_k函数，我们内核的L1
页目录表的基地址位于0xc0004000，而我们的内核代码则是放置在0xc0008000开始的位置。
而从0xc0004000到0xc0008000区间大小是16KB，刚好就是L1页表的大小

在这里需要注意一个概念: 内核的页目录表项和进程的页目录表项，内核的页目录表项是对系统所有进程
都是公共的；而进程的页目录表项则是跟特定进程相关的，每个应用进程都有自己的页目录表项，但
各个进程对应的内核空间的页目录表相都是一样的。正是由于每个进程都有自己的页目录表相，所以
才能做到每个进程都可以独立拥有属于自己的[0，3GB]的内存空间。

```
    addr = md->virtual & PAGE_MASK;
    phys = __pfn_to_phys(md->pfn);
    length = PAGE_ALIGN(md->length + (md->virtual & ~PAGE_MASK));

    if (type->prot_l1 == 0 && ((addr | phys | length) & ~SECTION_MASK)) {
        pr_warn("BUG: map for 0x%08llx at 0x%08lx can not be mapped using pages, ignoring.\n",
            (long long)__pfn_to_phys(md->pfn), addr);
        return;
    }

    pgd = pgd_offset_k(addr);
```

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/include/asm/pgtable.h/pgd_offset_k.md

pgd_addr_end
----------------------------------------

pgd_addr_end()确保[addr，next]地址不会跨越一个L1表项所能映射的最大内存空间2MB

```
    end = addr + length;
    do {
        unsigned long next = pgd_addr_end(addr, end);
```

为什么是2MB而不是1MB呢？这个是linux的一个处理技巧.
arm典型的mmu映射框架图显示的是映射1MB, linux映射框架图在它的基础做了些调整和优化。
linux所做的调整描述如下:

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/include/asm/pgtable-2level.h/comments.md

alloc_init_pud
----------------------------------------

alloc_init_pud()函数为定位到的L1页目录表项pgd所指向的二级页表(L2)建立映射表

```
        alloc_init_pud(pgd, addr, next, phys, type);

        phys += next - addr;
        addr = next;

        // pdg++下移L1页目录表项pgd，映射下一个2MB空间的虚拟地址到对应的2MB的物理空间。
    } while (pgd++, addr != end);
}
```
