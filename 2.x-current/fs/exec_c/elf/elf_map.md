elf_map
========================================

Source:
----------------------------------------

elf_map用于建立进程虚拟地址空间与目标映像文件中某个连续区间之间的映射.
其中, 传入参数信息如下所示:

* filep - 指向目标映像文件.
* addr - 装入地址.
* eppnt - 指明装入段(PT_LOAD)的程序头信息.
* prot - 指明装入段的权限.
* type - 指明映射标志.
* total_size - 表明elf image文件的大小.

```
static unsigned long elf_map(struct file *filep, unsigned long addr,
      struct elf_phdr *eppnt, int prot, int type,
      unsigned long total_size)
{
   unsigned long map_addr;
   /* 1.eppnt->p_vaddr给出了段(PT_LOAD)的数据映射到虚拟地址空间中的位置.
   * eppnt->p_filesz指定了段在二进制文件中的长度(单位字节).
   */
   unsigned long size = eppnt->p_filesz + ELF_PAGEOFFSET(eppnt->p_vaddr);
   /* 2.eppnt->p_offset给出了所述段在文件中的偏移量(单位为字节). */
   unsigned long off = eppnt->p_offset - ELF_PAGEOFFSET(eppnt->p_vaddr);
   addr = ELF_PAGESTART(addr);
   size = ELF_PAGEALIGN(size);

   /* mmap() will return -EINVAL if given a zero size, but a
    * segment with zero filesize is perfectly valid */
   if (!size)
      return addr;

   /*
   * total_size is the size of the ELF (interpreter) image.
   * The _first_ mmap needs to know the full size, otherwise
   * randomization might put this image into an overlapping
   * position with the ELF binary image. (since size < total_size)
   * So we first map the 'big' image - and unmap the remainder at
   * the end. (which unmap is needed for ELF images with holes.)
   */
   if (total_size) {
      total_size = ELF_PAGEALIGN(total_size);
      map_addr = vm_mmap(filep, addr, total_size, prot, type, off);
      if (!BAD_ADDR(map_addr))
         vm_munmap(map_addr+size, total_size-size);
   } else
      map_addr = vm_mmap(filep, addr, size, prot, type, off);

   return(map_addr);
}
```

针对我们a.out这个可执行文件来说其PT_LOAD段加载的信息如下所示:

```
Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
...
LOAD           0x000000 0x00008000 0x00008000 0x0073c 0x0073c R E 0x8000
LOAD           0x00073c 0x0001073c 0x0001073c 0x0012c 0x00130 RW  0x8000
```

经过elf_map重新计算后得到的值如下所示:

### LOAD1

```
addr=8000
size=1000
off=0
```

### LOAD2

```
addr=10000
size=1000
off=0
```

接下来调用vm_mmap函数来进行映射操作:

vm_mmap
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/2.x-current/mm/util_c/vm_mmap.md
