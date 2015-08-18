load_elf_interp
========================================

path: fs/binfmt_elf.c
```
/* This is much more generalized than the library routine read function,
   so we keep this separate.  Technically the library read function
   is only provided so that we can read a.out libraries that have
   an ELF header */

static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
        struct file *interpreter, unsigned long *interp_map_addr,
        unsigned long no_base, struct elf_phdr *interp_elf_phdata)
{
    struct elf_phdr *eppnt;
    unsigned long load_addr = 0;
    int load_addr_set = 0;
    unsigned long last_bss = 0, elf_bss = 0;
    unsigned long error = ~0UL;
    unsigned long total_size;
    int i;

    /* First of all, some simple consistency checks */
    if (interp_elf_ex->e_type != ET_EXEC &&
        interp_elf_ex->e_type != ET_DYN)
        goto out;
    if (!elf_check_arch(interp_elf_ex))
        goto out;
    if (!interpreter->f_op->mmap)
        goto out;

    total_size = total_mapping_size(interp_elf_phdata,
                    interp_elf_ex->e_phnum);
    if (!total_size) {
        error = -EINVAL;
        goto out;
    }

    eppnt = interp_elf_phdata;
    for (i = 0; i < interp_elf_ex->e_phnum; i++, eppnt++) {
        if (eppnt->p_type == PT_LOAD) {
            int elf_type = MAP_PRIVATE | MAP_DENYWRITE;
            int elf_prot = 0;
            unsigned long vaddr = 0;
            unsigned long k, map_addr;

            if (eppnt->p_flags & PF_R)
                    elf_prot = PROT_READ;
            if (eppnt->p_flags & PF_W)
                elf_prot |= PROT_WRITE;
            if (eppnt->p_flags & PF_X)
                elf_prot |= PROT_EXEC;
            vaddr = eppnt->p_vaddr;
            if (interp_elf_ex->e_type == ET_EXEC || load_addr_set)
                elf_type |= MAP_FIXED;
            else if (no_base && interp_elf_ex->e_type == ET_DYN)
                load_addr = -vaddr;

            map_addr = elf_map(interpreter, load_addr + vaddr,
                    eppnt, elf_prot, elf_type, total_size);
            total_size = 0;
            if (!*interp_map_addr)
                *interp_map_addr = map_addr;
            error = map_addr;
            if (BAD_ADDR(map_addr))
                goto out;

            if (!load_addr_set &&
                interp_elf_ex->e_type == ET_DYN) {
                load_addr = map_addr - ELF_PAGESTART(vaddr);
                load_addr_set = 1;
            }

            /*
             * Check to see if the section's size will overflow the
             * allowed task size. Note that p_filesz must always be
             * <= p_memsize so it's only necessary to check p_memsz.
             */
            k = load_addr + eppnt->p_vaddr;
            if (BAD_ADDR(k) ||
                eppnt->p_filesz > eppnt->p_memsz ||
                eppnt->p_memsz > TASK_SIZE ||
                TASK_SIZE - eppnt->p_memsz < k) {
                error = -ENOMEM;
                goto out;
            }

            /*
             * Find the end of the file mapping for this phdr, and
             * keep track of the largest address we see for this.
             */
            k = load_addr + eppnt->p_vaddr + eppnt->p_filesz;
            if (k > elf_bss)
                elf_bss = k;

            /*
             * Do the same thing for the memory mapping - between
             * elf_bss and last_bss is the bss section.
             */
            k = load_addr + eppnt->p_memsz + eppnt->p_vaddr;
            if (k > last_bss)
                last_bss = k;
        }
    }

    if (last_bss > elf_bss) {
        /*
         * Now fill out the bss section.  First pad the last page up
         * to the page boundary, and then perform a mmap to make sure
         * that there are zero-mapped pages up to and including the
         * last bss page.
         */
        if (padzero(elf_bss)) {
            error = -EFAULT;
            goto out;
        }

        /* What we have mapped so far */
        elf_bss = ELF_PAGESTART(elf_bss + ELF_MIN_ALIGN - 1);

        /* Map the last of the bss segment */
        error = vm_brk(elf_bss, last_bss - elf_bss);
        if (BAD_ADDR(error))
            goto out;
    }

    error = load_addr;
out:
    return error;
}
```