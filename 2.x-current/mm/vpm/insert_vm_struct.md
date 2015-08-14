insert_vm_struct
========================================

insert_vm_struct是内核用于插入新区域的标准函数.
其执行流程如下所示:

path: mm/mmap.c
```
/* Insert vm structure into process list sorted by address
 * and into the inode's i_mmap tree.  If vm_file is non-NULL
 * then i_mmap_rwsem is taken here.
 */
int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
{
    struct vm_area_struct *prev;
    struct rb_node **rb_link, *rb_parent;

    /*
     * The vm_pgoff of a purely anonymous vma should be irrelevant
     * until its first write fault, when page's anon_vma and index
     * are set.  But now set the vm_pgoff it will almost certainly
     * end up with (unless mremap moves it elsewhere before that
     * first wfault), so /proc/pid/maps tells a consistent story.
     *
     * By setting it to reflect the virtual start address of the
     * vma, merges and splits can happen in a seamless way, just
     * using the existing file pgoff checks and manipulations.
     * Similarly in do_mmap_pgoff and in do_brk.
     */
    if (!vma->vm_file) {
        BUG_ON(vma->anon_vma);
        vma->vm_pgoff = vma->vm_start >> PAGE_SHIFT;
    }
    if (find_vma_links(mm, vma->vm_start, vma->vm_end,
               &prev, &rb_link, &rb_parent))
        return -ENOMEM;
    if ((vma->vm_flags & VM_ACCOUNT) &&
         security_vm_enough_memory_mm(mm, vma_pages(vma)))
        return -ENOMEM;

    vma_link(mm, vma, prev, rb_link, rb_parent);
    return 0;
}
```

1.设置vma->vm_pgoff
----------------------------------------

如果vma描述的区域不是用来映射一个文件，那么设置vma描述的区域的偏移量vm_pgoff，
偏移量的单位是页而不是字节.

2.find_vma_links
----------------------------------------

find_vma_links函数通过新区域的起始地址和涉及的地址空间(mm_struct),获取如下信息:

* pprev - 前一个区域的vm_area_struct实例.
* rb_parent - 由mm->mm_rb描述的红黑树中保存新区域节点的父节点.
* rb_link - 包含该区域自身的(红黑树)叶节点.

path: mm/mmap.c
```
static int find_vma_links(struct mm_struct *mm, unsigned long addr,
        unsigned long end, struct vm_area_struct **pprev,
        struct rb_node ***rb_link, struct rb_node **rb_parent)
{
    struct rb_node **__rb_link, *__rb_parent, *rb_prev;

    __rb_link = &mm->mm_rb.rb_node;
    rb_prev = __rb_parent = NULL;

    while (*__rb_link) {
        struct vm_area_struct *vma_tmp;

        __rb_parent = *__rb_link;
        vma_tmp = rb_entry(__rb_parent, struct vm_area_struct, vm_rb);

        if (vma_tmp->vm_end > addr) {
            /* Fail if an existing vma overlaps the area */
            if (vma_tmp->vm_start < end)
                return -ENOMEM;
            __rb_link = &__rb_parent->rb_left;
        } else {
            rb_prev = __rb_parent;
            __rb_link = &__rb_parent->rb_right;
        }
    }

    *pprev = NULL;
    if (rb_prev)
        *pprev = rb_entry(rb_prev, struct vm_area_struct, vm_rb);
    *rb_link = __rb_link;
    *rb_parent = __rb_parent;
    return 0;
}
```

3.vma_link
----------------------------------------

在通过find_vma_links找到足够的信息后，接下来调用vma_link函数将新区域合并到该进程现存
的数据结构中去.

path: mm/mmap.c
```
static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
            struct vm_area_struct *prev, struct rb_node **rb_link,
            struct rb_node *rb_parent)
{
    struct address_space *mapping = NULL;

    if (vma->vm_file) {
        mapping = vma->vm_file->f_mapping;
        i_mmap_lock_write(mapping);
    }

    __vma_link(mm, vma, prev, rb_link, rb_parent);
    __vma_link_file(vma);

    if (mapping)
        i_mmap_unlock_write(mapping);

    mm->map_count++;
    validate_mm(mm);
}
```

### __vma_link

path: mm/mmap.c
```
static void
__vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
    struct vm_area_struct *prev, struct rb_node **rb_link,
    struct rb_node *rb_parent)
{
    __vma_link_list(mm, vma, prev, rb_parent);
    __vma_link_rb(mm, vma, rb_link, rb_parent);
}
```

* 1.__vma_link_list将新区域放置到进程管理区域的线性链表上。完成该工作,只需要提供
使用find_vma_links找到的前一个和后一个区域.

* 2. __vma_link_rb将新区域链接到红黑树的数据结构中.

### __vma_link_file

__vma_link_file将相关的address_space和映射(如果是文件映射)关联起来.

```
static void __vma_link_file(struct vm_area_struct *vma)
{
    struct file *file;

    file = vma->vm_file;
    if (file) {
        struct address_space *mapping = file->f_mapping;

        if (vma->vm_flags & VM_DENYWRITE)
            atomic_dec(&file_inode(file)->i_writecount);
        if (vma->vm_flags & VM_SHARED)
            atomic_inc(&mapping->i_mmap_writable);

        flush_dcache_mmap_lock(mapping);
        if (unlikely(vma->vm_flags & VM_NONLINEAR))
            vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
        else
            vma_interval_tree_insert(vma, &mapping->i_mmap);
        flush_dcache_mmap_unlock(mapping);
    }
}
```