free
========================================

Output
----------------------------------------

free工具用来查看系统可用内存:

```
$ free
             total       used       free     shared    buffers     cached
Mem:       8175320    6159248    2016072          0     310208    5243680
-/+ buffers/cache:     605360    7569960
Swap:      6881272      16196    6865076
```

解释一下Linux上free命令的输出。
下面是free的运行结果，一共有4行。为了方便说明，我加上了列号。这样可以把free的输出看成一个
二维数组FO(Free Output)。例如:

```
FO[2][1] = 24677460
FO[3][2] = 10321516

                   1          2          3          4          5          6
1              total       used       free     shared    buffers     cached
2 Mem:      24677460   23276064    1401396          0     870540   12084008
3 -/+ buffers/cache:   10321516   14355944
4 Swap:     25151484     224188   24927296
```

free的输出一共有四行，第四行为交换区的信息，分别是交换的总量（total），使用量（used）和
有多少空闲的交换区（free），这个比较清楚，不说太多。

free输出地第二行和第三行是比较让人迷惑的,这两行都是说明内存使用情况的。
第一列是总量（total），第二列是使用量（used），第三列是可用量（free）。

### 第一行

第一行的输出时从操作系统（OS）来看的,也就是说，从OS的角度来看，计算机上一共有:

24677460KB（缺省时free的单位为KB）物理内存，即FO[2][1]； 在这些物理内存中有
23276064KB（即FO[2][2]）被使用了； 还用1401396KB（即FO[2][3]）是可用的；

这里得到第一个等式：

```
FO[2][1] = FO[2][2] + FO[2][3]
```

FO[2][4]表示被几个进程共享的内存的，现在已经deprecated，其值总是0（当然在一些系统上也可能不是0，
主要取决于free命令是怎么实现的）。

FO[2][5]表示被OS buffer住的内存。FO[2][6]表示被OS cache的内存。在有些时候buffer和cache这两个词
经常混用。不过在一些比较低层的软件里是要区分这两个词的.

https://github.com/leeminghao/doc-linux/tree/master/misc/buffer-cache/README.md

也就是说buffer是用于存放要输出到disk（块设备）的数据的，而cache是存放从disk上读出的数据。
这二者是为了提高IO性能的，并由OS管理。

Linux和其他成熟的操作系统（例如windows），为了提高IO read的性能，总是要多cache一些数据，
这也就是为什么FO[2][6]（cached memory）比较大，而FO[2][3]比较小的原因。

### 第二行

free输出的第二行是从一个应用程序的角度看系统内存的使用情况。

对于FO[3][2]，即-buffers/cache，表示一个应用程序认为系统被用掉多少内存；
对于FO[3][3]，即+buffers/cache，表示一个应用程序认为系统还有多少内存；

因为被系统cache和buffer占用的内存可以被快速回收，所以通常FO[3][3]比FO[2][3]会大很多。

这里还用两个等式:

FO[3][2] = FO[2][2] - FO[2][5] - FO[2][6]
FO[3][3] = FO[2][3] + FO[2][5] + FO[2][6]

这二者都不难理解。

Configure
----------------------------------------

### /proc/sys/vm/drop_caches

cache内存释放.

```
To free pagecache:
# echo 1 > /proc/sys/vm/drop_caches
To free dentries and inodes:
# echo 2 > /proc/sys/vm/drop_caches
To free pagecache, dentries and inodes:
# echo 3 > /proc/sys/vm/drop_caches
```

### /proc/sys/vm/dirty_ratio

这个参数控制文件系统的文件系统写缓冲区的大小，单位是百分比，表示系统内存的百分比，表示
当写缓冲使用到系统内存多少的时候，开始向磁盘写出数据。增大之会使用更多系统内存用于磁盘写缓冲，
也可以极大提高系统的写性能。但是，当你需要持续、恒定的写入场合时，应该降低其数值，一般启动上
缺省是10。设1加速程序速度

### /proc/sys/vm/dirty_background_ratio

这个参数控制文件系统的pdflush进程，在何时刷新磁盘。单位是百分比，表示系统内存的百分比，
意思是当写缓冲使用到系统内存多少的时候，pdflush开始向磁盘写出数据。增大之会使用更多
系统内存用于磁盘写缓冲，也可以极大提高系统的写性能。但是，当你需要持续、恒定的写入场合时，
应该降低其数值，一般启动上缺省是5

### /proc/sys/vm/dirty_writeback_centisecs

这个参数控制内核的脏数据刷新进程pdflush的运行间隔。单位是1/100秒。缺省数值是500，也就是 5 秒。
如果你的系统是持续地写入动作，那么实际上还是降低这个数值比较好，这样可以把尖峰的写操作削平成
多次写操

### /proc/sys/vm/dirty_expire_centisecs

这个参数声明Linux内核写缓冲区里面的数据多“旧”了之后，pdflush进程就开始考虑写到磁盘中去。
单位是 1/100秒。缺省是 30000，也就是 30 秒的数据就算旧了，将会刷新磁盘。对于特别重载的写
操作来说，这个值适当缩小也是好的，但也不能缩小太多，因为缩小太多也会导致IO提高太快。
建议设置为 1500，也就是15秒算旧。

### /proc/sys/vm/page-cluster

该文件表示在写一次到swap区的时候写入的页面数量，0表示1页，1表示2页，2表示4页。

### /proc/sys/vm/swapiness

该文件表示系统进行交换行为的程度，数值（0-100）越高，越可能发生磁盘交换。

### /proc/sys/vm/vfs_cache_pressure

该文件表示内核回收用于directory和inode cache内存的倾向
