PAGE_OFFSET
========================================

path: arch/arm/include/asm/memory.h
```
/* PAGE_OFFSET - the virtual address of the start of the kernel image */
#define PAGE_OFFSET		UL(CONFIG_PAGE_OFFSET)
```

CONFIG_PAGE_OFFSET
----------------------------------------

### aries

path: arch/arm/configs/aries-perf-eng_defconfig
```
CONFIG_PAGE_OFFSET=0xC0000000
```
