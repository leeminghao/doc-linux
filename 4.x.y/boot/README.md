Linux内核启动
========================================

当bootloader完成它的使命之后就将CPU的使用权交给了Linux内核.Linux内核通常是以zImage的形式被
bootloader加载并执行的。

我们先来研究下zImage的生成过程及其组成部分，如下所示:

zImage编译过程
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/kbuild/zImage.md

在bootloader将kernel信息加载到内存，然后变跳转到内核执行. 根据分析zImage的编译过程
我们得知，内核第一条指令的地址是arch/arm/boot/compressed/head.S第一条指令的地址.