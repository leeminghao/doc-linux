__build_all_zonelists
========================================

__build_all_zonelists对系统中的各个NUMA结点分别调用build_zonelists。

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

    for_each_online_node(nid) {
        pg_data_t *pgdat = NODE_DATA(nid);

        build_zonelists(pgdat);
        build_zonelist_cache(pgdat);
    }

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