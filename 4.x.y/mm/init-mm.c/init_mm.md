init_mm
========================================

path: mm/init-mm.c
```
struct mm_struct init_mm = {
    .mm_rb        = RB_ROOT,
    .pgd        = swapper_pg_dir,
    .mm_users    = ATOMIC_INIT(2),
    .mm_count    = ATOMIC_INIT(1),
    .mmap_sem    = __RWSEM_INITIALIZER(init_mm.mmap_sem),
    .page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
    .mmlist        = LIST_HEAD_INIT(init_mm.mmlist),
    INIT_MM_CONTEXT(init_mm)
};
```

struct mm_struct
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/include/linux/mm_types.h/mm_struct.md

swapper_pg_dir
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/kernel/head.S/swapper_pg_dir.md
