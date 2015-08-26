boot_linux
========================================

path: lk/app/aboot/aboot.c
```
void boot_linux(void *kernel, unsigned *tags,
        const char *cmdline, unsigned machtype,
        void *ramdisk, unsigned ramdisk_size)
{
    unsigned char *final_cmdline;
#if DEVICE_TREE
    int ret = 0;
#endif

    /* 1.将传递进来的kernel, ramdisk,和tag地址转换成物理地址 */
    void (*entry)(unsigned, unsigned, unsigned*) = (entry_func_ptr*)(PA((addr_t)kernel));
    uint32_t tags_phys = PA((addr_t)tags);

    ramdisk = PA(ramdisk);

    final_cmdline = update_cmdline((const char*)cmdline);

#if DEVICE_TREE
    ...
#else
    /* Generating the Atags */
    generate_atags(tags, final_cmdline, ramdisk, ramdisk_size);
#endif

    dprintf(INFO, "booting linux @ %p, ramdisk @ %p (%d)\n",
        entry, ramdisk, ramdisk_size);

    enter_critical_section();
    /* do any platform specific cleanup before kernel entry */
    platform_uninit();
    arch_disable_cache(UCACHE);
    /* NOTE:
     * The value of "entry" is getting corrupted at this point.
     * The value is in R4 and gets pushed to stack on entry into
     * disable_cache(), however, on return it is not the same.
     * Not entirely sure why this dsb() seems to take of this.
     * The stack pop operation on return from disable_cache()
     * should restore R4 properly, but that is not happening.
     * Will need to revisit to find the root cause.
     */
    dsb();
#if ARM_WITH_MMU
    arch_disable_mmu();
#endif

    /* 直接跳转到内核执行. */
    entry(0, machtype, (unsigned*)tags_phys);
}
```

各个模块的初始地址如下所示:

* kernel_addr - 0x80208000
* tags_addr - 0x80200100
* ramdisk_addr -  0x82200000

generate_atags
----------------------------------------

改函数将boot_img_hdr头部保存的信息提取出来封装成tag作为参数传递给kernel.

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/generate_atags.md

entry
----------------------------------------

内核入口函数entry, 改函数地址就是kernel加载的地址.接下来跳转到内核去执行.