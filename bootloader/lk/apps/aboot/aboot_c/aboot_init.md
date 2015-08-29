aboot_init
========================================

path: lk/apps/aboot/aboot.c
```
void aboot_init(const struct app_descriptor *app)
{
    ...
    if (target_is_emmc_boot())
    {
        ...
        boot_linux_from_mmc();
    }
    ...
}
```

在aboot_init中会检查是否从emmc启动，如果是的话则从emmc加载linux内核.

boot_linux_from_mmc
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/apps/aboot/aboot_c/boot_linux_from_mmc.md