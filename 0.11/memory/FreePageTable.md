释放页表:
================================================================================

内核使用了内存,自然就会有释放的时候。当进程创建时,需要获得大量的内存,也会释放大量的内存空间;
当进程退出时,肯定有大量的内存需要释放。而伴随这种大量的内存释放工作,这些空间对应的页表也会
变成无用的。如果不进行回收,将是巨大的浪费。内核如果要做这种释放(见算法 free_page_tables ),
至少需要释放一个页表所映射的4M的线性空间,所以释放空间起始地址应该是以4M为边界的。要释放的空间
不可以是低16M的空间。因为这个线性空间是用于内核对物理内存的控制,不可以被释放。接下来要做的就很
明显了。整个操作将导致页目录表的变化。由于cpu为了提高内存访问速度,会将页目录表和部分页表加载到
cpu 页变换高速缓存中,我们修改了页目录表就必须使 cpu 页变换高速缓存中的内容同我们修改后的相同,
所以必须刷新页变换高速缓冲。通过重新对页目录表寄存器 cr3 赋值就可以使 cpu 刷新页变换高速缓冲。

```
算法: free_page_tables
输入: 要释放空间起始线性地址 from; 要释放空间大小 size
输出: 如果成功,返回0; 如果失败,使调用对象进入死循环
{
    if ( 要释放的空间不是以 4M 为边界 )
        显示出错信息,调用对象死循环;
    if( 要释放的空间是用于内核控制物理内存的低 16M 空间 )
        显示出错信息,调用对象死循环;
    计算要释放的空间所占的页表数;
    for( 每个要释放的页表 ) {
        for( 每个页表项 ) {
            if( 页表项映射有物理页面 )
                释放物理页面 free_page();
            将该页表项设为空闲;
        }
        释放页表使用的物理页;
        将该页表对应的页目录项设为空闲;
    }
    刷新页变换高速缓冲;
    return 0 ;
}
```

具体代码如下:

path: mm/memory.c
```
/*
 * This function frees a continuos block of page tables, as needed
 * by 'exit()'. As does copy_page_tables(), this handles only 4Mb blocks.
 * 下面函数释放页表连续的内存块, 'exit()' 需要该函数。与 copy_page_tables()
 * 类似,该函数仅处理 4Mb 的内存块。
 */
int free_page_tables(unsigned long from,unsigned long size)
{
    unsigned long *pg_table;
    unsigned long * dir, nr;

    if (from & 0x3fffff)  // 要释放空间线性地址应该以 4M 为边界。
        panic("free_page_tables called with wrong alignment");
    if (!from) // 这里只对低 4M 空间的释放进行限制, BUG
        panic("Trying to free up swapper memory space");
    size = (size + 0x3fffff) >> 22; // 计算要释放的页表数
    // 第一个要释放页表对应的页目录项
    dir = (unsigned long *) ((from>>20) & 0xffc); /* _pg_dir = 0 */
    for ( ; size-->0 ; dir++) {
        if (!(1 & *dir)) // 该目录项是否有效
            continue;
        // 计算页表起始地址。
        pg_table = (unsigned long *) (0xfffff000 & *dir);
        for (nr=0 ; nr<1024 ; nr++) {
            if (1 & *pg_table) // 页表项有效,则释放对应页。
                free_page(0xfffff000 & *pg_table);
            *pg_table = 0; // 将对应页表项置为空闲
            pg_table++;
        }
        free_page(0xfffff000 & *dir); // 释放页表使用的物理页;
        *dir = 0; // 将对应页目录表项置为空闲
    }
    invalidate(); // 刷新页变换高速缓冲。
    return 0;
}
```