页面异常
================================================================================

当cpu在进行内存访问时,可能因为缺页或者试图对一个只读页面进行写操作而产生页面异常,
cpu进入相应的页面异常中断处理程序。
由于异常可能由缺页或者写只读页面产生,两种情况的处理也是不同的,所以中断处理程序首先应该
区分产生本次异常的原因,进入不同的处理过程。算法如下:

```
算法: page_fault
输入: 出错码 error_code; 出错线性地址 address
输出: 无
{
    保存现场;
    根据出错码判断出错原因;
    if (缺页)
        作缺页处理 do_no_page(error_code, address);
    else
        作写保护出错处理 do_wp_page(error_code, address) ;
    恢复现场;
    return ;
}
```

在x86处理器中error_code由cpu产生并在保存了中断点的相关内容之后将其压入堆栈,出错码的
最低位指示出错原因(1: 写出错; 0: 缺页)。 address 则是由一个专门的32位寄存器cr2保存。
具体代码如下:

mm/page.s
```
.globl page_fault

page_fault:
    xchgl %eax,(%esp)  // 交换eax与esp所指向空间的内容 => 1.保存eax; 2.取出error_code
    // 保存现场
    pushl %ecx
    pushl %edx
    push %ds
    push %es
    push %fs
    // 使ds,es,fs指向系统数据段
    movl $0x10,%edx
    mov %dx,%ds
    mov %dx,%es
    mov %dx,%fs

    // 取出错线性地址
    // CR2用于出现页异常时报告出错信息。在报告页异常时，处理器会把引起异常的线性地址存放在CR2中。
    // 因此操作系统中的页异常处理程序可以通过检查CR2的内容来确定线性地址空间中哪一个页面引发了异常。
    movl %cr2,%edx
    // 将出错地址和出错码压入堆栈,作为处理函数的输入参数
    pushl %edx
    pushl %eax
    // 判断出错码最低位,决定调用函数
    testl $1,%eax
    jne 1f          // 为1 ,调用写保护出错处理函数
    call do_no_page // 为0, 调用缺页处理函数
    jmp 2f
1:  call do_wp_page
2:  addl $8,%esp  // 丢弃输入参数 error_code 和 address
    // 恢复现场
    pop %fs
    pop %es
    pop %ds
    popl %edx
    popl %ecx
    popl %eax
    iret
```

在这段代码中,我们可以充分领略到系统程序员对汇编编程知识的要求。 在"xchgl %eax,(%esp)",
必须非常清楚压栈过程。当cpu执行压栈操作时,是先执行esp=esp-4; 再将数据送入esp所指向的单元。
cpu 在进入异常中断处理程序之前,将error_code压入了堆栈,当前 esp 指向的单元存放的就是error_code,
所以上述命令,取出了error_code又将eax保存了,如果要用其他方法实现应该是:

```
pushl eax
movl (esp+4),eax
```

相比之下, 改行的程序将eax放在了error_code 原来存放的空间,节约了堆栈空间,同时也节约指令数,
可谓是一箭四雕。"2: addl $8,%esp" 对于输入参数的丢弃,不是用两次popl操作,而是直接将esp加8 ,
又省了一条指令。可见高水平的系统程序员为了提高效率是多么的抠门。这样的程序虽然效率高,
但是对于理解会有一定的障碍,不过换个方向来想,毕竟这种底层代码不是人人都会去仔细读的。

当处理器在转换线性地址到物理地址的过程中检测到以下两种条件时,就会发生页异常中断,中断14。
* 当 CPU 发现对应页目录项或页表项的存在位( Present )标志为 0 。
* 当前进程没有访问指定页面的权限。

对于页异常处理中断, CPU提供了两项信息用来诊断页异常和从中恢复运行。

(1). 放在堆栈上的出错码。该出错码指出了异常是由于页不存在引起的还是违反了访问权限引起的;
在发生异常时 CPU 的当前特权层;以及是读操作还是写操作。出错码的格式是一个32位的长字。
但只用了最后的 3 个比特位。分别说明导致异常发生时的原因:

* 位 2(U/S) - 0 表示在超级用户模式下执行, 1 表示在用户模式下执行;
* 位 1(W/R) - 0 表示读操作, 1 表示写操作;
* 位 0(P) - 0 表示页不存在, 1 表示页级保护。

(2). CR2(控制寄存器2)。CPU 将造成异常的用于访问的线性地址存放在CR2中。异常处理程序可以
使用这个地址来定位相应的页目录和页表项。如果在页异常处理程序执行期间允许发生另一个
页异常,那么处理程序应该将 CR2 压入堆栈中。

缺页中断
--------------------------------------------------------------------------------

在对进行进程初始设置时,内核并不是将进程可能用到的所有内存一次性分配给进程,而是在进程
要访问该地址时分配,将内存分配给一定会被访问的空间,这样就提高内存资源的使用率。这样作就不可避免
地会出现缺页中断。当cpu访问一个内存单元时,如果该单元所在的页面不在内存中, cpu将产生页面异常,
进一步进入缺页处理程序,算法如下:

```
算法: do_no_page
输入: 出错码 error_code; 出错线性地址 address
输出: 无
{
    if ( 出错进程没有对应的可执行文件
       || 出错地址不在代码和数据段 )
    {
        分配物理页面并映射到出错线性地址 ( 使用 get_empty_page()) ;
        return;
    }
    试图共享页面(使用 share_page()) ;
    if (共享页面成功)
        return;
    分配新的物理页面 (get_free_page() ) ;
    从可执行文件中将页面对应的内容读入内存;
    将页面中不属于代码段和数据段的内容清零;
    将新的物理页面映射到出错线性地址(put_page()) ;
    if ( 映射失败 )
    {
        释放新申请的物理页面;
        显示出错,死循环;
    }
    return;
}
```

进程在不同的时刻会处于不同的状态,如果进程此时还处于初始化时期,就可能还没有设置对应的
可执行文件,这个时候的内存使用请求可能是与其设置有关的,所以需要为其分配内存。
对于进程的可执行文件,在这里只是说一下它的基本结构:

https://github.com/leeminghao/doc-linux/blob/master/0.11/memory/exec.png

进程对应的可执行文件包含有进程的代码段和数据段的内容,进程的线性地址与可执行文件内容的
逻辑地址是对应的,如果出错是在代码段和数据段,应该先试图共享内存,共享不成功就应该分配
内存并从可执行文件中读取相应内容; 如果不是在这两个段,就直接分配内存。

可执行文件存储在磁盘上,磁盘的存储基本单位是1KB,所以要读取一个页面的内容就要读取四个磁盘块。
从可执行文件中读取内容由bmap和bread_page两个函数来做,首先将出错线性地址所在页面换算成可执行文件
对应的逻辑盘块号, bmap用于将逻辑盘块号换算成物理盘块号, 最后由bread_page将四个物理盘块读入内存。

在读入过程中,可能出现这种情况,由于线性地址太大,对应页面换算得到的逻辑盘块号过大,对应可执行文件
却没有这么大(如下所示,这时后两块逻辑盘块将不会被读入),多余的逻辑盘将不会被读入。

https://github.com/leeminghao/doc-linux/blob/master/0.11/memory/line_larger.png

另外,读入一页内存之后,该页的结束地址可能会超过end_data。由于上述两种情况,应该对多出来的内存清零。
最后就是映射页面, put_page只有在申请新的页表空间失败的情况会返回0,这时就应该将已经申请了的物理
页面释放,然后调用oom()报错。
具体代码如下:

path: mm/memory.c
```
// 页异常中断处理调用的函数。处理缺页异常情况。在 page.s 程序中被调用。
// 参数 error_code 是由 CPU 自动产生,address 是页面线性地址。
void do_no_page(unsigned long error_code,unsigned long address)
{
    int nr[4];
    unsigned long tmp;
    unsigned long page;
    int block,i;

    address &= 0xfffff000; // 页面地址。
    // 换算出相对于进程代码起始地址的相对地址
    tmp = address - current->start_code;
    // 若当前进程的executable空,或者指定地址超出代码+数据长度,则申请一页物理内存,并映射
    // 到指定的线性地址处。executable 是进程可执行文件的i节点结构。该值为0,表明进程刚开始设置,
    // 需要内存;而指定的线性地址超出代码加数据长度,表明进程在申请新的内存空间,也需要给予。
    // 因此就直接调用 get_empty_page()函数,申请一页物理内存并映射到指定线性地址处即可。
    // start_code是进程代码段地址(线性),end_data是代码加数据长度。对于Linux内核,它的代码段和
    // 数据段是起始基址是相同的。
    if (!current->executable || tmp >= current->end_data) {
        // 如果不是加载程序而是其它原因导致缺页，比如说压栈没地方了，那么直接申请页面就可以了.
        get_empty_page(address);
        return;
    }
    // 如果尝试共享页面成功,则退出。这样做的好处是尝试能不能和其它的进程共享程序，这样
    // 可以避免多次加载同一个可执行文件.
    if (share_page(tmp))
        return;
    // 取空闲页面,如果内存不够了,则显示内存不够,终止进程。
    if (!(page = get_free_page()))
        oom();
    /* remember that 1 block is used for header */
    /* 记住,(程序)头要使用 1 个数据块 */
    // 首先计算缺页所在的数据块项。BLOCK_SIZE = 1024 字节,因此一页内存需要4个数据块。
    block = 1 + tmp/BLOCK_SIZE;   // 换算文件逻辑块起始块号
    for (i=0 ; i<4 ; block++,i++) // 将数据块号换算成物理块号
        nr[i] = bmap(current->executable,block);
    // 读入一个页的四个磁盘块
    bread_page(page,current->executable->i_dev,nr);
    // 对超出数据段的内容清零
    i = tmp + 4096 - current->end_data;
    tmp = page + 4096;
    while (i-- > 0) {
        tmp--;
        *(char *)tmp = 0;
    }
    // 页面映射,将page指向的物理页面与线性地址address映射起来.
    if (put_page(page,address))
        return;
    free_page(page);
    oom();
}
```

页面写保护错误:
--------------------------------------------------------------------------------

由于进程的fork和share_page操作,会出现多个进程共享一个物理页面的情况,这个物理页面被置为只读方式,
如果其中一个进程想对这个页面进行写操作, cpu就会产生页面异常中断,并进一步进入写保护出错处理。
在写保护出错处理中,将会根据情况复制被共享的页或者取消对页面的写保护。

```
算法: do_wp_page
输入: 出错码 error_code; 出错线性地址 address
输出: 无
{
    if ( 出错地址属于进程的代码段 )
        将进程终止;
    if ( 出错页面属于主内存块且共享计数为 1)
    {
        取消写保护;
        刷新页变换高速缓冲;
        return ;
    }
    申请一个新的物理页;
    if ( 出错页面属于主内存块 )
        共享计数减 1 ;
    使出错时的页表项指向新的物理页;
    刷新页变换高速缓冲;
    复制共享页的内容到新的物理页;
    return ;
}
```

对于一般情况,对代码段的写操作是违法的,肯定是进程本身代码有问题,为了不进一步引起错误,系统将会把
该进程终止。但是estdio库(后来不再为 linux 所使用)支持对代码段的写操作, linus当时由于没有得到
这个库的具体资料,所以也只是预留了操作。一个页面被多个进程共享,每当一个进程产生一次写保护错误,
内核将给进程分配一个新的物理页面,将共享页面的内容复制过来,新的页面将设置为可读写,而共享页面
仍然是只读的,只是共享计数减小了。当其他共享进程都产生了一次写保护错误后,共享页面的共享计数减
成了1 ,其实就是被一个进程独占了,但此时该共享页面仍然是只读的,如果独占它的进程对它进行写操作
仍然会产生写保护出错。
为什么不在共享计数减成了1之后就将共享页面置为可写呢?原因很简单,因为系统并不知道最后是哪个
页表项指向这个共享页,如果要把它查找出来会有很大的系统开销,这是中断处理程序应当尽量避免的,
所以采用了以逸待劳的办法。如果当初共享的页面不属于主内存块,在共享时就没有作共享计数的处理,
就不存在共享计数的问题,直接复制就可以了。

path: mm/memory.c
```
#define copy_page(from,to)                                              \
    __asm__("cld ; rep ; movsl"::"S" (from),"D" (to),"c" (1024))
...
void un_wp_page(unsigned long * table_entry)
{
    unsigned long old_page,new_page;
    // 取出错页面对应的物理地址
    old_page = 0xfffff000 & *table_entry;
    // 如果属于主内存块且共享计数为 1
    if (old_page >= LOW_MEM && mem_map[MAP_NR(old_page)]==1) {
        *table_entry |= 2; // 共享页置为可写
        invalidate();
        return;
    }
    // 申请一个空闲物理页面
    if (!(new_page=get_free_page()))
        oom();
    // 如果在主内存块中,将共享数减 1
    if (old_page >= LOW_MEM)
        mem_map[MAP_NR(old_page)]--;
    // 改变 table_entry 的指向从而实现共享的分离
    *table_entry = new_page | 7;
    invalidate();
    // 复制 1 页内存(4K 字节)。
    copy_page(old_page,new_page); // 拷贝共享页
}

/*
 * This routine handles present pages, when users try to write
 * to a shared page. It is done by copying the page to a new address
 * and decrementing the shared-page counter for the old page.
 *
 * If it's in code space we exit with a segment error.
 */
/*
* 当用户试图往一个共享页面上写时,该函数处理已存在的内存页面,(写时复制)
* 它是通过将页面复制到一个新地址上并递减原页面的共享页面计数值实现的。
*
* 如果它在代码空间,我们就以段错误信息退出。
*/
void do_wp_page(unsigned long error_code,unsigned long address)
{
#if 0
    /* we cannot do this yet: the estdio library writes to code space */
    /* stupid, stupid. I really want the libc.a from GNU */
    /* 我们现在还不能这样做:因为 estdio 库会在代码空间执行写操作 */
    /* 真是太愚蠢了。我真想从 GNU 得到 libc.a 库。 */
    if (CODE_SPACE(address)) // 出错地址属于进程的代码段,则终止当前程序
        do_exit(SIGSEGV);
#endif
    // 处理取消页面保护。
    // 输入参数指向出错页的页表项的指针
    // 计算方法: 页表偏移量 + 页表起始地址
    un_wp_page((unsigned long *)
               (((address>>10) & 0xffc) + (0xfffff000 &
                                          *((unsigned long *) ((address>>20) &0xffc)))));

}
```

补充：
--------------------------------------------------------------------------------

正规文件中的数据是放在磁盘块的数据区中的,而一个文件名则通过对应的i节点与这些数据磁盘块相联系,
这些盘块的号码就存放在i节点的逻辑块数组i_zone中。 _bmap() 函数主要是对i节点的区块数组i_zone[]
进行处理, 并根据 i_zone[] 中所设置的盘块号来设置逻辑块位图的占用情况。正如前面所述,i_zone[0]至
i_zone[6] 用于存放对应文件的直接逻辑块号; i_zone[7]用于存放一次间接逻辑块号; 而i_zone[8]用于
存放二次间接逻辑块号。当文件较小时(小于7K),就可以将文件所使用的盘块号直接存放在i节点的7个
直接块项中;当文件稍大一些时(不超过 7K+512K ),需要用到一次间接块项 i_zone[7] ;当文件更大时,
就需要用到二次间接块项i_zone[8] 了。因此,比较文件小时, linux 寻址盘块的速度就比较快一些。

bmap函数用于将一个文件的逻辑块号换算成对应磁盘上的物理块号，具体实现如下所示:

path: fs/inode.c
```
/* _bmap() 函数用于文件数据块映射到盘块的处理操作。
 * 所带的参数: inode - 是文件的 i 节点指针; block - 是文件中的数据块号;
 *             create-是创建标志,表示在对应文件数据块不存在的情况下,是否需要在盘上建立对应的盘块。
 * 该函数的返回值是文件数据块对应在设备上的物理块号(盘块号)。
 * 当 create=0 时,该函数就是bmap() 函数。当 create=1 时,它就是 create_block() 函数。
 */
static int _bmap(struct m_inode * inode,int block,int create)
{
    struct buffer_head * bh;
    int i;

    if (block<0) // 如果块号小于 0,则死机。
        panic("_bmap: block<0");
    // 如果块号大于直接块数 + 间接块数 + 二次间接块数,超出文件系统表示范围,则死机。
    if (block >= 7+512+512*512)
        panic("_bmap: block>big");
    // 如果该块号小于 7,则使用直接块表示。
    if (block<7) {
        // 如果创建标志置位,并且i节点中对应该块的逻辑块(区段)字段为0, 则向相应设备申请一磁盘
        // 块(逻辑块,区块),并将盘上逻辑块号(盘块号)填入逻辑块字段中。然后设置i节点修改时间,
        // 置i节点已修改标志。最后返回逻辑块号。
        if (create && !inode->i_zone[block])
            if (inode->i_zone[block]=new_block(inode->i_dev)) {
                inode->i_ctime=CURRENT_TIME;
                inode->i_dirt=1;
            }
        return inode->i_zone[block];
    }

    // 如果该块号>=7,并且小于 7+512,则说明是一次间接块。下面对一次间接块进行处理。
    block -= 7;
    if (block<512) {
        // 如果是创建,并且该i节点中对应间接块字段为0,表明文件是首次使用间接块,则需申请
        // 一磁盘块用于存放间接块信息,并将此实际磁盘块号填入间接块字段中。然后设置i节点
        // 已修改标志和修改时间。
        if (create && !inode->i_zone[7])
            if (inode->i_zone[7]=new_block(inode->i_dev)) {
                inode->i_dirt=1;
                inode->i_ctime=CURRENT_TIME;
            }
        // 若此时i节点间接块字段中为0, 表明申请磁盘块失败,返回0退出
        if (!inode->i_zone[7])
            return 0;
        // 读取设备上的一次间接块。
        if (!(bh = bread(inode->i_dev,inode->i_zone[7])))
            return 0;
        // 取该间接块上第 block 项中的逻辑块号(盘块号)。
        i = ((unsigned short *) (bh->b_data))[block];
        // 如果是创建并且间接块的第 block 项中的逻辑块号为 0 的话,则申请一磁盘块(逻辑块),并让
        // 间接块中的第 block 项等于该新逻辑块块号。然后置位间接块的已修改标志。
        if (create && !i)
            if (i=new_block(inode->i_dev)) {
                ((unsigned short *) (bh->b_data))[block]=i;
                bh->b_dirt=1;
            }
        // 最后释放该间接块,返回磁盘上新申请的对应 block 的逻辑块的块号
        brelse(bh);
        return i;
    }
    // 程序运行到此,表明数据块是二次间接块,处理过程与一次间接块类似。下面是对二次间接块的处理。
    // 将 block 再减去间接块所容纳的块数(512)。
    block -= 512;
    // 如果是新创建并且i节点的二次间接块字段为0,则需申请一磁盘块用于存放二次间接块的一级块
    // 信息,并将此实际磁盘块号填入二次间接块字段中。之后,置i节点已修改编制和修改时间。
    if (create && !inode->i_zone[8])
        if (inode->i_zone[8]=new_block(inode->i_dev)) {
            inode->i_dirt=1;
            inode->i_ctime=CURRENT_TIME;
        }
    // 若此时 i 节点二次间接块字段为 0,表明申请磁盘块失败,返回 0 退出。
    if (!inode->i_zone[8])
        return 0;
    // 读取该二次间接块的一级块。
    if (!(bh=bread(inode->i_dev,inode->i_zone[8])))
        return 0;
    // 取该二次间接块的一级块上第(block/512)项中的逻辑块号。
    i = ((unsigned short *)bh->b_data)[block>>9];
    // 如果是创建并且二次间接块的一级块上第(block/512)项中的逻辑块号为 0 的话,则需申请一磁盘
    // 块(逻辑块)作为二次间接块的二级块,并让二次间接块的一级块中第(block/512)项等于该二级
    // 块的块号。然后置位二次间接块的一级块已修改标志。并释放二次间接块的一级块。
    if (create && !i)
        if (i=new_block(inode->i_dev)) {
            ((unsigned short *) (bh->b_data))[block>>9]=i;
            bh->b_dirt=1;
        }
    brelse(bh);
    // 如果二次间接块的二级块块号为 0,表示申请磁盘块失败,返回 0 退出。
    if (!i)
        return 0;
    // 读取二次间接块的二级块
    if (!(bh=bread(inode->i_dev,i)))
        return 0;
    // 取该二级块上第 block 项中的逻辑块号。(与上511是为了限定 block 值不超过 511)
    i = ((unsigned short *)bh->b_data)[block&511];
    if (create && !i)
        if (i=new_block(inode->i_dev)) {
            ((unsigned short *) (bh->b_data))[block&511]=i;
            bh->b_dirt=1;
        }
    // 最后释放该二次间接块的二级块,返回磁盘上新申请的对应 block 的逻辑块的块号。
    brelse(bh);
    return i;
}

int bmap(struct m_inode * inode,int block)
{
    return _bmap(inode,block,0);
}
```