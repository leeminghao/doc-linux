物理内存管理
========================================

有两种类型计算机，分别以不同的方法管理物理内存:

* UMA

UMA计算机（一致内存访问，uniform memory ac-cess）将可用内存以连续方式组织起来（可能有小的缺口）。
SMP系统中的每个处理器访问各个内存区都是同样快。

* NUMA

NUMA计算机（非一致内存访问，non-uniformmemory access）总是多处理器计算机。系统的各个CPU
都有本地内存，可支持特别快速的访问。各个处理器之间通过总线连接起来，以支持对其他CPU的本地
内存的访问，当然比访问本地内存慢些。

**UMA和NUMA的区别**:

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/mm/misc/res/uma_numa.jpg

两种类型计算机的混合也是可能的，其中使用不连续的内存。即在UMA系统中，内存不是连续的，
而有比较大的洞。在这里应用NUMA体系结构的原理通常有所帮助，可以使内核的内存访问更简单。

实际上内核会区分3种配置选项：
* FLATMEM
* DISCONTIGMEM
* SPARSEMEM

SPARSEMEM和DISCONTIGMEM实际上作用相同，但从开发者的角度看来，对应代码的质量有所不同。
SPARSEMEM被认为更多是试验性的，不那么稳定，但有一些性能优化。我们认为DISCONTIGMEM相关
代码更稳定一些，但不具备内存热插拔之类的新特性。
我们的讨论主要限于FLATMEM。在大多数配置中都使用该内存组织类型，通常它也是内核的默认值。
由于所有内存模型实际上都使用同样的数据结构，因此不讨论其他选项也没多大损失。真正的NUMA
会设置配置选项CONFIG_NUMA，相关的内存管理代码与上述两种变体有所不同。由于平坦内存模型在
NUMA计算机上没有意义，只有不连续内存模型和稀疏内存模型是可用的。但要注意，通过配置选项NUMA_EMU，
可以用平坦内存模型的AMD64系统来感受NUMA系统的复杂性，实际上是将内存划分为假的NUMA内存域。
在没有真正的NUMA计算机可用于开发时，该选项是有用的，由于某种原因，NUMA计算机过于昂贵。
我们集中在UMA系统，不考虑CONFIG_NUMA。这并不意味着NUMA相关的数据结构可以完全忽略。
由于UMA系统可以在地址空间包含比较大的洞时选择配置选项CONFIG_DISCONTIGMEM，这种情况下
在不采用NUMA技术的系统上也会有多个内存结点。

术语
----------------------------------------

* 结点

首先，内存划分为结点。每个结点关联到系统中的一个处理器，在内核中表示为pg_data_t的实例。

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/include/linux/mmzone.h/pg_data_t.md

* 内存域

各个结点又划分为内存域，是内存的进一步细分。

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/include/linux/mmzone.h/struct_zone.md

对应numa系统中的内存划分如下所示:

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/mm/misc/res/numa_struct.jpg
