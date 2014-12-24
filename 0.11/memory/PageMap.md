页面映射
================================================================================

如果进程请求一页空闲内存,或者页失效错误时,会出现页面请求。在这个时候请求是以线性地址的形式
提出来的。因为对于一个进程来说,它感知不到其他进程的存在,对它自己,觉得独占了所有资源。操作系统
在控制物理内存的同时又要控制进程的虚拟空间,这就需要在内存线性地址与物理地址之间作转换工作。

比如: 进程在线性地址0x0104 F380处产生了缺页中断,内核将进行一系列的处理,最后分配一个物理页面,
但是并不能这样返回进程执行,因为进程仍然需要从线性地址0x0104 F380处读取数据,就像没有发生过
缺页中断一样。操作系统就必须要做这个工作,将物理页面映射到线性地址上。

要将物理页面映射到线性地址上,就应该修改页目录表和页表的相关内容,这样进程才能通过线性地址
找到相应的物理页面。回顾一下386页面映射机制, cpu通过线性地址的高10位寻找到相应的页表,
再通过中间10位寻找到物理页面,最后通过低12位在物理页面中寻找到相应的内存单元。所以要让进程
找到物理页面,就必须根据线性地址设置页目录项和页表项。 linux0.11 使用put_page来作这个处理,
其算法如下:

```
算法: put_page
输入: 物理页面地址page, 线性地址 address
输出: 如果成功, 返回page; 如果失败,返回 0
{
    if ( 物理页面地址低于 LOW_MEM 或者不小于 HIGH_MEMORY)
        显示出错信息,返回 0 ;
    if ( 物理页面地址对应的内存映射数组映射项的值!= 1)
        显示出错信息,返回 0 ;
    根据线性地址高 10 位找到对应的页目录表项;
    if ( 页目录表项对应的页表在内存中 )
        根据页目录表项的到页表的物理地址;
    else {
        分配新的物理页面作为新的页表;
        初始化页目录表项,使它指向新的页表;
        根据页目录表项的到页表的物理地址;
    }
    根据线性地址中间 10 位找到对应的页表项;
    if( 对应的页表项已经被使用 )
        显示出错信息,返回 0 ;
    设置对应的页表项,使它指向物理页面;
    return 物理页面地址;
}
```

put_page操纵的是由get_free_page()分配得到的物理页面,所以物理页面地址应该是在主内存块中,
如果不在,就应该终止映射,返回失败。然后调用put_page函数的对象根据自身的特性作相关处理。
同样是因为put_page操纵的是新分配的物理页面,所以物理页面地址对应的内存映射数组映射项的值应该是1 。
如果不是1,也应该终止映射,返回失败。如果前面的检查通过了,就应该进行映射了。首先在页目录表中找到
对应页目录项,如果页目录项有效,即对应页表在内存中,就直接寻找页表项。否则就必须先分配一个物理页
作为页表。从理论上讲,在设置对应的页表项之前应该检查一下该页表项是否已经被使用。从而确保映射的
一致性,因为如果页表项已经被使用,对其的第二次赋值会使原来的映射关系失效。但是由于linux在总体设计
上的特点,而且新分配的页表被全部清零,所以不会出现这个问题。随着对代码分析的深入,将体会到这一点。
下面就是 put_page 的代码:

path: mm/memory.c
```
/*
 * This function puts a page in memory at the wanted address.
 * It returns the physical address of the page gotten, 0 if
 * out of memory (either when trying to access page-table or
 * page.)
 */
/*
 * 下面函数将一内存页面放置在指定地址处。它返回页面的物理地址,如果
 * 内存不够 ( 在访问页表或页面时 ) ,则返回 0 。
 */
unsigned long put_page(unsigned long page,unsigned long address)
{
    unsigned long tmp, *page_table;

    /* NOTE !!! This uses the fact that _pg_dir=0 */
    // 判断是否在主内存块中
    if (page < LOW_MEM || page >= HIGH_MEMORY)
        printk("Trying to put page %p at %p\n",page,address);
    // 判断对应映射项的值是否为 1
    if (mem_map[(page-LOW_MEM)>>12] != 1)
        printk("mem_map disagrees with %p at %p\n",page,address);
    // 根据线性地址找到对应的页目录表项;
    page_table = (unsigned long *) ((address>>20) & 0xffc);
    if ((*page_table)&1) // 根据线性地址找到对应的页目录表项;
        page_table = (unsigned long *) (0xfffff000 & *page_table); // 取对应页表物理地址
    else {
        if (!(tmp=get_free_page())) // 申请新物理页作为页表
            return 0;
        *page_table = tmp|7;  // 设置页目录项
        page_table = (unsigned long *) tmp;
    }
    page_table[(address>>12) & 0x3ff] = page | 7; // 页面设置为用户权限、可写、有效
    /* no need for invalidate */
    return page;  // 返回物理页面地址。
}
```

在这个代码中,如果第一个判断为真时,只是打印出错信息,并没有返回。
这将导致第二个判断时mem_map 数组溢出,由于 c 语言并不对数组溢出进行出错处理。
这里将可能出现错误。而且第二个判断也没有在打印错误信息之后返回,这将导致错误蔓延。
不过幸运的是, linux0.11 中不会以这种参数调用put_page ,所以这里只是作一个算法上的说明。

看了put_page之后,那么 get_empty_page 的代码就很好理解了。 get_empty_page 以线性地址为参数,
申请新的物理页面并完成映射过程。

path: mm/memory.c
```
void get_empty_page(unsigned long address)
{
    unsigned long tmp;

    if (!(tmp=get_free_page()) || !put_page(tmp,address)) {
        free_page(tmp);        /* 0 is ok - ignored */
        oom();
    }
}
```

其中 oom() 是用于内存使用完后的处理,显示完信息之后使调用进程退出。

path: mm/memory.c
```
static inline volatile void oom(void)
{
    printk("out of memory\n\r");
    do_exit(SIGSEGV); // 进程退出,出错码: SIGSEGV (资源暂时不可用)
}
```