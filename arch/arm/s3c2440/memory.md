S3C2440 Memory
========================================

内存映射表
----------------------------------------

参考s3c2440的datasheet，我们可以找到该芯片的内存映射表(Memory Map)
如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/arch/arm/s3c2440/res/memory_map.png

根据OM[1]和OM[0]引脚的不同，内存映射的方式有细微差别。但基本可以看出，
决定外接存储器的存储地址范围的因素主要是一组引脚nGCS0[0]~nGCS[7] 。

s3c2440芯片把存储系统分为了8个Bank，由nGCS0[0]~nGCS[7]这8根引脚决定
当前访问的是哪一个Bank对应的存储器。其中，前6个Bank用于连接ROM或者
SRAM(或者类似SRAM接口的存储器，如Nor Flash)（图中由SROM标识），
而第7和第8个Bank用于连接SDRAM，并且规定由第7个Bank地址作为SDRAM的起始
地址(即0x30000000）。我们可以看到，SDRAM芯片被连接到第7个Bank中，
起始地址为0x30000000，而Nor Flash被连接到了第0个Bank，起始地址为
0x0000000
