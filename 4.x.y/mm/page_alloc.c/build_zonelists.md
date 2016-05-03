build_zonelists
========================================

该函数的任务是，在当前处理的结点和系统中其他结点的内存域之间建立一种等级次序。
接下来，依据这种次序分配内存。如果在期望的结点内存域中，没有空闲内存，那么这种次序就很重要。

内核定义了内存的一个层次结构，首先试图分配“廉价的”内存。如果失败，则根据访问速度和容量，
逐渐尝试分配“更昂贵的”内存。

高端内存是最廉价的，因为内核没有任何部份依赖于从该内存域分配的内存。如果高端内存域用尽，
对内核没有任何副作用，这也是优先分配高端内存的原因。

普通内存域的情况有所不同。许多内核数据结构必须保存在该内存域，而不能放置到高端内存域。因此
如果普通内存完全用尽，那么内核会面临紧急情况。所以只要高端内存域的内存没有用尽，都不会从
普通内存域分配内存。

最昂贵的是DMA内存域，因为它用于外设和系统之间的数据传输。因此从该内存域分配内存是最后一招。
内核还针对当前内存结点的备选结点，定义了一个等级次序。这有助于在当前结点所有内存域的内存
都用尽时，确定一个备选结点。

current_zonelist_order
----------------------------------------

path: mm/page_alloc.c
```
static void build_zonelists(pg_data_t *pgdat)
{
    int j, node, load;
    enum zone_type i;
    nodemask_t used_mask;
    int local_node, prev_node;
    struct zonelist *zonelist;
    int order = current_zonelist_order;
```

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/mm/page_alloc.c/current_zonelist_order.md

node_zonelists
----------------------------------------

```
    /* initialize zonelists */
    /* node_zonelists数组对每种可能的内存域类型，都配置了一个独立的数组项。数组项包含了类型为
     * zonelist的一个备用列表.由于该备用列表必须包括所有结点的所有内存域，因此由
     * MAX_NUMNODES * MAX_NZ_ZONES项组成，外加一个用于标记列表结束的空指针。
     */
    for (i = 0; i < MAX_ZONELISTS; i++) {
        zonelist = pgdat->node_zonelists + i;
        zonelist->_zonerefs[0].zone = NULL;
        zonelist->_zonerefs[0].zone_idx = 0;
    }
```

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/include/linux/mmzone.h/pg_data_t.md

----------------------------------------

```
    /* NUMA-aware ordering of nodes */
    local_node = pgdat->node_id;
    load = nr_online_nodes;
    prev_node = local_node;
    nodes_clear(used_mask);

    memset(node_order, 0, sizeof(node_order));
    j = 0;

    /* 一个大的外部循环首先迭代所有的结点内存域。每个循环在zonelist数组中找到第node个zonelist，
     * 对第node个内存域计算备用列表。*/
    while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
        /*
         * We don't want to pressure a particular node.
         * So adding penalty to the first node in same
         * distance group to make it round-robin.
         */
        if (node_distance(local_node, node) !=
            node_distance(local_node, prev_node))
            node_load[node] = load;

        prev_node = node;
        load--;
        if (order == ZONELIST_ORDER_NODE)
            build_zonelists_in_node_order(pgdat, node);
        else
            node_order[j++] = node;    /* remember order */
    }

    if (order == ZONELIST_ORDER_ZONE) {
        /* calculate node order -- i.e., DMA last! */
        build_zonelists_in_zone_order(pgdat, j);
    }

    build_thisnode_zonelists(pgdat);
}
```