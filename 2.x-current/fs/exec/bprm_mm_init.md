bprm_mm_init
========================================

bprm_mm_init
----------------------------------------

path: fs/exec.c
```
/*
 * Create a new mm_struct and populate it with a temporary stack
 * vm_area_struct.  We don't have enough context at this point to set the stack
 * flags, permissions, and offset, so we use temporary values.  We'll update
 * them later in setup_arg_pages().
 */
static int bprm_mm_init(struct linux_binprm *bprm)
{
    int err;
    struct mm_struct *mm = NULL;

    bprm->mm = mm = mm_alloc();
    err = -ENOMEM;
    if (!mm)
        goto err;

    err = __bprm_mm_init(bprm);
    if (err)
        goto err;

    return 0;

err:
    if (mm) {
        bprm->mm = NULL;
        mmdrop(mm);
    }

    return err;
}
```

__bprm_mm_init
----------------------------------------

static int __bprm_mm_init(struct linux_binprm *bprm)
{
    int err;
    struct vm_area_struct *vma = NULL;
    struct mm_struct *mm = bprm->mm;

    bprm->vma = vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
    if (!vma)
        return -ENOMEM;

    down_write(&mm->mmap_sem);
    vma->vm_mm = mm;

    /*
     * Place the stack at the largest stack address the architecture
     * supports. Later, we'll move this to an appropriate place. We don't
     * use STACK_TOP because that can depend on attributes which aren't
     * configured yet.
     */
    BUILD_BUG_ON(VM_STACK_FLAGS & VM_STACK_INCOMPLETE_SETUP);
    vma->vm_end = STACK_TOP_MAX;
    vma->vm_start = vma->vm_end - PAGE_SIZE;
    vma->vm_flags = VM_SOFTDIRTY | VM_STACK_FLAGS | VM_STACK_INCOMPLETE_SETUP;
    vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
    INIT_LIST_HEAD(&vma->anon_vma_chain);

    err = insert_vm_struct(mm, vma);
    if (err)
        goto err;

    mm->stack_vm = mm->total_vm = 1;
    arch_bprm_mm_init(mm, vma);
    up_write(&mm->mmap_sem);
    bprm->p = vma->vm_end - sizeof(void *);
    return 0;
err:
    up_write(&mm->mmap_sem);
    bprm->vma = NULL;
    kmem_cache_free(vm_area_cachep, vma);
    return err;
}