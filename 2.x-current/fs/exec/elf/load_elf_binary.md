load_elf_binary
========================================

load_elf_binary用来装载一个elf格式的二进制文件，其具体实现如下所示:

path: fs/binfmt_elf.c
```
static int load_elf_binary(struct linux_binprm *bprm)
{
    struct file *interpreter = NULL; /* to shut gcc up */
    unsigned long load_addr = 0, load_bias = 0;
    int load_addr_set = 0;
    char * elf_interpreter = NULL;
    unsigned long error;
    struct elf_phdr *elf_ppnt, *elf_phdata, *interp_elf_phdata = NULL;
    unsigned long elf_bss, elf_brk;
    int retval, i;
    unsigned long elf_entry;
    unsigned long interp_load_addr = 0;
    unsigned long start_code, end_code, start_data, end_data;
    unsigned long reloc_func_desc __maybe_unused = 0;
    int executable_stack = EXSTACK_DEFAULT;
    struct pt_regs *regs = current_pt_regs();
    struct {
        struct elfhdr elf_ex;
        struct elfhdr interp_elf_ex;
    } *loc;
    struct arch_elf_state arch_state = INIT_ARCH_ELF_STATE;

    loc = kmalloc(sizeof(*loc), GFP_KERNEL);
    if (!loc) {
        retval = -ENOMEM;
        goto out_ret;
    }

    /* Get the exec-header */
    loc->elf_ex = *((struct elfhdr *)bprm->buf);

    retval = -ENOEXEC;
    /* First of all, some simple consistency checks */
    if (memcmp(loc->elf_ex.e_ident, ELFMAG, SELFMAG) != 0)
        goto out;

    if (loc->elf_ex.e_type != ET_EXEC && loc->elf_ex.e_type != ET_DYN)
        goto out;
    if (!elf_check_arch(&loc->elf_ex))
        goto out;
    if (!bprm->file->f_op->mmap)
        goto out;

    elf_phdata = load_elf_phdrs(&loc->elf_ex, bprm->file);
    if (!elf_phdata)
        goto out;

    elf_ppnt = elf_phdata;
    elf_bss = 0;
    elf_brk = 0;

    start_code = ~0UL;
    end_code = 0;
    start_data = 0;
    end_data = 0;

    for (i = 0; i < loc->elf_ex.e_phnum; i++) {
        if (elf_ppnt->p_type == PT_INTERP) {
            /* This is the program interpreter used for
             * shared libraries - for now assume that this
             * is an a.out format binary
             */
            retval = -ENOEXEC;
            if (elf_ppnt->p_filesz > PATH_MAX ||
                elf_ppnt->p_filesz < 2)
                goto out_free_ph;

            retval = -ENOMEM;
            elf_interpreter = kmalloc(elf_ppnt->p_filesz,
                          GFP_KERNEL);
            if (!elf_interpreter)
                goto out_free_ph;

            retval = kernel_read(bprm->file, elf_ppnt->p_offset,
                         elf_interpreter,
                         elf_ppnt->p_filesz);
            if (retval != elf_ppnt->p_filesz) {
                if (retval >= 0)
                    retval = -EIO;
                goto out_free_interp;
            }
            /* make sure path is NULL terminated */
            retval = -ENOEXEC;
            if (elf_interpreter[elf_ppnt->p_filesz - 1] != '\0')
                goto out_free_interp;

            interpreter = open_exec(elf_interpreter);
            retval = PTR_ERR(interpreter);
            if (IS_ERR(interpreter))
                goto out_free_interp;

            /*
             * If the binary is not readable then enforce
             * mm->dumpable = 0 regardless of the interpreter's
             * permissions.
             */
            would_dump(bprm, interpreter);

            retval = kernel_read(interpreter, 0, bprm->buf,
                         BINPRM_BUF_SIZE);
            if (retval != BINPRM_BUF_SIZE) {
                if (retval >= 0)
                    retval = -EIO;
                goto out_free_dentry;
            }

            /* Get the exec headers */
            loc->interp_elf_ex = *((struct elfhdr *)bprm->buf);
            break;
        }
        elf_ppnt++;
    }

    elf_ppnt = elf_phdata;
    for (i = 0; i < loc->elf_ex.e_phnum; i++, elf_ppnt++)
        switch (elf_ppnt->p_type) {
        case PT_GNU_STACK:
            if (elf_ppnt->p_flags & PF_X)
                executable_stack = EXSTACK_ENABLE_X;
            else
                executable_stack = EXSTACK_DISABLE_X;
            break;

        case PT_LOPROC ... PT_HIPROC:
            retval = arch_elf_pt_proc(&loc->elf_ex, elf_ppnt,
                          bprm->file, false,
                          &arch_state);
            if (retval)
                goto out_free_dentry;
            break;
        }

    /* Some simple consistency checks for the interpreter */
    if (elf_interpreter) {
        retval = -ELIBBAD;
        /* Not an ELF interpreter */
        if (memcmp(loc->interp_elf_ex.e_ident, ELFMAG, SELFMAG) != 0)
            goto out_free_dentry;
        /* Verify the interpreter has a valid arch */
        if (!elf_check_arch(&loc->interp_elf_ex))
            goto out_free_dentry;

        /* Load the interpreter program headers */
        interp_elf_phdata = load_elf_phdrs(&loc->interp_elf_ex,
                           interpreter);
        if (!interp_elf_phdata)
            goto out_free_dentry;

        /* Pass PT_LOPROC..PT_HIPROC headers to arch code */
        elf_ppnt = interp_elf_phdata;
        for (i = 0; i < loc->interp_elf_ex.e_phnum; i++, elf_ppnt++)
            switch (elf_ppnt->p_type) {
            case PT_LOPROC ... PT_HIPROC:
                retval = arch_elf_pt_proc(&loc->interp_elf_ex,
                              elf_ppnt, interpreter,
                              true, &arch_state);
                if (retval)
                    goto out_free_dentry;
                break;
            }
    }

    /*
     * Allow arch code to reject the ELF at this point, whilst it's
     * still possible to return an error to the code that invoked
     * the exec syscall.
     */
    retval = arch_check_elf(&loc->elf_ex, !!interpreter, &arch_state);
    if (retval)
        goto out_free_dentry;

    /* Flush all traces of the currently running executable */
    retval = flush_old_exec(bprm);
    if (retval)
        goto out_free_dentry;

    /* Do this immediately, since STACK_TOP as used in setup_arg_pages
       may depend on the personality.  */
    SET_PERSONALITY2(loc->elf_ex, &arch_state);
    if (elf_read_implies_exec(loc->elf_ex, executable_stack))
        current->personality |= READ_IMPLIES_EXEC;

    if (!(current->personality & ADDR_NO_RANDOMIZE) && randomize_va_space)
        current->flags |= PF_RANDOMIZE;

    setup_new_exec(bprm);

    /* Do this so that we can load the interpreter, if need be.  We will
       change some of these later */
    retval = setup_arg_pages(bprm, randomize_stack_top(STACK_TOP),
                 executable_stack);
    if (retval < 0)
        goto out_free_dentry;

    current->mm->start_stack = bprm->p;

    /* Now we do a little grungy work by mmapping the ELF image into
       the correct location in memory. */
    for(i = 0, elf_ppnt = elf_phdata;
        i < loc->elf_ex.e_phnum; i++, elf_ppnt++) {
        int elf_prot = 0, elf_flags;
        unsigned long k, vaddr;

        if (elf_ppnt->p_type != PT_LOAD)
            continue;

        if (unlikely (elf_brk > elf_bss)) {
            unsigned long nbyte;

            /* There was a PT_LOAD segment with p_memsz > p_filesz
               before this one. Map anonymous pages, if needed,
               and clear the area.  */
            retval = set_brk(elf_bss + load_bias,
                     elf_brk + load_bias);
            if (retval)
                goto out_free_dentry;
            nbyte = ELF_PAGEOFFSET(elf_bss);
            if (nbyte) {
                nbyte = ELF_MIN_ALIGN - nbyte;
                if (nbyte > elf_brk - elf_bss)
                    nbyte = elf_brk - elf_bss;
                if (clear_user((void __user *)elf_bss +
                            load_bias, nbyte)) {
                    /*
                     * This bss-zeroing can fail if the ELF
                     * file specifies odd protections. So
                     * we don't check the return value
                     */
                }
            }
        }

        if (elf_ppnt->p_flags & PF_R)
            elf_prot |= PROT_READ;
        if (elf_ppnt->p_flags & PF_W)
            elf_prot |= PROT_WRITE;
        if (elf_ppnt->p_flags & PF_X)
            elf_prot |= PROT_EXEC;

        elf_flags = MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE;

        vaddr = elf_ppnt->p_vaddr;
        if (loc->elf_ex.e_type == ET_EXEC || load_addr_set) {
            elf_flags |= MAP_FIXED;
        } else if (loc->elf_ex.e_type == ET_DYN) {
            /* Try and get dynamic programs out of the way of the
             * default mmap base, as well as whatever program they
             * might try to exec.  This is because the brk will
             * follow the loader, and is not movable.  */
#ifdef CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE
            /* Memory randomization might have been switched off
             * in runtime via sysctl or explicit setting of
             * personality flags.
             * If that is the case, retain the original non-zero
             * load_bias value in order to establish proper
             * non-randomized mappings.
             */
            if (current->flags & PF_RANDOMIZE)
                load_bias = 0;
            else
                load_bias = ELF_PAGESTART(ELF_ET_DYN_BASE - vaddr);
#else
            load_bias = ELF_PAGESTART(ELF_ET_DYN_BASE - vaddr);
#endif
        }

        error = elf_map(bprm->file, load_bias + vaddr, elf_ppnt,
                elf_prot, elf_flags, 0);
        if (BAD_ADDR(error)) {
            retval = IS_ERR((void *)error) ?
                PTR_ERR((void*)error) : -EINVAL;
            goto out_free_dentry;
        }

        if (!load_addr_set) {
            load_addr_set = 1;
            load_addr = (elf_ppnt->p_vaddr - elf_ppnt->p_offset);
            if (loc->elf_ex.e_type == ET_DYN) {
                load_bias += error -
                             ELF_PAGESTART(load_bias + vaddr);
                load_addr += load_bias;
                reloc_func_desc = load_bias;
            }
        }
        k = elf_ppnt->p_vaddr;
        if (k < start_code)
            start_code = k;
        if (start_data < k)
            start_data = k;

        /*
         * Check to see if the section's size will overflow the
         * allowed task size. Note that p_filesz must always be
         * <= p_memsz so it is only necessary to check p_memsz.
         */
        if (BAD_ADDR(k) || elf_ppnt->p_filesz > elf_ppnt->p_memsz ||
            elf_ppnt->p_memsz > TASK_SIZE ||
            TASK_SIZE - elf_ppnt->p_memsz < k) {
            /* set_brk can never work. Avoid overflows. */
            retval = -EINVAL;
            goto out_free_dentry;
        }

        k = elf_ppnt->p_vaddr + elf_ppnt->p_filesz;

        if (k > elf_bss)
            elf_bss = k;
        if ((elf_ppnt->p_flags & PF_X) && end_code < k)
            end_code = k;
        if (end_data < k)
            end_data = k;
        k = elf_ppnt->p_vaddr + elf_ppnt->p_memsz;
        if (k > elf_brk)
            elf_brk = k;
    }

    loc->elf_ex.e_entry += load_bias;
    elf_bss += load_bias;
    elf_brk += load_bias;
    start_code += load_bias;
    end_code += load_bias;
    start_data += load_bias;
    end_data += load_bias;

    /* Calling set_brk effectively mmaps the pages that we need
     * for the bss and break sections.  We must do this before
     * mapping in the interpreter, to make sure it doesn't wind
     * up getting placed where the bss needs to go.
     */
    retval = set_brk(elf_bss, elf_brk);
    if (retval)
        goto out_free_dentry;
    if (likely(elf_bss != elf_brk) && unlikely(padzero(elf_bss))) {
        retval = -EFAULT; /* Nobody gets to see this, but.. */
        goto out_free_dentry;
    }

    if (elf_interpreter) {
        unsigned long interp_map_addr = 0;

        elf_entry = load_elf_interp(&loc->interp_elf_ex,
                        interpreter,
                        &interp_map_addr,
                        load_bias, interp_elf_phdata);
        if (!IS_ERR((void *)elf_entry)) {
            /*
             * load_elf_interp() returns relocation
             * adjustment
             */
            interp_load_addr = elf_entry;
            elf_entry += loc->interp_elf_ex.e_entry;
        }
        if (BAD_ADDR(elf_entry)) {
            retval = IS_ERR((void *)elf_entry) ?
                    (int)elf_entry : -EINVAL;
            goto out_free_dentry;
        }
        reloc_func_desc = interp_load_addr;

        allow_write_access(interpreter);
        fput(interpreter);
        kfree(elf_interpreter);
    } else {
        elf_entry = loc->elf_ex.e_entry;
        if (BAD_ADDR(elf_entry)) {
            retval = -EINVAL;
            goto out_free_dentry;
        }
    }

    kfree(interp_elf_phdata);
    kfree(elf_phdata);

    set_binfmt(&elf_format);

#ifdef ARCH_HAS_SETUP_ADDITIONAL_PAGES
    retval = arch_setup_additional_pages(bprm, !!elf_interpreter);
    if (retval < 0)
        goto out;
#endif /* ARCH_HAS_SETUP_ADDITIONAL_PAGES */

    install_exec_creds(bprm);
    retval = create_elf_tables(bprm, &loc->elf_ex,
              load_addr, interp_load_addr);
    if (retval < 0)
        goto out;
    /* N.B. passed_fileno might not be initialized? */
    current->mm->end_code = end_code;
    current->mm->start_code = start_code;
    current->mm->start_data = start_data;
    current->mm->end_data = end_data;
    current->mm->start_stack = bprm->p;

#ifdef arch_randomize_brk
    if ((current->flags & PF_RANDOMIZE) && (randomize_va_space > 1)) {
        current->mm->brk = current->mm->start_brk =
            arch_randomize_brk(current->mm);
#ifdef CONFIG_COMPAT_BRK
        current->brk_randomized = 1;
#endif
    }
#endif

    if (current->personality & MMAP_PAGE_ZERO) {
        /* Why this, you ask???  Well SVr4 maps page 0 as read-only,
           and some applications "depend" upon this behavior.
           Since we do not have the power to recompile these, we
           emulate the SVr4 behavior. Sigh. */
        error = vm_mmap(NULL, 0, PAGE_SIZE, PROT_READ | PROT_EXEC,
                MAP_FIXED | MAP_PRIVATE, 0);
    }

#ifdef ELF_PLAT_INIT
    /*
     * The ABI may specify that certain registers be set up in special
     * ways (on i386 %edx is the address of a DT_FINI function, for
     * example.  In addition, it may also specify (eg, PowerPC64 ELF)
     * that the e_entry field is the address of the function descriptor
     * for the startup routine, rather than the address of the startup
     * routine itself.  This macro performs whatever initialization to
     * the regs structure is required as well as any relocations to the
     * function descriptor entries when executing dynamically links apps.
     */
    ELF_PLAT_INIT(regs, reloc_func_desc);
#endif

    start_thread(regs, elf_entry, bprm->p);
    retval = 0;
out:
    kfree(loc);
out_ret:
    return retval;

    /* error cleanup */
out_free_dentry:
    kfree(interp_elf_phdata);
    allow_write_access(interpreter);
    if (interpreter)
        fput(interpreter);
out_free_interp:
    kfree(elf_interpreter);
out_free_ph:
    kfree(elf_phdata);
    goto out;
}
```

下面我们逐步分析load_elf_binary函数的各部分机制:

1.为loc分配空间
----------------------------------------

```
    ...
    struct {
        struct elfhdr elf_ex;
        struct elfhdr interp_elf_ex;
    } *loc;
    ...
    loc = kmalloc(sizeof(*loc), GFP_KERNEL);
```

loc变量由两个struct elfhdr结构的变量elf_ex和interp_elf_ex组成,其中elfhdr是宏，定义如下所示:

path: include/linux/elf.h
```
#if ELF_CLASS == ELFCLASS32
...
#define elfhdr elf32_hdr // 32位体系结构
...
#else
...
#define elfhdr elf64_hdr // 64位体系结构
...
#endif
```

elf头部具体定义如下所示:

* https://github.com/leeminghao/doc-linux/tree/master/2.x-current/fs/exec/elf/elf.md

2.校验二进制文件elf header
----------------------------------------

```
    /* Get the exec-header */
    /* 1.bprm 的成员变量buf中存储可执行文件的前128个字节 */
    loc->elf_ex = *((struct elfhdr *)bprm->buf);

    retval = -ENOEXEC;
    /* First of all, some simple consistency checks */
    /* 2.校验是否是elf header. */
    if (memcmp(loc->elf_ex.e_ident, ELFMAG, SELFMAG) != 0)
        goto out;

    /* 3.校验二进制文件的type是否允许是允许load的type. */
    if (loc->elf_ex.e_type != ET_EXEC && loc->elf_ex.e_type != ET_DYN)
        goto out;
    /* 4.校验体系结构arch是否合法. */
    if (!elf_check_arch(&loc->elf_ex))
        goto out;
    /* 5.校验对应二进制文件是否提供mmap函数. */
    if (!bprm->file->f_op->mmap)
        goto out;
```

3.load_elf_phdrs加载程序头
----------------------------------------

```
    ...
    struct elf_phdr *elf_ppnt, *elf_phdata, *interp_elf_phdata = NULL;
    ...
    elf_phdata = load_elf_phdrs(&loc->elf_ex, bprm->file);
    ...
```

load_elf_phdrs具体实现如下所示:

* https://github.com/leeminghao/doc-linux/tree/master/2.x-current/fs/exec/elf/load_elf_phdrs.md

4.初始化局部变量
----------------------------------------

```
    ...
    struct elf_phdr *elf_ppnt, *elf_phdata, *interp_elf_phdata = NULL;
    unsigned long elf_bss, elf_brk;
    ...
    unsigned long start_code, end_code, start_data, end_data;
    ...
    // 将读出的程序头指针指向elf_ppnt
    elf_ppnt = elf_phdata;
    elf_bss = 0;
    elf_brk = 0;

    /* 可执行代码的虚拟地址空间区域，其开始和结束分别通过start_code和end_code标记 */
    start_code = ~0UL;
    end_code = 0;
    /* start_data和end_data标记了包含已经初始化数据的区域. */
    start_data = 0;
    end_data = 0;
```

5. 初始化INTERP段
----------------------------------------

```
    struct file *interpreter = NULL; /* to shut gcc up */
    ...
    char * elf_interpreter = NULL;
    ...
    /* 循环遍历所有程序头找到INTERP段. */
    for (i = 0; i < loc->elf_ex.e_phnum; i++) {
        /* 1.找到类型为INERP的程序头. */
        if (elf_ppnt->p_type == PT_INTERP) {
            /* This is the program interpreter used for
             * shared libraries - for now assume that this
             * is an a.out format binary
             */
            retval = -ENOEXEC;
            if (elf_ppnt->p_filesz > PATH_MAX ||
                elf_ppnt->p_filesz < 2)
                goto out_free_ph;

            retval = -ENOMEM;
            /* 2.为INTERP段分配内存空间. */
            elf_interpreter = kmalloc(elf_ppnt->p_filesz,
                          GFP_KERNEL);
            if (!elf_interpreter)
                goto out_free_ph;

            /* 3.从二进制文件中读出对应的INTERP段. INTERP段中存这对应链接器的名称. */
            retval = kernel_read(bprm->file, elf_ppnt->p_offset,
                         elf_interpreter,
                         elf_ppnt->p_filesz);
            if (retval != elf_ppnt->p_filesz) {
                if (retval >= 0)
                    retval = -EIO;
                goto out_free_interp;
            }
            /* make sure path is NULL terminated */
            retval = -ENOEXEC;
            if (elf_interpreter[elf_ppnt->p_filesz - 1] != '\0')
                goto out_free_interp;

            /* 4.调用open_exec打开对应链接器文件并保存为一个struct file的结构. */
            interpreter = open_exec(elf_interpreter);
            retval = PTR_ERR(interpreter);
            if (IS_ERR(interpreter))
                goto out_free_interp;

            /*
             * If the binary is not readable then enforce
             * mm->dumpable = 0 regardless of the interpreter's
             * permissions.
             */
            would_dump(bprm, interpreter);

            /* 5.从打开的解释器文件中读出前128个字节到bprm->buf中去. */
            retval = kernel_read(interpreter, 0, bprm->buf,
                         BINPRM_BUF_SIZE);
            if (retval != BINPRM_BUF_SIZE) {
                if (retval >= 0)
                    retval = -EIO;
                goto out_free_dentry;
            }

            /* Get the exec headers */
            /* locl->interp_elf_ex指向对应的interp头部. */
            loc->interp_elf_ex = *((struct elfhdr *)bprm->buf);
            break;
        }
        elf_ppnt++;
    }
    ...
```

6.校验其它程序段
----------------------------------------

```
    ...
    int executable_stack = EXSTACK_DEFAULT;
    ...
    elf_ppnt = elf_phdata;
    for (i = 0; i < loc->elf_ex.e_phnum; i++, elf_ppnt++)
        switch (elf_ppnt->p_type) {
        /* 读取堆栈段权限并设置堆栈段权限位. */
        case PT_GNU_STACK:
            if (elf_ppnt->p_flags & PF_X)
                executable_stack = EXSTACK_ENABLE_X;
            else
                executable_stack = EXSTACK_DISABLE_X;
            break;
        /* 处理器专用段检测. */
        case PT_LOPROC ... PT_HIPROC:
            retval = arch_elf_pt_proc(&loc->elf_ex, elf_ppnt,
                          bprm->file, false,
                          &arch_state);
            if (retval)
                goto out_free_dentry;
            break;
        }
    ...
```

7.校验解释器elf文件
----------------------------------------

```
    ...
    /* Some simple consistency checks for the interpreter */
    if (elf_interpreter) {
        retval = -ELIBBAD;
        /* Not an ELF interpreter */
        /* 1.检查解释器文件是否是elf格式文件. */
        if (memcmp(loc->interp_elf_ex.e_ident, ELFMAG, SELFMAG) != 0)
            goto out_free_dentry;
        /* Verify the interpreter has a valid arch */
        /* 2.检查解释器文件的arch是否合法. */
        if (!elf_check_arch(&loc->interp_elf_ex))
            goto out_free_dentry;

        /* Load the interpreter program headers */
        /* 3.加载解释器文件的所有程序头部. */
        interp_elf_phdata = load_elf_phdrs(&loc->interp_elf_ex,
                           interpreter);
        if (!interp_elf_phdata)
            goto out_free_dentry;

        /* Pass PT_LOPROC..PT_HIPROC headers to arch code */
        /* 4.处理解释器二进制文件的与处理器相关的程序段. */
        elf_ppnt = interp_elf_phdata;
        for (i = 0; i < loc->interp_elf_ex.e_phnum; i++, elf_ppnt++)
            switch (elf_ppnt->p_type) {
            case PT_LOPROC ... PT_HIPROC:
                retval = arch_elf_pt_proc(&loc->interp_elf_ex,
                              elf_ppnt, interpreter,
                              true, &arch_state);
                if (retval)
                    goto out_free_dentry;
                break;
            }
    }
    ...
```

8.arch_check_elf
----------------------------------------

目前改实现为空. 目的是提供最后一次机会来拒绝加载对应的ELF文件.

```
    ...
    /*
     * Allow arch code to reject the ELF at this point, whilst it's
     * still possible to return an error to the code that invoked
     * the exec syscall.
     */
    retval = arch_check_elf(&loc->elf_ex, !!interpreter, &arch_state);
    if (retval)
        goto out_free_dentry;
    ...
```

9.flush_old_exec
----------------------------------------

```
    ...
    /* Flush all traces of the currently running executable */
    retval = flush_old_exec(bprm);
    if (retval)
        goto out_free_dentry;
    ...
```

在bprm_mm_init函数中

https://github.com/leeminghao/doc-linux/tree/master/2.x-current/fs/exec/bprm_mm_init.md

我们专门为可执行的二进制文件申请了一个地址空间，使用mm_struct来表示，这个地址空间用来
替换当前进程的地址空间，flush_old_exec函数的作用就是用来替换当前进程地址空间的.
具体实现如下所示:

https://github.com/leeminghao/doc-linux/tree/master/2.x-current/fs/exec/flush_old_exec.md

10.设置与体系结构相关特性
----------------------------------------

```
    ...
    struct arch_elf_state arch_state = INIT_ARCH_ELF_STATE;
    ...
    /* Do this immediately, since STACK_TOP as used in setup_arg_pages
       may depend on the personality.  */
    SET_PERSONALITY2(loc->elf_ex, &arch_state);
    if (elf_read_implies_exec(loc->elf_ex, executable_stack))
        current->personality |= READ_IMPLIES_EXEC;

    /* 检查是否需要设置进程的PF_RANDOMIZE标志，如果设置了改标志，则内核不会为栈和内存
     * 映射的起点选择固定位置，而是每次新进程启动的时候随机改变这些值的设置. 引入这项
     * 的目的是使得攻击因缓冲区移除导致安全漏洞更加困难.
     */
    if (!(current->personality & ADDR_NO_RANDOMIZE) && randomize_va_space)
        current->flags |= PF_RANDOMIZE;
    ...
```

randomize_va_space的描述如下所示:

https://github.com/leeminghao/doc-linux/tree/master/2.x-current/mm/vpm/randomize_va_space.md

11.设置进程虚拟地址空间的布局
----------------------------------------

setup_new_exec函数用来设置进程虚拟地址空间的布局.

```
    ...
    setup_new_exec(bprm);
    ...
```

setup_new_exec函数具体实现如下所示:

https://github.com/leeminghao/doc-linux/tree/master/2.x-current/fs/exec/setup_new_exec.md

12.在适当位置创建栈
----------------------------------------

setup_arg_pages函数用来在进程虚拟地址空间适当的位置创建栈.

```
    ...
    /* Do this so that we can load the interpreter, if need be.  We will
       change some of these later */
    retval = setup_arg_pages(bprm, randomize_stack_top(STACK_TOP),
                 executable_stack);
    ...
    current->mm->start_stack = bprm->p;
```

STACK_TOP值在arm体系结构定义如下所示:

https://github.com/leeminghao/doc-linux/blob/master/2.x-current/arch/arm/mm/memory.md

setup_arg_pages具体实现如下所示:

https://github.com/leeminghao/doc-linux/tree/master/2.x-current/fs/exec/setup_arg_pages.md