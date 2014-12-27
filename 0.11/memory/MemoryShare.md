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
    // 计算要共享的页目录项个数.
    // 一个页目录项能够映射4MB内存，一个页表项能够映射4KB内存.
    size = ((unsigned) (size+0x3fffff)) >> 22;
    for( ; size-->0 ; from_dir++,to_dir++) {
        if (1 & *to_dir) // 被共享到的页表(页目录项)已经存在
            panic("copy_page_tables: already exist");
        if (!(1 & *from_dir)) // 被共享的页表(页目录项)不存在
            continue;
        // 取源页表地址
        from_page_table = (unsigned long *) (0xfffff000 & *from_dir);
        if (!(to_page_table = (unsigned long *) get_free_page()))
            return -1;    /* Out of memory, see freeing */
        // 设置该页属性(可写、用户、有效)
        *to_dir = ((unsigned long) to_page_table) | 7;
        // 如果是前4M空间,只共享 640K(160 页 )
        nr = (from==0)?0xA0:1024;
        for ( ; nr-- > 0 ; from_page_table++,to_page_table++) {
            this_page = *from_page_table;
            if (!(1 & this_page)) // 如果当前源页表项没有使用,则不用复制
                continue;
            this_page &= ~2;      // 将目的页表项设为只读
            *to_page_table = this_page;
            if (this_page > LOW_MEM) { // 如果被共享页在主内存块映射表映射范围内
                *from_page_table = this_page; // 源页表项设为只读
                this_page -= LOW_MEM;
                this_page >>= 12;
                mem_map[this_page]++; // 共享数加一
            }
        }
    }
    invalidate(); // 刷新页变换高速缓冲。
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

### 后期共享

当子进程被fork出来后,就会和父进程分道扬镳,独立地被内核调度执行,在这个过程中父进程和
子进程的执行是独立的,互不影响。如果父进程因为缺页新申请了物理页面,子进程是不知道的。
示例如下:

https://github.com/leeminghao/doc-linux/blob/master/0.11/memory/fork_share.png

当子进程产生缺页时,子进程还是要尽量地“偷懒”,除了在被fork出来时可以与父进程共享内存外,
父进程新申请的物理页也是可以被共享的。只要申请页被读入之后还没有被改变过就可以共享。
其实上面说的例子中,如果是子进程申请了新的物理页,父进程同样可以拿来用,如果子进程还fork了孙进程,
孙进程申请的页面子进程和父进程都可以使用。因为分道扬镳之后各个进程是平等的,只要大家都使用同一个
可执行程序,谁先申请新物理页都是一样的。
试图共享内存的算法如下:

```
算法:share_page
输入:共享地址 address
输出:如果成功,返回 1
{
    if ( 要求共享的进程 A 没有对应的可执行文件 )
        return 0 ;
    if (A 对应的可执行文件没有被多个进程使用 )
        return 0 ;
    for( 每个存在的进程 P)
    {
        if (P 就是要求共享的进程本身 )
            continue ;
        if (P 对应可执行文件与要求共享的进程的不同 )
            continue ;
        if (P 进程共享地址对应的物理页不存在或不干净 )
            continue ;
        if ( 对应物理页不属于主内存块 )
            continue ;
        if ( 进程 A 共享地址对应的页表不存在 ){
            为页表分配新的物理页;
            设置页目录项;
        }
        if ( 进程 A 对应的页表项已经存在 )
            显示错误信息,死循环;
        将进程 P 对应的页表项属性设为只读;
        设置进程 A 对应地址的页表项;
        物理页引用数加 1 ;
        刷新页变换高速缓冲。
        return 1 ;
    }
    return 0 ;
}
```

对于每一个进程都应该对应一个可执行文件,当进程处于某些特定时刻(如:正在作进行初始化设置)时
没有对应的可执行文件,当然也就不应该作共享处理。如果对应的可执行文件应用数不大于1,则表示
没有进程与要求共享的进程共享对应的可执行文件,也不会有共享对象。

接下来的任务就是找到一个符合要求的共享物理页,条件有:
* 进程对应可执行文件相同;
* 对应物理页在被读入之后没有被修改过。

如果要求共享进程对应地址的页表项存在,但是原来是因为缺页才进入共享操作的,肯定系统出现了严重错误。
最后进程P对应的页表项属性修改为只读,设置进程A对应地址的页表项,使它指向共享物理页,属性为只读,
物理页对应主内存块映射数组项加1;因为页表发生了变化,所以要刷新页变换高速缓冲。
下面是具体代码:

path: mm/memory.c
```
/*
 * share_page() tries to find a process that could share a page with
 * the current one. Address is the address of the wanted page relative
 * to the current data space.
 *
 * We first check if it is at all feasible by checking executable->i_count.
 * It should be >1 if there are other tasks sharing this inode.
 */
/*
* share_page() 试图找到一个进程,它可以与当前进程共享页面。参数 address 是
* 当前数据空间中期望共享的某页面地址。
*
* 首先我们通过检测 executable->i_count 来查证是否可行。如果有其它任务已共享
* 该 inode ,则它应该大于 1 。
*/
static int share_page(unsigned long address)
{
    struct task_struct ** p;

    if (!current->executable) // 没有对应的可执行文件
        return 0;
    if (current->executable->i_count < 2) // 不是多进程共享可执行文件
        return 0;
    for (p = &LAST_TASK ; p > &FIRST_TASK ; --p) { // 搜索每个进程控制块指针
        if (!*p) // 没有对应进程
            continue;
        if (current == *p) // 就是指向当前任务
            continue;
        if ((*p)->executable != current->executable) // 不是与当前任务使用同一个可执行文件
            continue;
        if (try_to_share(address,*p)) // 试图共享页面
            return 1;
    }
    return 0;
}
```

下面是try_to_share(address,*p)的代码:

path: mm/memory.c
```
/*
 * try_to_share() checks the page at address "address" in the task "p",
 * to see if it exists, and if it is clean. If so, share it with the current
 * task.
 *
 * NOTE! This assumes we have checked that p != current, and that they
 * share the same executable.
 */
/*
* try_to_share() 在任务 "p" 中检查位于地址 "address" 处的页面,看页面是否存在,是否干净。
* 如果是干净的话,就与当前任务共享。
* current 共享 p 已有的物理页面
* 注意!这里我们已假定 p != 当前任务,并且它们共享同一个执行程序。
*/
// address 是线性地址,是一个相对于 code_start 的偏移量,在执行完这个函数后, p 和 current 偏移是
// address 的位置共享物理内存 !!!
static int try_to_share(unsigned long address, struct task_struct * p)
{
    unsigned long from;
    unsigned long to;
    unsigned long from_page;
    unsigned long to_page;
    unsigned long phys_addr;

    // 计算相对于起始代码偏移的页目录项数
    from_page = to_page = ((address>>20) & 0xffc);
    // 加上自身的start_code的页目录项,得到 address 分别在 p 和 current 中对应的页目录项
    from_page += ((p->start_code>>20) & 0xffc);
    to_page += ((current->start_code>>20) & 0xffc);
    /* is there a page-directory at from? */
    from = *(unsigned long *) from_page; // 取页目录项的内容
    if (!(from & 1))  // 对应页表是否存在
        return 0;
    // 取对应的页表项
    from &= 0xfffff000;
    from_page = from + ((address>>10) & 0xffc);
    phys_addr = *(unsigned long *) from_page;
    /* is the page clean and present? */
    /* 页面干净并且存在吗? */
    if ((phys_addr & 0x41) != 0x01)
        return 0;
    phys_addr &= 0xfffff000;
    // 是否在主内存块中
    if (phys_addr >= HIGH_MEMORY || phys_addr < LOW_MEM)
        return 0;
    // 取页目录项内容to. 如果该目录项无效(P=0), 则取空闲页面,并更新to_page所指的目录项。
    to = *(unsigned long *) to_page; // 取目标地址的页目录项
    if (!(to & 1)) // 如果对应页表不存在
        if (to = get_free_page()) // 分配新的物理页
            *(unsigned long *) to_page = to | 7;
        else
            oom();
    to &= 0xfffff000; // 取目标地址的页表项
    to_page = to + ((address>>10) & 0xffc);
    if (1 & *(unsigned long *) to_page) // 如果对应页表项已经存在,则出错,死循环
        panic("try_to_share: to_page already exists");
    /* share them: write-protect */
    /* 对它们进行共享处理:写保护 . */
    *(unsigned long *) from_page &= ~2;
    // 共享物理内存
    *(unsigned long *) to_page = *(unsigned long *) from_page;
    // 刷新页变换高速缓冲。
    invalidate();
    // 共享物理页引用数加1
    phys_addr -= LOW_MEM;
    phys_addr >>= 12;
    mem_map[phys_addr]++;
    return 1;
}
```