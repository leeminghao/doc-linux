Linux 0.00
================================================================================

编译运行
--------------------------------------------------------------------------------

```
$ make
$ qemu-system-i386 -m 16 -boot a -fda Image
or
$ make disk
$ qemu-system-i386 -m 16 -boot a -fda a.img
```

Image生成过程
--------------------------------------------------------------------------------

### boot

```
boot: boot.s
	$(AS86) boot.s -o boot.o   // 编译生成与as部分兼容的目标文件
	$(LD86) -s boot.o -o boot  // 链接去掉符号信息
```

我们看下生成的boot信息:

```
$ ls -l boot*
-rwxrwxr-x 1 liminghao liminghao  544 Sep  6 17:35 boot*
-rw-rw-r-- 1 liminghao liminghao  298 Sep  6 17:35 boot.o
```

从上面ls命令列出的文件名中可以看出，最后生成的boot程序并不是前面所说的正好512B，而是长了32B。
这32B就是MINIX可执行文件的头结构。为了能使用这个程序引导启动机器，需要人工去掉这32B。

### system

```
system: head.o
	$(LD) $(LDFLAGS) head.o -o system > System.map

head.o: head.s
	$(AS) head.s -o head.o
```

as/ld编译链接出的system文件开始部分包括1024字节的a.out格式头部信息,
在合成内核映像Image文件时候需要去掉头部信息.

生成的system实质是elf格式文件，在elf格式文件中除了二进制代码外，
还包括该可执行文件的某些信息，比如符号表等；而经过objcopy处理的
head文件只包含二进制数据的内核代码，它已经不是elf格式，可直接
加载到内存中执行.

### Image

Image: 是源程序编译得到的可运行代码的1.44MB软盘映像文件.
其生成过程如下所示

```
Image: boot system
	dd bs=32 if=boot of=Image skip=1 // 利用dd命令来去除boot中的前32B，并把输出结果直接写到软盘
    // objcopy 将目标文件的一部分或者全部内容拷贝到另外一个目标文件中，或者实现目标文件的格式转换
	objcopy -O binary system head
	#dd bs=512 if=system of=head skip=2 seek=1
	cat head >> Image
```

由于as86/ld86编译链接产生的boot文件开始部分含有32字节的MINIX执行文件头部信息，
而as/ld编译链接出的system文件开始部分包括1024字节的a.out格式头部信息，因此在
生成内核Image文件时我们分别利用dd命令和objcopy命令把他们合并成内核映像文件Image.

注意：

objcopy裁剪system前后大小:

```
$ objcopy -O binary system head
$ ll system
-rwxrwxr-x 1 liminghao liminghao 9108 Sep  6 21:38 system*
$ ll head
-rwxrwxr-x 1 liminghao liminghao 4872 Sep  6 21:38 head*
```

### 制作软盘镜像

```
disk: Image
	dd bs=8192 if=Image of=a.img conv=notrunc
	sync; sync; sync
```

若要把Image复制到软盘或者制作的软盘镜像中，那么我们可以如上执行"make disk"命令

### dd命令简介

dd是Linux/UNIX下的一个非常有用的命令，作用是用指定大小的块拷贝一个文件，并在拷贝的同时进行指定的转换。

```
if=文件名：输入文件名，缺省为标准输入。即指定源文件。<if=inputfile>

of=file：输出文件名，缺省为标准输出

ibs=bytes：一次读入bytes个字节，即指定一个块大小为bytes个字节。

obs=bytes：一次输出bytes个字节，即指定一个块大小为bytes个字节。

bs=bytes：同时设置读入/输出的块大小为bytes个字节。

cbs=bytes：一次转换bytes个字节，即指定转换缓冲区大小。

skip=blocks：从输入文件开头跳过blocks个块后再开始复制。

seek=blocks：从输出文件开头跳过blocks个块后再开始复制。
注意：通常只用当输出文件是磁盘或磁带时才有效，即备份到磁盘或磁带时才有效。

count=blocks：仅拷贝blocks个块，块大小等于ibs指定的字节数。

conv=conversion：用指定的参数转换文件。
ascii：转换ebcdic为ascii
ebcdic：转换ascii为ebcdic
ibm：转换ascii为alternateebcdic
block：把每一行转换为长度为cbs，不足部分用空格填充
unblock：使每一行的长度都为cbs，不足部分用空格填充
lcase：把大写字符转换为小写字符
ucase：把小写字符转换为大写字符
swab：交换输入的每对字节
noerror：出错时不停止
notrunc：不截短输出文件
sync：将每个输入块填充到ibs个字节，不足部分用空（NUL）字符补齐。
```