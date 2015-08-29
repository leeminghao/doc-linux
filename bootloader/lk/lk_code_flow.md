lk code flow
========================================

_start
----------------------------------------

lk入口在crt0.s中_start函数开始. 在链接接文件system_onesegment.ld中指定.

path: lk/arch/arm/system-onesegment.ld
```
ENTRY(_start)
SECTIONS
{
    . = %MEMBASE%;
    ...
}
...
```

path: lk/arch/arm/crt0.s

* 1. 设置向量表
* 2. 初始化BSS
* 3. 跳到C函数(bl kmain)

kmain
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/bootloader/lk/kernel/main_c/kmain.md
