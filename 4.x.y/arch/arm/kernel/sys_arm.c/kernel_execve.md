kernel_execve
========================================

```
int kernel_execve(const char *filename,
          const char *const argv[],
          const char *const envp[])
{
    struct pt_regs regs;
    int ret;

    memset(&regs, 0, sizeof(struct pt_regs));
    ret = do_execve(filename,
            (const char __user *const __user *)argv,
            (const char __user *const __user *)envp, &regs);
    if (ret < 0)
        goto out;

    /*
     * Save argc to the register structure for userspace.
     */
    regs.ARM_r0 = ret;

    /*
     * We were successful.  We won't be returning to our caller, but
     * instead to user space by manipulating the kernel stack.
     */
    asm("add  r0, %0, %1\n\t"
        "mov  r1, %2\n\t"
        "mov  r2, %3\n\t"
        "bl   memmove\n\t"    /* copy regs to top of stack */
        "mov  r8, #0\n\t"    /* not a syscall */
        "mov  r9, %0\n\t"    /* thread structure */
        "mov  sp, r0\n\t"    /* reposition stack pointer */
        "b    ret_to_user"
        :
        : "r" (current_thread_info()),
          "Ir" (THREAD_START_SP - sizeof(regs)),
          "r" (&regs),
          "Ir" (sizeof(regs))
        : "r0", "r1", "r2", "r3", "r8", "r9", "ip", "lr", "memory");

 out:
    return ret;
}
EXPORT_SYMBOL(kernel_execve);
```

do_execve
----------------------------------------