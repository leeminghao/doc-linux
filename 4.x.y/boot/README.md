Linux内核启动
========================================

当bootloader完成它的使命之后就将CPU的使用权交给了Linux内核.Linux内核通常是以zImage的形式被
bootloader加载并执行的。

我们先来研究下zImage的生成过程及其组成部分，如下所示:

zImage生成构成
----------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/kbuild/zImage.md
