boot_img_hdr
========================================

bootimg不是普通意义上的文件系统，而是一种特殊的Android定制格式，这个文件通常是
kernel(内核), ramdisk.img(根文件系统),second stage loader(可选)和dt.img(设备树)的集合.

bootimg文件头定义如下所示:

boot_img_hdr
----------------------------------------

path: system/core/bootimg.h
```
typedef struct boot_img_hdr boot_img_hdr;

#define BOOT_MAGIC "ANDROID!"
#define BOOT_MAGIC_SIZE 8
#define BOOT_NAME_SIZE 16
#define BOOT_ARGS_SIZE 512

struct boot_img_hdr
{
    unsigned char magic[BOOT_MAGIC_SIZE];

    unsigned kernel_size;  /* size in bytes */
    unsigned kernel_addr;  /* physical load addr */

    unsigned ramdisk_size; /* size in bytes */
    unsigned ramdisk_addr; /* physical load addr */

    unsigned second_size;  /* size in bytes */
    unsigned second_addr;  /* physical load addr */

    unsigned tags_addr;    /* physical addr for kernel tags */
    unsigned page_size;    /* flash page size we assume */
    unsigned dt_size;      /* device_tree in bytes */
    unsigned unused;    /* future expansion: should be 0 */

    unsigned char name[BOOT_NAME_SIZE]; /* asciiz product name */

    unsigned char cmdline[BOOT_ARGS_SIZE];

    unsigned id[8]; /* timestamp / checksum / sha1 / etc */
};

/*
** +-----------------+
** | boot header     | 1 page
** +-----------------+
** | kernel          | n pages
** +-----------------+
** | ramdisk         | m pages
** +-----------------+
** | second stage    | o pages
** +-----------------+
** | device tree     | p pages
** +-----------------+
**
** n = (kernel_size + page_size - 1) / page_size
** m = (ramdisk_size + page_size - 1) / page_size
** o = (second_size + page_size - 1) / page_size
** p = (dt_size + page_size - 1) / page_size
** 0. all entities are page_size aligned in flash
** 1. kernel and ramdisk are required (size != 0)
** 2. second is optional (second_size == 0 -> no second)
** 3. load each element (kernel, ramdisk, second) at
**    the specified physical address (kernel_addr, etc)
** 4. prepare tags at tag_addr.  kernel_args[] is
**    appended to the kernel commandline in the tags.
** 5. r0 = 0, r1 = MACHINE_TYPE, r2 = tags_addr
** 6. if second_size != 0: jump to second_addr
**    else: jump to kernel_addr
*/
```

关于boot header这个数据结构我们需要重点注意几个比较重要的值,这些值通常不同厂商指定的不一样，
并通过给mkbootimg工具传入不同选项设置,默认值如下所示:

path: system/core/mkbootimg.c
```
    unsigned base           = 0x10000000;
    unsigned kernel_offset  = 0x00008000;
    unsigned ramdisk_offset = 0x01000000;
    unsigned second_offset  = 0x00f00000;
    unsigned tags_offset    = 0x00000100;
    ...
    hdr.kernel_addr =  base + kernel_offset;
    hdr.ramdisk_addr = base + ramdisk_offset;
    hdr.second_addr =  base + second_offset;
    hdr.tags_addr =    base + tags_offset;
    ...
    /* Even if we need to use the supplemental field, ensure we
     * are still NULL-terminated */
    strncpy((char *)hdr.cmdline, cmdline, BOOT_ARGS_SIZE - 1);
    hdr.cmdline[BOOT_ARGS_SIZE - 1] = '\0';
```
