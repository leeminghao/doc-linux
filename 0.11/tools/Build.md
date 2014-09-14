Linux 构建工具
================================================================================

Linux 内核源代码中的 tools 目录中包含一个生成内核磁盘映象文件的工具程序 build.c ,该程序将
单独编译成可执行文件,在 linux/ 目录下的 Makefile 文件中被调用运行,用于将所有内核编译代码连接和
合并成一个可运行的内核映像文件 Image.

具体方法是: 对 boot/ 中的 bootsect.s, setup.s使用 8086 汇编器进行编译,分别生成各自的执行模块。
再对源代码中的其它所有程序使用GNU的编译器 gcc/gas 进行编译,并连接成模块system。
然后使用 build 工具将这三块组合成一个内核映象文件 Image.

基本编译连接/组合结构如下图所示：

```
 head  main  kernel  mm  fs  lib
----------------------------------
                    |
 bootsect  setup  system
--------------------------
   |        |       |
   ------------------
           | build
         Image
```

该图各个子模块bootsect, setup, system的依赖关系可参考如下:

https://github.com/leeminghao/doc-linux/blob/master/0.11/tools/Dependencies.md

下面我们详细分析下build工具程序,分析其是如何构建出Image内核模块程序:
