嵌入式linux利用mkimage 把zImage转换为uImage的方法
================================================================================

通常，u－boot为kernel提供一些kernel无法知道的信息，比如ramdisk在RAM中的地址。
Kernel也必须为U-boot提供必要的信息，如通过mkimage这个工具（在u-boot代码的tools目录中）
可以给zImage添加一个header，也就是使得通常编译的内核zImage添加一个数据头，把添加头后的
image通常叫uImage，uImage是可以被U-boot直接引导的内核镜像。那么如何使用mkimage工具而产生uImage的呢？
下面将具体介绍mkimage工具的使用：

1.首先查看mkimage的命令参数
--------------------------------------------------------------------------------

```
[root@localhost tools]# ./mkimage
Usage: ./mkimage -l image
          -l ==> list image header information
       ./mkimage [-x] -A arch -O os -T type -C comp -a addr -e ep -n name -d data_file

[:data_file...] image
          -A ==> set architecture to 'arch'   //用于指定CPU类型，比如ARM
          -O ==> set operating system to 'os' //用于指定操作系统，比如Linux
          -T ==> set image type to 'type'      //用于指定image类型，比如Kernel
          -C ==> set compression type 'comp'   //指定压缩类型
          -a ==> set load address to 'addr' (hex) //指定image的载入地址
          -e ==> set entry point to 'ep' (hex)     //内核的入口地址，一般是：image的载入地址+0x40（信息头的大小）
          -n ==> set image name to 'name'          //image在头结构中的命名
          -d ==> use image data from 'datafile'    //无头信息的image文件名
          -x ==> set XIP (execute in place)        //设置执行位置
```

* -A 指定 CPU的体系结构，可用值有：alpha、arm 、x86、ia64、mips、mips64、ppc 、s390、sh、sparc 、sparc64、m68k等
* -O 指定操作系统类型，可用值有：openbsd、netbsd、freebsd、4_4bsd、linux、svr4、esix、solaris、irix、sco、
     dell、ncr、lynxos、vxworks、psos、qnx、u-boot、rtems、artos
* -T 指定映象类型，可用值有：standalone、kernel、ramdisk、multi、firmware、script、filesystem
* -C 指定映象压缩方式，可用值有：
      none   不压缩(一般使用这个，因为 zImage是已经被 bzip2压缩过的自解压内核)
      gzip    用 gzip的压缩方式
      bzip2   用 bzip2的压缩方式
* -a 指定映象在内存中的加载地址，映象下载到内存中时，要按照用 mkimage制作映象时，这个参数所指定的地址值来下载
* -e 指定映象运行的入口点地址，这个地址就是-a参数指定的值加上0x40（因为前面有个mkimage添加的 0x40个字节的头）
* -n 指定映象名
* -d 指定制作映象的源文件

以下是制作内核映像的命令示例：

```
mkimage -n ‘linux-2.6.32-arm2440’ -A arm -O linux –T kernel -C none -a 0x30008000 -e 0x30008040 -d zImage uImage
```

**注意**: -a参数后是内核的运行地址，-e参数后是入口地址。

1. 如果我们没用mkimage对内核进行处理的话，那直接把内核下载到0x30008000再运行就行，
   内核会自解压运行(不过内核运行需要一个tag来传递参数，而这个tag建议是由bootloader提供的，
   在u-boot下默认是由bootm命令建立的）。
2. 如果使用mkimage生成内核镜像文件的话，会在内核的前头加上了64byte的信息，供建立tag之用。
   bootm命令会首先判断bootm xxxx 这个指定的地址xxxx是否与-a指定的加载地址相同。
   如果不同的话会从这个地址开始提取出这个64byte的头部，对其进行分析，然后把去掉头部的内核复制到-a指定的load地址中去运行之
   如果相同的话那就让其原封不同的放在那，但-e指定的入口地址会推后64byte，以跳过这64byte的头部。

```
$ ./mkimage -A arm -O linux -T kernel -C none -a 30008000 -e 30008000 -n linux-2.6.14.1_cs8900 -d /arm9/u-boot-1.2.0/tools/zImage /arm9/u-boot-1.2.0/tools/uImage

$ ./mkimage -A arm -O linux -T kernel -C none -a 30008000 -e 30008040 -n linux-2.6.13 -d zImage uImage
```

总结:
--------------------------------------------------------------------------------

生成uImage的方法： 利用mkimage 命令 把zImage 包装 ，

```
mkimage -A arm -O linux -T kernel -C none -a 30008000 -e 30008000 -n linux-2.6.18.8 -d zImage uImage2.6.18.8
```
下面的总结都是 稍微调整一下上面的 -a -e -x 参数什么的， 你会发现这些参数不同，
就会导致你tftp dowload的地址会有不同， 有的时候kernel会run不起来。
addr是地址 ， 如果两个地方都是addr ，说明是同一个地址， 否则 我会比如addr+0x40 的

1. mkimage -a addr -e addr
   那么tftp 下载kernel 就一定不能下载 addr处 ， 否则，kernel不来。 因为u-boot并不搬运kernel代码，
   也就是没有把header去掉。 所以 只有入口是 addr+0x40才是kernel的入口。
   当然也不能下到 < addr + 2M 的地方， 否则搬运的时候会有一些覆盖， 导致搬运后的kernel不完整， bootm的时候，会RESET 的。

2. mkimage -a addr -e addr+0x40 或者 mkimage -a addr -x 两个是一回事.－x的意思 就在kernel所在地执行。
   不必搬运（代码里面的条件是 tftp 下kernel的时候 就下到 addr处）
   这种情况： tftp 就一定把kernel 下载到addr处 ，这样u-boot 在bootm的时候就不搬运了。
   起始这种情况更多的用在flash里面 。


比如卖产品的时候，kernel肯定是烧写在flash里面， 记住这个flash地址，
然后 mkimage -a 这个flash地址 -x , 这样bootm 也就不用搬运了， 直接在flash里面运行kernel 。
其实我不晓得这样可不可以， 按理说编译kernel的时候，link的时候用的vmlinux.lds里面的数值
都是 0x30008000 ， mkimage 随便指定一个flash 地址， 应该不行才对， 除非你把kernel里面的vmlinux.lds也改掉和mkimage一致。

总之, 一句话，u-boot 是为kernel服务，kernel里面定义好的参数，u-boot 不能乱改，一定要一致，否则kernel肯定翘辫子才对。
