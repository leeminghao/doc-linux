Init Memory
========================================

概述
----------------------------------------

在内存管理的上下文中，初始化（initialization）可以有多种含义。在许多CPU上，必须显式设置适于
Linux内核的内存模型。例如，在IA-32系统上需要切换到保护模式，然后内核才能检测可用内存和寄存器。
在初始化过程中，还必须建立内存管理的数据结构，以及其他很多事务。因为内核在内存管理完全初始化
之前就需要使用内存，在系统启动过程期间，使用了一个额外的简化形式的内存管理模块，然后又丢弃掉。
因为内存管理初始化中特定于CPU的部分使用了底层体系结构许多次要、微妙的细节，这些与内核的结构
没什么关系，最多不过是汇编语言程序设计的最佳实践而已.

对相关数据结构的初始化是从全局启动例程start_kernel中开始的，该例程在加载内核并激活各个
子系统之后执行。由于内存管理是内核一个非常重要的部分，因此在特定于体系结构的设置步骤中
检测内存并确定系统中内存的分配情况后，会立即执行内存管理的初始化。

此时，已经对各种系统内存模式生成了一个pg_data_t实例，用于保存诸如结点中内存数量以及内存在各个
内存域之间分配情况的信息。所有平台上都实现了特定于体系结构的NODE_DATA宏，用于通过结点编号，
来查询与一个NUMA结点相关的pg_data_t实例。有关物理内存的管理概述如下所示:

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/mm/pm_manage.md

分析场景
----------------------------------------

由于大部分系统都只有一个内存结点，我们只考察此类系统。具体是什么样的情况呢？为确保内存管理
代码是可移植的（因此它可以同样用于UMA和NUMA系统），内核在mm/page_alloc.c中定义了一个
pg_data_t实例（称作contig_page_data）管理所有的系统内存。根据该文件的路径名可以看出，
这不是特定于CPU的实现。实际上，大多数体系结构都采用了该方案。NODE_DATA的实现现在更简单了:

path: include/linux/mmzone.h
```
#ifndef CONFIG_NEED_MULTIPLE_NODES
extern struct pglist_data contig_page_data;
#define NODE_DATA(nid) (&contig_page_data)
#else
#endif
```

尽管该宏有一个形式参数用于选择NUMA结点，但在UMA系统中只有一个结点，因此总是返回同样的数据。
内核也可以依赖于下述事实：体系结构相关的初始化代码将numnodes变量设置为系统中结点的数目。
在UMA系统上因为只有一个（形式上的）结点，因此该数量是1。在编译时间，预处理器语句会为特定
的配置选择正确的定义。

系统启动过程的内存初始化
----------------------------------------

下图给出了start_kernel的代码流程图。其中只包括与内存管理相关的系统初始化函数:

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/init/main.c/res/start_kernel-init_mm.jpg

我们首先概述相关函数的任务:

### setup_arch

是一个特定于体系结构的设置函数，其中一项任务是负责初始化自举分配器。

#### ARM

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/arch/arm/kernel/setup.c/setup_arch.md

### setup_per_cpu_areas

在SMP系统上，setup_per_cpu_areas初始化源代码中（使用per_cpu宏）定义的静态per-cpu变量，这种变量
对系统中的每个CPU都有一个独立的副本。此类变量保存在内核二进制映像的一个独立的段中。
setup_per_cpu_areas的目的是为系统的各个CPU分别创建一份这些数据的副本。
在非SMP系统上该函数是一个空操作。

### build_all_zonelists

建立结点和内存域的数据结构。

### mem_init

是另一个特定于体系结构的函数，用于停用boot-mem分配器并迁移到实际的内存管理函数。

### kmem_cache_init

初始化内核内部用于小块内存区的分配器。

### setup_per_cpu_pageset

从上文提到的struct zone，为pageset数组的第一个数组元素分配内存。分配第一个数组元素，
换句话说，就是意味着为第一个系统处理器分配。系统的所有内存域都会考虑进来。该函数还
负责设置冷热分配器的限制.

**注意**: 在SMP系统上对应于其他CPU的pageset数组成员，将会在相应的CPU激活时初始化。