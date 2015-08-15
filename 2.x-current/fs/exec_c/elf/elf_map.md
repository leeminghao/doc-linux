elf_map
========================================

Source:
----------------------------------------

```
static unsigned long elf_map(struct file *filep, unsigned long addr,
      struct elf_phdr *eppnt, int prot, int type,
      unsigned long total_size)
{
   unsigned long map_addr;
   unsigned long size = eppnt->p_filesz + ELF_PAGEOFFSET(eppnt->p_vaddr);
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