struct map_desc
========================================

path: arch/arm/include/asm/mach/map.h
```
struct map_desc {
    unsigned long virtual;
    unsigned long pfn;
    unsigned long length;
    unsigned int type;
};
```