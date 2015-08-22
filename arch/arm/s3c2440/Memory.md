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

系统启动方式
----------------------------------------

### OM[1:0]=00

当系统一上电,CPU会自动从NAND Flash中读取前4KB的数据放置在片内SRAM
里(S3C2440是soc),CPU内部一般都集成小容量的SRAM(又叫stapping stone,
垫脚石),同时把这段片内SRAM映射到nGCS0片选的空间(即0x00000000).
而PC指针一上电就指向垫脚石的起始地址0x00000000。cpu是从0x00000000
开始执行，也就是NAND flash里的前4KB内容(bootloader内容)。因为
NAND FLASH连地址线都没有，不能直接把NAND映射到0x00000000，只好使用
片内SRAM做一个载体。通过这个载体把Nand Flash中的代码复制到RAM(一般
是SDRAM)中去执行.

### OM[1:0]=01或者10

Nor Flash被映射到0x00000000地址(就是nGCS0，这里就不需要片内SRAM来辅助
了，所以片内SRAM的起始地址还是0x40000000）. 然后cpu从0x00000000开始执行(也就是在Norfalsh中执行)。

**注意**:

为什么会有这两种启动方式，关键还是两种flash的不同特点造成:
NOR FLASH容量小，速度快，稳定性好，输入地址，然后给出读写信号即可从
数据口得到数据，适合做程序存储器。NANDFLASH 总容量大，但是读写都需要
复杂的时序，更适合做数据存储器。这种不同就造成了NOR Flash可以直接连接
到arm的总线并且可以运行程序，而NANDflash必须搬移到内存(SDRAM)中运行。
