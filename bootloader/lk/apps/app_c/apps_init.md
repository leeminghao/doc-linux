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

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/apps/aboot/aboot_c/aboot_init.md
