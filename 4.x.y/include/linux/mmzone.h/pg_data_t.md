pg_data_t
========================================

内存划分为结点, 每个结点关联到系统中的一个处理器，在内核中表示为pg_data_t的实例.
pg_data_t是用于表示结点的基本元素，定义如下：

数据结构
----------------------------------------

path: include/linux/mmzone.h
```
/*
 * The pg_data_t structure is used in machines with CONFIG_DISCONTIGMEM
 * (mostly NUMA machines?) to denote a higher-level memory zone than the
 * zone denotes.
 *
 * On NUMA machines, each NUMA node would have a pg_data_t to describe
 * it's memory layout.
 *
 * Memory statistics and page replacement data structures are maintained on a
 * per-zone basis.
 */
struct bootmem_data;
typedef struct pglist_data {
    struct zone node_zones[MAX_NR_ZONES];
    struct zonelist node_zonelists[MAX_ZONELISTS];
    int nr_zones;
#ifdef CONFIG_FLAT_NODE_MEM_MAP    /* means !SPARSEMEM */
    struct page *node_mem_map;
#ifdef CONFIG_PAGE_EXTENSION
    struct page_ext *node_page_ext;
#endif
#endif
#ifndef CONFIG_NO_BOOTMEM
    struct bootmem_data *bdata;
#endif
#ifdef CONFIG_MEMORY_HOTPLUG
    /*
     * Must be held any time you expect node_start_pfn, node_present_pages
     * or node_spanned_pages stay constant.  Holding this will also
     * guarantee that any pfn_valid() stays that way.
     *
     * pgdat_resize_lock() and pgdat_resize_unlock() are provided to
     * manipulate node_size_lock without checking for CONFIG_MEMORY_HOTPLUG.
     *
     * Nests above zone->lock and zone->span_seqlock
     */
    spinlock_t node_size_lock;
#endif
    unsigned long node_start_pfn;
    unsigned long node_present_pages; /* total number of physical pages */
    unsigned long node_spanned_pages; /* total size of physical page
                         range, including holes */
    int node_id;
    wait_queue_head_t kswapd_wait;
    wait_queue_head_t pfmemalloc_wait;
    struct task_struct *kswapd;    /* Protected by
                       mem_hotplug_begin/end() */
    int kswapd_max_order;
    enum zone_type classzone_idx;
#ifdef CONFIG_NUMA_BALANCING
    /* Lock serializing the migrate rate limiting window */
    spinlock_t numabalancing_migrate_lock;

    /* Rate limiting time interval */
    unsigned long numabalancing_migrate_next_window;

    /* Number of pages migrated during the rate limiting time interval */
    unsigned long numabalancing_migrate_nr_pages;
#endif
} pg_data_t;
```

* node_zones

是一个数组，包含了结点中各内存域的数据结构。

* node_zonelists

指定了备用结点及其内存域的列表，以便在当前结点没有可用空间时，在备用结点分配内存。
该数组用来表示所描述的层次结构。node_zonelists数组对每种可能的内存域类型，都配置
了一个独立的数组项。数组项包含了类型为zonelist的一个备用列表:

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/include/linux/mmzone.h/struct_zonelist.md

* nr_zones

结点中不同内存域的数目

* node_mem_map

是指向struct page实例数组的指针，用于描述结点的所有物理内存页。它包含了结点中所有内存域的页。

* bdata

在系统启动期间，内存管理子系统初始化之前，内核也需要使用内存（另外，还必须保留部分内存用于
初始化内存管理子系统）。为解决这个问题，内核使用了自举内存分配器（boot memory allocator）。
bdata指向自举内存分配器数据结构的实例。

* node_start_pfn

是该NUMA结点第一个页帧的逻辑编号。系统中所有结点的页帧是依次编号的，每个页帧的号码都是
全局唯一的（不只是结点内唯一）。node_start_pfn在UMA系统中总是0，因为其中只有一个结点，
因此其第一个页帧编号总是0。

* node_present_pages

指定了结点中页帧的数目

* node_spanned_pages

给出了该结点以页帧为单位计算的长度。node_present_pages和node_spanned_pages二者的值不一定相同，
因为结点中可能有一些空洞，并不对应真正的页帧。

 * node_id

是全局结点ID。系统中的NUMA结点都从0开始编号。

* kswapd_wait

是交换守护进程（swap daemon）的等待队列，在将页帧换出结点时会用到。

* kswapd

指向负责该结点的交换守护进程的task_struct。

* kswapd_max_order

用于页交换子系统的实现，用来定义需要释放的区域的长度.

关系
----------------------------------------

给出了结点及其包含的内存域之间的关联，以及备用列表，这些是通过结点数据结构起始处的几个数组建立的。
这些不是普通的数组指针。数组的数据就保存在结点数据结构之中。结点的内存域保存在
node_zones[MAX_NR_ZONES]。该数组总是有3个项，即使结点没有那么多内存域，也是如此。如果不足3个，
则其余的数组项用0填充。

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/mm/res/numa_struct.jpg
