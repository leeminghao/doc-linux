user_zonelist_order
========================================

path: mm/page_alloc.c
```
#ifdef CONFIG_NUMA
/* The value user specified ....changed by config */
static int user_zonelist_order = ZONELIST_ORDER_DEFAULT;
...
#endif
```

ZONELIST_ORDER_DEFAULT
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/mm/page_alloc.c/ZONELIST_ORDER_XXX.md
