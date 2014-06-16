Linux Trap Init
================================================================================

ARM-Linux内核启动时,通过如下调用方式:

```
start_kernel(/init/main.c) -->
setup_arch(/arch/arm/kernel/setup.c) -->
paging_init(/arch/arm/mm/nommu.c) -->
early_trap_init(/arch/arm/kernel/traps.c)
```

early_trap_init初始化中断异常向量表:

```
void __init early_trap_init(void *vectors_base)
{
        unsigned long vectors = (unsigned long)vectors_base;
        extern char __stubs_start[], __stubs_end[];
        extern char __vectors_start[], __vectors_end[];
        unsigned i;

        vectors_page = vectors_base;

        /*
         * Poison the vectors page with an undefined instruction.  This
         * instruction is chosen to be undefined for both ARM and Thumb
         * ISAs.  The Thumb version is an undefined instruction with a
         * branch back to the undefined instruction.
         */
         for (i = 0; i < PAGE_SIZE / sizeof(u32); i++)
             ((u32 *)vectors_base)[i] = 0xe7fddef1;

        /*
         * Copy the vectors, stubs and kuser helpers (in entry-armv.S)
         * into the vector page, mapped at 0xffff0000, and ensure these
         * are visible to the instruction stream.
         */
         memcpy((void *)vectors, __vectors_start, __vectors_end - __vectors_start);
         memcpy((void *)vectors + 0x1000, __stubs_start, __stubs_end - __stubs_start);

         kuser_init(vectors_base);

         flush_icache_range(vectors, vectors + PAGE_SIZE * 2);
         modify_domain(DOMAIN_USER, DOMAIN_CLIENT);
}
```

paging_init函数中调用传递的参数是: early_trap_init((void *)CONFIG_VECTORS_BASE);
early_trap_init主要完成将中断向量表(__vectors_start, __vectors_end)和中断入口函数表
(__stubs_start, __stubs_end)的相关代码copy到内存0xffff0000或者0x00000000处.
这个函数把定义在arch/arm/kernel/entry-armv.S中的异常向量表和异常处理程序的stub进行重定位:
异常向量表拷贝到0xFFFF_0000, 异常向量处理程序的stub拷贝到0xFFFF_0200,然后调用modify_domain()
修改了异常向量表所占据的页面的访问权限,这使得用户态无法访问该页,只有核心态才可以访问.