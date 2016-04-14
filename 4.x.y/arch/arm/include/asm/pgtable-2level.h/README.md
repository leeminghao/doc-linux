Linux arm page table
========================================

Linux page table
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/4.x.y//mm/misc/page_table.md

Linux arm page table
----------------------------------------

path: arch/arm/include/asm/pgtable-2level.h

Hardware-wise, we have a two level page table structure, where the first
level has 4096 entries, and the second level has 256 entries.  Each entry
is one 32-bit word.  Most of the bits in the second level entry are used
by hardware, and there aren't any "accessed" and "dirty" bits.

Linux on the other hand has a three level page table structure, which can
be wrapped to fit a two level page table structure easily - using the PGD
and PTE only.  However, Linux also expects one "PTE" table per page, and
at least a "dirty" bit.

Therefore, we tweak the implementation slightly - we tell Linux that we
have 2048 entries in the first level, each of which is 8 bytes (iow, two
hardware pointers to the second level.)  The second level contains two
hardware PTE tables arranged contiguously, preceded by Linux versions
which contain the state information Linux needs.  We, therefore, end up
with 512 entries in the "PTE" level.

This leads to the page tables having the following layout:

```
   pgd             pte
|        |
+--------+
|        |       +------------+ +0
+- - - - +       | Linux pt 0 |
|        |       +------------+ +1024
+--------+ +0    | Linux pt 1 |
|        |-----> +------------+ +2048
+- - - - + +4    |  h/w pt 0  |
|        |-----> +------------+ +3072
+--------+ +8    |  h/w pt 1  |
|        |       +------------+ +4096
```

See L_PTE_xxx below for definitions of bits in the "Linux pt", and
PTE_xxx for definitions of bits appearing in the "h/w pt".

PMD_xxx definitions refer to bits in the first level page table.

The "dirty" bit is emulated by only granting hardware write permission
iff the page is marked "writable" and "dirty" in the Linux PTE.  This
means that a write to a clean page will cause a permission fault, and
the Linux MM layer will mark the page dirty via handle_pte_fault().
For the hardware to notice the permission change, the TLB entry must
be flushed, and ptep_set_access_flags() does that for us.

The "accessed" or "young" bit is emulated by a similar method; we only
allow accesses to the page if the "young" bit is set.  Accesses to the
page will cause a fault, and handle_pte_fault() will set the young bit
for us as long as the page is marked present in the corresponding Linux
PTE entry.  Again, ptep_set_access_flags() will ensure that the TLB is
up to date.

However, when the "young" bit is cleared, we deny access to the page
by clearing the hardware PTE.  Currently Linux does not flush the TLB
for us in this case, which means the TLB will retain the transation
until either the TLB entry is evicted under pressure, or a context
switch which changes the user space mapping occurs.

Linux支持四级页表，作为其默认的页表结构。ARM是两级页表, PGD和PTE。从上面可以可以
看出一个work around的实现。PGD和PTE并不是直接对应ARM硬件的页表目录项。而是做了一些
为了linux上层的要求的一个方案。首先，他把4096个pgd项变成2048个，物理上还是一个pgd
指向一个256个pte项的数组的，这没办法改。但是pgd指针逻辑上合并成一个，各自指向的pte
数组也合并,并且是连续的。这512个pte项合并起来，这个pte分配的页（一般linux需要一个pte表
在一个页里，代码注释也写了）还剩下一半的内容，刚好可以存放arm不支持的一些标记(Linux pt 0, 1),
而这些标记是linux必须的，比如dirty。这个方案还非常具有可扩展性，不依赖arm本身的标记。
dirty标记的实现是通过对arm支持的权限fault的中断来写这个标记,这样方式是相当于一种模拟。