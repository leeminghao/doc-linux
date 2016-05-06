memblock_allow_resize
========================================

path: mm/memblock.c
```
void __init memblock_allow_resize(void)
{
    memblock_can_resize = 1;
}
```