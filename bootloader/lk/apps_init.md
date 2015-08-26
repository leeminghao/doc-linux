apps_init
========================================

path: lk/apps/app.c
```
/* one time setup */
void apps_init(void)
{
    const struct app_descriptor *app;

    /* call all the init routines */
    for (app = &__apps_start; app != &__apps_end; app++) {
        if (app->init)
            app->init(app);
    }

    /* start any that want to start on boot */
    for (app = &__apps_start; app != &__apps_end; app++) {
        if (app->entry && (app->flags & APP_FLAG_DONT_START_ON_BOOT) == 0) {
            start_app(app);
        }
    }
}
```

aboot是lk中的一个app,在这里会调用aboot的初始话函数aboot_init.

aboot_init
----------------------------------------

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