boot_linux_from_mmc
========================================

名词
----------------------------------------

在lk引导boot.img来加载内核之前，我们先来了解几个有关kernel的名词.

https://github.com/torvalds/linux/blob/bdec41963890f8ed9ad89f8b418959ab3cdc2aa3/Documentation/arm/Porting

* ZTEXTADDR:

  boot.img运行时候zImage的起始地址，即kernel解压代码的地址。这里没有虚拟地址的概念，因为没有开启
  MMU，所以这个地址是物理内存的地址。解压代码不一定需要载入RAM才能运行，在FLASH或者其他可寻址的
  媒体上都可以运行。

* ZBSSADDR:

  解压代码的BSS段的地址，这里也是物理地址。

* ZRELADDR:

  这个是kernel解压以后存放的内存物理地址，解压代码执行完成以后会跳到这个地址执行kernel的启动，
  这个地址和后面kernel运行时候的虚拟地址满足：__virt_to_phys(TEXTADDR) = ZRELADDR。

* INITRD_PHYS:

  Initial Ram Disk存放在内存中的物理地址，这里就是我们的ramdisk.img。

* INITRD_VIRT:

  Initial Ram Disk运行时候虚拟地址。

* PARAMS_PHYS:

   内核启动的初始化参数在内存上的物理地址。


下面这些值分别和前面那几个名词相对应，比如KERNEL就是ZTEXTADDR，RAMDISK_ADDR就是INITRD_PHYS,
而TAGS_ADDR就是PARAMS_PHYS。bootloader会从boot.img的分区中将kernel和ramdisk分别读入RAM上面
定义的地址中，然后就会跳到ZTEXTADDR开始执行.

path: bootable/bootloader/lk/target/msm8960/rules.mk
```
BASE_ADDR        := 0x80200000

TAGS_ADDR        := BASE_ADDR+0x00000100
KERNEL_ADDR      := BASE_ADDR+0x00008000
RAMDISK_ADDR     := BASE_ADDR+0x01000000
```

kernel的生成过程:
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/kbuild/zImage.md

整个过程大致如下:

vmlinux经过objcopy后生成一个未经压缩的raw binary(Image 4M左右)，这里的vmlinux是我们编译链接以后
生成的vmlinx，大概60多M。这里稍微说一下这个objcopy，在启动的时候ELF格式是没法执行的，ELF格式的
解析是在kernel启动以后有了操作系统之后才能进行的。因为虽然我们编出的img虽然被编成ELF格式，
但要想启动起来必须将其转化成原始的二进制格式Image, 得到Image以后，再将这个Image跟解压代码合成一个
vmlinux, 这个vmlinux就是将Image压缩以后根据vmlinux.lds与解压代码head.o和misc.o链接以后生成的一个
elf，而且用readelf或者objdump可以很明显地看到解压代码是PIC的，所有的虚拟地址都是相对的，没有
绝对地址。得到压缩以后的vmlinx以后再将这个vmlinx经过objcopy以后就得到我们的zImage了.

加载过程
----------------------------------------

通常lk加载的linux内核是一种通过特殊处理的文件格式bootimg，这个文件通常是
kernel(内核), ramdisk.img(根文件系统)和dt.img(设备树)的集合.

有关bootimg文件描述如下所示:

https://github.com/leeminghao/doc-linux/tree/master/bootloader/images/bootimg/README.md

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
     * 这是因为我们在arch_early_init函数中打开的mmu,所以先要将物理地址映射为虚拟地址才能
     * 完成正常的加载工作.
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
        second_actual  = ROUND_TO_PAGE(hdr->second_size,  page_mask);

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
        if(hdr->second_size != 0) {
            offset += second_actual;
            /* Second image loading not implemented. */
            ASSERT(0);
        }

#if DEVICE_TREE
        if(hdr->dt_size != 0) {

            /* Read the device tree table into buffer */
            if(mmc_read(ptn + offset,(unsigned int *) dt_buf, page_size)) {
                dprintf(CRITICAL, "ERROR: Cannot read the Device Tree Table\n");
                return -1;
            }
            table = (struct dt_table*) dt_buf;

            /* Restriction that the device tree entry table should be less than a page*/
            ASSERT(((table->num_entries * sizeof(struct dt_entry))+ DEV_TREE_HEADER_SIZE) < hdr->page_size);

            /* Validate the device tree table header */
            if((table->magic != DEV_TREE_MAGIC) && (table->version != DEV_TREE_VERSION)) {
                dprintf(CRITICAL, "ERROR: Cannot validate Device Tree Table \n");
                return -1;
            }

            /* Calculate the offset of device tree within device tree table */
            if((dt_entry_ptr = get_device_tree_ptr(table)) == NULL){
                dprintf(CRITICAL, "ERROR: Getting device tree address failed\n");
                return -1;
            }

            /* Validate and Read device device tree in the "tags_add" */
            if (check_aboot_addr_range_overlap(hdr->tags_addr, dt_entry_ptr->size))
            {
                dprintf(CRITICAL, "Device tree addresses overlap with aboot addresses.\n");
                return -1;
            }

            if(mmc_read(ptn + offset + dt_entry_ptr->offset,
                         (void *)hdr->tags_addr, dt_entry_ptr->size)) {
                dprintf(CRITICAL, "ERROR: Cannot read device tree\n");
                return -1;
            }

            /* Validate the tags_addr */
            if (check_aboot_addr_range_overlap(hdr->tags_addr, kernel_actual))
            {
                dprintf(CRITICAL, "Device tree addresses overlap with aboot addresses.\n");
                return -1;
            }
        }
#endif
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

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/apps/aboot/aboot_c/boot_linux.md
