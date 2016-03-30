struct memblock
========================================

path: include/linux/memblock.h
```
struct memblock {
    bool bottom_up;  /* is bottom up direction? */
    phys_addr_t current_limit;
    struct memblock_type memory;
    struct memblock_type reserved;
#ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
    struct memblock_type physmem;
#endif
};
```

* bottom_up
  表示分配器分配内存的方式: true - 从低地址(内核映像的尾部)向高地址分配;
  false - 也就是top-down,从高地址向地址分配内存.

* current_limit
  用于限制通过memblock_alloc的内存申请.

* memory
  是可用内存的集合.

* reserved
  已分配内存的集合.

struct memblock_type
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/include/linux/memblock.h/struct_memblock_type.md