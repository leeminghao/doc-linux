boot_linux_from_mmc
========================================

通常lk加载的linux内核是一种通过特殊处理的文件格式boot.img，这个文件通常是
kernel(内核), ramdisk.img(根文件系统)和dt.img(设备树)的集合.

boot.img这种文件头定义参考如下:

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/boot_img_hdr.md

path: lk/app/aboot/aboot.c
```
#ifdef MEMBASE
#define EMMC_BOOT_IMG_HEADER_ADDR (0xFF000+(MEMBASE))
#else
#define EMMC_BOOT_IMG_HEADER_ADDR 0xFF000
#endif
...
static unsigned char buf[4096]; // Equal to max-supported pagesize
...
int boot_linux_from_mmc(void)
{
    struct boot_img_hdr *hdr = (void*) buf;
    struct boot_img_hdr *uhdr;
    unsigned offset = 0;
    unsigned long long ptn = 0;
    const char *cmdline;
    int index = INVALID_PTN;

    unsigned char *image_addr = 0;
    unsigned kernel_actual;
    unsigned ramdisk_actual;
    unsigned imagesize_actual;
    unsigned second_actual = 0;

#if DEVICE_TREE
    struct dt_table *table;
    struct dt_entry *dt_entry_ptr;
    unsigned dt_table_offset;
#endif
    /* 1.检查固定地址处是否有boot_img_hdr, 如果有的话,则将hdr指向uhdr
     * 并且直接跳转去调用boot_linux去加载linux内核.否则跳转到步骤2去执行.
     */
    uhdr = (struct boot_img_hdr *)EMMC_BOOT_IMG_HEADER_ADDR;
    if (!memcmp(uhdr->magic, BOOT_MAGIC, BOOT_MAGIC_SIZE)) {
        dprintf(INFO, "Unified boot method!\n");
        hdr = uhdr;
        goto unified_boot;
    }

    /* 2.检查要启动到recovery还是boot. */
    if (!boot_into_recovery) {
        check_boot_image();

        index = partition_get_index("boot");
        ptn = partition_get_offset(index);
        if(ptn == 0) {
            dprintf(CRITICAL, "ERROR: No boot partition found\n");
                    return -1;
        }
    } else {
        index = partition_get_index("recovery");
        ptn = partition_get_offset(index);
        if(ptn == 0) {
            dprintf(CRITICAL, "ERROR: No recovery partition found\n");
                    return -1;
        }
    }

    /* 3.调用mmc_read接口到boot分区读取一页4096()数据. */
    if (mmc_read(ptn + offset, (unsigned int *) buf, page_size)) {
        dprintf(CRITICAL, "ERROR: Cannot read boot image header\n");
                return -1;
    }
    /* 4.检查是否是boot_img_hdr格式文件. */
    if (memcmp(hdr->magic, BOOT_MAGIC, BOOT_MAGIC_SIZE)) {
        dprintf(CRITICAL, "ERROR: Invalid boot image header\n");
                return -1;
    }

    /* 设置page_size大小 */
    if (hdr->page_size && (hdr->page_size != page_size)) {
        page_size = hdr->page_size;
        page_mask = page_size - 1;
    }

    /* Get virtual addresses since the hdr saves physical addresses. */
    /* 5.将hdr结构中保存的kernel, ramdisk, tag的物理地址转换成对应的虚拟地址.
     * 假设我们在生成boot.img时设置--base 0x80200000和--ramdisk_offset 0x02000000
     * 那么hdr结构中的各地址值如下所示:
     * kernel_addr=80208000
     * ramdisk_addr=82200000
     * tags_addr=80200100
     * 转换成对应的虚拟地址如下:
     * kernel_addr=80208000
     * ramdisk_addr=82200000
     * tags_addr=80200100
     */
    hdr->kernel_addr = VA((addr_t)(hdr->kernel_addr));
    hdr->ramdisk_addr = VA((addr_t)(hdr->ramdisk_addr));
    hdr->tags_addr = VA((addr_t)(hdr->tags_addr));

    /* 6. 计算kernel和ramdisk的大小. */
    kernel_actual  = ROUND_TO_PAGE(hdr->kernel_size,  page_mask);
    ramdisk_actual = ROUND_TO_PAGE(hdr->ramdisk_size, page_mask);

    /* Check if the addresses in the header are valid. */
    if (check_aboot_addr_range_overlap(hdr->kernel_addr, kernel_actual) ||
        check_aboot_addr_range_overlap(hdr->ramdisk_addr, ramdisk_actual))
    {
        dprintf(CRITICAL, "kernel/ramdisk addresses overlap with aboot addresses.\n");
        return -1;
    }

#ifndef DEVICE_TREE
    if (check_aboot_addr_range_overlap(hdr->tags_addr, MAX_TAGS_SIZE))
    {
        dprintf(CRITICAL, "Tags addresses overlap with aboot addresses.\n");
        return -1;
    }
#endif

    ...
    if(target_use_signed_kernel() && (!device.is_unlocked))
    {
        ......
    } else
    {
        ...

        dprintf(INFO, "Loading boot image (%d): start\n",
                kernel_actual + ramdisk_actual);

        offset = page_size;

        /* Load kernel */
        /* 7.加载kernel到内存地址0x80208000 */
        if (mmc_read(ptn + offset, (void *)hdr->kernel_addr, kernel_actual)) {
            dprintf(CRITICAL, "ERROR: Cannot read kernel image\n");
                    return -1;
        }
        offset += kernel_actual;

        /* Load ramdisk */
        if(ramdisk_actual != 0)
        {
            /* 8.加载ramdisk到0x82200000 */
            if (mmc_read(ptn + offset, (void *)hdr->ramdisk_addr, ramdisk_actual)) {
                dprintf(CRITICAL, "ERROR: Cannot read ramdisk image\n");
                return -1;
            }
        }
        offset += ramdisk_actual;

        dprintf(INFO, "Loading boot image (%d): done\n",
                kernel_actual + ramdisk_actual);
        /* 处理secondary和dt设备树 */
        ...
    }

unified_boot:
    /* 9.获取内核命令行 */
    if(hdr->cmdline[0]) {
        cmdline = (char*) hdr->cmdline;
    } else {
        cmdline = DEFAULT_CMDLINE;
    }
    dprintf(INFO, "cmdline = '%s'\n", cmdline);

    /* 10.调用boot_linux来启动内核. */
    boot_linux((void *)hdr->kernel_addr, (unsigned *) hdr->tags_addr,
           (const char *)cmdline, board_machtype(),
           (void *)hdr->ramdisk_addr, hdr->ramdisk_size);

    return 0;
}
```

boot_linux
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/boot_linux.md
