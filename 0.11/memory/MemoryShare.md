内存共享
================================================================================

有了386对页面共享的支持,共享内存的方法就很容易想到了。将被共享的内存的页目录表和页表复制一份,
并且将所有页表项的访问属性设为只读,并修改页面映射表中的页面引用信息即可。
具体算法如下:

```
算法: copy_page_tables
输入: 共享源页面起始地址 from; 共享目的空间页面起始地址 to; 被共享空间的大小 size
输出: 如果成功, 返回0
{
    if (from 或者 to 不是以 4M 为边界 )
        显示出错信息,使调用对象进入死循环;
    for ( 共享源空间的每一个页目录项 ) {
        if( 对应共享目的空间的页表已经存在 )
            显示出错信息,死循环;
        if( 共享源空间的页目录项不存在 )
            continue ;
        为对应共享目的空间分配空闲页作为页表;
        设置该空闲页属性(可写、用户、有效)
        if( 共享源空间本次复制的是前 4M 的内核空间 )
        本次共享空间只是前 640K ;
        for( 每个要共享空间的页表项 ){
            复制页表项;
            if( 对应页不存在 )
                continue ;
            if( 被共享页在主内存块映射表映射范围内 ){
                 将两个页表项都置为只读;
                 对应页面映射项内容加 1 ;
            }
            else
                只将复制的页表项置为只读;
        }
    }
    刷新 页变换高速缓冲;
}
```

对于页表复制,和页表的释放一样,必须保证被共享的空间和被共享到的空间起始地址是以4M为边界的;
每次共享 4M 的空间,像以前一样,对于内核空间必须作特殊处理。640K到1M的空间本来是高速缓冲块的空间,
但是被显存和 BIOS 占用了,所以这部分空间是不共享的; 因为linus 当初使用的计算机有16M的内存,
高速缓冲空间结束位置是 4M (见启动后内存分配),所以可能是由于这个原因, 1M到3,071K这个空间也是不
共享的,对高速缓冲共享是没有意义的, 这样内核的前4M空间就只共享640K。如果被共享页不在主内存块
映射表范围内,共享的就是这640K的空间,是内核使用的,在共享时,源页表项不被置为只读。

path: mm/memory.c
```
/*
 *  Well, here is one of the most complicated functions in mm. It
 * copies a range of linerar addresses by copying only the pages.
 * Let's hope this is bug-free, 'cause this one I don't want to debug :-)
 *
 * Note! We don't copy just any chunks of memory - addresses have to
 * be divisible by 4Mb (one page-directory entry), as this makes the
 * function easier. It's used only by fork anyway.
 *
 * NOTE 2!! When from==0 we are copying kernel space for the first
 * fork(). Then we DONT want to copy a full page-directory entry, as
 * that would lead to some serious memory waste - we just copy the
 * first 160 pages - 640kB. Even that is more than we need, but it
 * doesn't take any more memory - we don't copy-on-write in the low
 * 1 Mb-range, so the pages can be shared with the kernel. Thus the
 * special case for nr=xxxx.
 */
/*
* 好了,下面是内存管理 mm 中最为复杂的程序之一。它通过只复制内存页面
* 来拷贝一定范围内线性地址中的内容。希望代码中没有错误,因为我不想
* 再调试这块代码了 . 。
*
* 注意!我们并不是仅复制任何内存块 - 内存块的地址需要是 4Mb 的倍数(正好
* 一个页目录项对应的内存大小),因为这样处理可使函数很简单。不管怎样,
* 它仅被 fork() 使用( fork.c 第 56 行)。
*
* 当 from==0 时,是在为第一次 fork() 调用复制内核空间。此时我们
* 注意 2 !
* 不想复制整个页目录项对应的内存,因为这样做会导致内存严重的浪费 - 我们
* 只复制头 160 个页面 - 对应 640kB 。即使是复制这些页面也已经超出我们的需求,
* 但这不会占用更多的内存 - 在低 1Mb 内存范围内我们不执行写时复制操作,所以
* 这些页面可以与内核共享。因此这是 nr=xxxx 的特殊情况( nr 在程序中指页面数)。
*/
int copy_page_tables(unsigned long from,unsigned long to,long size)
{
    unsigned long * from_page_table;
    unsigned long * to_page_table;
    unsigned long this_page;
    unsigned long * from_dir, * to_dir;
    unsigned long nr;

    if ((from&0x3fffff) || (to&0x3fffff)) // 判断是否以4M为边界
        panic("copy_page_tables called with wrong alignment");
    // 计算起始页目录项
    from_dir = (unsigned long *) ((from>>20) & 0xffc); /* _pg_dir = 0 */
    to_dir = (unsigned long *) ((to>>20) & 0xffc);
    // 计算要共享的页表数
    size = ((unsigned) (size+0x3fffff)) >> 22;
    for( ; size-->0 ; from_dir++,to_dir++) {
        if (1 & *to_dir)
            panic("copy_page_tables: already exist");
        if (!(1 & *from_dir))
            continue;
        from_page_table = (unsigned long *) (0xfffff000 & *from_dir);
        if (!(to_page_table = (unsigned long *) get_free_page()))
            return -1;    /* Out of memory, see freeing */
        *to_dir = ((unsigned long) to_page_table) | 7;
        nr = (from==0)?0xA0:1024;
        for ( ; nr-- > 0 ; from_page_table++,to_page_table++) {
            this_page = *from_page_table;
            if (!(1 & this_page))
                continue;
            this_page &= ~2;
            *to_page_table = this_page;
            if (this_page > LOW_MEM) {
                *from_page_table = this_page;
                this_page -= LOW_MEM;
                this_page >>= 12;
                mem_map[this_page]++;
            }
        }
    }
    invalidate();
    return 0;
}
```

共享进程空间
--------------------------------------------------------------------------------

### 早期共享

当内核使用 fork 创建一个进程时,子进程将使用和父进程的进程空间进行完全的拷贝。子进程除了
要与父进程共享内存空间外,如果要在这个内存空间上运行还需要根据父进程的数据段描述符和代码段
描述符设置子进程的自己的数据段描述符和代码段描述符。算法如下:

```
算法: copy_mem
输入: 子进程进程号 nr; 子进程进程控制块 p
输出: 如果成功,返回0
{
    取得父进程的数据段、代码段的段限长和基地址;
    if (数据段和代码段段限长和基地址不合法)
        显示出错信息,死循环;
    设置子进程的数据段、代码段的段限长和基地址;
    共享代码段和数据段内存空间( copy_page_tables)
    if (共享失败) {
        释放子进程共享内存空间时申请的页面;
        return 共享失败;
    }
    return 0 ;
}
```

由于 linux0.11 只支持数据段和代码段基址相同的进程,所以判断数据段和代码段的合法性,首先应
该检测两者是否相同; 又由于代码段在数据段之前, 所以代码段限长一定要大于数据段限长;

path: kernel/fork.c
```
int copy_mem(int nr,struct task_struct * p)
{
    unsigned long old_data_base,new_data_base,data_limit;
    unsigned long old_code_base,new_code_base,code_limit;

    // 取当前进程代码段和数据段段限长
    code_limit=get_limit(0x0f);
    data_limit=get_limit(0x17);
    // 取原代码段和数据段段基址
    old_code_base = get_base(current->ldt[1]);
    old_data_base = get_base(current->ldt[2]);
    if (old_data_base != old_code_base)
        panic("We don't support separate I&D");
    if (data_limit < code_limit)
        panic("Bad data_limit");
    // 子进程基址 = 进程号 *64Mb( 进程线性空间 )
    new_data_base = new_code_base = nr * 0x4000000;
    p->start_code = new_code_base;
    // 设置代码段、数据段基址
    set_base(p->ldt[1],new_code_base);
    set_base(p->ldt[2],new_data_base);
    // 共享代码段和数据段内存空间
    if (copy_page_tables(old_data_base,new_data_base,data_limit)) {
        // 释放共享内存空间时申请的页面
        free_page_tables(new_data_base,data_limit);
        return -ENOMEM;
    }
    return 0;
}
```