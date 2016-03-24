内存布局
========================================

在我们的实验环境中,当加载完kernel之后，MSM8960各模块布局如下所示:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/msm8960/memory_layout.md

**注意**: 这里我们说的布局是指物理地址空间.

内核物理内存布局
----------------------------------------

/proc/iomem也提供了有关物理内存划分出的各个段的一些信息。

```
root@aries:/ # cat /proc/iomem
...
80200000-88dfffff : System RAM
  80208000-80e2c1d3 : Kernel code
  8101e000-81a10df3 : Kernel data
89000000-8d9fffff : System RAM
8ec00000-8effffff : System RAM
8f700000-8fdfffff : System RAM
8ff00000-9fdfffff : System RAM
  8ff00000-8ff3ffff : rmtfs
a0000000-a57fffff : System RAM
a5900000-ff2fefff : System RAM
```

内核虚拟内存布局
----------------------------------------

物理内存映射到虚拟地址空间中从0xc0008000开始。System.map中相关的项如下所示:

```
c0008000 T _text
...
c0e07f80 R _etext
...
c101e000 D _data
...
c1a4e2e4 B _end
```

* _text和_etext是代码段的起始和结束地址，包含了编译后的内核代码。
* 数据段位于_etext和_edata之间，保存了大部分内核变量。
* 初始化数据在内核启动过程结束后不再需要（例如，包含初始化为0的所有静态全局变量的BSS段）
  保存在最后一段，从_edata到_end。在内核初始化完成后，其中的大部分数据都可以从内存删除，
  给应用程序留出更多空间。这一段内存区划分为更小的子区间，以控制哪些可以删除，哪些不能删除.

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/System.map

在系统启动时，找到的内存区由内核函数print_memory_map显示:

```
...
[    0.000000] Memory: 140MB 74MB 4MB 7MB 255MB 88MB 1433MB = 2001MB total
[    0.000000] Memory: 1859388k/1859388k available, 207040k reserved, 1297404K highmem
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
[    0.000000]     timers  : 0xfffef000 - 0xffff0000   (   4 kB)
[    0.000000]     fixmap  : 0xfff00000 - 0xfffe0000   ( 896 kB)
[    0.000000]     vmalloc : 0xf0000000 - 0xff000000   ( 240 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xef800000   ( 760 MB)
[    0.000000]     pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
[    0.000000]     modules : 0xbf000000 - 0xbfe00000   (  14 MB)
[    0.000000]       .text : 0xc0008000 - 0xc0e07f80   (14336 kB)
[    0.000000]       .init : 0xc0f00000 - 0xc101df40   (1144 kB)
[    0.000000]       .data : 0xc101e000 - 0xc121aac0   (2035 kB)
[    0.000000]        .bss : 0xc121aae4 - 0xc1a4e2e4   (8398 kB)
```