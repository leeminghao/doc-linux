pgd_offset_k
========================================

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
