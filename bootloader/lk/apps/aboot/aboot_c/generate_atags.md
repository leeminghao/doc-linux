generate_atags
========================================

path: lk/app/aboot/aboot.c
```
void generate_atags(unsigned *ptr, const char *cmdline,
                    void *ramdisk, unsigned ramdisk_size)
{

    ptr = atag_core(ptr);
    ptr = atag_ramdisk(ptr, ramdisk, ramdisk_size);
    ptr = target_atag_mem(ptr);
    ptr = target_atag_pureason(ptr);
    ptr = target_atag_hwversion(ptr);
    ptr = target_atag_memvendor(ptr);

    /* Skip NAND partition ATAGS for eMMC boot */
    if (!target_is_emmc_boot()){
        ptr = atag_ptable(&ptr);
    }

    ptr = atag_cmdline(ptr, cmdline);
    ptr = atag_end(ptr);
}
```

atag_core
----------------------------------------

path: lk/app/aboot/aboot.c
```
unsigned *atag_core(unsigned *ptr)
{
    /* CORE */
    *ptr++ = 2;
    *ptr++ = 0x54410001;

    return ptr;

}
```

atag_ramdisk
----------------------------------------

path: lk/app/aboot/aboot.c
```
unsigned *atag_ramdisk(unsigned *ptr, void *ramdisk,
                               unsigned ramdisk_size)
{
    if (ramdisk_size) {
        *ptr++ = 4;
        *ptr++ = 0x54420005;
        *ptr++ = (unsigned)ramdisk;
        *ptr++ = ramdisk_size;
    }

    return ptr;
}
```

atag_ptable
----------------------------------------

path: lk/app/aboot/aboot.c
unsigned *atag_ptable(unsigned **ptr_addr)
{
    int i;
    struct ptable *ptable;

    if ((ptable = flash_get_ptable()) && (ptable->count != 0)) {
            *(*ptr_addr)++ = 2 + (ptable->count * (sizeof(struct atag_ptbl_entry) /
                              sizeof(unsigned)));
        *(*ptr_addr)++ = 0x4d534d70;
        for (i = 0; i < ptable->count; ++i)
            ptentry_to_tag(ptr_addr, ptable_get(ptable, i));
    }

    return (*ptr_addr);
}

atag_cmdline
----------------------------------------

path: lk/app/aboot/aboot.c
```
unsigned *atag_cmdline(unsigned *ptr, const char *cmdline)
{
    int cmdline_length = 0;
    int n;
    char *dest;

    cmdline_length = strlen((const char*)cmdline);
    n = (cmdline_length + 4) & (~3);

    *ptr++ = (n / 4) + 2;
    *ptr++ = 0x54410009;
    dest = (char *) ptr;
    while ((*dest++ = *cmdline++));
    ptr += (n / 4);

    return ptr;
}
```

atag_end
----------------------------------------

path: lk/app/aboot/aboot.c
```
unsigned *atag_end(unsigned *ptr)
{
    /* END */
    *ptr++ = 0;
    *ptr++ = 0;

    return ptr;
}
```