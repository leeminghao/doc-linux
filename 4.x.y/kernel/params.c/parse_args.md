parse_args
========================================

path: kernel/params.c
```
/* Args looks like "foo=bar,bar2 baz=fuz wiz". */
char *parse_args(const char *doing,
         char *args,
         const struct kernel_param *params,
         unsigned num,
         s16 min_level,
         s16 max_level,
         int (*unknown)(char *param, char *val, const char *doing))
{
    char *param, *val;

    /* Chew leading spaces */
    args = skip_spaces(args);

    if (*args)
        pr_debug("doing %s, parsing ARGS: '%s'\n", doing, args);

    while (*args) {
        int ret;
        int irq_was_disabled;

        args = next_arg(args, &param, &val);
        /* Stop at -- */
        if (!val && strcmp(param, "--") == 0)
            return args;
        irq_was_disabled = irqs_disabled();
        ret = parse_one(param, val, doing, params, num,
                min_level, max_level, unknown);
        if (irq_was_disabled && !irqs_disabled())
            pr_warn("%s: option '%s' enabled irq's!\n",
                doing, param);

        switch (ret) {
        case -ENOENT:
            pr_err("%s: Unknown parameter `%s'\n", doing, param);
            return ERR_PTR(ret);
        case -ENOSPC:
            pr_err("%s: `%s' too large for parameter `%s'\n",
                   doing, val ?: "", param);
            return ERR_PTR(ret);
        case 0:
            break;
        default:
            pr_err("%s: `%s' invalid for parameter `%s'\n",
                   doing, val ?: "", param);
            return ERR_PTR(ret);
        }
    }

    /* All parsed OK. */
    return NULL;
}
```

next_arg
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/kernel/params.c/next_arg.md

parse_one
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/kernel/params.c/parse_one.md
