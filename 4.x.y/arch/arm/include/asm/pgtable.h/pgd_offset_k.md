pgd_offset_k
========================================

pgd_offset_k宏将一个0-4G范围内的虚拟地址转换为内核进程主页表中的对应页表项所在的地址。
它首先根据pgd_index计算该虚拟地址对应的页表项在主页表中的索引值这里需要注意PGDIR_SHIFT的值为21，
而非20，所以它的偏移是取2M大小区块的索引，这是由于pgd_t的类型为两个长整形的元素。
然后根据索引值和内核进程中的init_mm.pgd取得页表项地址。

path: arch/arm/include/asm/pgtable.h
```
/* to find an entry in a page-table-directory */
#define pgd_index(addr)       ((addr) >> PGDIR_SHIFT)

#define pgd_offset(mm, addr)  ((mm)->pgd + pgd_index(addr))

/* to find an entry in a kernel page-table-directory */
#define pgd_offset_k(addr)    pgd_offset(&init_mm, addr)
```

init_mm
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/mm/init-mm.c/init_mm.md

PGDIR_SHIFT
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/include/asm/pgtable-2level.h/PMD_SIZE.md