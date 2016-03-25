update_device_tree
========================================

path: app/aboot/aboot.c
```
int update_device_tree(const void * fdt, char *cmdline,
                       void *ramdisk, unsigned ramdisk_size)
{
    int ret = 0;
    int offset;
    uint32_t *memory_reg;
    unsigned char *final_cmdline;
    uint32_t len;

    /* Check the device tree header */
    ret = fdt_check_header(fdt);
    if(ret)
    {
        dprintf(CRITICAL, "Invalid device tree header \n");
        return ret;
    }

    /* Get offset of the memory node */
    offset = fdt_path_offset(fdt,"/memory");

    memory_reg = target_dev_tree_mem(&len);

    /* Adding the memory values to the reg property */
    ret = fdt_setprop(fdt, offset, "reg", memory_reg, sizeof(uint32_t) * len * 2);
    if(ret)
    {
        dprintf(CRITICAL, "ERROR: Cannot update memory node\n");
        return ret;
    }

    /* Get offset of the chosen node */
    offset = fdt_path_offset(fdt, "/chosen");

    /* Adding the cmdline to the chosen node */
    final_cmdline = update_cmdline(cmdline);
    ret = fdt_setprop_string(fdt, offset, "bootargs", final_cmdline);
    if(ret)
    {
        dprintf(CRITICAL, "ERROR: Cannot update chosen node [bootargs]\n");
        return ret;
    }

    /* Adding the initrd-start to the chosen node */
    ret = fdt_setprop_cell(fdt, offset, "linux,initrd-start", ramdisk);
    if(ret)
    {
        dprintf(CRITICAL, "ERROR: Cannot update chosen node [linux,initrd-start]\n");
        return ret;
    }

    /* Adding the initrd-end to the chosen node */
    ret = fdt_setprop_cell(fdt, offset, "linux,initrd-end", (ramdisk + ramdisk_size));
    if(ret)
    {
        dprintf(CRITICAL, "ERROR: Cannot update chosen node [linux,initrd-end]\n");
        return ret;
    }

    fdt_pack(fdt);

    return ret;
}
```