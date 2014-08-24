Linux 0.11 更换根设备
================================================================================

准备工作
--------------------------------------------------------------------------------

在跳转到main函数并初始化以后：

https://github.com/leeminghao/doc-linux/blob/master/0.11/init/StartMainInit.md

设置了虚拟盘空间并初始化, 那时的虚拟盘只是一块“白盘”，尚未经过类似"格式化"的处理，
还不能当做一个块设备使用。格式化所用的信息就在boot操作系统的软盘上。

在开机启动以后：

https://github.com/leeminghao/doc-linux/blob/master/0.11/bios/Bios2Main.md

我们知道，第一个扇区是bootsect，后面4个扇区是setup，接下来的240个扇区是包含head的system模块，
一共有245个扇区。“格式化”虚拟盘的信息从256扇区开始。

之后，创建完进程1并由进程1完成安装硬盘文件系统的准备工作以后：

https://github.com/leeminghao/doc-linux/blob/master/0.11/filesystem/InstallDiskFs.md

接下来进程1就要格式化虚拟盘并更换根设备

进程1格式化虚拟盘并更换根设备为虚拟盘
--------------------------------------------------------------------------------

进程1调用rd_load()函数，用软盘上256以后扇区中的信息“格式化”虚拟盘，使之成为一个块设备。
执行代码如下所示:

path: kernel/blk_drv/hd.c
```
/* This may be used only once, enforced by 'static int callable' */
int sys_setup(void * BIOS)
{
    ......
    struct partition *p;
    struct buffer_head * bh;
    ......
    for (drive=0 ; drive<NR_HD ; drive++) {
        /* 第一个物理盘号是0x300, 第2个是0x305, 读每个物理硬盘的0号块，即引导块, 有分区信息 */
        if (!(bh = bread(0x300 + drive*5,0))) {
            printk("Unable to read partition table of drive %d\n\r",
                drive);
            panic("");
        }
        if (bh->b_data[510] != 0x55 || (unsigned char)
            bh->b_data[511] != 0xAA) {
            printk("Bad partition table on drive %d\n\r",drive);
            panic("");
        }
        p = 0x1BE + (void *)bh->b_data;
        for (i=1;i<5;i++,p++) {
            hd[i+5*drive].start_sect = p->start_sect;
            hd[i+5*drive].nr_sects = p->nr_sects;
        }
        brelse(bh);
    }
    if (NR_HD)
        printk("Partition table%s ok.\n\r",(NR_HD>1)?"s":"");

    rd_load();
    mount_root();
    return (0);
}
```

接着进入rd_load函数执行，执行代码如下所示:

path: kernel/blk_drv/ramdisk.c
```
/*
 * If the root device is the ram disk, try to load it.
 * In order to do this, the root device is originally set to the
 * floppy, and we later change it to be ram disk.
 */
void rd_load(void)
{
    struct buffer_head *bh;
    struct super_block    s;
    int        block = 256;    /* Start at block 256 */
    int        i = 1;
    int        nblocks;
    char        *cp;        /* Move pointer */

    if (!rd_length)
        return;
    printk("Ram disk: %d bytes, starting at 0x%x\n", rd_length,
        (int) rd_start);
    if (MAJOR(ROOT_DEV) != 2) // 如果根设备不是软盘
        return;
    /* 调用breada()函数从软盘预读一些数据块，也就是“格式化”虚拟盘需要的引导块,超级块
     * 注意：现在根设备是软盘。
     * breada()和bread()函数类似,不同点在于可以把一些连续的数据块都读进来，一共三块，分别是257,256和258，
     * 其中引导块在256(尽管引导块并未实际使用), 超级块在257中。从软盘上读取数据块与bread读硬盘上的数据块原理基本一致.
     * 3个连续的数据块被读入了高速缓冲区的缓冲块中。
     *
     * breada()用于读取指定的数据块,并标出还需要读的块,然后返回含有数据块的缓冲区指针。如果返回 NULL,
     * 则表示数据块不可读这里 block+1 是指磁盘上的超级块。
     */
    bh = breada(ROOT_DEV,block+1,block,block+2,-1);
    if (!bh) {
        printk("Disk error while looking for ramdisk!\n");
        return;
    }
    // 将s指向缓冲区中的软盘超级块, (d_super_block 软盘中超级块结构)
    *((struct d_super_block *) &s) = *((struct d_super_block *) bh->b_data);
    brelse(bh);
    // 如果不等，说明不是minix文件系统
    if (s.s_magic != SUPER_MAGIC)
        /* No ram disk image present, assume normal floppy boot */
        return;
    // 块数 = 逻辑块数(区段数) * 2^(每区段块数的次方)。
    // 如果数据块数大于内存中虚拟盘所能容纳的块数,则也不能加载,显示出错信息并返回。否则显示加载数据块信息。
    nblocks = s.s_nzones << s.s_log_zone_size;
    if (nblocks > (rd_length >> BLOCK_SIZE_BITS)) {
        printk("Ram disk image too big!  (%d blocks, %d avail)\n",
            nblocks, rd_length >> BLOCK_SIZE_BITS);
        return;
    }
    printk("Loading %d bytes into ram disk... 0000k",
        nblocks << BLOCK_SIZE_BITS);
    // cp指向虚拟盘起始处,然后将软盘上的根文件系统映象文件复制到虚拟盘上。
    cp = rd_start;
    while (nblocks) {    // 将软盘上准备格式化用的根文件系统复制到虚拟盘上
        if (nblocks > 2) // 如果需读取的块数多于 3 快则采用超前预读方式读数据块。
            bh = breada(ROOT_DEV, block, block+1, block+2, -1);
        else
            bh = bread(ROOT_DEV, block); // 否则就单块读取。
        if (!bh) {
            printk("I/O error on block %d, aborting load\n",
                block);
            return;
        }
        (void) memcpy(cp, bh->b_data, BLOCK_SIZE); // 将缓冲区中的数据复制到cp处
        brelse(bh);  // 释放缓冲区。
        printk("\010\010\010\010\010%4dk",i); // 打印加载块计数值。
        cp += BLOCK_SIZE; // 虚拟盘指针前移
        block++;
        nblocks--;
        i++;
    }
    printk("\010\010\010\010\010done \n");
    ROOT_DEV=0x0101; // 修改 ROOT_DEV 使其指向虚拟盘 ramdisk
}
```

在将软盘上的文件系统信息拷贝到虚拟盘中之后，需要在虚拟盘这个根设备上加载根文件系统：

https://github.com/leeminghao/doc-linux/blob/master/0.11/filesystem/InstallRootFsFromRamdisk.md