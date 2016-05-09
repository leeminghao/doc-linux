__build_all_zonelists
========================================

__build_all_zonelists对系统中的各个NUMA结点分别调用build_zonelists。

for_each_online_node
----------------------------------------

path: mm/page_alloc.c
```
static int __build_all_zonelists(void *data)
{
    int nid;
    int cpu;
    pg_data_t *self = data;

#ifdef CONFIG_NUMA
    memset(node_load, 0, sizeof(node_load));
#endif

    if (self && !node_online(self->node_id)) {
        build_zonelists(self);
        build_zonelist_cache(self);
    }

    /* for_each_online_node遍历了系统中所有的活动结点。由于UMA系统只有一个结点，
     * build_zonelists只调用了一次，就对所有的内存创建了内存域列表。NUMA系统调用
     * 该函数的次数等同于结点的数目。每次调用对一个不同结点生成内存域数据。
     * build_zonelists需要一个指向pgdat_t实例的指针作为参数，其中包含了结点内存配置
     * 的所有现存信息，而新建的数据结构也会放置在其中。
     */
    for_each_online_node(nid) {
```

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/include/linux/nodemask.h/for_each_online_node.md

NODE_DATA
----------------------------------------

```
        /* 在UMA系统上，NODE_DATA返回contig_page_data的地址。*/
        pg_data_t *pgdat = NODE_DATA(nid);
```

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/include/linux/mmzone.h/NODE_DATA.md

在UMA系统上contig_page_data的初始化如下所示:

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/arch/arm/mm/init.c/bootmem_init.md

build_zonelists
----------------------------------------

```
        build_zonelists(pgdat);
```

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/mm/page_alloc.c/build_zonelists.md

build_zonelist_cache
----------------------------------------

```
        build_zonelist_cache(pgdat);
    }
```

setup_pageset
----------------------------------------

```
    /*
     * Initialize the boot_pagesets that are going to be used
     * for bootstrapping processors. The real pagesets for
     * each zone will be allocated later when the per cpu
     * allocator is available.
     *
     * boot_pagesets are used also for bootstrapping offline
     * cpus if the system is already booted because the pagesets
     * are needed to initialize allocators on a specific cpu too.
     * F.e. the percpu allocator needs the page allocator which
     * needs the percpu allocator in order to allocate its pagesets
     * (a chicken-egg dilemma).
     */
    for_each_possible_cpu(cpu) {
        setup_pageset(&per_cpu(boot_pageset, cpu), 0);

#ifdef CONFIG_HAVE_MEMORYLESS_NODES
        /*
         * We now know the "local memory node" for each node--
         * i.e., the node of the first zone in the generic zonelist.
         * Set up numa_mem percpu variable for on-line cpus.  During
         * boot, only the boot cpu should be on-line;  we'll init the
         * secondary cpus' numa_mem as they come on-line.  During
         * node/memory hotplug, we'll fixup all on-line cpus.
         */
        if (cpu_online(cpu))
            set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
#endif
    }

    return 0;
}
```