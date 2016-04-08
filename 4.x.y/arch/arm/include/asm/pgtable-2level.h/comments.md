Linux对L1表项映射调整
========================================

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

重要调整说明如下：

L1页表从4096个item变为2048个item，但每个item的大小从原来的4字节变为8个字节。
一个page中，放置2个L2页表，每个还是256项，每项是4个字节，所以总计是256*2*4=2KB，
放置在page页的下半部，而上部分放置对应的linux内存管理系统使用的页表，mmu硬件是
不会去使用它的。所以刚好占满一个page页的大小（4KB），这样就不浪费空间了。